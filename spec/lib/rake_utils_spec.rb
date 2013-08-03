




require 'spec_helper'

describe RakeUtils do
  DIR_NAME = "#{Rails.root}/spec/data/nurse_images"
  FILE_NAMES = Dir["#{DIR_NAME}/*.jpeg"]

  def file_at_dir_index(dir_index) File.open(FILE_NAMES[dir_index], &:read) end

  # stubs Kernel.rand() and Array.sample so that they're predictable
  def stub_rand(value) 
    Kernel.stub(:rand).and_return(value)
    Array.any_instance.stub(:sample).and_return(FILE_NAMES[value])
  end

  let(:n) {Fabricate :nurse}

  describe "photify_all" do
    it "photifies all known nurses" do
      stub_rand 1
      2.times {Fabricate :nurse}
      RakeUtils.photify_all
      Nurse.all.each {|n| n.mugshot.should be}
    end
  end

  describe "photify" do
    it "sometimes will setup a nil mugshot, to see whether the default nurse is rendered" do
      stub_rand 0
      RakeUtils.photify n
      n.mugshot.should eq nil
    end
    it "normally sets the mugshot to an image" do
      stub_rand 1
      RakeUtils.photify n
      # could remove the following, needs only to test for !nil because of other tests
      checksum(n.mugshot).should eq checksum(file_at_dir_index(1))
    end
  end
  describe "random_file" do
    it "returns data from a file in a directory" do
      stub_rand 0
      data = File.open(RakeUtils.random_file(DIR_NAME), &:read)
      checksum(data).should eq checksum(file_at_dir_index(0))
    end
  end
end
