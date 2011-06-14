#$:.unshift(File.expand_path(File.join(File.dirname(__FILE__))))

module AWatir

  class Check
    #    class << self
    #      include Test::Unit::Assertions
    #    end
    @@total_warning = 0
    @@warning = 0
    @@op_fail = 0
    @@exception_fail = 0
    @@total_exception_fail = 0
    def self.init(id="Empty", title="Empty")
      @@warning = 0
      @@op_fail = 0
      @@exception_fail = 0
      TestRunLogger.instance.log_result_start(id, title)
    end

    def self.statistic(id="Empty", title="Empty")
      LogInfo.out_statistic(@@warning, @@op_fail)
      result = "Unknown"
      if(@@exception_fail>0)
        result = "SCFail"
      elsif(@@warning>0)
        result = "TCFail"
      else
        result = "Success"
      end
      TestRunLogger.instance.log_result_end(id, title, result, @@warning, @@op_fail)
    end

    def self.add_warning
      @@warning+=1
      @@total_warning+=1
    end
    def self.add_exception_fail
      @@exception_fail += 1
      @@total_exception_fail += 1
    end
    def self.add_op_fail
      @@op_fail = @@op_fail + 1
    end
    def self.total_exception_number
      return @@total_exception_fail
    end
    def self.total_warning_number
      return @@total_warning
    end
    def self.op_fail_number
      return @@op_fail
    end

    def self.warning_number
      return @@warning
    end

    def self.name
      return "����"
    end

#У��Ԥ��ֵ��ʵ��ֵ�Ƿ����
#@param [Object] actual ʵ��ֵ expected Ԥ��ֵ  message ��ע��Ϣ��Ĭ��Ϊnil
#@return [Nil]
#@example CheckText.verify_equal("���", "��ã�", "У��ҳ����ʾ�����Ƿ�Ϊ����á�")
    def self.verify_equal(actual, expected, message=nil)
      if actual.eql?(expected)
        LogInfo.out_true_report(name,expected)
      else
        LogInfo.out_false_report(name,actual,expected,message)
        puts caller(1)[0]
        add_warning
        captureWarning
      end
      return nil
    end
    #����Ŀ��:�õ�������
    def self.get_mname
      caller(2)[0]=~/`(.*?)'/  # note the first quote is a backtick
      return $1
    end
    def self.captureWarning
      if Automan.config.capture_warning
        captureDesktopJPG("����_#{get_mname}")
      end
    end
#У��Ԥ��ֵ��ʵ��ֵ�Ƿ����
#@param [Object] actual ʵ��ֵ expected Ԥ��ֵ  message ��ע��Ϣ��Ĭ��Ϊnil
#@return [Nil]
#@example CheckText.assert_equal("���", "��ã�", "У��ҳ����ʾ�����Ƿ�Ϊ����á�")
    def self.assert_equal(actual, expected, message=nil)
      if actual.eql?(expected)
        LogInfo.out_true_report(name,expected)
      else
        LogInfo.out_false_report(name,actual,expected,message)
        puts caller(1)[0]
        raise "assert not equal!"
      end
      return nil
    end
#У�������Ƿ���ȷ,һ�����󣬳����˳�����������
#@param [Object] expression ��ҪУ��ı��ʽ message ��ע��Ϣ��Ĭ��Ϊnil
#@return [Nil]
#@example CheckText.verify_true(text.include? "���")
    def self.verify_true(expression,message=nil)
      if expression
        puts "[����]���𽫶���ֱ�Ӵ�����������У��ؼ��Ƿ��������verify_true(obj.exist?)" if(expression.is_a?(AWatir::AElement))
        puts "#{name}:У����ȷ"
      else
        puts  "#{name}:У�����#{message}"
        add_warning
        puts caller(1)[0]
        captureWarning
      end
      return nil
    end
#У�������Ƿ���ȷ,һ�����󣬳���ֱ���˳�
#@param [Object] expression ��ҪУ��ı��ʽ message ��ע��Ϣ��Ĭ��Ϊnil
#@return [Nil]
#@example CheckText.assert_true(text.include? "���")
    def self.assert_true(expression,message=nil)
      if expression
        puts "[����]���𽫶���ֱ�Ӵ�����������У��ؼ��Ƿ��������assert_true(obj.exist?)" if(expression.is_a?(AWatir::AElement))
        puts "#{name}:У����ȷ"
      else
        puts  "#{name}:У�����#{message}"
        puts caller(1)[0]
        raise "assert not true!"
      end
    end
#У�������Ƿ����,һ�����ʽ��ȷ�������˳�����������
#@param [Object] expression ��ҪУ��ı��ʽ message ��ע��Ϣ��Ĭ��Ϊnil
#@return [Nil]
#@example CheckText.verify_false(text.include? "���")
    def self.verify_false(expression,message=nil)
      unless expression
        puts "[����]���𽫶���ֱ�Ӵ�����������У��ؼ��Ƿ񲻴�������verify_false(obj.exist?)" if(expression.is_a?(AWatir::AElement))
        puts "#{name}:У����ȷ"
      else
        puts  "#{name}:У�����#{message}"
        add_warning
        puts caller(1)[0]
        captureWarning
      end
    end
#У�������Ƿ���ȷ,һ�����󣬳���ֱ���˳�
#@param [Object] expression ��ҪУ��ı��ʽ message ��ע��Ϣ��Ĭ��Ϊnil
#@return [Nil]
#@example CheckText.assert_false(text.include? "���")
    def self.assert_false(expression,message=nil)
      unless expression
        puts "[����]���𽫶���ֱ�Ӵ�����������У��ؼ��Ƿ񲻴�������assert_false(obj.exist?)" if(expression.is_a?(AWatir::AElement))
        puts "#{name}:У����ȷ"
      else
        puts  "#{name}:У�����#{message}"
        puts caller(1)[0]
        raise "assert not false!"
      end
    end
#У��Ԥ��ֵ�Ƿ�ͽ��ֵƥ�䣬һ����ƥ�䣬���˳����򣬼���ִ������Ĵ���
#@param [Object] actual ʵ��ֵ regxp Ԥ��ֵ֧��������ʽ
#@return [Nil]
#@example CheckText.verify_match(text,/���/)
    def self.verify_match(actual, regxp, message=nil)
      if actual.match regxp
        LogInfo.out_true_report(name,regxp)
      else
        LogInfo.out_false_report(name,actual,regxp,message)
        add_warning
        puts caller(1)[0]
        captureWarning
      end
    end
#У��Ԥ��ֵ�Ƿ�ͽ��ֵƥ�䣬һ����ƥ�䣬����ֱ���˳�����ִ������Ĵ���
#@param [Object] actual ʵ��ֵ regxp Ԥ��ֵ֧��������ʽ
#@return [Nil]
#@example CheckText.assert_match(text,/���/)
    def self.assert_match(actual, regxp, message=nil)
      if actual.match regxp
        LogInfo.out_true_report(name,regxp)
      else
        LogInfo.out_false_report(name,actual,regxp,message)
        puts caller(1)[0]
        raise "assert not match!"
      end
    end
    
  end


  class CheckText < Check

    def self.name
      return "�ı�"
    end
    
  end
  
  class CheckDB < Check

    def self.name
      return "DB"
    end
    
  end
  CheckDb = CheckDB

  class CheckDialog < Check

    def self.name
      return "Dialog"
    end

  end

end

