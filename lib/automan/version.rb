module Automan
	def self.version
		detail = version_detail
    #ֻҪ���� .1 ��β�ģ�������ʽ�棬�����Ķ����ڲ�档
    if(detail =~ /\.1$/)
      result = "0.8 ��ʽ�� (version: #{detail})"
    else
      result = "0.8 �ڲ�� (version: #{detail})"
    end
    return result
	end
  def self.version_detail
    return "0.8.3.0"
  end
end