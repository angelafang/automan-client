Automan::Initializer.run do |config|
  config.project_tam_id     = "Base"
  config.tam_host           = "automan.heroku.com"
  #ǿ�Ƹ���page xml
  config.page_force_update  = true
  #Ҫ��Ҫ������ie��ʱ���Զ����
  config.ie_max             = true
  config.mock_db            = nil #��Ϊnil�ͻ�����ȥִ��sql��䣬��Ϊ STDOUT ����ֻ��ӡ��ִ��sql
  config.page_path          = "page"
  #�������assert���Խ�ͼ
  config.capture_error      = true
  #verify���Խ�ͼ
  config.capture_warning    = true
  config.capture_path       = "capture"
end
