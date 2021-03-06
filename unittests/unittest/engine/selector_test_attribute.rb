require File.dirname(__FILE__) + "/../setup"

include AWatir
class LogTests < Test::Unit::TestCase

  def setup
		goto_page("selector.html")
  end

  def test_selector_attribute_has
    ie = IEModel.attach(/selector.html/)
    m = ie.cast(HtmlModel)
    e = m.find_elements(AWatir::AElement, "a[id]")
    assert_equal(e.length, 2)
  end
  
  def test_selector_attribute_equal
    ie = IEModel.attach(/selector.html/)
    m = ie.cast(HtmlModel)
    e = m.find_elements(AWatir::AElement, "a[id=link_id]")
    assert_equal(e.length, 1)
  end

  def test_selector_attribute_not_equal
    ie = IEModel.attach(/selector.html/)
    m = ie.cast(HtmlModel)
    e = m.find_elements(AWatir::AElement, "a[id!=id2]")
    assert_equal(e.length, 1)
  end
  
  def test_selector_attribute_start
    ie = IEModel.attach(/selector.html/)
    m = ie.cast(HtmlModel)
    e = m.find_elements(AWatir::AElement, "a[id^=link]")
    assert_equal(e.length, 1)
  end

  def test_selector_attribute_end
    ie = IEModel.attach(/selector.html/)
    m = ie.cast(HtmlModel)
    e = m.find_elements(AWatir::AElement, "a[id$=2]")
    assert_equal(e.length, 1)
  end

  def test_selector_attribute_contain
    ie = IEModel.attach(/selector.html/)
    m = ie.cast(HtmlModel)
    e = m.find_elements(AWatir::AElement, "a[id*=ink]")
    assert_equal(e.length, 1)
  end
  
    def test_selector_attribute_multi
    ie = IEModel.attach(/selector.html/)
    m = ie.cast(HtmlModel)
    e = m.find_elements(AWatir::AElement, "a[href][id=link_id]") #TODO: bug here, multi-attribute filter still not supported
    assert_equal(e.length, 1)
  end
end