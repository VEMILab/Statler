class AnnotatorsController < ApplicationController
	skip_before_action :verify_authenticity_token

	# http://knoxjeffrey.github.io/rails/2015/10/07/rails-api-with-authentication/
	before_action :cors_preflight_check
	after_action :cors_set_access_control_headers

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
	
	include AnnotatorsHelper

	before_action :authenticate, only: [:addAnnotation, :deleteAnnotation, :editAnnotation]

	def authenticate
		logger.info "Authenticating..."
		authenticate_or_request_with_http_token do |token, options|
			token == "test"
			# User.find_by(token: token)
		end
	end

	
end
