# app/controllers/balances_controller.rb
class BalancesController < ApplicationController
  before_action :set_group

  def show
    @balances = current_user.group_balances(@group)

    # People you owe (positive balances)
    @owe_to = @balances.select { |user_id, amount| amount > 0 }
                       .transform_keys { |user_id| User.find(user_id) }

    # People who owe you (negative balances, converted to positive)
    @owed_by = @balances.select { |user_id, amount| amount < 0 }
                        .transform_keys { |user_id| User.find(user_id) }
                        .transform_values(&:abs)

    # Calculate net balance for current user
    @net_balance = @balances.values.sum
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end
end