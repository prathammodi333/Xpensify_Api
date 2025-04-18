class DashboardController < ApplicationController
  skip_before_action :authenticate_user!, only: :show, if: -> { user_signed_in? }
  def index
    # Dashboard logic
  end
  def show
    @user = current_user
    @recent_expenses = @user.expenses.order(created_at: :desc).limit(5)
    @groups = @user.groups.presence || []
    total_balances = @groups.map { |group| @user.group_balances(group).values.sum }
    @balance_owed = total_balances.select { |balance| balance > 0 }.sum
    @balance_due = total_balances.select { |balance| balance < 0 }.map(&:abs).sum

    @friends = @user.all_friends
    @friend_balances = calculate_friend_balances

    @transactions = TransactionHistory.where("payer_id = ? OR receiver_id = ?", @user.id, @user.id)
                                     .includes(:payer, :receiver)
                                     .order(created_at: :desc)

    Rails.logger.info "Final Friend Balances: #{@friend_balances.map { |f, b| "#{f.name}: #{b}" }.join(', ')}"
  end

  private

  # def calculate_friend_balances
  #   balances = {}
  #   Rails.logger.info "Starting friend balance calculation for user: #{@user.name}"
    
  #   @groups.each do |group|
  #     Rails.logger.info "Processing group: #{group.name} (ID: #{group.id})"
  #     @friends.each do |friend|
  #       if group.users.include?(friend)
  #         Rails.logger.info "Friend #{friend.name} (ID: #{friend.id}) is a member of the group '#{group.name}'"
  #         group_balances = @user.group_balances(group)
  #         Rails.logger.info "Group '#{group.name}' balances: #{group_balances.inspect}"
  #         friend_balance = group_balances[friend.id] || 0
  #         Rails.logger.info "Friend's balance in '#{group.name}': #{friend_balance}"
  #         balances[friend] ||= 0
  #         balances[friend] += -friend_balance
  #       else
  #         Rails.logger.info "Friend #{friend.name} (ID: #{friend.id}) is NOT a member of the group '#{group.name}'"
  #       end
  #     end
  #   end

  #   Rails.logger.info "Completed friend balances: #{balances.map { |f, b| "#{f.name}: #{b}" }.join(', ')}"
  #   balances
  # end
  def calculate_friend_balances
    balances = {}
    Rails.logger.info "Starting friend balance calculation for user: #{@user.name}"
  
    # Initialize all friends with zero balance
    @friends.each do |friend|
      balances[friend] = 0
      Rails.logger.info "Initialized friend #{friend.name} (ID: #{friend.id}) with balance 0"
    end
  
    # Calculate balances for friends in groups
    @groups.each do |group|
      Rails.logger.info "Processing group: #{group.name} (ID: #{group.id})"
      @friends.each do |friend|
        if group.users.include?(friend)
          Rails.logger.info "Friend #{friend.name} (ID: #{friend.id}) is a member of the group '#{group.name}'"
          group_balances = @user.group_balances(group)
          Rails.logger.info "Group '#{group.name}' balances: #{group_balances.inspect}"
          friend_balance = group_balances[friend.id] || 0
          Rails.logger.info "Friend's balance in '#{group.name}': #{friend_balance}"
          balances[friend] += -friend_balance
        else
          Rails.logger.info "Friend #{friend.name} (ID: #{friend.id}) is NOT a member of the group '#{group.name}'"
        end
      end
    end
  
    Rails.logger.info "Completed friend balances: #{balances.map { |f, b| "#{f.name}: #{b}" }.join(', ')}"
    balances
  end
  def amount_owed_to(user, friend)
    ExpenseShare
      .joins(:expense)
      .where(user: friend, expenses: { paid_by: user })
      .sum(:amount_owed)
  end
end