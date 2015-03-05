require 'json'
class PullRemoteFasta
  attr_accessor :config_file_path, 
                :items_to_pull
  def initialize(config_file_path = default_config_file_path)
   @config_file_path = config_file_path
   

   @items_to_pull = []
   read_config_file_if_present
  end
  def pull_remote_items
    items_to_pull.each do |config_args|
      remote_fata = RemoteFasta.new(config_args)
      remote_fata.get_data_and_write_out
    end
    
    
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

  def default_config_file_path
    File.join File.expand_path(File.dirname(__FILE__)), 'config', 'pull_db_config.json' 
  end
end


class RemoteFasta
  attr_reader :url, :name, :max_age_hrs, :database_dir
  
  attr_accessor :remote_data
              
  def initialize(args)
    @url  = args[:url]
    @name = args[:name]
    @max_age_hrs = args[:max_age_hrs]
    @database_dir = args[:database_dir]
    @remote_data = ''
  end
  def out_file_path
    File.join database_dir, name_with_fasta_suffix
  end
  def name_with_fasta_suffix
    "#{name}.fasta"
  end


  def should_data_be_pulled?
    out_file_exists? && check_if_data_is_older_then_max_age
  end

  
  def get_data_and_write_out
    cmd = make_cmd_to_download_data
    r = `#{cmd}`
    check_exit_status(r)
  end
  
  
  private
  def out_file_exists?
    File.exists? out_file_path
  end
  
  def check_if_data_is_older_then_max_age
    (out_file_time + max_age_in_secs) < Time.now
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