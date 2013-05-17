



require 'spec_helper'

describe Procedure do

  # describe "seed data" do
  # 	specify { Procedure.count.should > 0 }
  # end

  describe "fabricators" do
    describe "Fabricate :procedure" do
      it "if dept: is specified, then dept is set in procedure" do
        dept = Fabricate :dept, name: 'Dept'
        p = Fabricate :proc, dept: dept
        p.dept.name.should eq dept.name
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

    describe "random_proc" do
      it "returns random existing proc" do
        Fabricate :proc_seq
        # There's a procedure in the db now, so n of procs shouldn't go up
        proc_count = Procedure.count
        5.times { random_proc }
        Procedure.count.should eq proc_count
      end
    end
  end

end
