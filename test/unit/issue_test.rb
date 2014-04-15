require File.expand_path('../../test_helper', __FILE__)

class IssueTest < ActiveSupport::TestCase
  extend NotificationEvents
  fixtures :projects, :users, :members, :member_roles, :roles,
           :groups_users,
           :trackers, :projects_trackers,
           :enabled_modules,
           :versions,
           :issue_statuses, :issue_categories, :issue_relations, :workflows,
           :enumerations,
           :issues, :journals, :journal_details,
           :custom_fields, :custom_fields_projects, :custom_fields_trackers, :custom_values,
           :time_entries

  def setup
    @user = User.find(3)
    @user.admin = true # turn user into admin to avoid permissions issue
    @issue = Issue.find(2)
    @user.update_attribute(:mail_notification, 'all')
    @user.pref[:notify_for_all_fields] = false
    User.current = @user
    ActionMailer::Base.deliveries.clear
  end

  def teardown
    clear_notification_attributes
  end

  def test_notify_for_new_issue
    init_journal
    new_issue = Issue.new(:project => @issue.project, :subject => 'New Issue', :tracker => @issue.tracker, :author => @user)
    assert notify_about?(new_issue)
  end

  def test_notify_if_all_fields_set
    init_journal
    @user.pref[:notify_for_all_fields] = true
    @issue.subject = 'new subject'
    assert notify_about?
  end

  def test_do_not_notify_if_all_fields_not_set
    init_journal
    @issue.subject = 'new subject'
    assert !notify_about?
  end

  def test_notify_if_subject_changed
    init_journal
    add_notification_attribute(:subject)
    assert @user.notify_for_attribute?(:subject)
    @issue.subject = 'new subject'
    assert notify_about?
  end

  def test_do_not_notify_if_subject_unchanged
    init_journal
    add_notification_attribute(:subject)
    @issue.description = 'new description'
    assert !notify_about?
  end

  def test_notify_if_description_changed
    init_journal
    add_notification_attribute(:description)
    @issue.description = 'change the description'
    assert notify_about?
  end

  def test_notify_if_assignee_id_changed
    init_journal
    add_notification_attribute(:assigned_to_id)
    @issue.assigned_to = nil
    assert notify_about?
  end

  def test_notify_if_assignee_changed_from_me
    init_journal
    add_notification_attribute(:issue_assignee_from_me)
    @issue.assigned_to = nil
    assert notify_about?
  end

  def test_notify_if_assignee_changed_to_me
    @issue.assigned_to = nil
    @issue.save!
    init_journal
    add_notification_attribute(:issue_assignee_to_me)
    @issue.assigned_to = @user
    assert notify_about?
  end

  def test_notify_if_issue_closed
    init_journal
    add_notification_attribute(:issue_closed)
    @issue.status = closed_status
    assert notify_about?
  end

  def test_notify_if_issue_reopened
    @issue.status = closed_status
    @issue.save!
    init_journal
    add_notification_attribute(:issue_reopened)
    @issue.status = open_status
    assert notify_about?
  end

  def test_notify_if_notes_added
    add_notification_attribute(:notes)
    init_journal 'Comment on an issue'
    assert notify_about?
  end

  def test_notify_for_custom_field_if_all_fields_set
    @user.pref[:notify_for_all_fields] = true
    init_journal
    update_custom_value
    assert notify_about?
  end

  def test_notify_for_custom_field
    add_custom_field_notification_attribute custom_value.custom_field.id
    init_journal
    update_custom_value
    assert notify_about?
  end

  def test_do_not_notify_for_custom_field_if_not_selected
    init_journal
    update_custom_value
    assert !notify_about?
  end

  def test_notify_for_user_custom_field
    add_custom_field_notification_attribute user_custom_value.custom_field.id
    update_user_custom_value nil.to_s
    @issue.save!
    init_journal
    update_user_custom_value
    assert notify_about?
  end

  def test_notify_for_custom_field_to_me
    add_custom_field_notify_to_me user_custom_value.custom_field.id
    update_user_custom_value nil.to_s
    @issue.save!
    init_journal
    update_user_custom_value
    assert notify_about?
  end

  def test_notify_for_custom_field_array_to_me
    add_custom_field_notify_to_me user_custom_value(true).custom_field.id
    update_user_custom_value nil.to_s
    @issue.save!
    init_journal
    update_user_custom_value [@user.id.to_s, 4.to_s]
    assert notify_about?
  end

  def test_dont_notify_if_additional_users_added
    add_custom_field_notify_to_me user_custom_value(true).custom_field.id
    add_custom_field_notify_from_me user_custom_value(true).custom_field.id
    update_user_custom_value [@user.id.to_s]
    @issue.save!
    init_journal
    update_user_custom_value [@user.id.to_s, 4.to_s]
    assert !notify_about?
  end

  def test_notify_for_custom_field_from_me
    add_custom_field_notify_from_me user_custom_value.custom_field.id
    update_user_custom_value
    @issue.save!
    init_journal
    update_user_custom_value nil.to_s
    assert notify_about?
  end

  def test_notify_for_custom_field_array_from_me
    add_custom_field_notify_from_me user_custom_value(true).custom_field.id
    update_user_custom_value [@user.id.to_s, 4.to_s]
    @issue.save!
    init_journal
    update_user_custom_value nil.to_s
    assert notify_about?
  end

  def test_notify_if_project_specific_custom_field_set
    return unless project_specific_plugin_installed?
    add_notification_attribute :psec_field_changed
    init_journal
    update_project_specific_custom_value
    assert notify_about?
  end

  def test_dont_notify_if_project_specific_custom_field_not_set
    return unless project_specific_plugin_installed?
    init_journal
    update_project_specific_custom_value
    assert !notify_about?
  end
  
  private
  def notify_about?(issue = @issue)
    @user.save!
    @user.pref.save!
    @user.reload
    issue.save!
    delivery = ActionMailer::Base.deliveries.last
    return false if delivery.nil?
    mail = @user.mail
    delivery.to.include?(mail) or delivery.cc.include?(mail) or delivery.bcc.include?(mail)
  end

  def init_journal(notes = "")
    @issue.init_journal @user, notes
  end

  def clear_notification_attributes
    @user.pref[:enabled_notifications] = []
    @user.pref[:custom_field_notifications] = []
    @user.pref[:changed_to_me_notifications] = []
    @user.pref[:changed_from_me_notifications] = []
  end

  def add_notification_attribute(attribute)
    @user.pref[:enabled_notifications] ||= [attribute.to_s]
  end

  def add_custom_field_notification_attribute(custom_field_id)
    @user.pref[:custom_field_notifications] ||= [custom_field_id.to_s]
  end

  def add_custom_field_notify_to_me(custom_field_id)
    @user.pref[:changed_to_me_notifications] ||= [custom_field_id.to_s]
  end

  def add_custom_field_notify_from_me(custom_field_id)
    @user.pref[:changed_from_me_notifications] ||= [custom_field_id.to_s]
  end  

  def closed_status
    IssueStatus.where(:is_closed => true).first
  end

  def open_status
    IssueStatus.where(:is_closed => false).first
  end

  def custom_value
    @issue.editable_custom_field_values(@user).first
  end

  def update_custom_value(value='1.2345')
    @issue.custom_field_values = { custom_value.custom_field.id => value }
  end

  def user_custom_value(multiple = false)
    #IssueCustomField.where(:field_format => 'user').destroy_all
    initial_field_value = find_user_custom_value(multiple)
    return @user_custom_value if @user_custom_value
    user_custom_field = IssueCustomField.new(:name => 'user custom field', :field_format => 'user', :is_for_all => 'true', :editable => 'true', :multiple => multiple)
    user_custom_field.trackers << @issue.tracker
    user_custom_field.save!
    @issue.reload
    @user_custom_value = find_user_custom_value(multiple)
  end

  def find_user_custom_value(multiple)
    @issue.editable_custom_field_values(@user).select{ |v| v.custom_field.field_format == 'user' and v.custom_field.multiple == multiple}.first
  end

  def update_user_custom_value(user_id=@user.id.to_s)
    @issue.custom_field_values = { @user_custom_value.custom_field.id => user_id}
  end

  def project_specific_plugin_installed?
    IssueTest::project_specific_plugin_installed?
  end

  def update_project_specific_custom_value(value='New Value')
    @issue.custom_field_values = {project_specific_custom_field.id => value}
  end

  def project_specific_custom_field
    return @project_specific_custom_field if @project_specific_custom_field
    @project_specific_custom_field = PSpecIssueCustomField.new(:name => 'project specific field', :project => @issue.project, :field_format=>'string', :editable => 'true')
    @project_specific_custom_field.trackers << @issue.tracker
    @project_specific_custom_field.save!
    @issue.reload
    @project_specific_custom_field
  end


end