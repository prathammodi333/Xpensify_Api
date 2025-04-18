# app/controllers/api/sessions_controller.rb
module Api
  class SessionsController < BaseController
    skip_before_action :authenticate_request, only: [:login, :signup]

    def signup
      user = User.new(sign_up_params)
      if user.save
        # Handle inviter friendships
        inviter_message = nil
        if params[:inviter_id].present?
          inviter = User.find_by(id: params[:inviter_id])
          if inviter
            Friendship.find_or_create_by(user: user, friend: inviter)
            Friendship.find_or_create_by(user: inviter, friend: user)
            inviter_message = "You are now friends with #{inviter.name}!"
          end
        end

        # Handle group invite
        group_message = nil
        if params[:pending_group_invite_token].present?
          group = Group.find_by(invite_token: params[:pending_group_invite_token])
          if group && !group.users.include?(user)
            GroupMembership.find_or_create_by(user: user, group: group)
            group.users.each do |member|
              next if member == user
              unless user.all_friends.include?(member)
                Friendship.find_or_create_by(user: user, friend: member)
                Friendship.find_or_create_by(user: member, friend: user)
              end
            end
            group_message = "You have successfully joined the group!"
          else
            group_message = "Invalid invite link."
          end
        end

        token = JwtService.encode({ user_id: user.id })
        Rails.logger.info("User #{user.id} signed up")
        render json: {
          status: { code: 200, message: group_message || inviter_message || 'Signed up successfully.' },
          data: { id: user.id, name: user.name, email: user.email },
          token: token
        }, status: :ok
      else
        Rails.logger.debug("User errors: #{user.errors.full_messages}")
        render json: {
          status: { code: 422, message: "User couldn't be created.", errors: user.errors.full_messages }
        }, status: :unprocessable_entity
      end
    end

    def login
      user = User.find_by(email: session_params[:email])
      if user&.valid_password?(session_params[:password])
        token = JwtService.encode({ user_id: user.id })
        render json: { token: token }, status: :ok
      else
        render json: { error: 'Invalid credentials' }, status: :unauthorized
      end
    end

    def logout
      result = authenticate_request
      Rails.logger.debug("Authenticate Request Result: #{result.inspect}")
      if result
        current_user.update_column(:jti, SecureRandom.uuid)
        render json: { message: 'Logged out' }, status: :ok
      else
        nil
      end
    end

    private
    def sign_up_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    def session_params
      params.require(:user).permit(:email, :password)
    end
  end
end