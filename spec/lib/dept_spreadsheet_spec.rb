






require 'spec_helper'

describe DeptSpreadsheet do
  def load_dept(file_name) File.open(file_name) {|io| DS.load_dept io} end

  describe "(utility methods)" do
    before(:all) do
      @io = File.open(TEST_XLS)
      @ds = DS.new @io
    end
    after(:all) {@io.close}

    describe "::get_sheet" do
      it "provides option to give different names for sheets" do
        sheet = @ds.get_sheet 'dept', 'Dept Info'
        sheet.name.should eq 'Dept Info'
      end
      it "doesn't care about case" do
        @ds.get_sheet('dept info').name.should eq 'Dept Info'
      end
      it "finds a sheet called 'procedures' with procs in it" do
        @ds.get_sheet('procedures').first[0].downcase.should eq 'name'
      end
    end

    describe "::key_value_pairs" do
      it "gets keys from column 0 and values from column 1" do
        hash = @ds.key_value_pairs @ds.get_dept_info_sheet
        hash[:name].should eq 'Test Dept'
        hash[:hospital].should eq 'Test Hospital'
        hash[:location].should eq 'Test Location'
      end
    end
  end
  
  describe "::load_dept" do
    before(:all) do
      clear_db
      @dept = load_dept TEST_XLS
    end
    describe "(procs)" do
      def proc_by_name(name) Procedure.where(name: name).first end 

      it "saves correct number of procs, skips over any blank lines"  do
        Procedure.count.should eq nonblank_rows_for_sheet('procedures')-1
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
      it "removes spaces at beginning and end of name" do
        (proc_by_name "Spaces at either side of name").should be
      end
      it "removes spaces in the middle of name" do
        (proc_by_name "Spaces in the middle of name").should be
      end

      subject {proc_by_name "Everything"}
      its(:name) {should eq 'Everything'}
      its(:abbrev) {should eq 'E'}
      its(:options) {should eq 'A,B,C,D'}
      its(:comments) {should eq 'Hello!'}
      its('dept.name') {should eq 'Test Dept'}
    
      it "gives procs the correct dept" do
        Procedure.all.each {|p| p.dept.name.should eq 'Test Dept'}
      end
    end

    describe "(nurses)" do
      def nurse_by_name(name) Nurse.where(name: name).first end

      it "saves correct number of nurses" do
        Nurse.count.should eq nonblank_rows_for_sheet('nurses')-1
      end

      context "assigns all fields correctly" do
        subject {nurse_by_name "Jackie Everything"}
        its(:name) {should eq "Jackie Everything"}
        its(:username) {should eq "jackie"}
        its(:validator) {should be_true}
        its(:email) {should eq "japple@random.com"}
        its(:designation) {should eq "Dominator"}
        its(:comments) {should eq "Excellent nurse."}
        its('dept.name') {should eq "Test Dept"}
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
      it "gives nurses the correct dept" do
        Nurse.all.each {|n| n.dept.name.should eq 'Test Dept'}
      end
    end

    context "creates a dept with correct options" do
      subject {Dept.first}
      its(:name) {should eq 'Test Dept'}
      its(:hospital) {should eq 'Test Hospital'}
      its(:location) {should eq 'Test Location'}
    end
    it "returns dept that's been created" do
      @dept.should eq Dept.first
    end
  end
  describe "when spreadsheet has invalid procs or nurses, but department is valid" do
    before(:all) do
      clear_db
      # INVALID_XLS has many errors in nurses and procs
      @dept = load_dept INVALID_XLS
    end
    it "no errors in dept" do
      @dept.errors.any?.should be_false
      @dept.valid?.should be_true # Redundant?
    end
    it "forcing an error in dept prevents loading of nurses and procs" do
      # reload, will trigger validation for dept
      nurses = Nurse.count
      (d = load_dept INVALID_XLS).valid?.should be_false
      Nurse.count.should eq nurses
    end
    it "errors in nurses bubble up to dept#upload_errors" do
      (error = @dept.upload_errors.grep(/nancy/)[0]).should_not be_nil
      error.downcase.should match /line 5/
    end
    it "errors in procs bubble up to dept#upload_errors" do
      error = @dept.upload_errors.grep(/Proc/)[0]
      error.downcase.should match /line 7/
    end
  end
  describe "when dept sheet is missing or invalid" do
    it "adds an error to dept, to be displayed when upload fails" do
      @dept = load_dept "#{DATA_DIR}/no_dept_sheet.xls"
      @dept.valid?.should be_false
      @dept.errors.full_messages.grep(/'dept info'/).any?.should be
    end
  end
  describe "other errors" do
    before(:all) {@dept = load_dept "#{DATA_DIR}/no_nurse_sheet.xls"}
    it "if nurse sheet is missing, adds an error to dept.upload_errors" do
      @dept.upload_errors.grep(/Couldn't find worksheet 'Nurses'/).any?.should be
      @dept.valid?.should be
    end
    it "if there's no 'name' column, log an error in upload_errors and don't load it" do
      @dept.upload_errors.grep(/Couldn't find column 'name'/).any?.should be
      p @dept.upload_errors
      @dept.procedures.any?.should be_false
      @dept.valid?.should be
    end
  end
end

require 'spreadsheet'
def nonblank_rows_for_sheet sheet_name  
  File.open(TEST_XLS) do |io|
    DS.new(io).get_sheet(sheet_name).inject(0) {|accu, i| i[0].nil? ? accu : accu+1}
  end
end

