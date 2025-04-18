class ExpenseShare < ApplicationRecord
  belongs_to :expense
  belongs_to :user

  validates :amount_owed, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :expense_id, uniqueness: { scope: :user_id }
  
  validate :amount_owed_does_not_exceed_expense

  private

  def amount_owed_does_not_exceed_expense
    if amount_owed && expense && (amount_owed > expense.amount)
      errors.add(:amount_owed, "cannot be greater than the expense amount")
    end
  end
end