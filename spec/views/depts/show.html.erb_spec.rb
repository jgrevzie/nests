require 'spec_helper'

describe "depts/show" do
  before(:each) do
    @dept = assign(:dept, stub_model(Dept,
      :name => "Name",
      :hospital => "Hospital",
      :location => "Location"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Hospital/)
    rendered.should match(/Location/)
  end
end
