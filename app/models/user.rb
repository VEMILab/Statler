require 'securerandom'

class User < ActiveRecord::Base
  
  has_many :annotations

	def generate_auth_token
		if token.present?
			return token
		end
		token = SecureRandom.uuid.gsub(/\-/,'')
		self.update_columns(token: token)
		token
	end

	def invalidate_auth_token
		self.update_columns(token: nil)
	end

	def self.search(search)
	  #query to identify users where the 'name' field contains a partial or complete string resembling the user query
	  where("name like ?", "%#{search}%")
	end

  has_secure_password
  

end
