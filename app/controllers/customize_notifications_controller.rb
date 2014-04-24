class CustomizeNotificationsController < ApplicationController
  unloadable
  helper :users

  before_filter :find_user, :require_self_or_admin

  def restore_defaults
    @user.load_default_notification_settings
    respond_to do |format|
      format.js { render :partial => 'users/notification_fields'}
    end
  end

  private
  def find_user
    @user = User.find(params[:id])
  end

  def require_self_or_admin
    return deny_access if !User.current.logged?
    return deny_access if !User.current.admin? and (User.current != @user)
  end
end
