class CreateTransactionHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :transaction_histories do |t|
      t.references :payer, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.timestamps

    end
  end
end
