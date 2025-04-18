class CreateGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.integer :created_by, null: false
      t.string :invite_token, null: false

      t.timestamps
    end

    # Add unique index to invite_token for fast lookups and ensure uniqueness
    add_index :groups, :invite_token, unique: true

    # Add foreign key constraint for created_by to reference users table
    add_foreign_key :groups, :users, column: :created_by
  end
end
