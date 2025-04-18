# module Api
#     module V1
#       module Users
#         class RegistrationsController < Devise::RegistrationsController
#           include RackSessionFix
#           respond_to :json
#           skip_forgery_protection # Ensure CSRF is disabled
#           before_action :configure_sign_up_params, only: [:create]
  
#           def create
#             Rails.logger.debug "API Signup params: #{sign_up_params.inspect}"
#             build_resource(sign_up_params)
#             Rails.logger.debug "User before save: #{resource.inspect}"
  
#             if resource.save
#               sign_in(resource_name, resource)
  
#               inviter_message = nil
#               if params[:inviter_id].present?
#                 inviter = User.find_by(id: params[:inviter_id])
#                 if inviter
#                   Friendship.create(user: resource, friend: inviter) unless Friendship.exists?(user: resource, friend: inviter)
#                   Friendship.create(user: inviter, friend: resource) unless Friendship.exists?(user: inviter, friend: resource)
#                   inviter_message = "You are now friends with #{inviter.name}!"
#                 end
#               end
  
#               group_message = nil
#               if params[:pending_group_invite_token].present?
#                 group = Group.find_by(invite_token: params[:pending_group_invite_token])
#                 if group && !group.users.include?(resource)
#                   GroupMembership.create(user: resource, group: group)
#                   group.users.each do |member|
#                     next if member == resource
#                     unless resource.all_friends.include?(member)
#                       Rails.logger.debug "Creating friendship between #{resource.name} and #{member.name}"
#                       Friendship.create(user: resource, friend: member) unless Friendship.exists?(user: resource, friend: member)
#                       Friendship.create(user: member, friend: resource) unless Friendship.exists?(user: member, friend: resource)
#                     end
#                   end
#                   group_message = "You have successfully joined the group!"
#                 else
#                   group_message = "Invalid invite link."
#                 end
#               end
  
#               render json: {
#                 status: { code: 200, message: group_message || inviter_message || 'Signed up successfully.' },
#                 data: UserSerializer.new(resource).serializable_hash[:data][:attributes],
#                 token: request.env['warden-jwt_auth.token']
#               }, status: :ok
#             else
#               Rails.logger.debug "User errors: #{resource.errors.full_messages}"
#               render json: {
#                 status: { code: 422, message: "User couldn't be created.", errors: resource.errors.full_messages }
#               }, status: :unprocessable_entity
#             end
#           end
  
#           private
  
#           def configure_sign_up_params
#             devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password, :password_confirmation])
#           end
  
#           def sign_up_params
#             params.require(:user).permit(:name, :email, :password, :password_confirmation)
#           end
#         end
#       end
#     end
#   end
# app/controllers/api/v1/registrations_controller.rb
module Api
  module V1
    class RegistrationsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :configure_devise_parameters, only: [:create]

      def create
        user = User.new(sign_up_params)
        
        if user.save
          token = user.generate_jwt
          render json: { 
            status: { code: 200, message: 'Signed up successfully.' },
            data: UserSerializer.new(user).serializable_hash[:data][:attributes],
            token: token
          }, status: :ok
        else
          render json: { 
            status: { 
              code: 422, 
              message: "User couldn't be created successfully. #{user.errors.full_messages.to_sentence}" 
            } 
          }, status: :unprocessable_entity
        end
      end

      private

      def configure_devise_parameters
        request.env["devise.mapping"] = Devise.mappings[:user]
      end

      def sign_up_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end