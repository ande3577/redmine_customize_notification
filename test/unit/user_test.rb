require File.expand_path('../../test_helper', __FILE__)

class UserTest < ActiveSupport::TestCase
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
    User.current = @user
    ActionMailer::Base.deliveries.clear
  end

  def teardown
    clear_notifications(@user.pref)
    clear_notifications(plugin_settings)
  end

  def test_loading_default_user_settings
    plugin_settings[:enabled_notifications] << :project_id.to_s
    @user.load_default_notification_settings
    assert @user.notify_for_attribute?(:project_id)
  end

  def test_loading_default_clears_user_settings
    add_notification_attribute(:status_id)
    @user.load_default_notification_settings
    assert !@user.notify_for_attribute?(:status_id)
  end

  def test_loading_default_user_settings_does_not_save
    plugin_settings[:enabled_notifications] << :project_id.to_s
    @user.load_default_notification_settings
    @user.reload
    assert !@user.notify_for_attribute?(:project_id)
  end

  def test_loading_default_custom_field_settings
    plugin_settings[:custom_field_notifications] << "1"
    @user.load_default_notification_settings
    assert @user.notify_for_custom_field?(1, nil, nil)
  end

  def test_loading_default_custom_field_to_me_settings
    plugin_settings[:changed_to_me_notifications] << user_custom_field.id.to_s
    @user.load_default_notification_settings
    assert @user.notify_for_custom_field?(user_custom_field.id, nil, @user.id)
  end

  def test_loading_default_custom_field_from_me_settings
    plugin_settings[:changed_from_me_notifications] << user_custom_field.id.to_s
    @user.load_default_notification_settings
    assert @user.notify_for_custom_field?(user_custom_field.id, @user.id, nil)
  end

  private

  def plugin_settings
    Setting.plugin_redmine_customize_notification
  end

  def clear_notifications(settings)
    settings[:enabled_notifications] = []
    settings[:custom_field_notifications] = []
    settings[:changed_to_me_notifications] = []
    settings[:changed_from_me_notifications] = []
  end

  def add_issue_relations_notification
    add_notification_attribute(:relation)
  end

  def add_notification_attribute(attribute)
    @user.pref[:enabled_notifications] ||= [attribute.to_s]
  end

  def user_custom_field
    return @user_custom_field if @user_custom_field
    @user_custom_field = IssueCustomField.new(:name => 'user custom field', :field_format => 'user', :is_for_all => 'true', :editable => 'true')
    @user_custom_field.save!
    @user_custom_field
  end

  def find_user_custom_value(multiple)
    @issue.editable_custom_field_values(@user).select{ |v| v.custom_field.field_format == 'user' and v.custom_field.multiple == multiple}.first
  end

end