# class ApplicationController < ActionController::Base
#   protect_from_forgery with: :exception
#   before_action :authenticate_user!, unless: :skip_authentication?
#   skip_before_action :authenticate_user!, if: -> { request.path.start_with?('/api/') }
#   before_action :log_session_and_warden
#   skip_forgery_protection if: -> { request.path.start_with?('/api/') }
#   allow_browser versions: :modern

#   def after_sign_in_path_for(resource)
#     if session[:pending_friend_request_sender_id].present?
#       sender_id = session[:pending_friend_request_sender_id]
#       sender = User.find_by(id: sender_id)
#       if sender && !resource.all_friends.include?(sender)
#         Friendship.create(user: resource, friend: sender)
#         Friendship.create(user: sender, friend: resource)
#         flash[:notice] = "You are now friends with #{sender.name}!"
#       end
#       session.delete(:pending_friend_request_sender_id)
#     end
#     dashboard_path
#   end

#   private

#   def skip_authentication?
#     devise_controller? || (controller_name == 'groups' && action_name == 'invite')
#   end

#   def log_session_and_warden
#     Rails.logger.info "Request Path: #{request.path}"
#     Rails.logger.info "Session ID: #{request.session.id}"
#     Rails.logger.info "Session Data: #{session.inspect}"
#     Rails.logger.info "Warden User: #{warden.user.inspect if warden}"
#     Rails.logger.info "Current User: #{current_user.inspect}"
#     Rails.logger.info "User Signed In?: #{user_signed_in?}"
#   end
# end
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_forgery_protection if: -> { request.path.start_with?('/api/') }
  before_action :authenticate_user!, unless: :api_request?
# Override Devise's unauthenticated redirect
# def authenticate_user!
#   unless user_signed_in?
#     respond_to do |format|
#       format.html do
#         store_location_for(:user, request.fullpath)
#         flash[:alert] = "You need to sign in or sign up before continuing."
#         redirect_to new_user_session_path
#       end
#       format.json do
#         render json: { error: "You need to sign in or sign up before continuing." }, status: :unauthorized
#       end
#     end
#   end
# end

def after_sign_out_path_for(resource)
  new_user_session_path
  # if request.format.html?
  #   new_user_session_path
  # else
  #   super(resource)
  # end
end
  def after_sign_in_path_for(resource)
    if session[:pending_friend_request_sender_id].present?
      sender_id = session[:pending_friend_request_sender_id]
      sender = User.find_by(id: sender_id)
      if sender && !resource.all_friends.include?(sender)
        Friendship.create(user: resource, friend: sender)
        Friendship.create(user: sender, friend: resource)
        flash[:notice] = "You are now friends with #{sender.name}!"
      end
      session.delete(:pending_friend_request_sender_id)
    end
    dashboard_path
  end

  private

  def api_request?
    request.path.start_with?('/api/') || devise_controller?
  end

  def log_session_and_warden
    Rails.logger.info "Request Path: #{request.path}"
    Rails.logger.info "Session ID: #{request.session.id}"
    Rails.logger.info "Session Data: #{session.inspect}"
    Rails.logger.info "Warden User: #{warden.user.inspect if warden}"
    Rails.logger.info "Current User: #{current_user.inspect}"
    Rails.logger.info "User Signed In?: #{user_signed_in?}"
  end
end