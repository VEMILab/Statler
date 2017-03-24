class Video < ActiveRecord::Base

	has_many :annotations
	has_many :locations

	def self.search(search)
	  #query to identify videos where the 'title' field matches the annotation ID
	  where("title like ?", "%#{search}%")
	end

end
