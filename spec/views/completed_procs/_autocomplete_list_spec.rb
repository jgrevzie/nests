require 'spec_helper'






describe 'completed_procs/_autocomplete_list' do
  it 'renders correct list of procedures' do
    render
    eval("[ #{rendered} ].size").should == Procedure.count
  end
  it 'correctly renders procedures with html unfriendly names' do
    unfriendly_name = '+++++&&&&&'
    Fabricate :procedure, name: unfriendly_name
    render
    rendered.should include unfriendly_name
  end
end

describe 'completed_procs/_options' do
  it "shows a happy little list of radio buttons" do 
    options = "sparkly, shiny, stinky, satisfactory"
    render 'completed_procs/options', options: options
    options.split(',').each do |i|
      rendered.should have_selector("input[type='radio'][value='#{i}']")
    end
  end
  it "shows checkbox if appropriate incantation is hummed" do 
    options = "teleport?"
    render 'completed_procs/options', options: options
    rendered.should have_selector("input[type='checkbox'][value='#{options.chop}']")
  end
end