require 'spec_helper'
require 'fileutils'

module PullRemoteFastaSpecHelper

  def base_export_dir
    File.join File.expand_path(File.dirname(__FILE__)), 'database', 'remote_database'
  end
  def test_example_db_config
    File.join File.expand_path(File.dirname(__FILE__)), 'remote_config_files', 'example_db_config.json' 
  end
  def clean_remote_data_directory
    f = "#{base_export_dir}/TEST_DB_1.fasta"
    return unless File.exists? f
    `rm #{f}`
  end
  def temp_fasta_file
    File.join base_export_dir, "temp_fasta.fasta"
  end
  def touch_temp_fasta_file
    FileUtils.touch temp_fasta_file
  end
  
end

describe 'PullRemoteFasta' do
  include PullRemoteFastaSpecHelper

  before :each do
    # Empty Database collection so we can use different directories as
    # needed.      
   # Database.clear
  end
  it 'should be able to find config files for remote files' do
    pull_remote_fasta = PullRemoteFasta.new(test_example_db_config )
    expect(pull_remote_fasta.config_file_path).to match /example_db_config.json/
  end
  it 'should be able to use a default path to config file if no path given' do
    pull_remote_fasta = PullRemoteFasta.new
     expect(pull_remote_fasta.config_file_path).to match /pull_db_config.json/
  end
  
end


describe "It should be able to pull data and write out data" do
  include PullRemoteFastaSpecHelper
  before(:each) do
    @pull_remote_fasta = PullRemoteFasta.new( test_example_db_config )
  end
  it 'should know about urls to pull' do
    expect(@pull_remote_fasta.items_to_pull.length).to eq 2
  end
end



describe "Should have a helper class to pull the actual data" do
  include PullRemoteFastaSpecHelper
  before(:each) do
    @remote_fasta = RemoteFasta.new(
                      {:name =>         "TEST_DB_1",
                       :max_age_hrs =>  24,
                       :url =>          "http://google.com",
                       :database_dir => base_export_dir
                      }
                    )
  end
  it 'should have some reader methods' do
    expect(@remote_fasta.url).to eq 'http://google.com'
    expect(@remote_fasta.name).to eq 'TEST_DB_1'
    expect(@remote_fasta.max_age_hrs).to eq 24
    expect(@remote_fasta.database_dir).to match 'remote_database'
  end
  it 'should be able to make a path to the database_dir' do
    expect(@remote_fasta.out_file_path).to match /remote_database\/TEST_DB_1/
  end
  
  it 'should be able to get data and write out ' do   
   expect(@remote_fasta.get_data_and_write_out).to eq nil
   
  end
  after(:each) do
    clean_remote_data_directory
  end
  
end


describe "Should be able to figure out if files are older then max age" do
  include PullRemoteFastaSpecHelper
  
  before(:each) do
    @remote_fasta = RemoteFasta.new(
                      {:name =>         "old_fasta_file",
                       :max_age_hrs =>  0.00138888888889, #5 secs
                       :url =>          "http://google.com",
                       :database_dir => base_export_dir
                      }
                    )
  end
  it 'should know if file is older then max age' do
    expect(@remote_fasta.should_data_be_pulled?).to eq true
  end
  it 'should not pull data if file is not expired' do
    @remote_fasta = RemoteFasta.new(
                      {:name =>         "old_fasta_file",
                       :max_age_hrs =>  24, 
                       :url =>          "http://google.com",
                       :database_dir => base_export_dir
                      }
                    )
    touch_temp_fasta_file
    
    expect(@remote_fasta.should_data_be_pulled?).to eq false
  
  end
  
  
end