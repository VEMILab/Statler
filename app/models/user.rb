require 'securerandom'

class User < ActiveRecord::Base
  
  has_many :annotations

	before_create :set_auth_token

	private
		def set_auth_token
			return if token.present?
			self.token = generate_auth_token
		end

		def generate_auth_token
			SecureRandom.uuid.gsub(/\-/,'')
		end
	end

	def self.search(search)
	  #query to identify users where the 'name' field contains a partial or complete string resembling the user query
	  where("name like ?", "%#{search}%")
	end

  has_secure_password
  

end
