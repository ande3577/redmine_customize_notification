module CustomizeNotificationUserPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      extend NotificationEvents
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def notify_for_field?(field, old_value, new_value)
      field = field.to_sym
      case field
      when :assigned_to_id
        begin
          return true if notify_for_attribute?(:issue_assignee_from_me) and old_value and is_or_belongs_to?(User.find(old_value))
          return true if notify_for_attribute?(:issue_assignee_to_me) and new_value and is_or_belongs_to?(User.find(new_value))
        rescue ActiveRecord::IndexNotFoundError
        end
      when :status_id
        initial_closed = IssueStatus.find(old_value).is_closed?
        final_closed = IssueStatus.find(new_value).is_closed?
        return true if notify_for_attribute?(:issue_closed) and !initial_closed and final_closed
        return true if notify_for_attribute?(:issue_reopened) and initial_closed and !final_closed
      end
      return notify_for_attribute?(field.to_sym)
    end

    def notify_for_custom_field?(custom_field_id, old_value, new_value)
      return true if custom_field_notifications.include?(custom_field_id.to_s)
      field = CustomField.find(custom_field_id)
      if field.field_format == 'user'
        return true if changed_to_me_notifications.include?(custom_field_id.to_s) and new_value and is_or_belongs_to?(User.find(new_value))
        return true if changed_from_me_notifications.include?(custom_field_id.to_s) and old_value and is_or_belongs_to?(User.find(old_value))
      end
      return notify_for_attribute?(:psec_field_changed) if User.project_specific_custom_field?(field)
      false
    end

    def notify_for_all_fields?
      self.pref[:notify_for_all_fields]
    end

    def notify_for_issue_relations?(relation_type)
      notify_for_attribute?(:relation)
    end
    
    def notify_for_issue_attachment?(property_key)
      notify_for_attribute?(:attachment)
    end

    def notify_for_attribute?(attribute)
      enabled_notifications.include?(attribute.to_s)
    end

    def enabled_notifications
      get_preference_hash(:enabled_notifications)
    end

    def custom_field_notifications
      get_preference_hash(:custom_field_notifications)
    end

    def changed_to_me_notifications
      get_preference_hash(:changed_to_me_notifications)
    end

    def changed_from_me_notifications
      get_preference_hash(:changed_from_me_notifications)
    end

    def load_default_notification_settings
      [:enabled_notifications, 
        :custom_field_notifications, 
        :changed_to_me_notifications, 
        :changed_from_me_notifications].each do |setting|
          load_default_notification_hash(setting)
        end
    end
  end
  
  private
    def get_preference_hash(identifier)
      return self.pref[identifier] if self.pref[identifier]
      []
    end

    def plugin_settings
      Setting.plugin_redmine_customize_notification
    end

    def load_default_notification_hash(setting_name)
      self.pref[setting_name] = plugin_settings[setting_name]
    end
  
end

User.send(:include, CustomizeNotificationUserPatch)