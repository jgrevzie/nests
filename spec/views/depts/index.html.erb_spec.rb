require 'spec_helper'

describe "depts/index" do
  before(:each) do
    assign(:depts, [
      stub_model(Dept,
        :name => "Name",
        :hospital => "Hospital",
        :location => "Location"
      ),
      stub_model(Dept,
        :name => "Name",
        :hospital => "Hospital",
        :location => "Location"
      )
    ])
  end

  it "renders a list of depts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Hospital".to_s, :count => 2
    assert_select "tr>td", :text => "Location".to_s, :count => 2
  end
end
