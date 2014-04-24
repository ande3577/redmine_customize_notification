module NotificationHelper
  extend NotificationEvents

  def render_notification_events(user, settings_name)
    @settings_name = settings_name
    h = ""      
    NotificationEvents::ISSUE_EVENTS.each do |ev, label|
      dependent_event = NotificationHelper.dependent_event?(ev)
      h << '<ul>' if dependent_event
      h << notification_attribute_checkbox_tag(ev, label, user)
      h << '</ul>' if dependent_event
    end
    h << hidden_field_tag("#{@settings_name}[enabled_notifications][]", '')
    IssueCustomField.all.each do |field|
      h << custom_field_notification_checkbox_tag(field, user)
    end
    if NotificationHelper.project_specific_plugin_installed?
      h << notification_attribute_checkbox_tag(:psec_field_changed, :notification_event_project_specific_custom_field_changed, user)
    end

    h << hidden_field_tag("#{@settings_name}[custom_field_notifications][]", '')
    h << hidden_field_tag("#{@settings_name}[changed_to_me_notifications][]", '')
    h << hidden_field_tag("#{@settings_name}[changed_from_me_notifications][]", '')
    h.html_safe
  end

  private
    def notification_attribute_checkbox_tag(event, label, user)
    h = '<li>'
    h << check_box_tag(
         "#{@settings_name}[enabled_notifications][]",
         event,
         user.enabled_notifications.include?(event.to_s),
         :onchange => "draw()",
         :id => "enabled_notifications_#{event.to_s}"
      )
    h << t(label)
    h << '</li>'
  end
  
  def custom_field_notification_checkbox_tag(field, user)
    if field.field_format == 'user'
      h = user_custom_field_notification_checkboxes(field, user)
    else
      h = '<li>'
      h << check_box_tag(
           "#{@settings_name}[custom_field_notifications][]",
           field.id,
           user.custom_field_notifications.include?(field.id.to_s)
        )
      h << t(:notification_event_custom_field_changed, :name => field.name)
      h << '</li>'
    end
    h
  end

  def user_custom_field_notification_checkboxes(field, user)
    notify_on_field = user.custom_field_notifications.include?(field.id.to_s)
    h = '<li>'
    h << check_box_tag(
         "#{@settings_name}[custom_field_notifications][]",
         field.id,
         notify_on_field,
         :onchange => "$(field_#{field.id}_changed_to_me).attr('disabled', this.checked);
            $(field_#{field.id}_changed_from_me).attr('disabled', this.checked);"
      )
    h << t(:notification_event_custom_field_changed, :name => field.name)
    h << '</li>'
    h << '<ul><li>'
    h << check_box_tag(
         "#{@settings_name}[changed_to_me_notifications][]",
         field.id,
         user.changed_to_me_notifications.include?(field.id.to_s),
         :id => "field_#{field.id}_changed_to_me",
         :disabled => notify_on_field
      )
    h << t(:notification_event_custom_field_changed_to_me, :name => field.name)
    h << '</li>'
    h << '<li>'
    h << check_box_tag(
         "#{@settings_name}[changed_from_me_notifications][]",
         field.id,
         user.changed_from_me_notifications.include?(field.id.to_s),
         :id => "field_#{field.id}_changed_from_me",
         :disabled => notify_on_field
      )
    h << t(:notification_event_custom_field_changed_from_me, :name => field.name)
    h << '</li></ul>'
  end


end