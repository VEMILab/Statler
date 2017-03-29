class TagAnnotation < ActiveRecord::Base

	belongs_to :annotation
	belongs_to :semantic_tag
end
