# class GroupsController < ApplicationController
#   before_action :authenticate_user!, except: [:invite]
#   before_action :set_group, only: [:show, :generate_invite_token, :invite, :destroy, :add_member, :add_member_email, :edit, :update]
#   before_action :authorize_owner, only: [:edit, :update, :destroy]
#   before_action :authorize_member, only: [:show] # New before_action

#   def edit
#   end

#   def update
#     if @group.update(group_params)
#       redirect_to @group, notice: "Group name updated successfully!"
#     else
#       render :edit, alert: "Failed to update group name."
#     end
#   end

#   def generate_invite_token
#     @group.update(invite_token: @group.generate_invite_token)
#     redirect_to @group, notice: "Invite link generated!"
#   end

#   # def invite
#   #   token = params[:token]
#   #   Rails.logger.debug "is user signed in? : #{user_signed_in?}"
#   #   if user_signed_in?
#   #     @group = Group.find_by(invite_token: token)
#   #     if @group
#   #       flash[:notice] = "You have successfully joined the group!😍"
#   #       GroupMembership.create(user: current_user, group: @group)
#   #       Rails.logger.debug "Group membership created after invite link"
#   #       @group.users.each do |member|
#   #         next if member == current_user
#   #         unless current_user.all_friends.include?(member)
#   #           puts "Creating friendship between #{current_user.name} and #{member.name}"
#   #           Friendship.create(user: current_user, friend: member) unless Friendship.exists?(user: current_user, friend: member)
#   #           Friendship.create(user: member, friend: current_user) unless Friendship.exists?(user: member, friend: current_user)
#   #         end
#   #       end
#   #       redirect_to @group
#   #     else
#   #       flash[:alert] = "Invalid invite link."
#   #       redirect_to dashboard_path
#   #     end
#   #   else
#   #     session[:pending_group_invite_token] = token
#   #     redirect_to new_user_session_path, alert: "Please log in first to join the group."
#   #   end
#   # end
#   def invite
#     token = params[:token]
#     Rails.logger.debug "Invite token: #{token}"
#     Rails.logger.debug "is user signed in? : #{user_signed_in?}"
#     if user_signed_in?
#       @group = Group.find_by(invite_token: token)
#       Rails.logger.debug "Group found: #{@group.inspect}"
#       if @group
#         unless @group.users.include?(current_user) # Prevent re-joining
#           GroupMembership.create(user: current_user, group: @group)
#           Rails.logger.debug "Group membership created after invite link"
#           @group.users.each do |member|
#             next if member == current_user
#             unless current_user.all_friends.include?(member)
#               Rails.logger.debug "Creating friendship between #{current_user.name} and #{member.name}"
#               Friendship.create(user: current_user, friend: member) unless Friendship.exists?(user: current_user, friend: member)
#               Friendship.create(user: member, friend: current_user) unless Friendship.exists?(user: member, friend: current_user)
#             end
#           end
#           flash[:notice] = "You have successfully joined the group!😍"
#         else
#           flash[:notice] = "You are already a member of this group."
#         end
#         redirect_to @group
#       else
#         flash[:alert] = "Invalid invite link."
#         redirect_to dashboard_path
#       end
#     else
#       session[:pending_group_invite_token] = token
#       redirect_to new_user_session_path, alert: "Please log in first to join the group."
#     end
#   end
#   def create
#     @group = current_user.created_groups.build(group_params)
#     if @group.save
#       GroupMembership.create(user: current_user, group: @group)
#       respond_to do |format|
#         format.html { redirect_to @group, notice: "Group created successfully!" }
#         format.js
#       end
#     else
#       respond_to do |format|
#         format.html { redirect_to dashboard_path, alert: "Failed to create group." }
#         format.js
#       end
#     end
#   end

#   def show
#     @members = @group.users
#     @expenses = @group.expenses.includes(:paid_by).order(created_at: :desc)
#     @friends = current_user.all_friends - @members
#   end

#   def destroy
#     @group.group_memberships.destroy_all
#     @group.destroy
#     redirect_to dashboard_path, notice: "Group deleted successfully."
#   end

#   def add_member_email
#     email = params[:email].downcase.strip
#     FriendRequestMailer.invite_to_group(current_user, email, @group).deliver_now
#     redirect_to group_path(@group), notice: "An invitation has been sent to #{email}"
#   end

#   def add_member
#     user = User.find(params[:user_id])
#     if @group.users.include?(user)
#       redirect_to group_path(@group), alert: "#{user.name} is already a member of the group."
#     else
#       GroupMembership.create(user: user, group: @group)
#       redirect_to group_path(@group), notice: "#{user.name} was added to the group!"
#       @group.users.each do |member|
#         next if member == user
#         unless user.all_friends.include?(member)
#           puts "Creating friendship between #{user.name} and #{member.name}"
#           Friendship.create(user: user, friend: member) unless Friendship.exists?(user: user, friend: member)
#           Friendship.create(user: member, friend: user) unless Friendship.exists?(user: member, friend: user)
#         end
#       end
#     end
#   end

#   private

#   # def set_group
#   #   if params[:id].present?
#   #     @group = Group.find(params[:id])
#   #   elsif params[:token].present?
#   #     @group = Group.find_by(invite_token: params[:token])
#   #   end
#   # end
#   def set_group
#     @group = if params[:id].present?
#                Group.find_by(id: params[:id])
#              elsif params[:token].present?
#                Group.find_by(invite_token: params[:token])
#              end
  
