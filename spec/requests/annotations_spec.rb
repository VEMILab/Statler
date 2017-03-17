require 'rails_helper'

RSpec.describe "Annotations", type: :request do
  describe "GET /annotations" do
    it "works! (now write some real specs)" do
      get annotations_path
      expect(response).to have_http_status(200)
    end
  end
end
