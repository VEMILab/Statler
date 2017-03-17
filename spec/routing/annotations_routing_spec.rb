require "rails_helper"

RSpec.describe AnnotationsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/annotations").to route_to("annotations#index")
    end

    it "routes to #new" do
      expect(:get => "/annotations/new").to route_to("annotations#new")
    end

    it "routes to #show" do
      expect(:get => "/annotations/1").to route_to("annotations#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/annotations/1/edit").to route_to("annotations#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/annotations").to route_to("annotations#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/annotations/1").to route_to("annotations#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/annotations/1").to route_to("annotations#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/annotations/1").to route_to("annotations#destroy", :id => "1")
    end

  end
end
