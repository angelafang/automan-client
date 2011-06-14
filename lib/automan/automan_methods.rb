module Automan
	class << self
    #�Զ������ļ������е�rb�ļ�
    #@param [Hash] options ������:reload_page => true��ʹ��load��ʽ���أ�:donot_raise_error => true�����Լ���ʱ�Ĵ���
    #@example Automan.require_folder("c:/automan/folder", {:reload_page => true, :donot_raise_error => true})
    #@example Automan.require_folder("c:/automan/folder", :donot_raise_error => true)
		def require_folder(path, options = {})
			raise "page path: #{path} is not a folder or not exist!" unless File.directory?(path)
      files = Dir["#{path}/**/*.rb"]
			raise "folder #{path}/**/*.rb is empty" if files.empty?
	    files.each do|f|
	    	error_message = nil
	    	begin
	    		f = File.expand_path(f)
          if options[:reload_page]
            load f
          else
            require f
          end	    		
	    	rescue MissingSourceFile => file_missing
	    		error_message = "Missing source File when require #{f}, message: #{file_missing.message}"
    		rescue Exception => exception
	    		error_message = "exception thrown when require #{f}, message: #{exception.message}"
	    	end
	    	
	    	if error_message
	    		if options[:donot_raise_error]
		      	puts "Error: #{error_message}"
	      	else
	      		raise error_message
	    		end
	      end
	    end
      return nil
		end
	end
end