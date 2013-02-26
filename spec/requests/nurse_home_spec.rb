




require 'spec_helper'




describe "Nurse's home page" do

  it "shows title for signed in nurse"

  describe "(completed proc table)" do
    it "shows pending procs, with a row for each pending proc"
    it "doesn't show pending procs for a different nurse"
    it "doesn't show rejected procs"
    it "doesn't show validated procs"
  end

  describe "(rejected proc table)" do
    it "shows rejected procs, row for each reject"
    it "shows links to procs in red"
    it "when link is clicked, acks rejected status"
  end

  describe "(summary table)" do
    it "shows count of each validated proc"
    it "doesn't show procs with 0 count"
  end

end