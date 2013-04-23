



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
end
