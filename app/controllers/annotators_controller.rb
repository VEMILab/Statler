class AnnotatorsController < ApplicationController
	skip_before_action :verify_authenticity_token
	
	include AnnotatorsHelper

	base.before_action :authenticate, only: [:addAnnotation, :deleteAnnotation, :editAnnotation]

	def authenticate
		authenticate_or_request_with_http_basic('Administration') do |username, password|
			user = User.find_by_username(username).authenticate(password)
			!user.nil?
		end
	end

	
end
