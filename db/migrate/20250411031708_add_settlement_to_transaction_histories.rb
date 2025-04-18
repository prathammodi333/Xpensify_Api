class AddSettlementToTransactionHistories < ActiveRecord::Migration[8.0]
  def change
    add_column :transaction_histories, :settlement_id, :integer
    add_foreign_key :transaction_histories, :settlements, column: :settlement_id
    add_index :transaction_histories, :settlement_id, unique: true # Ensures one-to-one
  end
end
