# class SessionsController < Devise::SessionsController
#   def new
#     Rails.logger.info "Sessions#new, User Signed In?: #{user_signed_in?}"
#     if user_signed_in?
#       redirect_to dashboard_path and return
#     end
#     super
#   end

#   def create
#     Rails.logger.info "Sessions#create, Params: #{params.inspect}"
#     self.resource = warden.authenticate!(auth_options)
#     if resource
#       Rails.logger.info "Authenticating user: #{resource.inspect}"
#       sign_in(resource_name, resource)
#       Rails.logger.info "After sign_in, Warden User: #{warden.user.inspect}"
#       if session[:pending_group_invite_token]
#         token = session.delete(:pending_group_invite_token)
#         group = Group.find_by(invite_token: token)
#         if group && !group.users.include?(resource)
#           GroupMembership.create(user: resource, group: group)
#           flash[:notice] ||= "You have successfully joined the group!"
#           Rails.logger.debug "Checking friendship between #{group.users}"
#           group.users.each do |member|
#             next if member == resource
#             unless resource.all_friends.include?(member)
#               Rails.logger.debug "Creating friendship between #{resource.name} and #{member.name}"
#               Friendship.create(user: resource, friend: member) unless Friendship.exists?(user: resource, friend: member)
#               Friendship.create(user: member, friend: resource) unless Friendship.exists?(user: member, friend: resource)
#             end
#           end
#         else
#           flash[:alert] = "Invalid invite link or you are already a member of the group."
#         end
#       end
#       redirect_to dashboard_path, notice: flash[:notice] || "Logged in successfully"
#     else
#       flash.now[:alert] = "Invalid email or password"
#       render :new, status: :unprocessable_entity
#     end
#   end
#   def destroy
#     Rails.logger.info "Logging out user #{current_user.id if current_user}" # Debug log
#     signed_out = sign_out(resource_name)
#     Rails.logger.info "Signed out: #{signed_out}"
#     redirect_to new_user_session_path, notice: "Signed out successfully." if signed_out
#   end

#   private

#   def auth_options
#     { scope: resource_name, recall: "#{controller_path}#new" }
#   end
# end

class SessionsController < Devise::SessionsController
  def new
    Rails.logger.info "Sessions#new, User Signed In?: #{user_signed_in?}"
    if user_signed_in?
      redirect_to dashboard_path and return
    end
    super
  end

  def create
    Rails.logger.info "Sessions#create, Params: #{params.inspect}"
    self.resource = warden.authenticate!(auth_options)
    if resource
      Rails.logger.info "Authenticating user: #{resource.email}"
      sign_in(resource_name, resource)
      Rails.logger.info "After sign_in, Warden User: #{warden.user&.email}"
      
      if session[:pending_group_invite_token]
        token = session.delete(:pending_group_invite_token)
        Rails.logger.debug "Processing pending invite token: #{token}"
        group = Group.find_by(invite_token: token)
        if group
          if group.users.include?(resource)
            Rails.logger.debug "User #{resource.email} already in group #{group.id}"
            flash[:notice] = "You are already a member of the group."
          else
            Rails.logger.debug "Creating membership for user #{resource.email} in group #{group.id}"
            GroupMembership.create!(user: resource, group: group)
            group.users.each do |member|
              next if member == resource
              unless resource.all_friends.include?(member)
                Rails.logger.debug "Creating friendship between #{resource.name} and #{member.name}"
                Friendship.create!(user: resource, friend: member) unless Friendship.exists?(user: resource, friend: member)
                Friendship.create!(user: member, friend: resource) unless Friendship.exists?(user: member, friend: resource)
              end
            end
            flash[:notice] = "You have successfully joined the group!😍"
          end
          redirect_to group_path(group)
        else
          Rails.logger.debug "Invalid invite token: #{token}"
          flash[:alert] = "Invalid or expired invite link."
          redirect_to dashboard_path
        end
      else
        redirect_to dashboard_path, notice: "Logged in successfully"
      end
    else
      flash.now[:alert] = "Invalid email or password"
      render :new
    end
  end

  def destroy
    Rails.logger.info "Logging out user #{current_user&.id}"
    signed_out = sign_out(resource_name)
    Rails.logger.info "Signed out: #{signed_out}"
    redirect_to new_user_session_path, notice: "Signed out successfully." if signed_out
  end

  private

  def auth_options
    { scope: resource_name, recall: "#{controller_path}#new" }
  end
end