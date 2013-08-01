



module RakeUtils
  DIR_NAME = "#{Rails.root}/spec/data/nurse_images"
	def self.photify_all
    Nurse.all.each {|n| photify n}
	end
  def self.photify nurse
    # sometimes leave it nil to see if the 'standard' photo comes up
    Kernel.rand(10)==0 ? nurse.mugshot=nil : nurse.mugshot=random_file(DIR_NAME)
    nurse.save
  end
  def self.random_file dir_name
    File.open(Dir["#{dir_name}/*.jpeg"].sample) {|f| f.read}
  end  
end
