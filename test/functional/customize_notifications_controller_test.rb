require File.expand_path('../../test_helper', __FILE__)

class CustomizeNotificationsControllerTest < ActionController::TestCase
  fixtures :users

  def test_restoring_defaults_restores_user_defaults
    get :restore_defaults, :id => @user.id, :format => :js
    assert_response 200
    assert assigns(:user)
    assert_equal @user, assigns(:user)
  end

  def test_able_to_access_other_users_defaults_as_admin
    @user.admin = true
    @user.save!

    new_user = User.find(2)
    get :restore_defaults, :id => new_user.id, :format => :js
    assert_response 200
    assert assigns(:user)
    assert_equal new_user, assigns(:user)
    assert assigns(:user).notify_for_attribute?(:project_id)
  end

  def test_not_able_to_access_other_users_if_not_admin
    new_user = User.find(2)
    get :restore_defaults, :id => new_user.id, :format => :js
    assert_response 403
  end

  def setup
    @user = User.find(3)
    @user.admin = false
    @user.save!
    Setting.plugin_redmine_customize_notification[:enabled_notifications] << :project_id.to_s
    Setting.all.each do |s|
      s.save!
    end
    @request.session[:user_id] = @user.id
  end

  def teardown
    Setting.plugin_redmine_customize_notification[:enabled_notifications] = []
  end

end
