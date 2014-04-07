require_dependency 'customize_notification_user_patch'
require_dependency 'customize_notification_users_helper_patch'

Redmine::Plugin.register :redmine_customize_notification do
  name 'Redmine Customize Notification plugin'
  author 'David S Anderson'
  description 'Allows a user to customize the issue fields for which to receive notification emails.'
  version '0.0.1'
  url 'https://github.com/ande3577/redmine_customize_notification'
  author_url 'https://github.com/ande3577'
end
