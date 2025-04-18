class Settlement < ApplicationRecord
  belongs_to :payer, class_name: 'User'
  belongs_to :payee, class_name: 'User'
  belongs_to :group
  has_one :transaction_history, dependent: :destroy
  validates :amount, numericality: { greater_than: 0 }
end