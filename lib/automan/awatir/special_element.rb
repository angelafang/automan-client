#�����е����Ա�ҳ�����õ��������Element��������ԱҲ�����Լ������Ҫ���⴦��Ŀؼ����ͣ��Ա���ҳ��ģ��������
module AWatir
  #���ı��ؼ����̳�AElement�����з���
  class AInnerTextSetElement < AElement
    #�Ը��ı����������
    #@param [String] value ���������
    #@example  page.dft_editor.set("��ӭ���ҵ����磡")
    def set(value)
      if(empty?)
        Logger.log_element_empty(self, value)
      else
        @elementD.innerText = value
        Logger.log_operation_success(self, value)
      end
    end
  end
  #��Ҫ��doclick�����Ŀؼ����̳�AElement�����з���
  class ADoClickElement < AElement
    #����Ҫ��doclick�����Ŀؼ�������doclick����
    #@example  page.btn_editor.click
    def click
      if(empty?)
        Logger.log_element_empty(self)
      else
        self._doclick
        Logger.log_operation_success(self)
      end
    end
  end

  #�Ե����ᴥ��������Ŀؼ���������ͣ��̳�AElement�����з���
  class ANoWaitElement < AElement

    def click_wait
      @elementD.click
    end
    #�첽���
    #@example page.dft_confirm.click
    def click
      if(empty?)
        Logger.log_element_empty(self)
      else
        HtmlHelper.click_in_spawned_process(self)
      end
    end
  end
end
