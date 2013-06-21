



require 'spec_helper'

describe Procedure do

  # describe "seed data" do
  # 	specify { Procedure.count.should > 0 }
  # end

  describe "fabricators" do

    describe "Fabricate :proc_seq" do
      it "makes a sequence of procs" do
        p1 = Fabricate :proc_seq
        p2 = Fabricate :proc_seq
        p1.name.should_not eq p2.name
        p1.dept.should eq p2.dept
      end
      it "if dept: is specified, then dept is set in procedure" do
        dept = Fabricate :dept, name: 'Dept'
        p = Fabricate :proc_seq, dept: dept
        p.dept.name.should eq dept.name
      end
    end

    describe "random_existing_proc" do
      it "returns random existing proc" do
        Fabricate :proc_seq
        # There's a procedure in the db now, so n of procs shouldn't go up
        proc_count = Procedure.count
        5.times { random_existing_proc }
        Procedure.count.should eq proc_count
      end
    end

    describe "procedure validations" do
      it "procs can have same name, as long as they're in different depts" do
        d1 = Fabricate :dept, name: 'd1'
        d2 = Fabricate :dept, name: 'd2'
        Fabricate :proc, name: 'proc', dept: d1
        expect { Fabricate :proc, name: 'proc', dept: d2}.not_to raise_error
      end
    end
  end

end
