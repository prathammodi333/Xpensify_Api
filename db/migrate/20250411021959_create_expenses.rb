class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.references :paid_by, null: false, foreign_key: { to_table: :users }
      t.references :group, foreign_key: true, null: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.text :description, null: false

      t.timestamps
    end
  end
end
