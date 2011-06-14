# ���һЩ���õķ���
require 'timeout'

module AWatir

  class IEUtil
    

    # ɾ��IE��ʱ�ļ�
    # ����������cookie���ڵ�Ŀ¼��Ĭ��ΪC��·����
    #@param [String] ��ʱ�ļ����λ�ã�Ĭ��Ϊdir= ENV['USERPROFILE']+"\\Local Settings\\Temporary Internet Files"
    #@example  IEUtil.kill_all_cookie ���� IEUtil.kill_all_cookie(url)
    def self.kill_all_cookie (dir= ENV['USERPROFILE']+"\\Local Settings\\Temporary Internet Files")
      require 'fileutils'
      FileUtils.rm_rf dir
    end

    # ɾ��IE��cookie��cache
    # ����������cookie���ڵ�Ŀ¼��Ĭ��ΪC��·����
    #@example  IEUtil.clear_ie_cookie_and_cache
    def self.clear_ie_cookie_and_cache
      require 'watir/cookiemanager'
      Watir::CookieManager::WatirHelper.deleteSpecialFolderContents(Watir::CookieManager::WatirHelper::COOKIES)
      Watir::CookieManager::WatirHelper.deleteSpecialFolderContents(Watir::CookieManager::WatirHelper::INTERNET_CACHE)
    end

    # �ر��û�ͨ������򿪵�����IE�����е�����ʱ����10�����ʾ�ر�ʧ��
    #@example  IEUtil.close_ies
    def self.close_ies
      #[Bug]{TODO}Ҫ�Ȱ�����popwin���ص�
      begin
        Timeout.timeout(20) do
          IEModel.get_ies.each do |ie|
            ie.close
          end
        end
      rescue Timeout::Error => e
        puts "�޷��رգ�10�볬ʱ"
      end
      return nil
    end

    # �رյ�ǰ���е�IE
    #@example  IEUtil.close_all_ies

    def self.close_all_ies
      begin
        Timeout.timeout(10) do
          IEModel.get_all_ies.each do |ie|
            ie.close
          end
        end
      rescue Timeout::Error => e
        kill_all_ie      
      end
      return nil
    end

    # �رյ�ǰ���е�IE,�����µ����֣�close_all_ies
    #@example  IEUtil.close_all_ies
    def self.close_all_ie
      puts "[����]�����µ����֣�close_all_ies"
      self.close_all_ies
    end

    private
    def self.kill_all_ie
      begin
        mgmt = WIN32OLE.connect('winmgmts:\\\\.')
        getout = false
        while 1
          processes = mgmt.instancesof("win32_process")
          processes.each do |process|
            # puts process
            if  process.name.downcase =="iexplore.exe" then
              process.terminate()
              sleep 1 #Ԥ��ie�رղ���ʱ������Ĵ���
              getout = false
              break
            end
            getout = true
          end
          return if getout
        end
      rescue ex
        puts ex
      end
    end
  end

  class ExcelUtil
    #�г�excel��process������������
    def self.show_process(path, parser_sym = :ruby)
      case(parser_sym)
      when :ruby
        rows = Automan::WorkbookParser::WorkbookNativeParser.new(path).sheet_rows("process")
      when :ole
        rows = Automan::WorkbookParser::WorkbookOleParser.new(path).sheet_rows("process")
      else
				raise "Automan.config.excel_parser = #{parser_sym}, not valid"
      end
      
      result = []
      rows.each{|r|
        c = []
        r.cells.each{|e|
          c<<e.value
        }
        result << c*"|"
      }
      puts result*"\r\n"
      return nil
    end
  end

  require 'Win32API'

  class Cursor
    MOUSEEVENTF_ABSOLUTE=32768
    MOUSEEVENTF_MOVE=1
    M0USEEVENTF_LEFTDOWN=2
    MOUSEEVENTF_LEFTUP=4
    def initialize
      @getCursorPos=Win32API.new("user32","GetCursorPos",['P'],'V')
      @setCursorPos=Win32API.new("user32","SetCursorPos",['i']*2,'V')
      @mouse_event=Win32API.new("user32","mouse_event",['L']*5,'V')
    end
    def pos
      lpPoint ="\0"*8
      @getCursorPos.Call(lpPoint)
      x, y   =   lpPoint.unpack("LL")
      Point.new(x, y)
    end
    def pos=(p)
      @setCursorPos.Call(p.x, p.y)
    end
    def leftdown
      @mouse_event.Call(M0USEEVENTF_LEFTDOWN,0,0,0,0)
    end
    def leftup
      @mouse_event.Call(MOUSEEVENTF_LEFTUP,0,0,0,0)
    end
    def click
      leftdown
      leftup
    end
  end

end

