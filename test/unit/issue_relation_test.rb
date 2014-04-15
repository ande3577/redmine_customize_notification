require File.expand_path('../../test_helper', __FILE__)

class IssueRelationTest < ActiveSupport::TestCase
  extend NotificationEvents
  fixtures :projects, :users, :members, :member_roles, :roles,
           :groups_users,
           :trackers, :projects_trackers,
           :enabled_modules,
           :versions,
           :issue_statuses, :issue_categories, :workflows,
           :enumerations,
           :issues, :journals, :journal_details,
           :custom_fields, :custom_fields_projects, :custom_fields_trackers, :custom_values,
           :time_entries

  def setup
    @user = User.find(3)
    @user.admin = true # turn user into admin to avoid permissions issue
    @issue = Issue.find(2)
    @related_issue = Issue.find(3)
    @user.update_attribute(:mail_notification, 'all')
    @user.pref[:notify_for_all_fields] = false
    User.current = @user
    ActionMailer::Base.deliveries.clear
  end

  def teardown
    clear_notification_attributes
  end

  def test_notify_for_new_relation
    add_issue_relations_notification
    assert notify_about?
  end

  def test_dont_notify_if_not_set
    assert !notify_about?
  end

  private
  def notify_about?(relation = issue_relation)
    @user.save!
    @user.pref.save!
    @user.reload
    relation.save!
    delivery = ActionMailer::Base.deliveries.last
    return false if delivery.nil?
    mail = @user.mail
    delivery.to.include?(mail) or delivery.cc.include?(mail) or delivery.bcc.include?(mail)
  end

  def issue_relation
    IssueRelation.where(:issue_from_id => @issue, :issue_to_id => @related_issue).destroy_all
    IssueRelation.new(:issue_from => @issue, :issue_to => @related_issue, :relation_type => IssueRelation::TYPE_RELATES)
  end

  def clear_notification_attributes
    @user.pref[:enabled_notifications] = []
  end

  def add_issue_relations_notification
    add_notification_attribute(:relation)
  end

  def add_notification_attribute(attribute)
    @user.pref[:enabled_notifications] ||= [attribute.to_s]
  end

end