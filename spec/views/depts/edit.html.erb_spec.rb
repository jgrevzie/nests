require 'spec_helper'

describe "depts/edit" do
  before(:each) do
    @dept = assign(:dept, stub_model(Dept,
      :name => "MyString",
      :hospital => "MyString",
      :location => "MyString"
    ))
  end

  it "renders the edit dept form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => depts_path(@dept), :method => "post" do
      assert_select "input#dept_name", :name => "dept[name]"
      assert_select "input#dept_hospital", :name => "dept[hospital]"
      assert_select "input#dept_location", :name => "dept[location]"
    end
  end
end
