class CreateGroupMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :group_messages do |t|
      t.text :content, null: false
      t.boolean :system, default: false
      t.references :group, null: false, foreign_key: true
      t.references :user, foreign_key: true # can be null for system messages

      t.timestamps
    end
  end
end
