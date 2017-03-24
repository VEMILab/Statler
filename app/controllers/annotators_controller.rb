class AnnotatorsController < ApplicationController
	skip_before_action :verify_authenticity_token
	
	include AnnotatorsHelper
end
