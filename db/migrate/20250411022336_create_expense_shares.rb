class CreateExpenseShares < ActiveRecord::Migration[8.0]
  def change
    create_table :expense_shares do |t|
      t.references :expense, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :amount_owed, precision: 10, scale: 2

      t.timestamps
    end

    add_index :expense_shares, [:expense_id, :user_id], unique: true
  end
end