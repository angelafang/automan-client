module CommonOperation
  def capture
    raise NotImplementedError.new("#{self.class.name}##{caller(0)[0]=~/:in (.*)/ && $1}�ǳ��󷽷�")
  end
  # �Ҳ���������false
  # �ҵ������������true
  def click_by_image(img_path)
    large = ImageProcess::Bitmap.new(capture)
    small = ImageProcess::Bitmap.new(img_path)
    found = large.find_one(small)
    if(found.nil?)
      return false
    end
    point = found + offset_point
    
    p = Point.new(small.width/2, small.height/2) + point
    cs=Cursor.new
    cs.pos=p
    cs.click
    sleep 0.1   #�ȴ��¼��Ĵ���
    wait
    return true
  end
  def offset_point
    raise NotImplementedError.new("#{self.class.name}##{caller(0)[0]=~/:in (.*)/ && $1}�ǳ��󷽷�")
  end
  #�ȴ�������Ч��
  def wait
    raise NotImplementedError.new("#{self.class.name}##{caller(0)[0]=~/:in (.*)/ && $1}�ǳ��󷽷�")
  end
end

require 'benchmark'
module AEngine
  # All PageModel should derive from this class
  # Support convert from
  class BaseElement
    include CommonOperation
    #��������ݿ��Գ�ʼ������������
    def element
      raise NotImplementedError.new("#{self.class.name}##{caller(0)[0]=~/:in (.*)/ && $1}�ǳ��󷽷�")
    end
    # Tag
    def control
      raise NotImplementedError.new("#{self.class.name}##{caller(0)[0]=~/:in (.*)/ && $1}�ǳ��󷽷�")
    end
    # Children
    def children
      raise NotImplementedError.new("#{self.class.name}##{caller(0)[0]=~/:in (.*)/ && $1}�ǳ��󷽷�")
    end
    def _class
      raise NotImplementedError.new("#{self.class.name}##{caller(0)[0]=~/:in (.*)/ && $1}�ǳ��󷽷�")
    end
    def id
      raise NotImplementedError.new("#{self.class.name}##{caller(0)[0]=~/:in (.*)/ && $1}�ǳ��󷽷�")
    end
    def parent
      raise NotImplementedError.new("#{self.class.name}##{caller(0)[0]=~/:in (.*)/ && $1}�ǳ��󷽷�")
    end
    #�������������ʵ�ֵģ�����ͨ��children�ĵ�������equal��ʵ�֣�TODO
    def _next
      raise NotImplementedError.new("#{self.class.name}##{caller(0)[0]=~/:in (.*)/ && $1}�ǳ��󷽷�")
    end
    #�൱��Html��innerText��Windows��name�������ӽڵ��name
    def _text
      raise NotImplementedError.new("#{self.class.name}##{caller(0)[0]=~/:in (.*)/ && $1}�ǳ��󷽷�")
    end
