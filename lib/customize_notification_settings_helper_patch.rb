module CustomizeNotificationSettingsHelperPatch
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
    def render_default_notification_events_settings
      render_notification_events(DefaultNotificationSettingsUser.new, 'settings')
    end
  end
  
  private  
end

SettingsHelper.send(:include, CustomizeNotificationSettingsHelperPatch)