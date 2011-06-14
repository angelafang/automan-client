require "automan/baseline"
class TestTODO < Automan::DataDrivenTestcase
  def process(checkresult, search_content)
    IEUtil.close_all_ies  #�رյ�ǰ����򿪵�����IE
    ie = IEModel.start("http://s.taobao.com/")                                  #����һ��url
    page = ie.cast(Taobao::Searchtaobao)                                        #��IE��ͼת��Ϊhtmlmodel��ͼ
    ptext = page.search_tabs[2].lnk_tab_item.text                               #ȡҳ���ϵ�ĳ������
    CheckText.assert_equal(ptext,checkresult)                                   # У����ȡ�������Ƿ���Ԥ��ֵ
    page.search_tabs["����"].lnk_tab_item.click                                 #��������̡�tab
    page.txt_search.set search_content                                          #���������������Ҫ����������
    page.btn_search.click                                                       #�������������ť
    ie.close
  end
end
