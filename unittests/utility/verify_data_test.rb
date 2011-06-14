require File.dirname(__FILE__) + "/setup"

class CheckTest < Test::Unit::TestCase
	def	test_verify_equal
    actual = "1"
    out = capture_stdout{
      CheckDb.verify_equal(actual, "3")
    }
    assert_match(/DBʵ��ֵ��\|1\|/,out)
    assert_match(/Ԥ��ֵΪ��\|3\|/,out)
    assert_match( /verify_data_test.rb:7:in `test_verify_equal'/,out)

    out = capture_stdout{
      CheckText.verify_equal(actual, "2")
    }
    assert_match(/�ı�ʵ��ֵ��\|1\|/,out)

    out = capture_stdout{
      CheckDialog.verify_equal(actual, "1")
    }
    assert_match(/Dailog�� 1-----У����ȷ/,out)

    out = capture_stdout{
      result = Check.statistic
      assert_equal(result,"TCFail")
    }
    assert_match(/���������ۼƵ�У��������: 2��/,out)
    assert_match(/���������ۼƵĲ���ʧ�ܴ���: 0��/,out)
	end
end
8