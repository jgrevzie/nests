






require 'spec_helper'

describe SpreadsheetLoader do

  TEST_XLS = "#{File.dirname __FILE__}/test.xls"
  SL = SpreadsheetLoader
  
  describe "::load_procs", skip_procs: true do
    before(:each) {SL.load_procs TEST_XLS}
    def proc_by_name(name) Procedure.where(name: name).first end 

    it "saves correct number of procs"  do
      Procedure.count.should eq SL::load_sheet(TEST_XLS, 'procedures').row_count-1
    end
    it "removes spaces between options" do
      (proc_by_name "Space between the options").options.should eq "Orange,Red"
    end
    it "handles spaces within options, while still removing spaces between options" do
      (proc_by_name "Options can include spaces").options.should eq "Option 1,Option 2"
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

  describe "::load_sheet" do
    it "finds a sheet called 'procedures' with procs in it" do
      SL::load_sheet(TEST_XLS, 'procedures').first[0].downcase.should eq 'name'
    end
  end  

end