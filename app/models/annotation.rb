class Annotation < ActiveRecord::Base

	belongs_to :video
	belongs_to :location
	belongs_to :user
	has_many :semantic_tags

	#this should be searching itself, with the search parameter submitted by the user	
	def self.search(search)
	  #query to identify annotations where the 'annotation' field contains a partial or complete string resembling the user query
	##if search.respond_to?(:to_i)	  
##	elsif search.respond_to?(:to_s)
		where ("annotation LIKE %#{search}% OR id LIKE %#{search}%"))

	end #end of search()
	
	#query to identify annotations by id
#	def self.search(id_search)
##	  where (:id == "%#{search}%")
##	end
	##def self.to_s
	##	"Name: #{self.name} Video: #{:video} Author: #{:user} Tags: #{:tags}"
	##end #end of to_s
	
end
