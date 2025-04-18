module Api
    class DashboardController < BaseController
      def friends
        friends = current_user.all_friends
        if friends.empty?
          render json: { message: "No friends have been added yet" }, status: :ok
          return
        end
        friend_balances = calculate_friend_balances(friends)
        render json: friend_balances.map { |friend, balance|
          {
            id: friend.id,
            name: friend.name,
            balance: balance.round(2)
          }
        }, status: :ok
      end
  
      def activities
        transactions = TransactionHistory.where("payer_id = ? OR receiver_id = ?", current_user.id, current_user.id)
                                        .includes(:payer, :receiver)
                                        .order(created_at: :desc)
        if transactions.empty?
          render json: { message: "No recent activities" }, status: :ok
          return
        end
        render json: transactions.map { |tx|
          {
            id: tx.id,
            description: tx.payer == current_user ? "You paid #{tx.receiver.name}" : "#{tx.payer.name} paid you",
            amount: tx.amount.to_f.round(2),
            created_at: tx.created_at.strftime("%Y-%m-%d %H:%M:%S"),
            payer: { id: tx.payer.id, name: tx.payer.name },
            receiver: { id: tx.receiver.id, name: tx.receiver.name }
          }
        }, status: :ok
      end
  
      private
  
      def calculate_friend_balances(friends)
        balances = {}
        Rails.logger.info "Starting friend balance calculation for user: #{current_user.name}"
        friends.each do |friend|
          balances[friend] = 0
          Rails.logger.info "Initialized friend #{friend.name} (ID: #{friend.id}) with balance 0"
        end
  
        groups = current_user.groups
        groups.each do |group|
          Rails.logger.info "Processing group: #{group.name} (ID: #{group.id})"
          friends.each do |friend|
            if group.users.include?(friend)
              Rails.logger.info "Friend #{friend.name} (ID: #{friend.id}) is a member of group '#{group.name}'"
              group_balances = current_user.group_balances(group)
              friend_balance = group_balances[friend.id] || 0
              Rails.logger.info "Friend's balance in '#{group.name}': #{friend_balance}"
              balances[friend] += -friend_balance
            else
              Rails.logger.info "Friend #{friend.name} (ID: #{friend.id}) is NOT a member of group '#{group.name}'"
            end
          end
        end
  
        Rails.logger.info "Completed friend balances: #{balances.map { |f, b| "#{f.name}: #{b}" }.join(', ')}"
        balances
      end
    end
  end