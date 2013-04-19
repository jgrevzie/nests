



require 'spec_helper'

describe Procedure do

  describe "seed data" do
  	specify { Procedure.count.should > 0 }
  end

  describe "fabricators" do
    describe "Fabricate :procedure" do
      it "makes a few procs with the same dept" do
        dept = Fabricate :dept, name: 'Dept'
        p1 = Fabricate :proc, name: 'PROC1', dept: dept
        p2 = Fabricate :proc, name: 'PROC2', dept: dept
        p1.dept.name.should eq p2.dept.name
      end
    end
  end

  describe "Fabricate :proc_seq" do
    it "makes a sequence of procs" do
      p1 = Fabricate :proc_seq
      p2 = Fabricate :proc_seq
      p1.name.should_not eq p2.name
      p1.dept.should eq p2.dept
    end
  end

end
