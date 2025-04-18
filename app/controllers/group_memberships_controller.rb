class GroupMembershipsController < ApplicationController
  before_action :set_group

  def create
    user = User.find_by(email: params[:email].downcase.strip)

    if user.nil?
      redirect_to group_path(@group), alert: "No user found with that email."
      return
    end

    if @group.users.include?(user)
      redirect_to group_path(@group), alert: "#{user.name} is already a member of this group."
      return
    end

    @group.group_memberships.create(user: user)
    redirect_to group_path(@group), notice: "#{user.name} was successfully added to the group."
  end

  def destroy
    membership = @group.group_memberships.find_by(user_id: current_user.id)

    if membership
      membership.destroy
      redirect_to dashboard_path, notice: "You left the group."
    else
      redirect_to dashboard_path, alert: "You are not a member of this group."
    end
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end
end