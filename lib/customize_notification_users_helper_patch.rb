module CustomizeNotificationUsersHelperPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      include NotificationEvents
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def render_notification_events(user, pref_fields)
      h = '<ul class="projects issue-notification-list">'
      NotificationEvents::ISSUE_EVENTS.each do |ev, label|
        h << '<li>'
        h << check_box_tag(
            'pref[enabled_notifications][]',
             ev,
             @user.enabled_notifications.include?(ev.to_s),
             :onchange => "draw()",
             :id => "enabled_notifications_#{ev.to_s}"
          )
        h << t(label)
        h << '</li>'
      end
      h << hidden_field_tag('pref[enabled_notifications][]', '')
      IssueCustomField.all.each do |field|
        h << '<li>'
        h << check_box_tag(
             'pref[custom_field_notifications][]',
             field.id,
             @user.custom_field_notifications.include?(field.id.to_s)
          )
        h << t(:notification_event_custom_field_changed, :name => field.name)
        h << '</li>'
      end
      h << hidden_field_tag('pref[custom_field_notifications][]', '')
      h << '</ul>'
      h.html_safe
    end
  end
  
  private
  
end

UsersHelper.send(:include, CustomizeNotificationUsersHelperPatch)