require 'automan/mini'

module AWatir
  #�ṩû��ҳ��ģ���£�����ʹ��automan�ķ�ʽ
  class AutomanIE < IEModel
    #��������������Ԫ�أ�����ΪĬ��
    #@param [String] selector Ԫ�ز��ҷ�ʽ
    #@return [AWatir::AElement]
    def element(selector)
      return find(AWatir::AElement, selector)
    end
    #��������������Ԫ�ؼ���
    #@return [Array<AWatir::AElement>]
    def elements(selector)
      return finds(AWatir::AElement, selector)
    end
    #�������������İ�ť
    #@return [AWatir::AButton]
    def button(selector)
      return find(AWatir::AButton, selector)
    end
    #������������������
    #@return [AWatir::ALink]
    def link(selector)
      return find(AWatir::ALink, selector)
    end
    #���������������ı���
    #@return [AWatir::ATextField]
    def text_field(selector)
      return find(AWatir::ATextField, selector)
    end
    #�������������Ĺ�ѡ��
    #@return [AWatir::ACheckBox]
    def checkbox(selector)
      return find(AWatir::ACheckBox, selector)
    end
    #��������������ѡ��ť
    #@return [AWatir::ARadio]
    def radio(selector)
      return find(AWatir::ARadio, selector)
    end
    #��������������������
    #@return [AWatir::ASelectList]
    def select_list(selector)
      return find(AWatir::ASelectList, selector)
    end
    #�������������ĸ��ı��򣬼���Ҫset inner text�Ŀؼ�
    #@return [AWatir::AInnerTextSetElement]
    def rich_text(selector)
      return find(AWatir::AInnerTextSetElement, selector)
    end
    #�������������Ĵ�������Ŀؼ�
    #@return [AWatir::ANoWaitElement]
    def no_wait(selector)
      return find(AWatir::ANoWaitElement, selector)
    end

    #��������������ģ��
    #@return [AutomanModel] ���ص�ģ�ͣ����Լ�������
    def model(selector)
      return  _internal_cast(HtmlModel).find_model(AutomanModel, selector)
    end
    #@return [Array<AutomanModel>] ���ص�ģ�͵ļ���
    def models(selector)
      return  _internal_cast(HtmlModel).find_models(AutomanModel, selector)
    end
    
    def find(type, selector)
      return _internal_cast(HtmlModel).find_element(type, selector)
    end
    private :find
    def finds(type, selector)
      return _internal_cast(HtmlModel).find_elements(type, selector)
    end
    private :finds
  end
  class AutomanModel < HtmlModel
    #@see AutomanIE#element
    #@return (see AutomanIE#element)
    def element(selector)
      return find(AWatir::AElement, selector)
    end
    #@see AutomanIE#elements
    #@return (see AutomanIE#elements)
    def elements(selector)
      return finds(AWatir::AElement, selector)
    end
    #@see AutomanIE#button
    #@return (see AutomanIE#button)
    def button(selector)
      return find(AWatir::AButton, selector)
    end
    #@see AutomanIE#link
    #@return (see AutomanIE#link)
    def link(selector)
      return find(AWatir::ALink, selector)
    end
    #@see AutomanIE#text_field
    #@return (see AutomanIE#text_field)
    def text_field(selector)
      return find(AWatir::ATextField, selector)
    end
    #@see AutomanIE#checkbox
    #@return (see AutomanIE#checkbox)
    def checkbox(selector)
      return find(AWatir::ACheckBox, selector)
    end
    #@see AutomanIE#radio
    #@return (see AutomanIE#radio)
    def radio(selector)
      return find(AWatir::ARadio, selector)
    end
    #@see AutomanIE#select_list
    #@return (see AutomanIE#select_list)
    def select_list(selector)
      return find(AWatir::ASelectList, selector)
    end
    #@see AutomanIE#rich_text
    #@return (see AutomanIE#rich_text)
    def rich_text(selector)
      return find(AWatir::AInnerTextSetElement, selector)
    end
    #@see AutomanIE#no_wait
    #@return (see AutomanIE#no_wait)
    def no_wait(selector)
      return find(AWatir::ANoWaitElement, selector)
    end
    
    #@see AutomanIE#model
    def model(selector)
      return  find_model(AutomanModel, selector)
    end
    #@see AutomanIE#models
    def models(selector)
      return  find_models(AutomanModel, selector)
    end

    def find(type, selector)
      return find_element(type, selector)
    end    
    private :find
    def finds(type, selector)
      return find_elements(type, selector)
    end
    private :finds
  end
end
