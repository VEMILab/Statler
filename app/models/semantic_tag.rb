class SemanticTag < ActiveRecord::Base

  belongs_to :annotation

  def self.search(search)
	  #query to identify videos where the 'title' field matches the annotation ID
	  where("tag LIKE \"%#{search}%\"")
  end
end
