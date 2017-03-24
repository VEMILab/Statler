class SearchController < ApplicationController
	
	include SearchHelper

#	helper :all
#
#	def index
 #         #@annotations = Annotation.all <--this seems unnecessary
  #        if params[:search] 	
#	    #if search value was passed through url, search method of Annotation model is #		    initiated
 #           @annotations = Annotation.search(params[:search]).order("created_at DESC")
#	  else
#	    @annotations = Annotation.all.order('created_at DESC')
#	  end
#	  @annotations	

	  #render :text => @annotations

  #<% if @posts.present? %>
  #  <%= render @posts %>
  #<% else %>
  #  <p>There are no posts containing the term(s) <%= params[:search] %>.</p>
  #<% end %>

#end
end


