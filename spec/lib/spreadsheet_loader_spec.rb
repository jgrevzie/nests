






require 'spec_helper'

describe SpreadsheetLoader, reset_db: false do
  before(:all) do
    clear_db
    SL.load_procs TEST_XLS
    SL.load_nurses TEST_XLS, Fabricate(:dept, name: 'Disco Dept')
  end

  TEST_XLS = "#{File.dirname __FILE__}/test.xls"
  
  describe "::load_procs" do
    def proc_by_name(name) Procedure.where(name: name).first end 

    it "saves correct number of procs"  do
      Procedure.count.should eq SL::get_sheet(TEST_XLS, 'procedures').row_count-1
    end
    it "removes spaces between options" do
      (proc_by_name "Space between the options").options.should eq "Orange,Red"
    end
    it "handles spaces within options, while still removing spaces between options" do
      (proc_by_name "Options can include spaces").options.should eq "Option 1,Option 2"
    end
    it "handles question marks in options" do
      (proc_by_name "Question mark in options").options.should eq "What?"
    end

    subject {proc_by_name "Everything"}
    its(:name) {should eq 'Everything'}
    its(:abbrev) {should eq 'E'}
    its(:options) {should eq 'A,B,C,D'}
    its(:comments) {should eq 'Hello!'}
  end

  describe "::get_dept_name" do
    specify {expect {SL.get_dept_name("hello")}.to raise_error}
    specify {SL.get_dept_name("hello.xls").should eq "hello"}
    specify {SL.get_dept_name("/pretty/long/path/to/hello.xls").should eq "hello"}
    specify {SL.get_dept_name("with spaces all over.xls").should eq "with spaces all over"}
    specify {SL.get_dept_name("FunkyCaps.xls").should eq "FunkyCaps"}
  end

  describe "::get_sheet" do
    it "finds a sheet called 'procedures' with procs in it" do
      SL::get_sheet(TEST_XLS, 'procedures').first[0].downcase.should eq 'name'
    end
  end 

  describe "::load_nurses" do
    def nurse_by_name(name) Nurse.where(name: name).first end

    it "saves correct number of nurses" do
      Nurse.count.should eq 5
    end

    context "assigns all fields correctly" do
      subject {nurse_by_name "Jackie Everything"}
      its(:name) {should eq "Jackie Everything"}
      its(:username) {should eq "jackie"}
      its(:validator) {should be_true}
      its(:email) {should eq "japple@random.com"}
      its(:designation) {should eq "Dominator"}
      its(:comments) {should eq "Excellent nurse."}
      its('dept.name') {should eq "Disco Dept"}
    end

    it "handles boolean value TRUE for validator" do
      nurse_by_name("Jenny Banana").validator.should be_true
    end
    it "builds username" do
      nurse_by_name("Jenny Banana").username.should eq 'jennyb'
    end
     it "builds email" do
      nurse_by_name("Jenny Banana").email.should eq 'jenny.banana@svpm.org.au'
    end
    it "builds non-validator by default" do
      nurse_by_name("Jennifer Cantelope").validator.should be_false
    end
    it "handles boolean value false for validator" do
      nurse_by_name("Jody Dragonfruit").validator.should be_false
    end
    it "handles n as false for validator" do
      nurse_by_name("Josephine Eggplant").validator.should be_false
    end
 end

end