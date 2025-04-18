class UpdateUsersForJwt < ActiveRecord::Migration[8.0]
  def change
    # Add jti column (allow null temporarily)
    add_column :users, :jti, :string unless column_exists?(:users, :jti)

    # Initialize jti for existing users
    reversible do |dir|
      dir.up do
        User.find_each do |user|
          user.update_column(:jti, SecureRandom.uuid)
        end
      end
    end

    # Add NOT NULL constraint
    change_column_null :users, :jti, false

    # Add unique index
    add_index :users, :jti, unique: true unless index_exists?(:users, :jti)

    # Remove old API key columns
    remove_column :users, :private_api_key_bidx, :string if column_exists?(:users, :private_api_key_bidx)
    remove_column :users, :private_api_key_ciphertext, :text if column_exists?(:users, :private_api_key_ciphertext)
  end
end