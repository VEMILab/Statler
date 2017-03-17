require 'rails_helper'

RSpec.describe "annotations/edit", type: :view do
  before(:each) do
    @annotation = assign(:annotation, Annotation.create!())
  end

  it "renders the edit annotation form" do
    render

    assert_select "form[action=?][method=?]", annotation_path(@annotation), "post" do
    end
  end
end
