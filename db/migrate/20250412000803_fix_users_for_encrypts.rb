# db/migrate/[timestamp]_fix_users_for_encrypts.rb
class FixUsersForEncrypts < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :private_api_key, :text if column_exists?(:users, :private_api_key)
    add_column :users, :private_api_key_ciphertext, :text unless column_exists?(:users, :private_api_key_ciphertext)
  end
end