#    def to_s
#      raise NotImplementedError.new("#{self.class.name}##{caller(0)[0]=~/:in (.*)/ && $1}�ǳ��󷽷�")
#    end
    def get_attribute(name)
      raise NotImplementedError.new("#{self.class.name}##{caller(0)[0]=~/:in (.*)/ && $1} #{name}�ǳ��󷽷�")
    end
    #element: string
    #type: :Id, :ControlName, :ControlName, :All
    def match_element(element, type)
      if(element.empty?)
        raise ArgumentError.new(element)
      end

      case type
      when :Id then
        if(self.id)
          return element.downcase == self.id.downcase
        else
          return false
        end
      when :ControlName then
        if(self.control)
          return element.downcase == self.control.downcase
        else
          return false
        end
      when :ClassName then
        if(self._class)
          return element.downcase == self._class.downcase
        else
          return false
        end
      when :All then
        return true
      else
        raise ArgumentError.new("No such type: #{type}")
      end
    end

    def match_attribute(name, operation, value)      
      actual = self.get_attribute(name)
      if actual.nil? 
        return false
      elsif actual.is_a? String
        return false if actual.empty?
      elsif actual.is_a? Fixnum
        actual = actual.to_s
      end
      case operation
      when "",nil then
        return !actual.empty?
      when "=" then
        return actual.downcase == value.downcase
      when "!=" then
        return actual.downcase != value.downcase
      when "^=" then
        return (actual.downcase=~/^#{value.downcase}/) !=nil
      when "$=" then
        return (actual.downcase=~/#{value.downcase}$/) != nil
      when "*=" then
        return (actual.downcase=~/#{value.downcase}/) !=nil
      else
        raise ArgumentError.new("#{operation} not supported")
      end
    end

    def match_content(operation, param)
      case operation
      when "empty" then
        return children.length == 0
      when "parent" then
        return children.length != 0
      when "has" then
        return Selector.new(self).find(param).current.length != 0
      when "not" then
        return Selector.new(self).find(param).current.length == 0
      when "contains" then
        if(_text)
          trim = param.gsub(/^\'|\'$/,"") #��ͷβ�ĵ����Ŷ�ȥ��
          return (_text=~/#{trim}/) != nil
        else
          return false
        end
      else
        raise ArgumentError.new("#{operation} not supported")
      end
    end

    def find_relatives(operation, param)
      c = Array.new(self.parent.children)
      return nil if c.empty?
      case operation
      when "nth-child" then
        case param
        when "even" then          
          if(c.index(self)%2 != 0)
            return self
          else
            return nil
          end
        when "odd" then
          if(c.index(self)%2 == 0)
            return self
          else
            return nil
          end
        else
          index = 0
          begin
            index = Integer(param)
          rescue
            raise ArgumentError.new("#{param} not supported" )
          end
          if index>=0 && index<c.length
            return (c.index(self) == index)
          else
            return nil
          end
        end
      when "first-child" then
        return (c.index(self) == 0)
      when "last-child" then
        return (c.index(self) == c.length-1)
      when "only-child" then
        if c.length == 1
          return self
        else
          return nil
        end
      else
        raise ArgumentError.new("#{operation} not supported" )
      end
    end

    def get_all_children
      result = []
      queue = self.children
      #�ö���(���ǰ��)����ݹ飬Ŀǰ�ǲ㼶����  
      while(current = queue.shift)
        result << current
        current.children.each{|e| queue.push e }
      end
      
      #������㷨��������ȱ���
      #      while(current = queue.shift)
      #        result << current
      #        temp = current.children
      #        queue = temp.concat(queue)
      #      end
      return result
    end

    def descendant
      collection=[]
      time = Benchmark.realtime {
        collection = get_all_children
      }
      num = collection.length
      AWatir::DebugInfo.save_descendant(num, time)
      return collection
    end

    def siblings
      p = self.parent
      return nil unless p
      c = Array.new(p.children)
      c.delete(self)
      return c
    end
    
    def get_scope_element(scope)
      case scope
      when :Descendant then
        return self.descendant
      when :Child then
        return self.children
      when :Next then
        if self._next
          return Array(self._next)
        else
          return nil
        end
      when :Siblings
        return self.siblings
      when :None
        raise ArgumentError.new("not supported scope #{scope}")
      else
        raise ArgumentError.new("not supported scope #{scope}")
      end
    end

    def self.filter_collection(collection, element, etype)
      if(collection)
        collection.delete_if { |e| !e.match_element(element, etype) }
      else
        return nil
      end
    end

    def get_element_by_id(id, scope)
      collection = get_scope_element(scope)
      self.class.filter_collection(collection, id, :Id)
      return collection
    end
    def get_element_by_control_name(name, scope)
      collection = get_scope_element(scope)
      self.class.filter_collection(collection, name, :ControlName)
      return collection
    end
    def get_element_by_class_name(name, scope)
      collection = get_scope_element(scope)
      self.class.filter_collection(collection, name, :ClassName)
      return collection
    end     
    def log_info
      @log_info||=BaseElementLogInfo.new
    end
    def log_info= value
      @log_info = value
    end
    def self.empty
      raise NotImplementedError.new("#{self.class.name}##{caller(0)[0]=~/:in (.*)/ && $1}�ǳ��󷽷�")
    end
    def empty?
      raise NotImplementedError.new("#{self.class.name}##{caller(0)[0]=~/:in (.*)/ && $1}�ǳ��󷽷�")
    end
  end

  class BaseElementLogInfo
    #Copy instance and remove reference
    def dup
      result = self.class.new
      result.action_history = self.action_history.dup
      result.selector_history = self.selector_history.dup
      result.empty_history = self.empty_history.dup
      return result
    end

    def self.filter_action(options)
      result = {}
      unless(options.empty?)
        result.store(:name, options[:name]) if(options.has_key?(:name))
        result.store(:description, options[:description]) if (options.has_key?(:description))
      end
      return result;
    end

    def selector_history
      @selector_history||=[]
    end
    def selector_history= value
      @selector_history = value
    end
    def action_history
      @action_history||=[]
    end
    def action_history= value
      @action_history = value
    end
    def empty_history
      @empty_history||=[]
    end
    def empty_history= value
      @empty_history = value
    end

  end

  

  class ModelArray < Array
    def [](index)
      success = true
      result = nil
      selector = ""
      if index.is_a? Hash
        if(index[:html])
          list = select{|e|  e.current.array_search_html.include?(index[:html]) }
          result = list[0]
          selector = ":html=>\"#{index[:html]}\""
        elsif(index[:text])
          list = select{|e|  e.current.array_search_text.include?(index[:text]) }
          result = list[0]
          selector = ":text=>\"#{index[:text]}\""
        end
      elsif index.is_a? String
        list = select{|e|  e.current.array_search_text.include?(index) }
        result = list[0]
        selector = "\"#{index}\""
      else
        result = super
        selector = index
      end
      if(result.nil?)
        success = false
        #�Ҳ�����ʱ����empty model����
        m = super(0)
        e = m.current.class.empty
        e.log_info = m.current.log_info.dup
        result = Model.create(m.class, e, m.parent, "this is fake selector for empty model")
      end
      unless(result.nil?)
        if(result.current.log_info.selector_history.last.match(/^\[.+\]$/))
          result.current.log_info.selector_history.pop
          result.current.log_info.empty_history.pop
        end
        result.current.log_info.selector_history << "[#{selector}]"
        result.current.log_info.empty_history << result.empty?
        result.current.log_info.action_history << {}
      end
      unless(success)
        AWatir::Logger.log_find_model_array_fail(result, selector, length)
      end
      return result
    end
    def length
      result = super
      if(result==1)
        result = 0 if at(0).empty?
      end
      return result
    end
    alias size length
  end
  class ElementArray < Array
    def [](index)
      success = true
      result = nil
      selector = ""
      if index.is_a? Hash
        if(index[:html])
          list = select{|e|  e.array_search_html.include?(index[:html]) }
          result = list[0]
          selector = ":html=>\"#{index[:html]}\""
        elsif(index[:text])
          list = select{|e|  e.array_search_text.include?(index[:text]) }
          result = list[0]
          selector = ":text=>\"#{index[:text]}\""
        end
      elsif index.is_a? String
        list = select{|e|  e.array_search_text.include?(index) }
        result = list[0]
        selector = "\"#{index}\""
      else
        result = super
        selector = index
      end
      if(result.nil?)
        success = false
        #�Ҳ�����ʱ����empty model����
        element = super(0)
        empty = element.class.empty
        empty.log_info = element.log_info.dup
        result = empty
      end
      unless(result.nil?)
        if(result.log_info.selector_history.last.match(/^\[.+\]$/))
          result.log_info.selector_history.pop
          result.log_info.empty_history.pop
        end
        result.log_info.selector_history << "[#{selector}]"
        result.log_info.empty_history << result.empty?
        result.log_info.action_history << {}
      end
      unless(success)
        AWatir::Logger.log_find_element_array_fail(result, selector, length)
      end
      return result
    end
    def length
      result = super
      if(result==1)
        result = 0 if at(0).empty?
      end
      return result
    end
    alias size length
  end

  class Model
    @current=nil
    attr_reader :parent
    attr_reader :selector

    def empty?
      return @current.empty?
    end
    alias :exist? empty?

    def initialize(base_element, parent, selector)
      @current = base_element
      @parent = parent
      @selector = selector
    end
    def find_elements(type, selector,options={})
      list = []
      # type.new(element) ������ BaseElement����������еķ�������������
      internal_find_elements(selector,options).each { |e|
        typed_ele = type.new(e.element)
        typed_ele.log_info = e.log_info.dup
        list << typed_ele
      }
      return ElementArray.new(list)
    end
    # find_element(AWatir::AElement, "#id", :name=>"standard_login", :description=>"��׼��¼")
    def find_element(type, selector, options={})
      eles = internal_find_elements(selector, options)
      return nil if(eles.length == 0)
      # type.new(element) ������ BaseElement����������еķ�������������
      target_ele = eles.first
      typed_ele = type.new(target_ele.element)
      typed_ele.log_info = target_ele.log_info.dup
      return typed_ele
    end
    def find_model(type,selector,options={})
      result = internal_find_models(type,selector,options)
      if (result.length != 0)
        return result.first
      end
    end
    def find_models(type,selector,options={})
      return ModelArray.new(internal_find_models(type,selector,options))
    end
    def self.create(mtype, e, parent, selector)
      return mtype.new(e, parent, selector)
    end
    def internal_find_models(type, selector, options={})
      result = []
      #look for model elements
      elements = internal_find_elements(selector, options)

      # TODO cache����������������Ҫ����������Ӳ���
      # ÿһ��find�������cache������һ����selector�ͷ���һ����Ԫ��

      elements.each { |e| result.concat(Array( self.class.create(type, e, self, selector))) }

      return result
    end
    #ά����ǰModel��BaseElement
    def current
      return @current
    end

    # ˽�з���
    def internal_find_elements(selector, options={})
      actions = BaseElementLogInfo.filter_action(options)
      
      result=[]
      # TODO cache����������������Ҫ����������Ӳ���
      time = Benchmark.realtime {
        # perf��־�����￪ʼ
        # ÿһ��find�������cache������һ����selector�ͷ���һ����Ԫ��
        if(empty?)
          #��empty���ҳ�����Ԫ�ػ���empty
          result = current.class.empty
        else
          result = Selector.new(current).find(selector).current
          #�Ҳ���Ԫ��ʱ����empty����
          result = current.class.empty if(result.empty?)
        end
        result = Array(result)
      
        result.each {|r|
          r.log_info = current.log_info.dup
          r.log_info.selector_history << selector
          r.log_info.action_history << actions
          r.log_info.empty_history << r.empty?
        }
        # ��cache
        # perf��־���������
      }
      AWatir::DebugInfo.save_general_find(time, result[0].log_info, result[0])

      return result
    end
    private :internal_find_elements
  end
end