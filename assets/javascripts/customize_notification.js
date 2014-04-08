var disable_control = function(control, disabled) {
  control.attr('disabled', disabled);
};

var draw = function() {
  var issue_status_changed = $(enabled_notifications_status_id).is(':checked');
  disable_control($(enabled_notifications_issue_closed), issue_status_changed);
  disable_control($(enabled_notifications_issue_reopened), issue_status_changed);
  var issue_assignee_changed = $(enabled_notifications_assigned_to_id).is(':checked');
  disable_control($(enabled_notifications_issue_assignee_to_me), issue_assignee_changed);
  disable_control($(enabled_notifications_issue_assignee_from_me), issue_assignee_changed);
};

$(document).ready(draw);