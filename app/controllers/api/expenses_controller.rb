# app/controllers/api/expenses_controller.rb
module Api
    class ExpensesController < BaseController
      before_action :set_group, only: [:create]
      before_action :set_expense, only: [:show]
  
      def index
        expenses = current_user.expenses.includes(:group, :paid_by).order(created_at: :desc)
        if expenses.empty?
          render json: { message: "No expenses paid by user" }, status: :ok
        else
          render json: expenses.as_json(
            include: { group: { only: [:id, :name] }, paid_by: { only: [:id, :name] } },
            methods: :amount_owed
          ), status: :ok
        end
      end
  
      def show
        render json: @expense.as_json(
          include: {
            group: { only: [:id, :name] },
            paid_by: { only: [:id, :name] },
            expense_shares: { include: { user: { only: [:id, :name] } } }
          }
        ), status: :ok
      end
  
      def create
        expense = @group.expenses.new(expense_params.except(:member_ids))
        expense.paid_by = current_user
  
        # Validate member_ids
        if params[:expense][:member_ids].present?
          invalid_ids = validate_member_ids(params[:expense][:member_ids])
          if invalid_ids.any?
            render json: { errors: ["Invalid member IDs: #{invalid_ids.join(', ')} are not group members"] },
                   status: :unprocessable_entity
            return
          end
        end
  
        if expense.save
          create_expense_shares(expense)
          render json: expense.as_json(
            include: { group: { only: [:id, :name] }, paid_by: { only: [:id, :name] } }
          ), status: :created
        else
          render json: { errors: expense.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      private
  
      def set_group
        @group = Group.find_by(id: params[:expense][:group_id])
        unless @group && @group.users.include?(current_user)
          render json: { error: 'Group not found or you are not a member' }, status: :not_found
          return
        end
      end
  
      def set_expense
        @expense = current_user.expenses.find_by(id: params[:id])
        unless @expense
          render json: { error: 'Expense not found' }, status: :not_found
          return
        end
      end
  
      def expense_params
        params.require(:expense).permit(:description, :amount, :group_id, member_ids: [])
      end
  
      def validate_member_ids(member_ids)
        return [] if member_ids.blank?
        group_member_ids = @group.users.pluck(:id).map(&:to_s)
        member_ids.reject { |id| group_member_ids.include?(id.to_s) }
      end
  
      def create_expense_shares(expense)
        total = expense.amount.to_d
        selected_ids = params[:expense][:member_ids]&.reject(&:blank?) || @group.users.pluck(:id)
        members = @group.users.where(id: selected_ids)
        return if members.empty?
  
        total_cents = (total * 100).to_i
        base_cents = total_cents / members.count
        remainder = total_cents % members.count
  
        members.each_with_index do |member, index|
          amount_cents = index < remainder ? base_cents + 1 : base_cents
          amount = (amount_cents / 100.0).to_d.round(2)
          next if member == current_user
          expense.expense_shares.create!(
            user: member,
            amount_owed: amount
          )
        end
      end
    end
  end