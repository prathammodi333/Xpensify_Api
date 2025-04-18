# db/migrate/xxx_add_private_api_key_ciphertext_to_users.rb

class AddPrivateApiKeyToUsers < ActiveRecord::Migration[6.1]
  def change
    # encrypted data
    add_column :users, :private_api_key_ciphertext, :text

    # blind index
    add_column :users, :private_api_key_bidx, :string
    add_index :users, :private_api_key_bidx, unique: true
  end
end
