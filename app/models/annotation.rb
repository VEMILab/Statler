require 'json'
require 'digest/sha1'

class Annotation < ActiveRecord::Base

	belongs_to :video
	belongs_to :location
	belongs_to :user
	has_many :tag_annotations
	has_many :semantic_tags, :through => :tag_annotations
	

	#this should be searching itself, with the search parameter submitted by the user	
	def self.search(search)
	    #query to identify annotations where the 'annotation' field contains a partial or complete string resembling the user query
		where("annotation like \"%#{search}%\"")

	end #end of search()

    def asOpenAnnotationJSON()
        # Collect related info
		video = Video.select("title", "location_ID").where(:ID => self.video_id)
		location = Location.select("location").where(:ID => self.location_id)
		user = User.select("name", "email").where(:ID => self.user_id)	
		tag_strings = self.semantic_tags.collect(&:tag)

        # Build hash from this annotation object
		oa = {}
        oa[:@context] = "http://www.w3.org/ns/anno.jsonld"
        oa[:id] = self.id
        oa[:type] = "Annotation"
        oa[:motivation] = "highlighting"

        unless user[0].nil?
            username = user[0].name
            # SHA1 email address
            email = Digest::SHA1.hexdigest user[0].email
            oa[:creator] = {
                type: "Person",
                nickname: username,
                email: email
            }
        end

        body = []
        # Create text descriptor
        body.push({
            type: "TextualBody",
            value: self.annotation,
            format: "text/plain",
            language: "en",
            purpose: "describing"
        })

        # Add tag descriptors
        for tag in tag_strings
            body.push({
                type: "TextualBody",
                purpose: "tagging",
                value: tag
            })
        end
        
        oa[:body] = body


        target = {
            id: location[0].location,
            type: "Video"
        }

        target_selectors = []

        # Add spatial selector (polygon)
        # Get 2D array from string
        points_array = JSON.parse(self.pointsArray)

        unless points_array.blank?

            points_string = ""
            for item in points_array
                # Convert from coordinate point string pairs to float pairs
                raw_point = item.map(&:to_f)
                # Add to the points string
                points_string += "#{raw_point[0]},#{raw_point[1]} "
            end
            svgHTML = "<svg:svg viewBox='0 0 100 100' preserveAspectRatio='none'><polygon points='#{points_string}' /></svg:svg>"
            target_selectors.push({
                type: "svgSelector",
                value: svgHTML
            })
        end

        # Add temporal selector
        beginTimeSeconds = self.beginTime.to_f / 1000.0
        endTimeSeconds = self.endTime.to_f / 1000.0
        target_selectors.push({
            type: "FragmentSelector",
            conformsTo: "http://www.w3.org/TR/media-frags/",
            value: "t=#{beginTimeSeconds},#{endTimeSeconds}"
        })

        target[:selector] = target_selectors

        oa[:target] = target
        return oa


	end
	

end
