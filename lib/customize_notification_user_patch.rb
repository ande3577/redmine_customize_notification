module CustomizeNotificationUserPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def notify_for_all_fields?
      self.pref[:notify_for_all_fields]
    end

    def enabled_notifications
      get_preference_hash(:enabled_notifications)
    end

    def custom_field_notifications
      get_preference_hash(:custom_field_notifications)
    end
  end
  
  private
    def get_preference_hash(identifier)
      return self.pref[identifier] if self.pref[identifier]
      []
    end
  
end

User.send(:include, CustomizeNotificationUserPatch)