Automan::Initializer.run do |config|
  #ָ����ǰ���������
  config.project_tam_id     = "{ProjectId}"
  #ָ����ǰ�Ķ��������
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

