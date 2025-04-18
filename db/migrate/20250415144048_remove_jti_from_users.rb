# db/migrate/YYYYMMDDHHMMSS_remove_jti_from_users.rb
class RemoveJtiFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :jti, :string
  end
end