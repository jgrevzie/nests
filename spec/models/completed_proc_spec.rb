require 'spec_helper'




describe "completed_proc" do

  describe "validations" do
     it "fabricates a valid random completed_proc" do
      completed_proc = Fabricate(:random_completed_proc)
    end
  end

end