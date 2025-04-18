# db/migrate/[timestamp]_fix_private_api_key_column_for_lockbox.rb
class FixPrivateApiKeyColumnForLockbox < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :private_api_key_ciphertext, :text
    add_column :users, :private_api_key, :text # Lockbox encrypts this directly
  end
end