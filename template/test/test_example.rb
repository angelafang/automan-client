=begin
      �� �� ��:
      �ű�����: 1.
               2.
               3.
      �������ڣ�2010-09-03
      ��Ӧ������
=end
require 'automan/baseline' #����automan���Զ�����boot�ļ��������ã�Ĭ�ϵ�page����λ����c:\automan\base\page

class TestExample < Automan::DataDrivenTestcase

  # processǰִ�У�һ��classֻ����һ��
#  def class_initialize
#    IEUtil.close_all_ies
#    #����login��ֻ��ִ��һ�εĲ���
#  end

  # process��ִ�У�һ��classֻ����һ��
#  def class_cleanup
#    IEUtil.close_ies
#  end

	def process(*m)
    ie = IEModel.start("http://login.daily.taobao.net/member/login.jhtml?")
    bpage = ie.cast(Mms::LoginPage)
    bpage.chk_safelogin.clear
    bpage.txt_username.set "automan_sample"
    ie.close
	end

end