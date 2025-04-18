class UsersController < Devise::RegistrationsController
  before_action :set_user, only: [:edit]
  before_action :configure_account_update_params, only: [:update]
  before_action :configure_sign_up_params, only: [:create]

  # GET /signup
  def new
    super do |resource|
      @inviter_id = params[:inviter_id]
    end
  end

  # POST /signup
  def create
    Rails.logger.debug "Signup params: #{params.inspect}"
    super do |resource|
      Rails.logger.debug "User before save: #{resource.inspect}"
      if resource.persisted?
        # If the user was invited, add them to the inviter's friend list
        if params[:inviter_id]
          inviter = User.find_by(id: params[:inviter_id])
          if inviter
            Friendship.create(user: resource, friend: inviter)
            Friendship.create(user: inviter, friend: resource)
            flash[:notice] = "You are now friends with #{inviter.name}!"
          end
        end

        # Handle pending group invite
        if session[:pending_group_invite_token].present?
          group = Group.find_by(invite_token: session.delete(:pending_group_invite_token))
          if group && !group.users.include?(resource)
            GroupMembership.create(user: resource, group: group)
            group.users.each do |member|
              next if member == resource
              unless resource.all_friends.include?(member)
                Rails.logger.debug "Creating friendship between #{resource.name} and #{member.name}"
                Friendship.create(user: resource, friend: member) unless Friendship.exists?(user: resource, friend: member)
                Friendship.create(user: member, friend: resource) unless Friendship.exists?(user: member, friend: resource)
              end
            end
            flash[:notice] ||= "You have successfully joined the group!"
          else
            flash[:alert] = "Invalid invite link."
          end
        end
      end
    end
  end

  # GET /profile/edit
  def edit
    # Uses set_user to ensure only current_user can edit
  end

  # PATCH/PUT /profile
  def update
    if @user.update(user_params)
      bypass_sign_in(@user)
      redirect_to root_path, notice: "Account updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def after_update_path_for(resource)
    dashboard_path
  end
  def set_user
    @user = current_user
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
  private

def configure_account_update_params
  devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :password, :password_confirmation, :current_password])
end

  # Override Devise's redirect after sign-up
  def after_sign_up_path_for(resource)
    flash[:notice] = I18n.t("devise.registrations.updated")
    dashboard_path
  end
  def require_no_authentication
    if user_signed_in?
      flash[:notice] = I18n.t("devise.registrations.updated") if request.path == registration_path(resource_name)
      redirect_to after_update_path_for(resource)
    else
      super
    end
  end
end