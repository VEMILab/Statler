require 'rails_helper'

RSpec.describe "annotations/new", type: :view do
  before(:each) do
    assign(:annotation, Annotation.new())
  end

  it "renders new annotation form" do
    render

    assert_select "form[action=?][method=?]", annotations_path, "post" do
    end
  end
end
