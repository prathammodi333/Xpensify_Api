module Api
    class SettlementsController < BaseController
      def create
        group = current_user.groups.find_by(id: settlement_params[:group_id])
        unless group
          render json: { error: 'Group not found or you are not a member' }, status: :not_found
          return
        end
  
        payee = User.find_by(id: settlement_params[:payee_id])
        unless payee
          render json: { error: 'Payee not found' }, status: :not_found
          return
        end
  
        unless group.users.include?(payee)
          render json: { error: 'Payee is not a member of the group' }, status: :unprocessable_entity
          return
        end
  
        if payee == current_user
          render json: { error: 'You cannot settle with yourself' }, status: :unprocessable_entity
          return
        end
  
        amount_owed = current_user.group_balances(group)[payee.id] || 0
        amount = settlement_params[:amount].to_f
        if amount <= 0 || amount > amount_owed
          render json: { error: "Amount must be between 0.01 and #{amount_owed.round(2)}" }, status: :unprocessable_entity
          return
        end
  
        settlement = current_user.settlements_paid.new(
          payee: payee,
          amount: amount,
          group: group
        )
  
        if settlement.save
          settlement.create_transaction_history(
            payer: current_user,
            receiver: payee,
            amount: settlement.amount
          )
          render json: {
            id: settlement.id,
            group: { id: group.id, name: group.name },
            payer: { id: current_user.id, name: current_user.name },
            payee: { id: payee.id, name: payee.name },
            amount: settlement.amount.round(2)
          }, status: :created
        else
          render json: { errors: settlement.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      private
  
      def settlement_params
        params.require(:settlement).permit(:group_id, :payee_id, :amount)
      end
    end
  end