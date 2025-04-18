class Payment < ApplicationRecord
  belongs_to :payer
  belongs_to :receiver
end
class Payment < ApplicationRecord
  belongs_to :payer, class_name: 'User'
  belongs_to :receiver, class_name: 'User'


  validates :amount, numericality: { greater_than: 0 }
  validate :payer_and_receiver_cannot_be_same

  private

  def payer_and_receiver_cannot_be_same
    if payer_id == receiver_id
      errors.add(:receiver, "can't be the same as payer")
    end
  end
end
