require File.dirname(__FILE__) + "/../setup"

include AWatir
class LogTests < Test::Unit::TestCase

  def setup
		goto_page("taobao.html")
  end

  def test_find_elements_string_not_in_array
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    m.product_list["�����ڵ�Ԫ��"].click
  end
  def test_find_elements_index_out_of_range
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    c = m.product_list.length
    m.product_list[c+1].click    
  end
  def test_find_models_index_out_of_range
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    c = m.product_model.length
    m.product_model[c+1].search_text.set '123'
  end
  def test_find_models_string_not_in_array
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    m.product_model["�����ڵ�Ԫ��"].search_text.set '123'
  end

  def _test_name_description_not_found
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    m.search_text_not_exist.set "abc"
    assert_equal(m.search_text_not_exist.exist?, false)
    m.not_exist_model.not_exist_search.set "test1"
  end

  def _test_name_description_when_find
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    m.search_text.set "abc"
    assert_nil(m.search_text.get("nothing"))
    assert_equal(m.search_text.get("title"), "��������")
    m.search_model.search_text.set "abc"
  end
  
  def _test_text_field_can_not_find_element
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    m.not_exist_model.not_exist_search.set "test3"
    ele = m.not_exist_model.not_exist_search
    ele.set "test4"
  end

  def _test_text_field_can_not_find_model_element
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    ele = m.find_element(AWatir::ATextField, "input#q_not_exist", :name=>"only_have_name")
    ele.set "test5"
  end

  def _test_text_field_submodel
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    ele = m.search_model.search_text
    ele.set "test2"
  end
  
  def _test_text_field_withindex
    ie = IEModel.attach(/taobao/)
    m = ie.cast(HtmlModel)
    models = m.find_models(HtmlModel, "div.search-panel")
    m = models[0].find_model(HtmlModel, ">.search-input-box")
    ele = m.find_element(AWatir::ATextField, "input#q", :description=>"ֻ��������û������")
    ele.set "test6"
  end
    
end

class TaobaoUnitTestPage < HtmlModel
  #��׼��¼
  def search_text
    find_element(AWatir::ATextField, "input#q", :name=>"search_text", :description=>"�Ա���ҳ������")
  end
  #̫�������õģ������ڵ�������
  def search_text_not_exist
    find_element(AWatir::ATextField, "input_not_exist#q")
    find_element(AWatir::ATextField, "input_not_exist#q", :name=>"search_text_not_exist", :description=>"̫�������õģ������ڵ�������")
  end
  #����ģ��1
  def search_model
    find_model(TaobaoUnitTestSubModel, "div.search-panel", :name=>"search_model", :description=>"����ģ��1")
  end
  #�����ڵ�ģ��
  def not_exist_model
    find_model(TaobaoUnitTestSubModel, "div.search-panel_not_exist", :name=>"not_exist_model_for_test", :description=>"̫�������õģ������ڵ�ģ��")
  end
  def product_list
    find_elements(AWatir::AElement, "#J_MegaMenu li", :name=>"product_list", :description=>"��Ʒ�б�")
  end
  def product_model
    find_models(TaobaoUnitTestSubModel, "#J_MegaMenu li", :name=>"product_list", :description=>"��Ʒ�б�ģ��")
  end
end
class TaobaoUnitTestSubModel < HtmlModel
  def search_text
    find_element(AWatir::ATextArea, "input#q", :name=>"search_text", :description=>"�Ա���ҳģ���µ�������")
  end
  def not_exist_search
    find_element(AWatir::ATextArea, "input#q_not_exist", :name=>"not_exist_search", :description=>"̫�������õģ��Ա���ҳģ���µĲ����ڵ�������")
  end
end