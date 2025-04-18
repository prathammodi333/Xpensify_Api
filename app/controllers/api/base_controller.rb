# app/controllers/api/base_controller.rb
module Api
    class BaseController < ActionController::Base
      skip_before_action :verify_authenticity_token
      before_action :authenticate_request
  
      def authenticate_request
        header = request.headers['Authorization']
        Rails.logger.debug("Authorization Header: #{header}")
        token = header.split('Bearer ').last if header.present? && header.start_with?('Bearer ')
        Rails.logger.debug("Extracted Token: #{token}")
        payload = JwtService.decode(token)
        Rails.logger.debug("Decoded Payload: #{payload}")
        if payload && payload['jti']
          @current_user = User.find(payload['user_id'])
          Rails.logger.debug("User JTI: #{@current_user.jti}, Token JTI: #{payload['jti']}")
          unless @current_user.jti == payload['jti']
            Rails.logger.debug("JTI Mismatch")
            render json: { error: 'Token revoked' }, status: :unauthorized
            return false
          end
          true # Return true on successful authentication
        else
          Rails.logger.debug("No payload or JTI")
          render json: { error: 'Invalid token' }, status: :unauthorized
          return false
        end
      rescue ActiveRecord::RecordNotFound
        Rails.logger.debug("User not found")
        render json: { error: 'User not found' }, status: :unauthorized
        false
      rescue JWT::ExpiredSignature
        Rails.logger.debug("Token expired")
        render json: { error: 'Token expired' }, status: :unauthorized
        false
      rescue JWT::DecodeError => e
        Rails.logger.debug("JWT Decode Error: #{e.message}")
        render json: { error: 'Invalid token' }, status: :unauthorized
        false
      end
  
      protected
  
      def current_user
        @current_user
      end
    end
  end