#     unless @group
#       respond_to do |format|
#         format.html do
#           flash[:alert] = params[:id].present? ? "Group not found." : "Invalid or expired invite token."
#           redirect_to root_path
#         end
#         format.json do
#           render json: {
#             status: { code: 404, message: params[:id].present? ? "Group not found." : "Invalid or expired invite token." },
#             errors: ["Group not found"]
#           }, status: :not_found
#         end
#       end
#     end
#   end

#   def group_params
#     params.require(:group).permit(:name)
#   end

#   def authorize_owner
#     unless @group.created_by == current_user.id
#       redirect_to group_path(@group), alert: "Only the group owner can perform this action."
#     end
#   end
#   def authorize_member
#     unless @group.users.include?(current_user) || @group.created_by == current_user.id
#       redirect_to dashboard_path, alert: "You are not a member of this group."
#     end
#   end
# end

class GroupsController < ApplicationController
  before_action :authenticate_user!, except: [:invite]
  before_action :set_group, only: [:show, :generate_invite_token, :invite, :destroy, :add_member, :add_member_email, :edit, :update]
  before_action :authorize_owner, only: [:edit, :update, :destroy]
  before_action :authorize_member, only: [:show]

  def edit
  end

  def update
    if @group.update(group_params)
      redirect_to @group, notice: "Group name updated successfully!"
    else
      render :edit, alert: "Failed to update group name."
    end
  end

  def generate_invite_token
    @group.update(invite_token: @group.generate_invite_token)
    redirect_to @group, notice: "Invite link generated!"
  end

  def invite
    token = params[:token]
    Rails.logger.debug "Invite action called with token: #{token}"
    Rails.logger.debug "User signed in? #{user_signed_in?}, Current user: #{current_user&.id}"
    
    unless @group
      Rails.logger.debug "Group not found for token: #{token}"
      flash[:alert] = "Invalid or expired invite link."
      redirect_to dashboard_path
      return
    end

    if user_signed_in?
      Rails.logger.debug "Processing invite for user: #{current_user.email}"
      if @group.users.include?(current_user)
        Rails.logger.debug "User #{current_user.email} is already a member of group #{@group.id}"
        flash[:notice] = "You are already a member of this group."
        redirect_to @group
      else
        Rails.logger.debug "Creating membership for user #{current_user.email} in group #{@group.id}"
        GroupMembership.create!(user: current_user, group: @group)
        @group.users.each do |member|
          next if member == current_user
          unless current_user.all_friends.include?(member)
            Rails.logger.debug "Creating friendship between #{current_user.name} and #{member.name}"
            Friendship.create!(user: current_user, friend: member) unless Friendship.exists?(user: current_user, friend: member)
            Friendship.create!(user: member, friend: current_user) unless Friendship.exists?(user: member, friend: current_user)
          end
        end
        flash[:notice] = "You have successfully joined the group!😍"
        redirect_to @group
      end
    else
      Rails.logger.debug "User not signed in, storing token: #{token}"
      session[:pending_group_invite_token] = token
      redirect_to new_user_session_path, alert: "Please log in or sign up to join the group."
    end
  end

  def create
    @group = current_user.created_groups.build(group_params)
    if @group.save
      GroupMembership.create(user: current_user, group: @group)
      respond_to do |format|
        format.html { redirect_to @group, notice: "Group created successfully!" }
        format.js
      end
    else
      respond_to do |format|
        format.html { redirect_to dashboard_path, alert: "Failed to create group." }
        format.js
      end
    end
  end

  def show
    @members = @group.users
    @expenses = @group.expenses.includes(:paid_by).order(created_at: :desc)
    @friends = current_user.all_friends - @members
  end

  def destroy
    @group.group_memberships.destroy_all
    @group.destroy
    redirect_to dashboard_path, notice: "Group deleted successfully."
  end

  def add_member_email
    email = params[:email].downcase.strip
    FriendRequestMailer.invite_to_group(current_user, email, @group).deliver_now
    redirect_to group_path(@group), notice: "An invitation has been sent to #{email}"
  end

  def add_member
    user = User.find(params[:user_id])
    if @group.users.include?(user)
      redirect_to group_path(@group), alert: "#{user.name} is already a member of the group."
    else
      GroupMembership.create(user: user, group: @group)
      redirect_to group_path(@group), notice: "#{user.name} was added to the group!"
      @group.users.each do |member|
        next if member == user
        unless user.all_friends.include?(member)
          Rails.logger.debug "Creating friendship between #{user.name} and #{member.name}"
          Friendship.create(user: user, friend: member) unless Friendship.exists?(user: user, friend: member)
          Friendship.create(user: member, friend: user) unless Friendship.exists?(user: member, friend: user)
        end
      end
    end
  end

  private

  def set_group
    @group = if params[:id].present?
               Group.find_by(id: params[:id])
             elsif params[:token].present?
               Group.find_by(invite_token: params[:token])
             end

    unless @group
      respond_to do |format|
        format.html do
          flash[:alert] = params[:id].present? ? "Group not found." : "Invalid or expired invite token."
          redirect_to root_path
        end
        format.json do
          render json: {
            status: { code: 404, message: params[:id].present? ? "Group not found." : "Invalid or expired invite token." },
            errors: ["Group not found"]
          }, status: :not_found
        end
      end
    end
  end

  def group_params
    params.require(:group).permit(:name)
  end

  def authorize_owner
    unless @group.created_by == current_user.id
      redirect_to group_path(@group), alert: "Only the group owner can perform this action."
    end
  end

  def authorize_member
    unless @group.users.include?(current_user) || @group.created_by == current_user.id
      redirect_to dashboard_path, alert: "You are not a member of this group."
    end
  end
end