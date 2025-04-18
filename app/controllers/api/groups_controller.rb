# app/controllers/api/groups_controller.rb
module Api
    class GroupsController < BaseController
        before_action :set_group, only: [:show, :update, :destroy]
        before_action :authorize_owner, only: [:update, :destroy]
  
      def index
        groups = current_user.groups.includes(:users)
        render json: groups.as_json(
          include: { users: { only: [:id, :name] } },
          only: [:id, :name, :invite_token]
        ), status: :ok
      end
  
      def show
        render json: @group.as_json(
          include: {
            users: { only: [:id, :name] },
            expenses: {
              include: { paid_by: { only: [:id, :name] } },
              only: [:id, :description, :amount, :created_at]
            }
          },
          only: [:id, :name, :invite_token]
        ), status: :ok
      end
  
      def create
        group = current_user.created_groups.new(group_params)
        if group.save
          GroupMembership.create!(user: current_user, group: group)
          render json: group.as_json(
            include: { users: { only: [:id, :name] } },
            only: [:id, :name, :invite_token]
          ), status: :created
        else
          render json: { errors: group.errors.full_messages }, status: :unprocessable_entity
        end
      end
      def update
        if @group.update(group_params)
          render json: @group.as_json(
            include: { users: { only: [:id, :name] } },
            only: [:id, :name, :invite_token]
          ), status: :ok
        else
          render json: { errors: @group.errors.full_messages }, status: :unprocessable_entity
        end
      end
      def destroy
        @group.group_memberships.destroy_all
        @group.destroy
        render json: { message: "Group deleted successfully" }, status: :ok
      end

  
      private
      def authorize_owner
        Rails.logger.debug "Checking if user #{current_user.id} is owner of group #{@group.id}"
        unless @group.created_by == current_user.id
          Rails.logger.warn "User #{current_user.id} is not the owner of group #{@group.id}"
          render json: { error: 'Only the group owner can update the group' }, status: :forbidden
          return
        end
      end
      def set_group
        @group = current_user.groups.find_by(id: params[:id])
        unless @group
          render json: { error: 'Group not found or you are not a member' }, status: :not_found
          return
        end
      end
      
      def group_params
        params.require(:group).permit(:name)
      end
    end
  end