require 'rails_helper'

RSpec.describe "annotations/show", type: :view do
  before(:each) do
    @annotation = assign(:annotation, Annotation.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
