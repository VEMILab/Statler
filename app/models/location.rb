class Location < ActiveRecord::Base

	belongs_to :video
	has_many :annotations

	def self.search(search)
	  #query to identify locations where the 'location' field matches the annotation ID
	  where("location like ?", "%#{search}%")
	end
end
