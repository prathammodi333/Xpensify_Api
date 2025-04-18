# app/controllers/api_controller.rb
class ApiController < ActionController::Base
  # Skip CSRF token verification since APIs don't use it
  skip_before_action :verify_authenticity_token

  # Public callback method for authentication
  def authenticate_request
    header = request.headers['Authorization']
    token = header.split('Bearer ').last if header.present? && header.start_with?('Bearer ')
    payload = JwtService.decode(token)
    @current_user = User.find(payload['user_id']) if payload
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    render json: { error: 'Unauthorized' }, status: :unauthorized
    false
  end

  protected

  def current_user
    @current_user
  end
end