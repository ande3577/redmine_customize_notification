module CustomizeNotificationJournalPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method_chain :notified_users, :customize_notification
      alias_method_chain :notified_watchers, :customize_notification
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def notified_users_with_customize_notification
      select_notified_users notified_users_without_customize_notification
    end

    def notified_watchers_with_customize_notification
      select_notified_users notified_watchers_without_customize_notification
    end
  end
  
  private
  def select_notified_users(notified)
    # print("\nJournal = #{self.inspect}\n")
    return notified unless notified
    notified.select! {|user| should_notify_user?(user)}
    notified
  end

  def should_notify_user?(user)
    return true if journalized_type != 'Issue' or user.notify_for_all_fields?
    return true if user.notify_for_attribute?(:notes) and notes and notes.length > 0
    # print("JournalDetails:\n")
    details.each do |detail|
      # print("#{detail.inspect}\n")
      case detail.property
      when 'attr'
        return true if user.notify_for_field?(detail.prop_key, detail.old_value, detail.value)
      when 'cf'
        return true if user.notify_for_custom_field?(detail.prop_key, detail.old_value, detail.value)
      else
        return true
      end
    end
    false
  end

end

Journal.send(:include, CustomizeNotificationJournalPatch)