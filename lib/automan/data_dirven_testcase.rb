require "data_process/data_sheet"
module Automan
  #����excel�Ľ���
	class DataDrivenHelper
		attr_reader :sheet		
		def initialize(file)
			@sheet = DataSheet.parse_file(file)
		end

    #����excel�����ݳ�ʼ��
		def setup
		end
		#����excel����������
		def teardown		
		end
	end

  # ֧������������TestBase
	class DataDrivenTestCase
    #����excel��������excel��setup
	  def setup
	  	@helper = nil
      @warning_number = 0
	  	if(file = $0.sub(".rb", ".xls")) && File.file?(file)
	  		@helper = DataDrivenHelper.new(file)
			end
      @helper && @helper.setup
      if defined? setup_db
        raise "setup_db����֧�֡�����class_initialize����setup_db����class_initialize�Ĵ������excel����׼���󱻵��ã�һ��class��ֻ�����һ��"
      end
	  end

    #ִ�нű�
	  def test_process
	    if @helper
	      @helper.sheet.testcase_records.each{|testcase_record|
          if(ARGV.length==1) #����ֻ��һ��ʱ��ִ�в�����execute������ֱ��ִ��
            if(ARGV.include?(testcase_record.id.to_s))
              puts "����[#{testcase_record.id}��#{testcase_record.title}]��ͨ��ָ��ID��ʽ����ʼִ�С��������Ƿ�ִ���ֶΣ�"
              run_process(testcase_record)
            end
          else
            if(testcase_record.execute.nil?)
              puts "����[#{testcase_record.id}��#{testcase_record.title}]���Ƿ�ִ�б���ΪN������"
            else
              puts "����[#{testcase_record.id}��#{testcase_record.title}]����ʼִ�С�"
              run_process(testcase_record)
            end
          end
      	}
	    else
	      run_no_xls_process
	    end
	  end

    # ��excelʱ��ִ�е�������
    def run_no_xls_process
      Check.init
      begin
	      process()
      rescue Exception => ex
        _exception_handle(ex)
      end
      Check.statistic      
    end

    # ִ�е�������ʱ��������
    def _exception_handle(ex)
      if(Automan.config.capture_error)
        title = File.basename($0, ".rb").gsub(/[\/:\*\?<>\\]/,'_')
        captureDesktopJPG("����_#{title}")
      end
      Check.add_exception_fail
      TestRunLogger.instance.log_exception(ex)
    end
    private :_exception_handle

    # ��excelʱ��ִ�е�������
    def run_process(testcase_record)
      Check.init(testcase_record.id, testcase_record.title)      # ��check�����      TestRunLogger.instance.log_result_start
      begin
        process(*testcase_record.test_data)
      rescue Exception => ex
        _exception_handle(ex)
      end
      Check.statistic(testcase_record.id, testcase_record.title) #��check�����       TestRunLogger.instance.log_result_end
    end

	  def process(*arg)	    
	  end
    #������excel���delete_sql��init_sql�����У�һ��classֻ����һ��
    def class_initialize
    end
    #������excel���reback_sqlǰ���У�һ��classֻ����һ��
    def class_cleanup
    end

    #����excel��teardown����������
	  def teardown
      @helper && @helper.teardown
      if(Check.total_exception_number > 0)
        puts "�ű�����ʧ�ܣ��μ�������Ϣ��"
        exit 1
      elsif(Check.total_warning_number > 0)
        puts "�ű�����ʧ�ܣ���ΪWarning�˳����ۼ�Warning#{Check.total_warning_number}�Ρ�"
        exit 2
      else
        puts "�ű����гɹ���"
      end
	  end

    #������DataDrivenTestcase������
	  def run
      TestRunLogger.load_logger
      begin
        setup
        begin
          class_initialize
          test_process
        ensure
          class_cleanup
        end
      rescue Exception => ex
        TestRunLogger.instance.log_init_error(ex)
      ensure
        teardown
      end
    end

    #�������еģ�DataDrivenTestcase������
    def self.run_all
      collect_clazz.each{|clazz|clazz.new.run}
    end
	  
    private
    def self.collect_clazz
      result = []
      ::ObjectSpace.each_object(Class) do |klass|
        if (DataDrivenTestCase > klass)
          result << klass
        end
      end
      result
    end
	  
    at_exit do
      unless $!
        DataDrivenTestCase.run_all
      end
    end
	  
  end
  DataDrivenTestcase = DataDrivenTestCase
end

