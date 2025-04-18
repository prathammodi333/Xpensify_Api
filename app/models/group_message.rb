class GroupMessage < ApplicationRecord
  belongs_to :group
  belongs_to :user, optional: true  # For system messages where user might be nil

  validates :content, presence: true
  attribute :system, :boolean, default: false
end
