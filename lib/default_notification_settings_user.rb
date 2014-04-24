class DefaultNotificationSettingsUser
  def enabled_notifications
    plugin_settings[:enabled_notifications]
  end

  def custom_field_notifications
    plugin_settings[:custom_field_notifications]
  end

  def changed_to_me_notifications
    plugin_settings[:changed_to_me_notifications]
  end

  def changed_from_me_notifications
    plugin_settings[:changed_from_me_notifications]
  end

  private
  def plugin_settings
    Setting.plugin_redmine_customize_notification
  end
end