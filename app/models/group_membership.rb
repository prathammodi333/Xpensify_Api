class GroupMembership < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :group

  # Ensure a user cannot be added to the same group more than once
  validates :user_id, uniqueness: {
    scope: :group_id,
    message: "is already a member of this group"
  }
end
