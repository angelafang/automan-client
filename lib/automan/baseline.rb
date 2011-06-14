
file = $0
if(File.exist?(file))
  current = File.expand_path(file)
  puts "����baseline���ļ�Ϊ��#{current}"
  boot_file = ""
  while (parent = File.dirname(current)) != current #��Ŀ¼ʱ��File.dirname(current)==current
    if File.exist?(parent+"/config/boot.rb") #���ҷ���config�µ�boot.rb�ļ�
      boot_file = File.expand_path(parent+"/config/boot.rb")
      break
    end
    current = parent
  end

  #��Ŀ������boot_file����load boot_fileΪ����automan console��reload��ֱ�Ӹ�load
  if(File.exist?(boot_file))
    load boot_file
  end
elsif(file == "irb")
  #˵����console�������ģ�ɶҲ����
else
  puts "����baseline���ļ�Ϊ��#{file}����������"
end


#��Ŀ����boot_fileû�ж���AUTOMAN_ROOT����ʹ��Ĭ��ֵ
#��������AUTOMAN_ROOT������ִ�����������
if (!defined? AUTOMAN_ROOT) || (defined? @step_in_again)
  #@step_in_againΪ��ȷ��ֻҪ����һ�Σ��ʹδζ�������
  require 'automan'

  unless defined? AUTOMAN_ROOT
    AUTOMAN_ROOT = "c:/automan/"
    require 'fileutils'
    FileUtils.mkdir_p AUTOMAN_ROOT
  end
  @step_in_again = true  unless defined? @step_in_again

  Automan::Initializer.run do |config|
    config.project_tam_id     = (defined?AUTOMAN_CONSOLE_PROJECT_ID).nil? ? "base": AUTOMAN_CONSOLE_PROJECT_ID
    config.tam_host           = "automan.taobao.net"
    #ǿ�Ƹ���page xml
    config.page_force_update  = true
    #Ҫ��Ҫ������ie��ʱ���Զ����
    config.ie_max             = true
    config.mock_db            = nil #��Ϊnil�ͻ�����ȥִ��sql��䣬��Ϊ STDOUT ����ֻ��ӡ��ִ��sql

    #�������assert���Խ�ͼ
    config.capture_error      = true
    #verify���Խ�ͼ
    config.capture_warning    = true
    config.log_level          = :info
  end
end

include Share if defined? Share


