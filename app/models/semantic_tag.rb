class SemanticTag < ActiveRecord::Base

##  belongs_to :annotation
  has_many :tag_annotations
  has_many :annotations, :through => :tag_annotations

  def self.search(search)
	  #query to identify videos where the 'title' field matches the annotation ID
	  where("tag like \"%#{search}%\"")
  end
end
