class Group < ApplicationRecord
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  has_many :group_memberships
  has_many :users, through: :group_memberships
  has_many :expenses
  has_many :group_messages

  before_create :generate_invite_token
  
    # Validations
    validates :created_by, presence: true
    private

    def generate_invite_token
      self.invite_token = SecureRandom.hex(10)
    end
  end
  