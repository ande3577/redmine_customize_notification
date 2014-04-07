module NotificationEvents
  ISSUE_EVENTS = {
    :issue_status_changed => :notification_event_status_changed,
    :issue_closed => :notification_event_issue_closed,
    :issue_reopened => :notification_event_issue_reopened,
    :issue_priority_changed => :notification_event_priority_changed,
    :issue_assignee_changed => :notification_event_assignee_changed,
    :issue_assignee_to_me => :notification_event_assignee_changed_to_me,
    :issue_assignee_from_me => :notification_event_assignee_changed_from_me,
    :issue_category_changed => :notification_event_category_changed,
    :issue_target_version_changed => :notification_event_target_version_changed,
    :issue_start_date_changed => :notification_event_start_date_changed,
    :issue_due_date_changed => :notification_event_due_date_changed,
    :issue_description_changed => :notification_event_description_changed,
    :issue_commented_on => :notification_event_issue_commented_on
  }.freeze
end