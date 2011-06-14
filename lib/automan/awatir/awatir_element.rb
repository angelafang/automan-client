module AWatir
  #�����ؼ����̳�AElement�����з���
  class ATextField < AElement
    #���ֳ�ʼ�������Ǹ�Model��Find����������
    def initialize(a_ole_object)
      super
    end    

    #��ȡ�����ؼ���readonly����ֵ
    #@return [Boolean] true/false
    #@example  readonly_value = page.txt_password.readonly  readonly_value=>true
    def readonly
      @elementD.readonly
    end
    # instance.readonly = true
    # instance.readonly = false
    #�������ؼ���readonly����ֵ��ֵ
    #@param [Boolean] true/false
    #@example  page.txt_password.readonly=true
    def readonly=value
      @elementD.readonly=value
    end
    # �����������ֵ
    #@param [String] value ��Ҫ���������
    #@example page.txt_password.set("Hello!")
    def set(value)
      if(empty?)
        Logger.log_element_empty(self, value)
      else
        begin
          _set(value)
          Logger.log_operation_success(self, value)
        rescue
          Logger.log_operation_fail(self, value)
        end
      end      
    end

    # settings
    def _type_keys
      return true
    end
    def _typingspeed
      return 0.1
    end

    def _set(value)
      @elementD.scrollIntoView
      if _type_keys
	      @elementD.focus
	      @elementD.select
	      @elementD.fireEvent("onSelect")
	      @elementD.fireEvent("onKeyPress")
	      @elementD.value = ""
	      _type_by_character(value)
	      @elementD.fireEvent("onChange")
	      @elementD.fireEvent("onBlur")
	    else
				@elementD.value = value
      end
    end

    # Type the characters in the specified string (value) one by one.
    # It should not be used externally.
    #   * value - string - The string to enter into the text field
    def _type_by_character(value)
      if @elementD.invoke('type') =~ /textarea/i # text areas don't have maxlength
        maxlength = -1
      else
        maxlength = @elementD.maxlength
      end
      
      _characters_in(value, maxlength) do |c|
        sleep _typingspeed
        @elementD.value = @elementD.value.to_s + c
        @elementD.fireEvent("onKeyDown")
        @elementD.fireEvent("onKeyPress")
        @elementD.fireEvent("onKeyUp")
      end
    end

    # Supports double-byte characters
    # @param [String] maxlength �����Զ���ȡmaxlength�ĳ��ȣ���maxlength<0ʱ������ȡ
    def _characters_in(value, maxlength, &blk)
      if RUBY_VERSION =~ /^1\.8/
        index = 0        
        while index < value.length
          len = value[index] > 128 ? 2 : 1
          yield value[index, len]
          maxlength = maxlength - 1
          break if(maxlength==0)
          index += len
        end
      else
        value.each_char{|c|
          yield c
          maxlength = maxlength - 1
          break if(maxlength==0)
        }
      end
    end
  end

  # ATextArea����ATextField�ı���
  ATextArea = ATextField
 
  #�̳�AElement�����з���
  class ALink < AElement
    #���ֳ�ʼ�������Ǹ�Model��Find����������
    def initialize(a_ole_object)
      super
      #��emptyΪtrueʱ��@operator=true����emptyΪfalseʱ��@operator=XXX.new(...)
      @operator = empty? || Watir::Link.new(a_ole_object.ie, :ole_object, a_ole_object.element)
    end

    #���ֳ�ʼ��������ֱ�Ӵ�ie�����ģ�һ����Ҫʵ�֣��Ժ���Բ�����
    def self.create(ie, how, what)
      operator = Watir::Link.new(ie, how, what)
      element_t = AOleElement.new(ie, ie, operator.document)
      instance = self.new(element_t)
      instance.operator = operator
      return instance;
    end

    #�������
    #@example page.lnk_standard_login.click
    def click()
      if(empty?)
        Logger.log_element_empty(self)
      else
        @operator.click
        Logger.log_operation_success(self)
      end  
    end
  end
  
  # Button�ؼ����̳�AElement�����з���
  class AButton < AElement
    #���ֳ�ʼ�������Ǹ�Model��Find����������
    def initialize(a_ole_object)
      super
      #��emptyΪtrueʱ��@operator=true����emptyΪfalseʱ��@operator=XXX.new(...)
      @operator = empty? || Watir::Button.new(a_ole_object.ie, :ole_object, a_ole_object.element)
    end

    #���ֳ�ʼ��������ֱ�Ӵ�ie�����ģ�һ����Ҫʵ�֣��Ժ���Բ�����
    def self.create(ie, how, what)
      operator = Watir::Button.new(ie, how, what)
      element_t = AOleElement.new(ie, ie, operator.ole_object)
      instance = self.new(element_t)
      instance.operator = operator
      return instance;
    end
    #���ܣ�����ؼ�
    # @example  page.btn_login.click
    def click()
      if(empty?)
        Logger.log_element_empty(self)
      else
        @operator.click
        Logger.log_operation_success(self)
      end
    end

  end
  #checkbox��ѡ�򣬼̳�AElement�����з���
  class ACheckBox < AElement
    #���ֳ�ʼ�������Ǹ�Model��Find����������
    def initialize(a_ole_object)
      super
    end

    #�жϿؼ��Ƿ�ѡ��
    #@return [Boolean] true:��ѡ�У�false:δ��ѡ��
    #@example value = page.chk_order.checked
    def checked
      return @elementD.checked
    end
    
    #���CheckBox��ѡ�пؼ�
    #@example  page.chk_order.set
    def set
      if(empty?)
        Logger.log_element_empty(self)
      else
        begin
          set_clear_item(true)
          Logger.log_operation_success(self)
        rescue
          Logger.log_operation_fail(self)
        end
      end
    end

    def set_clear_item(set)
      unless @elementD.checked == set
        @elementD.checked = set
        @elementD.fireEvent("onClick")
        if @elementAoe.container
          @elementAoe.container.wait #TODO ������bug�ġ���û�ж���@elementAoe.container.wait������
        else
          @elementAoe.ie.wait
        end
      end
    end
    private :set_clear_item
    
    #���CheckBox��ȡ����CheckBox��ѡ��
    #@example  page.chk_order.clear
    def clear
      if(empty?)
        Logger.log_element_empty(self)
      else
        begin
          set_clear_item(false)
          Logger.log_operation_success(self)
        rescue
          Logger.log_operation_fail(self)
        end
      end
    end
  end
  
  #Radio�ؼ����ͣ��̳�AElement�����з���
  class ARadio < AElement
    #���ֳ�ʼ�������Ǹ�Model��Find����������
    def initialize(a_ole_object)
      super
      #��emptyΪtrueʱ��@operator=true����emptyΪfalseʱ��@operator=XXX.new(...)
      @operator = empty? || Watir::Radio.new(a_ole_object.ie, :ole_object, a_ole_object.element)
    end

    #���ֳ�ʼ��������ֱ�Ӵ�ie�����ģ�һ����Ҫʵ�֣��Ժ���Բ�����
    def self.create(ie, how, what)
      operator = Watir::Radio.new(ie, how, what)
      element_t = AOleElement.new(ie, ie, operator.ole_object)
      instance = self.new(element_t)
      instance.operator = operator
      return instance;
    end

    #���Radio��ѡ��Radio
    #@example  page.rad_addrId.set
    def set
      if(empty?)
        Logger.log_element_empty(self)
      else
        begin
          @operator.set
          Logger.log_operation_success(self)
        rescue
          Logger.log_operation_fail(self)
        end
      end
    end
    #���Radio��ȡ����Radio��ѡ��
    #@example  page.rad_addrId.clear
    def clear
      if(empty?)
        Logger.log_element_empty(self)
      else        
        begin
          @operator.clear
          Logger.log_operation_success(self)
        rescue
          Logger.log_operation_fail(self)
        end
      end
    end
    #�жϿؼ��Ƿ�ѡ��
    #@return [Boolean] true:��ѡ�У�false:δ��ѡ��
    #@example value =  page.rad_addrId.checked
    # instance.checked => false / true
    def checked
      return @operator.set?
    end
  end
  #SelectList�ؼ����ͣ��̳�AElement�����з���
  class ASelectList < AElement
    #���ֳ�ʼ�������Ǹ�Model��Find����������
    def initialize(a_ole_object)
      super
      #��emptyΪtrueʱ��@operator=true����emptyΪfalseʱ��@operator=XXX.new(...)
      @operator = empty? || Watir::SelectList.new(a_ole_object.ie, :ole_object, a_ole_object.element)
    end

    #���ֳ�ʼ��������ֱ�Ӵ�ie�����ģ�һ����Ҫʵ�֣��Ժ���Բ�����
    def self.create(ie, how, what)
      operator = Watir::SelectList.new(ie, how, what)
      element_t = AOleElement.new(ie, ie, operator.ole_object)
      instance = self.new(element_t)
      instance.operator = operator
      return instance;
    end
    #������ѡ������ѡ��
    #@param [String] value ������Ҫѡ���ѡ������
    #@example  page.lst_addrId.set ("�㽭")
    # instance.set("ѡ��1")
    def set (value)
      if value.is_a? Fixnum
        value=value.to_s
      end
      if(empty?)
        Logger.log_element_empty(self, value)
      else
        begin
          @operator.select value
          Logger.log_operation_success(self, value)
        rescue
          Logger.log_operation_fail(self, value)
        end
      end
    end
    # ���� ��һ����ѡ�е�ѡ��
    # @return [String]
    # @example select_value = page.lst_addrId.selected_value
    # select_value => "ѡ��1"
    def selected_value
      if(empty?)
        Logger.log_element_empty(self)
      else
        return @operator.selected_options.first
      end
    end


    #��ȡASelectList������options
    #@return [Array]
    #@example options_value = page.lst_addrId.options
    # options_value => ['ѡ��1', 'ѡ��2', 'ѡ��3']
    def options
      return @operator.options
    end
  end

end


