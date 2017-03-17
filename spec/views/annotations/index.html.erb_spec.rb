require 'rails_helper'

RSpec.describe "annotations/index", type: :view do
  before(:each) do
    assign(:annotations, [
      Annotation.create!(),
      Annotation.create!()
    ])
  end

  it "renders a list of annotations" do
    render
  end
end
