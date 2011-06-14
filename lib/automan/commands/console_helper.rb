# work around the at_exit hook in test/unit, which kills IRB
require File.dirname(__FILE__) + '/../../automan'

#�������Ŀ¼��config�ļ��У��ͼ��������boot
if File.exists?("config/boot.rb")
	require "config/boot"
else
  #���û�У���automan console������Ŀ¼�������c:\automan\PROJECT_ID�£��ͼ���PROJECT_ID
  current = (File.expand_path ".").downcase  
  match_data = current.match /^c:\/automan\/(\w+)/
  if match_data
    AUTOMAN_CONSOLE_PROJECT_ID = match_data[1] #��������automan consoleʱ������Ŀ���а�
    load File.dirname(__FILE__) + '/../baseline.rb' #û��ֱ��ʹ��baseline���߼���Ϊ���ǲ�Ҫ�������automan console������base
  end
end
puts "���ӵ�... [#{Automan.config.tam_host}]�������[#{Automan.config.project_tam_id}]"

def helper
  @helper ||= AWatir::HtmlHelper
end
private :helper

#���ҷ������������пؼ�
#@return [Array<type>] ���ط��������ؼ��ļ���
def find(reg,selector,type=AWatir::AElement)
	helper.find_elements_from_ie(reg,selector,type)
end

#���ҷ��������Ŀؼ�
#@return [type] ���ط��������ĵ�һ���ؼ�
def find_one(reg,selector,type=AWatir::AElement)
	helper.find_element_from_ie(reg,selector,type)
end

#���ؼ��ӿ����
def show(elements)
  if(elements.is_a? ModelArray)
    target = []
    elements.each{|e|target<<e.current}
  elsif(elements.is_a? HtmlModel)
    target = elements.current
  else
    target = elements
  end
	AWatir::WebHighlighter.highlight_elements(Array(target))
  return ElementArray.new(Array(target)).length
end

#�г��ؼ����ؼ����������Ƚڵ㣬������show���صĿؼ���
def show_path(element)
  if(element.empty?)
    return element
  end
  if(element.is_a?Array)
    return "�����뵥���ؼ�"
  end
  result = []
  if(element.is_a? HtmlModel)
    target = element.current
  else
    target = element
  end
  current = target
  while current
    result << current
    current = current.parent
  end
  AWatir::WebHighlighter.highlight_elements(result)
  return HtmlHelper.get_path_array_from_element(target)
end

# ��automan console�µ��ԣ���Ҫͬ�����ϵ�ҳ��ģ�ͣ�ʹ��reload���
def reload  
  #�������Ŀ¼��config�ļ��У��ͼ��������boot������ͼ���automan/baseline
  if File.exists?("config/boot.rb")
    load File.expand_path("config/boot.rb")
    load File.expand_path("config/automan_config.rb")
  else
    load File.dirname(__FILE__) + '/../baseline.rb'
  end
  
  if File.exist?(Automan.config.page_path)
    Automan.require_folder Automan.config.page_path, :reload_page => true
  end
end

#�÷� mark(/taobao/, Mms::LoginPage)
def mark(url, page_type)
  AWatir::PageMarker.mark_page(url, page_type)
end
