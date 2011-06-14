#$LOAD_PATH.unshift  File.expand_path(File.join(File.dirname(__FILE__)))

module AWatir

  #д������־
  class DebugInfo
    def self.save_descendant(num, time)
      if(num!=0)
        File.open("c:/automan_perf.log", "a") { |file|
          file << "[Desc]���������#{num}\tʱ��(s)��#{time}\t����ʱ��(ms)��#{time/num*1000}\r\n"
        }
      end
    end
    def self.save_general_find(time, log_info, element)
      oneline = log_info.selector_history*"|" #���߸���
      ele_names=[]
      log_info.action_history.each{|act|
        ele_names << act[:name]
      }
      ele_name = ele_names*"."
      title = element.empty? ? "FndF":"FndS"
      File.open("c:/automan_perf.log", "a") { |file|
        file << "[#{title}]�ҷ���#{oneline}\tʱ��(s)��#{time}\t���ƣ�#{ele_name}\r\n"
      }
    end
    def self.save_cast(page_type)
      File.open("c:/automan_perf.log", "a") { |file|
        file << "[Cast]ת��ҳ�棺#{page_type.inspect}\r\n"
      }
    end
    
  end
  
  class LogInfo

=begin rdoc
  �������ƣ� out_report(check_type,out_state)
  ����˵����
    check_typeΪУ�����ͣ���Ϊ��text,db,dialog,3��
    out_state: ���״̬ true �� false
  ���ߣ� ����
