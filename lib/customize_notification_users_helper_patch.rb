module CustomizeNotificationUsersHelperPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      include NotificationHelper
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def render_notification_events_for_user(user)
      render_notification_events(user, 'pref')
    end
  end
  
  def user_notify_for_all_fields_options(user)
    [[t(:label_user_notify_for_all_fields), "1"],
     [t(:label_user_notify_for_selected_fields), "0"]]
  end
  
  private  
end

UsersHelper.send(:include, CustomizeNotificationUsersHelperPatch)