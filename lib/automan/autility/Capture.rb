require 'rubygems'
require 'Win32API'
require 'dl/import'

# ��ͼ���ܵ�Windows api֧��
module Screenshot
  extend DL::Importable

  dlload "kernel32.dll","user32.dll","gdi32.dll"

  user32 = DL.dlopen("user32")
  @@enum_windows = user32['EnumWindows', 'IPL']
  @@get_window_text_length = user32['GetWindowTextLengthA' ,'LI' ]
  @@get_window_text = user32['GetWindowTextA', 'iLsL' ]
  
  sDllFile = File.dirname(__FILE__)+"/JpgDll.dll"
  @@jpg = Win32API.new(sDllFile,"BmpToJpg",["p","p"],"l")

  silence_warnings {
    SRCCOPY = 0xCC0020
    GMEM_FIXED = 0
    DIB_RGB_COLORS = 0
  }
  typealias "HBITMAP","unsigned int"
  typealias "LPRECT","unsigned int*"

  extern "HWND GetForegroundWindow()"
  extern "HWND GetDesktopWindow()"
  extern "BOOL GetWindowRect(HWND, LPRECT)"
  extern "BOOL GetClientRect(HWND, LPRECT)"
  extern "HDC GetDC(HWND)"
  extern "HDC GetWindowDC(int)"
  extern "HDC CreateCompatibleDC(HDC)"
  extern "int GetDeviceCaps(HDC, int)"
  extern "HBITMAP CreateCompatibleBitmap(HDC, int, int)"
  extern "long SelectObject(HDC, HBITMAP)"
  extern "long BitBlt(HDC, long, long, long, long, HDC, long, long, long)"
  extern "void* GlobalAlloc(long, long)"
  extern "void* GlobalLock(void*)"
  extern "long GetDIBits(HDC, HBITMAP, long, long, void*, void*, long)"
  extern "long GlobalUnlock(void*)"
  extern "long GlobalFree(void*)"
  extern "long DeleteObject(unsigned long)"
  extern "long DeleteDC(HDC)"
  extern "long ReleaseDC(long, HDC)"
  extern "BOOL SetForegroundWindow(HWND)"

  module_function
  # ��ȡһ������ĵײ�ʵ��
  # @return [Array] [width, height, rawData]
  def capture(hScreenDC, x1, y1, x2, y2)
    w = x2-x1
    h = y2-y1

    #���㲹��
    fill_pix = 0 #����Ҫ��������
    if(w%4>0)
      fill_pix = (4-(w%4))
    end
    fill_zero_line = fill_pix*3 % 4 #ÿ��Ҫ�Ӷ��ٸ����ֽ�"\000"

    # Reserve some memory
    hmemDC = createCompatibleDC(hScreenDC)
    hmemBM = createCompatibleBitmap(hScreenDC, w+fill_pix, h)
    selectObject(hmemDC, hmemBM)
    bitBlt(hmemDC, 0, 0, w+fill_pix, h, hScreenDC, x1, y1, SRCCOPY)
    hpxldata = globalAlloc(GMEM_FIXED, (w+fill_pix) * h * 3)
    lpvpxldata = globalLock(hpxldata)

    # Bitmap header
    # http://www.fortunecity.com/skyscraper/windows/364/bmpffrmt.html

    # BITMAPINFOHEADER λͼ�ļ���Ϣͷ
    bmInfo = [40, w, h, 1, 24, 0, 0, 0, 0, 0, 0].pack('LLLSSLLLLLL').to_ptr

    getDIBits(hmemDC, hmemBM, 0, h, lpvpxldata, bmInfo, DIB_RGB_COLORS)

    # BITMAPFILEHEADER λͼ�ļ��ļ�ͷ
    bmFileHeader = [
      19778,
      (w * h * 3) + 40 + 14 +fill_zero_line*h,
      0,
      0,
      54
    ].pack('SLSSL').to_ptr

    data = bmFileHeader.to_s(14) + bmInfo.to_s(40) + lpvpxldata.to_s(h * (w*3+fill_zero_line)) # +"\000"*fill_zero_line*h

    globalUnlock(hpxldata)
    globalFree(hpxldata)
    deleteObject(hmemBM)
    deleteDC(hmemDC)
    releaseDC(0, hScreenDC)

    return [w, h, data]
  end

  # ͨ��hwnd����ȡ����
  def capture_hwnd(hwnd)
    hScreenDC = getDC(hwnd)

    # Find the dimensions of the window
    rect = DL.malloc(DL.sizeof('LLLL'))
    getClientRect(hwnd, rect)
    x1, y1, x2, y2 = rect.to_a('LLLL')

    capture(hScreenDC, x1, y1, x2, y2)
  end

  # �ض��㴰��
  def foreground
    hwnd = getForegroundWindow
    capture_hwnd(hwnd)
  end

  # ����������
  def desktop
    hwnd = getDesktopWindow
    capture_hwnd(hwnd)
  end

  #��һ������
  # @param [Fixnum] x �����ͼ��ŵ�λ�ã��������Ļ���϶����x����
  # @param [Fixnum] y �����ͼ��ŵ�λ�ã��������Ļ���϶����y����
  # @param [Fixnum] width Ҫ������Ŀ��
  # @param [Fixnum] height Ҫ������Ŀ��
  def area(x, y, width, height)
    hwnd = getDesktopWindow
    hScreenDC = getDC(hwnd)
    capture(hScreenDC, x, y, x+width, y+height)
  end

  # ����title���ش���
  # @param [Fixnum] delay �������Ƶ�ǰ���ĵȴ���Чʱ��(s)
  def window(title_query, delay=0.1)
    hwnd = nil

    proc = DL.callback('ILL') do |curr_hwnd, lparam|
      textLength, a = @@get_window_text_length.call(curr_hwnd)
      captionBuffer = " " * (textLength+1)
      t, textCaption = @@get_window_text.call(curr_hwnd, captionBuffer, textLength+1)
      text = textCaption[1].to_s
      if text =~ title_query
        hwnd = curr_hwnd
        0
      else
        1
      end
    end
    @@enum_windows.call(proc, 0)

    raise "Couldn't find window with title matching #{title_query}" if hwnd.nil?
    setForegroundWindow(hwnd)
    sleep(delay)
    capture_hwnd(hwnd)
  end

  # ��bmpͼת��Ϊjpgͼ
  # @return [0, 1] 1����ת���ɹ���0����ת��ʧ��
  def convert_to_jpg(bmp_path, jpg_path)
    @@jpg.call(bmp_path,jpg_path)
  end