=end
    def self.out_true_report(check_type,check_value)
      check_type_text = get_type(check_type)
      info = "#{check_type_text}�� #{check_value}-----У����ȷ"
      puts info
    end

    def self.out_statistic(warning, op)
      puts "���������ۼƵ�У��������: #{warning}��"
      puts "���������ۼƵĲ���ʧ�ܴ���: #{op}��"
    end

    def self.out_false_report(check_type,actual,check_value,message=nil)
      check_type_text = get_type(check_type)
      errorinfo = "#{check_type_text}�� #{check_value}-----У�����"
      puts errorinfo
      result = "#{check_type}ʵ��ֵ��|#{actual}|��Ԥ��ֵΪ��|#{check_value}|"
      if(actual.class != check_value.class)
        result+=", ʵ��ֵ���ͣ�#{actual.class}��Ԥ��ֵ���ͣ�#{check_value.class}"
      end
      if(message)
        result+=", ������Ϣ #{message}"
      end
      puts result
    end

    private
    #���������ƣ�ת�������ı�
    def self.get_type(check_type)
      case check_type.downcase
      when "����"
        return "����"
      when "text"
        return "�ı�"
      when "db"
        return "DB"
      when "dialog"
        return "Dailog"
      else
        return "�ı�"
      end
    end    
  end

  class TestRunLogger
    include Singleton

    # ������ִ�з�ʽ�µĵ��÷���
    def self.load_logger
      input_hash = {}
      if(ARGV.length==1)
        arg_hash = {}
      else
        arg_hash = Hash[*ARGV]
      end
      input_hash[:jobId]=arg_hash["-jobId"] if arg_hash["-jobId"]
      input_hash[:date]=arg_hash["-date"] if arg_hash["-date"]
      input_hash[:scriptName]=File.basename($0,".rb")
      TestRunLogger.config(input_hash)      
    end
    
    def need_xml_log
      return defined? @@log_file
    end
    # ���ú����дһ���ļ�������Ѿ����������ᱻ���ǡ�
    def self.config(hash)
      unless defined? @@log_file
        t=Time.now
        init = {:jobId=>(t.seconds_since_midnight).to_i, :date=>t.strftime("%Y-%m-%d"), :scriptName=>"DefaultTestScriptName"}
        hash = init.merge(hash)
      
        job_id = hash[:jobId]
        date = hash[:date]
        script_name = hash[:scriptName]
        @@log_file = "c:/automan/log/#{date}/#{job_id}_#{script_name.gsub(/[\/:\*\?<>\\]/,'_')}.xml"
        path = File.expand_path(File.dirname(@@log_file))
        unless(File.exist?(path))
          FileUtils.mkdir_p(path)
          xsl_file = File.dirname(__FILE__)+"/../resource/CaseReport.xsl"
          FileUtils.copy_file(xsl_file, path+"/CaseReport.xsl")
        end
        
        File.open(@@log_file, "w") { |file|
          file << "<?xml version=\"1.0\" encoding=\"gb2312\" ?>"
          file << "<?xml-stylesheet type=\"text/xsl\" href=\"CaseReport.xsl\"?>"
          file << "<TestRun jobId=\"#{job_id}\" date=\"#{date}\" scriptName=\"#{script_name}\" time=\"#{Time.now}\">"
        }
        @@default_type = "System"
        require 'automan/autility/ExtandPuts'
        puts "XML��־λ�ã�[#{@@log_file}]"
        ObjectSpace::define_finalizer(self.instance, proc{ File.open(@@log_file, "a") { |file| file << "</TestRun>"} })
      end
    end    
    def log_result_start(id, title)      
      File.open(@@log_file, "a") { |file| file << "<TestResult id=\"#{id}\" title=\"#{title}\" type=\"start\" time=\"#{Time.now}\" />"}
    end
    def log_result_end(id, title, result, warning, op_fail)
      if(need_xml_log)
        File.open(@@log_file, "a") { |file| file << "<TestResult id=\"#{id}\" title=\"#{title}\" type=\"end\" result=\"#{result}\" verifyError=\"#{warning}\" operationError=\"#{op_fail}\" time=\"#{Time.now}\" />"}
      else
        return result
      end
    end
    def log_debug_message(str)
      if(need_xml_log)
        File.open(@@log_file, "a") { |file| file << "<Trace type=\"Debug\"><![CDATA[#{str}]]></Trace>"}
        STDOUT.puts str
      else
        return str
      end
    end
    def log_exception(ex)
      AutomanExceptionAnalyser.analyse(ex)
      str = "Error: #{ex} (#{ex.class})."
      File.open(@@log_file, "a") { |file| file << "<Trace type=\"Exception\"><![CDATA[#{str}]]></Trace>"}
      STDOUT.puts str
      arr = ex.backtrace
      str = arr*"\n"
      File.open(@@log_file, "a") { |file| file << "<Trace type=\"BackTrace\"><![CDATA[#{str}]]></Trace>"}
      STDOUT.puts str
    end
    def log_init_error(ex)
      log_exception(ex)
      File.open(@@log_file, "a") { |file| file << "<TestResult id=\"All\" title=\"All\" result=\"NotRun\" verifyError=\"0\" operationError=\"0\" time=\"#{Time.now}\" />"}
    end
    # TestRunLogger.default_type=System
    # TestRunLogger.default_type=User
    def self.default_type=(type)
      @@default_type = type
    end
    #����չ�����ã�������xml��־
    def puts(object)
      str = object.to_s
      str = convert_for_html(str)
      File.open(@@log_file, "a") { |file| file << "<Trace type=\"#{@@default_type}\">#{str}</Trace>"}
    end

    private
    def initialize
      if(!defined?(@@log_file) || @@log_file.nil?)
        # ˵������������������ģʽ�£�ʲô��������
      end
    end
    def convert_for_html(str)
      str = str.gsub("<","&lt;").gsub(">","&gt;").gsub("\\","&#92;")
      return str
    end
  end

  #���ݵ���ջ��������ԭ�򣬻�����־�ϼ�[�������]�Ľڵ�
  class AutomanExceptionAnalyser
    #�������������
    def self.analyse(ex)
      raise "NotSupported" unless(ex.is_a?(Exception))
      if(message = AutomanExceptionAnalyser._process(ex)) #�������
        puts "[�������]" + message
      end
    end
    #��������
    def self._process(ex)
      rule.each{|r|
        if(r[:class]==ex.class)
          if r[:block_return_true].call(ex)
            result = ""
            result += "[#{r[:error_type]}]" if(r[:error_type])
            result += r[:rule_message].call(ex)
            return result
          end
        end
      }
      return nil
    end
    #�����б�
    def self.rule
      arr = []
      ## NoMethodError, selector_go,
      ## undefined method `selector_go' for [Detail::AuctionDetail::CWangPuDetail::ShopAttachsEmpty Node]:AEngine::ModelArray
      arr << {
        :class=>NoMethodError, #����Դ����
        :block_return_true=>lambda{|ex|
          if(matches = (/^undefined method `#{ex.name}' for (.*)$/).matches(ex.message.gsub("\r\n","")))
            if matches[1].to_s =~ /AEngine::ModelArray/
              return true
            end
          end
          return false
        }, #���鷵��true����ƥ�����
        :rule_message=>lambda{|ex|
          return "��Ŀؼ���Submodel Collection������[0]��[\"�ı�\"]��ʽ����λ��ĳһ��Submodel"
        }, #����������Ϣ
        :error_type=>"�﷨����" #������������
      }
      arr << {
        :class=>NoMethodError,
        :block_return_true=>lambda{|ex|
          if(matches = (/^undefined method `#{ex.name}' for (.*)$/).matches(ex.message.gsub("\r\n","")))
            if matches[1].to_s =~ /AEngine::ElementArray/
              return true
            end
          end
          return false
        },
        :rule_message=>lambda{|ex|
          return "��Ŀؼ���Element Collection������[0]��[\"�ı�\"]��ʽ����λ��ĳһ��Element"
        },
        :error_type=>"�﷨����"
      }
      return arr
    end
  end
end

