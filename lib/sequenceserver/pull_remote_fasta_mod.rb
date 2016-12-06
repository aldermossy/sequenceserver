module PullRemoteFastaMod

  
  module InstanceMethods
    
    def pull_remote_fasta_files_if_needed
      
      pull_remote_fasta = PullRemoteFasta.new("./config/pull_db_config.json",  config[:database_dir])
      pull_remote_fasta.pull_remote_items

      if pull_remote_fasta.data_has_been_pulled?
       # SequenceServer::Database.scan_databases_dir
        pull_remote_fasta.all_new_fasta_paths.each do |path_to_fasta_to_recreate_blast_db|
             SequenceServer::Database.remove_from_collection( path_to_fasta_to_recreate_blast_db  )
        end
        #Turn off the STDIN questions         
        SequenceServer::Database.use_default_for_command_line= true
        SequenceServer::Database.make_blast_databases 
        
        #Restart webserver to clear cached database names        
        restart_thin_server
      end
    end
    def restart_thin_server
      `sv restart thin`
    end
  end
  
  def self.included(receiver)
    receiver.send :include, InstanceMethods
  end
end