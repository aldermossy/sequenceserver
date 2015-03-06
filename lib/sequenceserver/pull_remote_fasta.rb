require 'json'
class PullRemoteFasta
  attr_accessor :config_file_path, 
                :items_to_pull,
                :database_dir,
                :data_has_been_pulled,
                :all_new_fasta_paths
                
  def initialize(config_file_path, database_dir)
   @config_file_path = config_file_path
   @database_dir = database_dir
   
   @items_to_pull = []
   @all_new_fasta_paths  = []
   @data_has_been_pulled = false
   read_config_file_if_present
  end
  def pull_remote_items
    items_to_pull.each do |config_args|
      remote_fasta = RemoteFasta.new(config_args, self)
      remote_fasta.get_data_and_write_out
    end
  end
  
  def data_has_been_pulled?
    data_has_been_pulled
  end
  
  
  private
  def read_config_file_if_present
    return unless config_file_exists?

    @items_to_pull = JSON.parse(read_config_file, {:symbolize_names => true})  
  end
  def read_config_file
    File.open(config_file_path).read
  end
  def config_file_exists?
    File.exists? config_file_path
  end

end


class RemoteFasta
  attr_reader :url, :name, :max_age_hrs, :pull_remote_fasta_obj
  
  attr_accessor :remote_data, :data_has_been_pulled

  def initialize(args, pull_remote_fasta_obj)
    @url  = args[:url]
    @name = args[:name]
    @max_age_hrs = args[:max_age_hrs]

    @remote_data = ''
    @data_has_been_pulled = false
    
    
    @pull_remote_fasta_obj = pull_remote_fasta_obj
    
  end
  def out_file_path

    File.join database_dir, name_with_fasta_suffix
  end
  def name_with_fasta_suffix
    "#{name}.fasta"
  end
  def should_data_be_pulled?
    return true if out_file_does_not_exist
    return true if (out_file_exists? && check_if_data_is_older_then_max_age)
    false #default to NOT pulling data 
  end
  
  def get_data_and_write_out
    return unless should_data_be_pulled?
    cmd = make_cmd_to_download_data
    r = `#{cmd}`
    check_exit_status(r)
    record_data_has_been_pulled
    true
  end
  

  
  private
  def record_data_has_been_pulled
    pull_remote_fasta_obj.data_has_been_pulled = true
    pull_remote_fasta_obj.all_new_fasta_paths << out_file_path
  end
  def database_dir
    pull_remote_fasta_obj.database_dir
  end
  def out_file_does_not_exist
    ! out_file_exists?
  end
  def out_file_exists?
    File.exists? out_file_path
  end
  
  def check_if_data_is_older_then_max_age
    out_file_time < (Time.now - max_age_in_secs)
  end
  def out_file_time
    File.stat(out_file_path).mtime
  end

  def max_age_in_secs
    max_age_hrs * 3600
  end
  def check_exit_status(returned)
    unless $?.exitstatus == 0
      raise "Could not download data: Error #{$?.to_s} : returned data: #{returned}"
    end
  end
  def make_cmd_to_download_data
    "curl --globoff \"#{url}\" -o #{out_file_path}"
  end

  
  
  
end