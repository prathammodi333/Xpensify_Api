class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  validates :user_id, uniqueness: { scope: :friend_id, message: "already added as a friend" }
  validate :cannot_friend_self

  after_create :create_inverse, unless: :inverse_exists?

  private

  def cannot_friend_self
    errors.add(:friend_id, "can't be the same as user") if user_id == friend_id
  end

  def create_inverse
    self.class.create(user: friend, friend: user)
  end

  def inverse_exists?
    self.class.exists?(user: friend, friend: user)
  end
end
