class AddFieldToFromMeToUserPreferences < ActiveRecord::Migration
  def self.up
    add_column :user_preferences, :changed_to_me_notifications, :text
    add_column :user_preferences, :changed_from_me_notifications, :text
  end
  
  def self.down
    remove_column :user_preferences, :changed_to_me_notifications
    remove_column :user_preferences, :changed_from_me_notifications
  end
end