end

# ����Ļ��ͼ
module CaptureScreen

  # ����ǰ�����ͼ����Ϊһ��JPG��ͼƬ
  # @param [String] capture_filename ��ͼ�ļ�����������nilʱ��ʹ��"C:\\screenimg\\screenimg%y%m%d\\"
  # @param [String] capture_path ��ͼ�ļ�·����������nilʱ��ʹ��"img_%Y_%m_%d_%H_%M_%S.jpg"
  # @return [String] ��ͼ�����·��
  def captureDesktopJPG(capture_filename=nil,capture_path=nil)
    begin
      if  not File.directory? 'C:\\screenimg'
        FileUtils.makedirs('C:\\screenimg')
      end
      if not capture_filename.nil?
        capture_filename=capture_filename.gsub(/[\/\\<>\*\"\|\?]/,"_")
      end
      str = Time.now.strftime("%y%m%d")
      file_trace = 'C:\\screenimg\\screenimg'+ str
      #      puts file_trace
      if  not File.directory? file_trace
        FileUtils.makedirs(file_trace)
      end
      #      path_config = YAML.load(File.open(DATA_FILE))
      if capture_path.nil?
        #        path = path_config["path"]["default"]
        path = file_trace
      else
        #        path = path_config["path"][capture_path]
      end
      sBmpFileName = path +"\\tmp.bmp"
      path_home = capture_filename ? "\\#{capture_filename}":"\\img"
      sJpgFileName = path + path_home + Time.now.strftime("_%Y_%m_%d_%H_%M_%S") + ".jpg"
      width, height, bmp = Screenshot.desktop
      File.open(sBmpFileName,"wb"){|bmpFile|     bmpFile.print(bmp) }
      Screenshot.convert_to_jpg(sBmpFileName,sJpgFileName)
      File.delete(sBmpFileName)
      puts "�����ɹ����μ�#{sJpgFileName.gsub("\\","/")}"
      return sJpgFileName
    rescue
      raise "������������"
    end
  end

  # ����Ļ�ϵķ��������ͼ
  # @param (see Screenshot#area)
  # @param [String] bmp_full_path �����ͼ��ŵ�λ��
  #
  # @return [String] ��ͼ��ŵ�·��
  def captureBMP(x, y, width, height, bmp_full_path="c:\\1.bmp")
    width, height, bmp = Screenshot.area(x, y, width, height)
    File.open(bmp_full_path,"wb"){|bmpFile|     bmpFile.print(bmp) }
    return bmp_full_path
  end
end

# ͼ����
module ImageProcess
  # ����BmpͼƬ����
  class Bitmap    
    # @param [String] bmp_file bmp�ļ�·��
    def initialize(bmp_file)
      raise "�ļ������� - #{bmp_file}" unless File.exist?(bmp_file)
      raw = nil
      File.open(bmp_file,"rb"){|bmpFile|   raw = bmpFile.read}

      #����bmpͼ��
      bfOffBits = raw[10..11].unpack('S')[0]
      gap = raw[28..29].unpack('S')[0] / 8 #һ�����ص�����ֽ�
      assert(gap==3)
      @biWidth = raw[18..21].unpack('L')[0]
      @biHeight = raw[22..25].unpack('L')[0]

      fill_pix = (4-(@biWidth%4))
      fill_zero_line = fill_pix*3 % 4 #ÿ��Ҫ�Ӷ��ٸ����ֽ�"\000"

      start = bfOffBits
      arr_h = []
      for h in 0...@biHeight
        arr_w = HorizontalArray.new
        for w in 0...@biWidth
          arr_w << Pixel.new(raw[start],raw[start+1],raw[start+2])
          start=start+3
        end
        arr_h << arr_w
        start+=fill_zero_line #�����ֽ�
      end
      @pixel_arr = arr_h
    end

    # @return [String] ��automan consoleʹ�ã���ʵ������ʱ����ʾһ��ͼƬ��ASCII������
    def inspect
      result = "\r\n"
      piexl_table.reverse.each{|r| r.each{|p| result << "#{(p.g+p.r+p.b)/3/128}"} ; result<<"\r\n" }
      return result.gsub("1","_").gsub("0","8")
    end
    
    # @return [Fixnum] ͼƬ�Ŀ��
    def width
      @biWidth
    end
    # @return [Fixnum] ͼƬ�ĸ߶�
    def height
      @biHeight
    end
    # @return [Array<HorizontalArray>] ���ص���ɵı�
    def piexl_table
      @pixel_arr
    end

    # ����Сͼ�ڴ�ͼ�ϵ�λ������
    # @param [String] bitmap_small ��С��bmp���ļ�·��
    # @return [Array<Point>] Сͼ�ڴ�ͼ�ϵ�λ�ã����ϵ�Ϊ0,0
    def find(bitmap_small)
      return [-1,-1] if (height<bitmap_small.height) && (width<bitmap_small.width)
      point = []
      for hh in 0..height-1
        #ȡ��һ��
        match_list = (0..width-1).to_a.zip([hh]*(width))
        break if (hh+bitmap_small.height)>height
        for h in hh..(hh+bitmap_small.height-1)
          match_list = piexl_table[h].get_match_list(bitmap_small.piexl_table[h-hh], match_list)
          break if match_list.length==0
        end
        next if match_list.length==0 || match_list[0].length-2<bitmap_small.height
        point.concat(match_list)
      end
      #�����������
      result = []
      return result if point.length==0
      point.each{|p|
        x = p[0]
        y = p[1]
        y = y+bitmap_small.height-1 #������
        y = height-1-y
        noise = 0
        p[2..-1].each{|n|noise+=n}
        result<<{:x=>x,:y=>y,:noise=>noise} #+1�����1��ʼ��
      }
      result = result.sort_by{|r|r[:y]} #ͬʱƥ��ʱ���ȵ��ĸ���
      ret = []
      result.each { |r| ret << Point.new(r[:x], r[:y]) }
      return ret
    end
    
    # ����Сͼ�ڴ�ͼ�ϵ�λ������
    # @param (see ImageProcess#Bitmap#find)
    # @return [Point, nil] Сͼ�ڴ�ͼ�ϵ�λ�ã����ϵ�Ϊ0,0���Ҳ�������nil
    def find_one(bitmap_small)
      result = find(bitmap_small)
      unless result.empty?
        return result[0]
      else
        return nil
      end
    end
    # �жϴ�ͼƬ���Ƿ����СͼƬ    #
    # @param (see ImageProcess#Bitmap#find)
    # @return [true, false] ��ͼƬ�а���СͼƬ����true����ͼƬ�в�����СͼƬ����false
    def contain(bitmap_small)
      result = find(bitmap_small)
      return !result.empty?
    end
  end
  # ���ص�
  # @attr [Fixnum] b ��RBG����ʾ���ص�ֵ��b�ķ�Χ[0, 255]
  # @attr [Fixnum] g ��RBG����ʾ���ص�ֵ��g�ķ�Χ[0, 255]
  # @attr [Fixnum] r ��RBG����ʾ���ص�ֵ��r�ķ�Χ[0, 255]
  class Pixel < Struct.new(:b, :g, :r)
  end
  # BmpͼƬ�У�һ�����ص�
  class HorizontalArray < Array
    Threshold = 1200 #��ֵ������ (20**2)*3

    # ���ص���ƥ��Ľ��
    #
    # @param [HorizontalArray] arr_small СͼƬ��Ҫ���жԱȵ�ĳһ��
    # @param [Array<Fixnum>] check_positions СͼƬ��Ҫ���жԱȵ�һЩ�㣬[x, y , noise1, noise2, noise3, noise4]����(x,y)�������½���ƥ�䣬��ƥ������Ϊnoise��¼���������
    #
    # @return [Array<Fixnum>] ��noise����ķ�Χ�ڣ���ƥ�������ӵ�check_positions��Ԫ�غ���
    def get_match_list(arr_small, check_positions)
      if arr_small.nil?
        raise "arr_small can't be nil"
      end
      list = []
      return list if length<arr_small.length
      check_positions.each{|match|
        index = match[0]
        next if length<(index+arr_small.length)
        match_record = self[index..index+arr_small.length-1].match(arr_small)
        if(match_record>=0)
          list << (match<<match_record)
        end
      }
      return list
    end

    # ����������ص�ƥ��̶�
    # @param [HorizontalArray, Array<Pixel>] arr
    # @return [Fixnum] ���ʾ��ȫƥ�䣬������ʾ�����Ĵ�С��-1��ʾ��ƥ��
    def match(arr)
      if(length == arr.length)
        thre = Threshold * length
        noise = 0
        for i in 0..length-1
          current = (self[i].r-arr[i].r)**2+(self[i].g-arr[i].g)**2+(self[i].b-arr[i].b)**2
          noise = noise+current
          return -1 if(noise>thre)
        end
        return noise
      else
        return -1
      end
    end
  end
end