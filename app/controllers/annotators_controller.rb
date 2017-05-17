class AnnotatorsController < ApplicationController
	skip_before_action :verify_authenticity_token

	# http://knoxjeffrey.github.io/rails/2015/10/07/rails-api-with-authentication/
	before_action :cors_preflight_check
	after_action :cors_set_access_control_headers

	helper_method :session_user

	def cors_preflight_check
		if request.method == 'OPTIONS'
		headers['Access-Control-Allow-Origin'] = '*'
		headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
		headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token'
		headers['Access-Control-Max-Age'] = '1728000'

		render text: '', content_type: 'text/plain'
		end
	end

	def cors_set_access_control_headers
		headers['Access-Control-Allow-Origin'] = '*'
		headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
		headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
		headers['Access-Control-Max-Age'] = "1728000"
	end
	
	#include AnnotatorsHelper

	# Authenticate using user/password info. Only used for initial token request
	def user_auth
		logger.info "Authenticating..."
		authenticate_or_request_with_http_basic do |username, password|
			user = User.find_by_name(username)
			return invalid_username unless user
			logger.info "Found user: #{user.name}"
			user.authenticate(password)
		end
	end

	def write_auth
		authHeader = get_auth_type
		if type == "Token"
			return token_auth
		elsif type == "ApiKey"
			return api_key_auth
		end
		return false
	end

	# Authenticate using token.
	def token_auth
		logger.info "Authenticating..."
		authenticate_or_request_with_http_token do |token, options|
			User.find_by(token: token)
		end
	end

	def api_key_auth
		authHeader = request.headers["HTTP_AUTHORIZATION"]
		key = authHeader.split(" ").last
		
		ApiKey.find_by(api_key: key)
	end

	def get_auth_type
		authHeader = request.headers["HTTP_AUTHORIZATION"]
		type = authHeader.split(" ").first
		return type
	end

	def invalid_username
		render json: { errors: [ { detail: "Username does not exist." }]}, status: 401
	end

	# def session_user
	# 	@_session_user ||= token_auth
	# end

	def require_login!
		return true if write_auth
		render json: { errors: [ { detail: "Access denied" } ] }, status: 401
	end

	#before_action :require_login!, only: [:login]

	
end
