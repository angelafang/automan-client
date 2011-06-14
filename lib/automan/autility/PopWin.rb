# ������ֵ����򡢼�ģ���������
module Popwin
  require 'automan/autility/LibAutoit'

  #�ϴ��ļ�
  #@param [String] string ������Ҫ�ϴ����ļ�·��
  #@example file_upload(:file_path => "C:\\Documents and Settings\\ss2.jpg")
  def file_upload(options={})
    LibAutoit::AutoItApi.instance.ChooseFileDialog(options[:file_path])
  end
  #js���������ݲ�֧��radio���������
  #@param [String] ��Ҫ�����button����
  #@example  deal_dialog("ȷ��")
  def deal_dialog(name=nil)
    LibAutoit::AutoItApi.instance.DealConfirmDialog(name)
  end

  #��������������Prompt�Ի���
  #@param [String] string ������ı����� type ���ȷ����ȡ����ť��type:ȷ�� or ȡ��
  #@return [Boolean] true �ɹ� false ʧ��
  #@example  deal_prompt_dialog('test',"ȷ��")
  def deal_prompt_dialog(string,type)
    LibAutoit::AutoItApi.instance.DealPromptDialog(string,type)
  end


  #�����ļ����ضԻ��򣬵���DealPathDialog��������·���������ļ�
  #@param [String] file_path���ļ����غ��ŵ�·������ʽ�磺c:\\test file_name  �ļ������磺test.txt
  #@return [Boolean]  true �ɹ� false ʧ��
  #@example  save_file(��c:\\test��,"test.txt")
  def save_file(file_path,file_name)
    LibAutoit::AutoItApi.instance.DealDownloadDialog(file_path,file_name)
  end

  #��ȡ����������ݣ����60�����û�м��������򣬾ͷ���nil
  #@return [String] ��ȡ�����������
  #@example ����ʾ����text = get_content
  def get_content
    return LibAutoit::AutoItApi.instance.DealConfirmContent()
  end

  #����˵����ģ����������ַ�
  #����ֵ˵������
  #@param [String] ������ַ�����Ϣ��
  #@example Send("#r")�������� Win+r,�⽫�򿪡����С��Ի���.
  #@example Send("^!a")�����Ͱ��� "CTRL + ALT + a".
  #@example Send(" !a")������"ALT + a".
  def SendKey(string = '{ENTER}')
    LibAutoit::AutoItApi.instance.SendKey(string)
  end  
end