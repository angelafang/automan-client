require File.dirname(__FILE__) + "/setup"
  
class CaptureScreenTest < Test::Unit::TestCase

	def	test_capture_screen

    out = capture_stdout{
      captureDesktopJPG("capture_filename",capture_path=nil)
    }
    assert_match(/�����ɹ����μ�/,out)
    
	end
end
