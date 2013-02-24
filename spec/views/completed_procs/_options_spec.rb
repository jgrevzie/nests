




require 'spec_helper'

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