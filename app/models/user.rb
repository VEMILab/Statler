class User < ActiveRecord::Base
  
  has_many :annotations

	def self.search(search)
	  #query to identify users where the 'name' field contains a partial or complete string resembling the user query
	  where("name like ?", "%#{search}%")
	end

  has_secure_password
  

end
