class TransactionHistory < ApplicationRecord
  belongs_to :payer, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  belongs_to :settlement

  validates :amount, numericality: { greater_than: 0 }
end
