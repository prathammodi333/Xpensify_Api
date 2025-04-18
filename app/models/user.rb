class User < ApplicationRecord
  # include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  before_create :set_jti
        



  # Friendships (Self-referential many-to-many)
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships

  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'friend_id', dependent: :destroy
  has_many :inverse_friends, through: :inverse_friendships, source: :user

  def all_friends
    (friendships.map(&:friend) + inverse_friendships.map(&:user)).uniq
  end

  # Groups
  has_many :group_memberships, dependent: :nullify
  has_many :groups, through: :group_memberships
  has_many :created_groups, class_name: 'Group', foreign_key: 'created_by'

  # Expenses
  has_many :expenses, foreign_key: 'paid_by_id'
  has_many :expense_shares
  has_many :shared_expenses, through: :expense_shares, source: :expense

  # Payments
  has_many :payments_sent, class_name: 'Payment', foreign_key: 'payer_id'
  has_many :payments_received, class_name: 'Payment', foreign_key: 'receiver_id'

  # Transaction History
  has_many :transaction_histories_sent, class_name: 'TransactionHistory', foreign_key: 'payer_id'
  has_many :transaction_histories_received, class_name: 'TransactionHistory', foreign_key: 'receiver_id'
  # sttlement
  has_many :settlements_paid, class_name: 'Settlement', foreign_key: 'payer_id'
  has_many :settlements_received, class_name: 'Settlement', foreign_key: 'payee_id'
  # Validations
  validates :name, presence: true, length: { minimum: 2 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :strong_password, if: -> { password.present? }
  def group_balances(group)
    # Initialize a hash to store net balances
    balances = Hash.new(0)
  
    # 1. Calculate debts from expense shares
    ExpenseShare.joins(:expense)
      .where(expenses: { group_id: group.id })
      .each do |share|
        # Current user owes money for this share
        balances[share.expense.paid_by_id] += share.amount_owed if share.user_id == id
        # Current user is owed money from this share
        balances[share.user_id] -= share.amount_owed if share.expense.paid_by_id == id
      end
  
    # 2. Subtract any settlements
    Settlement.where(group: group).each do |s|
      if s.payer_id == id
        balances[s.payee_id] -= s.amount
      elsif s.payee_id == id
        balances[s.payer_id] += s.amount
      end
    end
  
    balances
  end
  def password_required?
    # Password is required for new records or when explicitly updating the password
    new_record? || password.present? || password_confirmation.present?
  end
 
  private
  
  def set_jti
    self.jti = SecureRandom.uuid
  end

  def strong_password
    return if password.length >= 8 &&
              password.match(/[a-z]/) &&
              password.match(/[A-Z]/) &&
              password.match(/\d/) &&
              password.match(/[\W_]/)

    errors.add(:password, "must be at least 8 characters and include at least one uppercase letter, one lowercase letter, one digit, and one special character.")
  end


end