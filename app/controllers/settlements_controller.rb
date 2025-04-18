class SettlementsController < ApplicationController
  before_action :set_group
  before_action :set_payee, only: [:new, :create]
  before_action :verify_payer, only: [:new, :create]

  def new
    @settlement = Settlement.new
    @amount_owed = current_user.group_balances(@group)[@payee.id] || 0
  end

  def create
    @settlement = current_user.settlements_paid.new(
      payee: @payee,
      amount: params[:settlement][:amount],
      group: @group
    )

    if @settlement.save
      @settlement.create_transaction_history(
        payer: current_user,
        receiver: @payee,
        amount: @settlement.amount
      )
      redirect_to group_balance_path(@group), notice: 'Payment recorded successfully'
    else
      @amount_owed = current_user.group_balances(@group)[@payee.id] || 0
      render :new
    end
  end

  private

  def verify_payer
    payer_id = params[:payer_id]&.to_i
    if payer_id && payer_id != current_user.id
      redirect_to group_balance_path(@group), alert: "You can only settle your own payments."
    end
  end

  def set_group
    @group = Group.find(params[:group_id])
  end

  def set_payee
    @payee = User.find(params[:payee_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to group_balance_path(@group), alert: 'User not found'
  end

  def settlement_params
    params.require(:settlement).permit(:amount)
  end
end