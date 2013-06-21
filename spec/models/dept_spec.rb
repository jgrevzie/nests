



require 'spec_helper'

describe Dept do
  describe "fabricators" do
    describe "Fabricate :dept_singleton" do
      it "fabricates the same dept each time" do
        d1 = Fabricate :dept_singleton
        d2 = Fabricate :dept_singleton
        d1.should eq d2
      end
    end
  end
  describe "using_upload" do
    def grep_errors(dept) dept.errors.full_messages.grep(/'dept info'/).any? end

    it "when set, adds an error after validation reminding user to include 'dept info' sheet" do
      dept = Dept.new # Invalid because does not specify name and hospital and location
      dept.using_upload = true
      dept.valid?.should be_false
      p dept.errors
      grep_errors(dept).should be
    end
    it "no missing sheet reminder unless there's a 'can't be blank' error already" do
      ds = Fabricate :dept_singleton
      (d = Dept.new ds.attributes).using_upload = true
      d.valid?.should be_false
      grep_errors(d).should be_false
    end
    it "no missing sheet reminder if dept isn't from an upload" do
      (d = Dept.new).valid?.should be_false
      grep_errors(d).should be_false
    end
  end
end
