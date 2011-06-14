module AWatir
  include AEngine

  class HtmlModel < Model
    #����ǰIEת����html_model_type��������cast����
    def convert(html_model_type)
      result = IEModel.new(IEElement.new(ie))._internal_cast(html_model_type)
      Logger.log_model_success(result)
      DebugInfo.save_cast(html_model_type)
      return result
    end
    
    def automan_methods
      return self.class.instance_methods-HtmlModel.instance_methods
    end

    #����Ǹ�irb�õģ����Գ�����Ϣ��
    def inspect
      element = self.current
      return "\r\n#{self.class}\r\n#{element.inspect}"
    end
    
    def close
      IEModel.new(IEElement.new(ie)).close
    end
    def ie
      #current.ie
      current.element.ie
    end
    def exist?
      current.exist?
    end
    def empty?
      current.empty?
    end
    #��ȡģ����ı�inner_text���ԡ�
    #@return [String] ����inner_text����ֵ
    #@example  page.sub_model.text
    def text
      current.text
    end
    #ģ��Ľ�ͼ�������ܽ�ģ�龫ȷ�ؽ�������
    #@return [String] ���ؽ�ͼ֮���ͼƬ���λ��
    #@example  page.sub_model.capture
    def capture
      current.capture
    end
    def find_element(type, selector, options={})
      result = nil
      if /^\:/=~selector  #����һ�η�ѡ��ѡ���þɵĲ��ҷ��������µ�
        #�ɵĲ��ҷ�ʽ����֧��
        raise "��֧��key value�ԣ���ʹ��selector��ʽ��λԪ�أ�"
      else
        result = super
      end
      
      return result
    end
  end

  class HtmlRootModel < HtmlModel

  end
  
  class IEModel < Model
    def initialize(ie_element)
      super(ie_element, nil, nil)
    end
    #��һ���µ�IE����
    #@param [String] url ��IE��url����
    #@return [IEModel] ����һ��IEModel��ʵ��
    #@IEModel.start("www.google.com")
    def self.start(url)
      result = self.new(IEElement.create(Watir::IE.start(url)))
      if Automan.config.ie_max
        result.maximize
      end
      Logger.log_ie_success(url)
      return result
    end
    #��ǰ�򿪶��IEʱ����Ҫ��ժ���󶨣����ض���IE�½��в���
    #@param [String] url ��Ҫ���󶨵�IE��url,֧��������ʽ
    #@return [IEModel]����һ��IEModel��ʵ��
    #@example ie=IEModel.attach(/msn/)
    def self.attach(url)
      result = self.new(IEElement.create(Watir::IE.attach(:url, url)))
      if Automan.config.ie_max
        result.maximize
      end
      Logger.log_ie_success(url, result)
      return result
    end
    #�Ե�ǰ��IE�½���ˢ��
    #@example ie.refresh
    def refresh
      ie = @current.element
      ie.refresh
      Logger.log_ie_success
    end
    #��ȡ��ǰ���д򿪵�ie
    #@return [Array] ����Array����IEModel��ʵ��
    #@example  IEModel.get_all_ies
    def self.get_all_ies
      list = []
      Watir::IE.each { |ie| list << self.new(IEElement.new(ie)) }
      return list
    end
    #��ȡ�û�����������ie,����IEModel.start��IEModel.attach
    #@return [Array] ����Array����IEModel��ʵ��
    #@example  IEModel.get_ies
    def self.get_ies
      list = []
      IEElement.get_internal_ies.each { |ie| list << self.new(ie) }
      return list
    end
    #����ǰIEת��ָ����url
    #@param [String] url ��Ҫ�����url
    #@example  ie.goto("www.google.com")
    def goto(url)
      ie = @current.element
      ie.goto(url)
      Logger.log_ie_success(url)
    end
    # Watir��bug��close��ʱ��֧��IE8�Ķ�tabģʽ
    #�رյ�ǰie
    #@example  ie.close
    def close      
      @current.close # Watir��bug��close��ʱ��֧��IE8�Ķ�tabģʽ
      Logger.log_ie_success
    end
    #�����������IE�����Զ���last_open��IE����IE hash
    #@return [IEModel] ����IEModel��ʵ��
    #@example IEModel.last_ie
    def self.last_ie
      result = get_all_ies.last
      if(result)
        IEHash.instance.store(result.current)
        if Automan.config.ie_max
          result.maximize #���Ӷ�last_ie���Զ���󻯣���attach��ͬ��Ч����
        end
        result.current.element.wait #last_ieҲҪȷ��������ɡ���watir��attach��start�߼���ͬ
        Logger.log_ie_success(nil, result)
        return result
      else
        return nil
      end
    end
    #����ǰIEת����html_model_type
    #@param [HtmlModel] html_model_type �����ڶ�������Page
    #@return [HtmlModel] ���ؾ���Page���ͣ�html_model_type����ʵ��
    #@example page=ie.cast(HtmlModel)
    def cast(html_model_type)
      result = _internal_cast(html_model_type)
      Logger.log_model_success(result)
      DebugInfo.save_cast(html_model_type)
      return result
    end
    def _internal_cast(html_model_type)
      ie=@current.element
      ie.wait #��ť�Ѿ��ڵ�������wait�ˣ������wait��Ϊ��click_no_wait���ֵ�������ҳ��ˢ�µ����
      #ָ��ie��ֱ��child��˭
      html = HtmlHelper.get_html_from_document(ie.document)      
      a_ole_element=AOleElement.new(ie, nil, html) #���ڵ��container��nil
      return html_model_type.new(AElement.new(a_ole_element), self, nil)
    end
    #����ǰIE���
    #@example ie.maximize
    def maximize
      ie = @current.element
      ie.maximize
    end
    #��ǰ�򿪶��IEʱ����Ҫ�ض���IE�ŵ���ǰ��
    #@return [Boolean] true
    #@example ie.bring_to_front = > true
    def bring_to_front
      hwnd = @current.hwnd
      win_object = WinObject.new
      win_object.makeWindowActive(hwnd)
      win_object.setWindowTop(hwnd)
      return true
    end
    #��ȡ��ǰie��url
    #@return [String] ����ie��url
    #@example ie.url
    def url
      return @current.url
    end
    #��ȡ��ǰmodel��inner_text��Ϣ
    #@return [String] ����model��inner_text��Ϣ
    #@example ie.submodel.text
    def text
      #      ie = @current.element
      #      return ie.document.body.innerText
      return self._internal_cast(HtmlModel).current._text
    end
    #��ȡ��ǰie��title
    #@return [String] ����ie��title
    #@example ie.title
    def title
      return @current.title
    end

  end

  class IEHash < Hash
    include Singleton	
    
    def store(ie_element)
      unless(has_key?(ie_element.hwnd)) #��ֹattach�ظ��ġ�
        super(ie_element.hwnd, ie_element)
        @array << ie_element.hwnd
      end
    end
    def delete(ie_element)
      if(has_key?(ie_element.hwnd))
        super(ie_element.hwnd)
        @array.delete(ie_element.hwnd)
      else
        TestRunLogger.instance.log_debug_message("[Debug]���IE����start��attach�ģ��������ڲ�IE���ά��������")
      end
    end
    def last
      if(has_key?(@array.last))
        return fetch(@array.last)
      else
        return nil
      end
    end
    private
    def initialize
      @array = []
    end
  end

  class IEElement < BaseElement
    @operator=nil
    def initialize(watir_ie)
      #      @operator = Watir::IE.new(watir_ie)
      @operator = watir_ie
    end
    def self.create(watir_ie)
      result = new(watir_ie)
      IEHash.instance.store result
      return result
    end
    #Ԫ���ݣ���Ӧ����Watir::IE
    def element
      return @operator
    end
    def hwnd
      return @operator.hwnd
    end
    #��ȡ��ǰ��ʵ��IE��title
    #@return [String] ���ص�ǰ��ʵ��IE��title
    #@example ie.title
    def title
      return @operator.title
    end
    #�رյ�ǰ��ʵ��IE����
    #@example ie.close
    def close
      IEHash.instance.delete self
      @operator.close #bug�����ܹر�ieʧ�ܣ�
    end
    def self.last_ie
      return IEHash.instance.last
    end
    def self.get_internal_ies
      return IEHash.instance.values
    end
    #��ȡ��ǰ��ʵ��IE��url
    #@return [String] ���ص�ǰ��ʵ��IE��url
    #@example ie.url
    def url
      return @operator.url
    end
  end

  class AOleElement
    #��Ӧ��ie
    @_ie = nil
    #һ���������ie��iframe/frame����frame
    @_container = nil
    #Ԫ���ݣ���Ӧ����ole_object
    @elementT = nil
    def initialize(ie, container, ole_object, empty = false)
      @_ie=ie
      #��ʾ���׵�a_ole_element
      @_container=container
      @elementT=ole_object
      @empty = empty
    end
    #��Ӧ��ie
    def ie
      return @_ie
    end
    #һ���������ie��iframe/frame����frame
    def container
      return @_container
    end
    #Ԫ���ݣ���Ӧ����ole_object
    def element
      return @elementT
    end

    def empty?
      return @empty
    end

    @@empty_instance = self.new(nil, nil, nil, true);
    def self.empty
      return @@empty_instance
    end
  end

  #AutoMan��ܶ���Ŀؼ�����
  class AElement < BaseElement
    #Ԫ���ݣ���Ӧ����AOleElement
    @elementAoe = nil
    #������dom element
    @elementD = nil
    #�����AElement
    attr_accessor :operator;

    #����ĳ�ʼ��������Ϊ��ʵ�ڲ���ȷ�������ˣ�����FindElement(AElement,"selector")
    def initialize(a_ole_element)
      assert a_ole_element
      @elementAoe = a_ole_element
      @elementD = @elementAoe.element
      @ie = @elementAoe.ie
      #      @operator = Watir::Element.new(a_ole_element.element)
    end

    @@empty_instance = self.new(AOleElement.empty)
    def self.empty
      return @@empty_instance
    end
    #�жϿؼ��Ƿ�Ϊ��
    #@return [Boolean] true:�ؼ�Ϊ�գ�false:�ؼ���Ϊ��
    #@example page.dft_login.empty? => true
    def empty?
      return self.element.equal?(self.class.empty.element)
    end
    #�жϿؼ��Ƿ����
    #@return [Boolean] true:�ؼ����ڣ�false:�ؼ�������
    #@example page.dft_login.exist? => false
    def exist?
      return !empty?
    end

    #�����ǲ��ҷ���
    #Ԫ���ݣ���Ӧ����AOleElement
    def element
      return @elementAoe
    end
    # Tag
    def control
      @elementD.nodeName
    end

    #�жϿؼ��Ƿ�ɼ�
    #@return [Boolean] true �ɼ� false:���ɼ�
    #@example page.dft_buy.visible
    def visible
      # Now iterate up the DOM element tree and return false if any
      # parent element isn't visible or is disabled.
      object = @elementD
      while object
        begin
          if object.currentstyle.invoke('visibility') =~ /^hidden$/i
            return false
          end
          if object.currentstyle.invoke('display') =~ /^none$/i
            return false
          end
          if object.invoke('isDisabled')
            return false
          end
        rescue WIN32OLERuntimeError
        end
        object = object.parentElement
      end
      true
    end
      
    # Children
    def children
      arr=[]
      first = @elementD.firstChild
      if(first)
        while first
          # @elementD.childNodes.each{|e| �Ļ�����һ��
          arr << AElement.new(AOleElement.new(@elementAoe.ie, @elementAoe.container, first)) 
          first = first.nextSibling
        end
      else
        d_name = control.downcase
        if d_name == "iframe" || d_name == "frame"
          frame =  @elementD.contentWindow
          docu = HtmlHelper.get_document_in_frame(frame)
          if(docu)
            html = HtmlHelper.get_html_from_document(docu)
            #TODO ˭��container
            container = @elementAoe
            arr << AElement.new(AOleElement.new(@elementAoe.ie, container, html))
          end
        end
      end
      return arr
    end

    #aoe_element��ǰͬ��ڵ�aoe
    #ole��ǰ�ڵ�ole
    def get_element_by_tag_in_frame(name, ole, aoe_element)
      arr = []
      if(ole.nodename && ole.nodename.to_s.downcase =~ /^i?frame$/)        
        iframe = [ole]
      else
        iframe = ole.getElementsByTagName("iframe")
        frame = ole.getElementsByTagName("frame")
        i_frame = frame.length
      end
      i_iframe = iframe.length
      if(i_iframe==0 && i_frame==0)
        return arr
      else
        if(i_iframe==0)
          iframe = frame #ֻͳ��һ��
        end
        iframe.each{|f|
          fr = f.contentWindow
          docu = HtmlHelper.get_document_in_frame(fr)
          c = AOleElement.new(aoe_element.ie, aoe_element.container, f)
          if(docu)
            html = HtmlHelper.get_html_from_document(docu)
            #TODO ˭��container
            oles = html.getElementsByTagName(name)
            oles.each{|o|
              arr << AElement.new(AOleElement.new(aoe_element.ie, c, o))
            }
            arr.concat get_element_by_tag_in_frame(name,html,AOleElement.new(aoe_element.ie, c, html))
          end
        }
        return arr
      end
    end
    
    def get_element_by_control_name(name, scope)
      if(scope.eql?(:Descendant))
        begin
          ole = self.element.element
          oles = ole.getElementsByTagName(name)
          arr = []
          oles.each{|o|
            #��û�мӽ�ȥiframe�µ�ͬtag
            arr << AElement.new(AOleElement.new(@elementAoe.ie, @elementAoe.container, o))
          }
          frame_arr = get_element_by_tag_in_frame(name,ole,@elementAoe)
          return arr.concat(frame_arr)
        rescue => e
          TestRunLogger.instance.log_debug_message("[DEBUG]ץȡgetElementsByTagNameʧ�ܣ�#{e}")
        end
      end
      collection = get_scope_element(scope)
      self.class.filter_collection(collection, name, :ControlName)
      return collection
    end

    def parent
      pnode = @elementD.parentNode
      if(pnode)
        if(pnode.nodeName.downcase != "#document") #��������#document��ֱ�ӷ���parentNode
          return AElement.new(AOleElement.new(@elementAoe.ie, @elementAoe.container, pnode))
        end        
      end
      container = @elementAoe.container
      if(container)
        #�ص�container
        return AElement.new(AOleElement.new(@elementAoe.ie, container.container, container.element))
      else
        return nil
      end
      
    end

    def _text
      if(is_element)
        result = inner_text
      else
        result = get_attribute("NodeValue")
      end
      return result
    end
    #��ȡ�ؼ���inner_text����ֵ
    #@return [String]
    #@example page.dft_buy.text
    def text
      if empty?
        Logger.log_element_empty(self)
        return nil
      end
      result = _text
      Logger.log_operation_success(self)
      return result
    end
    #��ȡ�ؼ���inner_text����ֵ
    #@return [String]
    #@example page.dft_buy.inner_text
    def inner_text
      return nil if empty?
      @elementD.innerText
    end
    #��ȡ�ؼ���inner_html����ֵ
    #@return [String]
    #@example page.dft_buy.inner_html
    def inner_html
      return nil if empty?
      @elementD.innerHtml
    end
    #��ȡ�ؼ���outer_html����ֵ
    #@return [String]
    #@example page.dft_buy.outer_html
    def outer_html
      return nil if empty?
      begin
        #        Iconv.conv("GBK//IGNORE","UTF-8//IGNORE", @elementD.outerHtml)
        @elementD.outerHtml
      rescue
        #TODO ��log
        return nil
      end
    end

    def get_attribute(name)
      return nil if empty?
      #����һ��style����Ϊ��style��֧��
      if(name.downcase == "style")
        begin
          style = @elementD.invoke("style")
          result = style.csstext
          return result
        rescue
          #TODO: ��log
          return nil
        end
      else
        #��class��classname������html���class
        if(name.downcase == "class") #ISSUE ����classname���������html�ﲻ����
          name = "classname"
        end

        begin
          result = @elementD.invoke(name)
          return result
        rescue
          #TODO: ��log
          return nil
        end
      end
    end

    #���ҳ����idʱ����bug�����ص�id����string����win32ole����http://favorite.daily.taobao.net/popup/add_collection.htm?id=1600052554&itemtype=1&scjjc=1&nekot=1279180794088
    #�������ַ�ʽ�ƿ���
    def get_attribute_from_list(name)
      atts = @elementD.attributes
      atts.each{|e|
        if(e.nodeName==name)
          return e.nodeValue
        end
      }
      return nil
    end

    #ȡ�ؼ������ԣ�����text, inner_test, inner_html��
    #@param  [String] name �ؼ���������
    #@return [String] �ؼ��������ƶ�Ӧ��ֵ
    #@example property = page.dft_buy.get("class")=> "btn"
    def get(name)
      #�ٳ֣�����html��û��text�������
      if(name.downcase == "text")
        return text #Known issue: �ᵼ��log��Ϣ����ȷ�����Խ��ܣ�
      end
      if empty?
        Logger.log_element_empty(self, name)
        return nil
      else
        result = get_attribute(name)
        if(result.nil?)
          Logger.log_operation_fail(self, name)
          return nil
        else
          Logger.log_operation_success(self, name)
          return result
        end
      end
    end

    def eql?(element)
      return super unless(element)
      is_e = is_element
      unless(is_e^(element.is_element))
        if(is_e)
          return @elementD.sourceIndex == element.element.element.sourceIndex
        else
          if(HtmlHelper.get_current_tag_and_index(self) == HtmlHelper.get_current_tag_and_index(element))
            return parent.eql?(element.parent)
          else
            return false
          end
        end
      else
        return false
      end
    end

    alias == eql?
    
    def _class
      begin
        @elementD.classname
      rescue
        #TODO ��log
        return nil
      end
    end

    def _next
      if @elementD.nextSibling
        return AElement.new(AOleElement.new(@elementAoe.ie, @elementAoe.container, @elementD.nextSibling))
      else
        return nil
      end
    end
    #��ȡ�ؼ���id����ֵ
    #@return [String]
    #@example page.dft_buy.id => "kw"
    def id
      begin
        result = @elementD.Id
        unless (result.is_a? String)
          result = get_attribute_from_list("id")
        end
        return result
      rescue
        #TODO log here
        return nil
      end
    end

    #��һ��Ԫ�ع������Ӵ�
    #@param [Boolean]  true Ԫ�ػᱻ�������Ӵ��Ķ�����false �ᱻ�������Ӵ��ײ���Ĭ��Ϊtrue
    #@example page.rad_addrId.scrollIntoView
    def scrollIntoView(top = true)
      @elementD.scrollIntoView(top)
      sleep 0.1 #�ȴ��¼�����
      wait
    end
    #�����㶨λ����ǰ�ؼ�
    #@example  page.dft_buy. focus
    def focus
      if empty?
        Logger.log_element_empty(self)
      else
        @elementD.focus
        Logger.log_operation_success(self)
      end
    end
    #ģ����궯���������ؼ����¼�
    #@param [String] name ����¼�
    #@example page.dft_buy. fire_event("onmouseover")
    def fire_event(name)
      if empty?
        Logger.log_element_empty(self)
      else
        @elementD.fireEvent(name)
        Logger.log_operation_success(self, name)
      end
    end
    #�ȴ�IE����
    #@example ie.wait
    def wait
      @ie.wait
    end
    # ȡ�ؼ��ĳ���
    # @return [Fixnum] �ؼ��ĳ���
    # @example page.dft_buy.height => 28
    def height
      return @elementD.offsetHeight
    end
    # ȡ�ؼ��Ŀ��
    # @return [Fixnum] �ؼ��Ŀ��
    # @example page.dft_buy.width => 12
    def width
      return @elementD.offsetWidth
    end
    # ��ȡ�ؼ������ĵ�λ��
    # @return [Point] �ؼ����ĵ㣬�������ʹ��
    # ����ؼ��ڴ����⣬�Զ����ؼ��ƶ���������
    #@example page.dft_login.center_point=> #<struct AWatir::Point x=568, y=161>

    def center_point
      p = offset_point
      x = p.x + width/2
      y = p.y + height/2

      return Point.new(x, y)
    end
    #��ȡ�ؼ������϶����ֵ
    # @return [Point] �ؼ����϶����ֵ�������������ͼʹ��
    # ����ؼ��ڴ����⣬�Զ����ؼ��ƶ���������
    #@example page.dft_login.offset_point=> #<struct AWatir::Point x=568, y=161>
    def offset_point
      if @elementD.offsetWidth.to_i ==0 || @elementD.offsetHeight.to_i ==0
        raise "��Ҫ��ʾ��Ԫ���ڽ����ϲ��ɼ���Ԫ�ص�htmlΪ:#{@elementD.outerHTML}"
      end

      top = @elementD.offsetTop
      left = @elementD.offsetLeft

      parent_ole_obj = @elementD.offsetParent
      while parent_ole_obj.tagName.downcase !="body" && parent_ole_obj.tagName.downcase !="html"
        top += parent_ole_obj.offsetTop
        left += parent_ole_obj.offsetLeft
        parent_ole_obj = parent_ole_obj.offsetParent
      end
      body_ole_obj = parent_ole_obj.document.documentElement
      if  body_ole_obj.clientHeight.to_i == 0
        body_ole_obj = parent_ole_obj.document.body
      end
      top +=body_ole_obj.ClientTop
      left += body_ole_obj.ClientLeft

      top -= body_ole_obj.ScrollTop
      left -= body_ole_obj.ScrollLeft

      right = left + width
      bottom = top + height

      current_width = body_ole_obj.ClientLeft + body_ole_obj.ClientWidth
      current_height =  body_ole_obj.ClientTop + body_ole_obj.ClientHeight
      if (right > current_width || bottom > current_height)
        @elementD.scrollIntoView

        top = @elementD.offsetTop
        left = @elementD.offsetLeft

        parent_ole_obj = @elementD.offsetParent
        while parent_ole_obj.tagName.downcase !="body"
          top += parent_ole_obj.offsetTop
          left += parent_ole_obj.offsetLeft
          parent_ole_obj = parent_ole_obj.offsetParent
        end
        body_ole_obj = parent_ole_obj.document.documentElement

        if  body_ole_obj.clientHeight.to_i == 0
          body_ole_obj = parent_ole_obj.document.body
        end
        top +=body_ole_obj.ClientTop
        left += body_ole_obj.ClientLeft

        top -= body_ole_obj.ScrollTop
        left -= body_ole_obj.ScrollLeft
      end
      x= left
      y= top

      x =  x + @ie.document.parentWindow.screenLeft
      y = y + @ie.document.parentWindow.screenTop

      return Point.new(x+2, y+2) # 2,2����ֵ
    end
    #ģ�����ĵ������
    #@example page.dft_login._doclick

    def _doclick
      p = center_point

      hwnd = @ie.hwnd
      win_object = WinObject.new
      win_object.makeWindowActive(hwnd)
      win_object.setWindowTop(hwnd)

      cs=Cursor.new
      cs.pos=p
      cs.click
      sleep 0.1   #�ȴ��¼��Ĵ���
      @ie.wait
    end
    #�ؼ���ͼ�������ܽ��ؼ���ȷ�ؽ�������
    #@return [String] ���ؽ�ͼ֮���ͼƬ���λ��
    #@example  page.dft_login.capture
    def capture
      if empty?
        Logger.log_element_empty(self)
      else
        hwnd = @ie.hwnd
        win_object = WinObject.new
        win_object.makeWindowActive(hwnd)
        win_object.setWindowTop(hwnd)
        sleep 0.2 #�ȴ��õ�ǰ̨

        path = captureBMP(offset_point.x, offset_point.y, width, height)
        Logger.log_operation_success(self)
        return path
      end
    end

    # ���пؼ��������
    # @example page.dft_login.click
    def click
      if empty?
        Logger.log_element_empty(self)
      else
        @elementD.click
        wait
        Logger.log_operation_success(self)
      end
    end

    #������ͨ�÷���
    #����Ǹ�netbeans�����õ�
    def to_s
      return string_creator.join(",\r\n")
    end

    #����Ǹ�irb�õģ����Գ�����Ϣ��
    def inspect
      if(self.empty?)
        return "Empty Node"
      else
        return "\r\n" + string_creator.join(",\r\n")
      end
    end

    def array_search_text
      if(self.empty?)
        return "Empty Node"
      else
        return self._text.to_s
      end
    end

    def array_search_html
      if(self.empty?)
        return "Empty Node"
      else
        return self.outer_html.to_s
      end
    end

    # ��consoleʹ��
    # @private
    TO_S_SIZE = 15
    # Return an array of current node properties, in a format to be used by the method: to_s
    def string_creator
      n = []
      if(self.empty?)
        n << "Empty Node"
      else
        #      n <<   "type:".ljust(TO_S_SIZE) + self.type.to_s
        n <<   "[�ؼ���]".ljust(TO_S_SIZE) + self.control.to_s

        n << "[�ı�]".ljust(TO_S_SIZE) + self._text.to_s unless (self.is_element)

        n <<   "[ID]".ljust(TO_S_SIZE) + self.id.to_s if (self.id && !self.id.empty?)
        n <<   "[class]".ljust(TO_S_SIZE) + self._class.to_s if (self._class && !self._class.empty?)

        if (self.outer_html && !self.outer_html.empty?)
          before = "[outerHtml]".ljust(TO_S_SIZE) + self.outer_html.to_s
          max_length = 1000
          ommit = "......"
          if(before.length > max_length)
            before = before.slice(0..max_length) + ommit
          end
          n << before
        end
      end
      return n
    end
    private :string_creator
    def is_element
      return control!="#text"
    end

    #��������debug
    def get_properties
      dic = Hash.new
      return dic unless @elementD
      dic.store("TagName", control)
      dic.store("NodeValue", @elementD.nodeValue) if @elementD.nodeValue
      if is_element
        atts = @elementD.attributes
        puts "Retrieving #{atts.length} attributes for current node."
        atts.each do |e|
          if(e.nodeValue && e.nodeValue.to_s!="")
            dic.store(e.nodeName, e.nodeValue)
          end
        end
        style = @elementD.invoke("style")
        if(style)
          csstext = style.csstext
          if(csstext && csstext.to_s!="")
            dic.store("style", csstext)
          end
        end
      end
      return dic
    end
  end

end