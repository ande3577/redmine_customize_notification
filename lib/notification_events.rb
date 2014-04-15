module NotificationEvents
  ISSUE_EVENTS = {
    :project_id => :notification_event_project_changed,
    :tracker_id => :notification_event_tracker_changed,
    :status_id => :notification_event_status_changed,
    :issue_closed => :notification_event_issue_closed,
    :issue_reopened => :notification_event_issue_reopened,
    :category_id => :notification_event_category_changed,
    :assigned_to_id => :notification_event_assignee_changed,
    :issue_assignee_to_me => :notification_event_assignee_changed_to_me,
    :issue_assignee_from_me => :notification_event_assignee_changed_from_me,
    :priority_id => :notification_event_priority_changed,
    :fixed_version_id => :notification_event_target_version_changed,
    :subject => :notification_event_subject_changed,
    :description => :notification_event_description_changed,
    :start_date => :notification_event_start_date_changed,
    :due_date => :notification_event_due_date_changed,
    :done_ratio => :notification_event_percent_done_changed,
    :estimated_hours => :notification_event_estimated_time_changed,
    :parent_issue_id => :notification_event_parent_issue_changed,
    :notes => :notification_event_issue_commented_on
  }.freeze
  
  def dependent_event?(event)
    case event
    when :issue_assignee_to_me, :issue_assignee_from_me, :issue_closed, :issue_reopened
      true
    else
      false
    end
  end

  def project_specific_plugin_installed?
    begin
      Redmine::Plugin.find('redmine_project_specific_custom_field')
    rescue Redmine::PluginNotFound
      false
    end
  end

  def project_specific_custom_field?(field)
    project_specific_plugin_installed? and field.type == 'PSpecIssueCustomField'
  end
end