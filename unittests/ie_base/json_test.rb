require File.dirname(__FILE__) + "/setup"

class ButtonTest < Test::Unit::TestCase
  #��web_driver��ʹ��
  def test_json
    p = ["taichan"]
    args = {:args => p}
    j = args.to_json
    puts j #Ӧ��û���쳣
  end

  def test_callEmbeddedSelenium
    page = start("selector")
    ele = page.find_element(FElement, "a#id2")
    @struct = ele.element
    assert_equal("a", JavascriptLibrary.callEmbeddedSelenium(@struct.bridge, "getTagName", @struct.element))
  end
end
