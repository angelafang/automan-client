#LibAutoit��Ҫ����windows�����ĶԻ��򣬵���autoit����д���
#�������£�
#- ChooseFileDialog����������ѡ���ļ��Ի��򴰿�
#- clearSecurityAlert����������ȫ����Ի���
#- ControlSetText���������Ի����е�ĳ���ؼ�����ֵ
#- ControlClick��������ָ���ؼ��������������
#- ControlGetText��������ȡָ���ؼ�ֵ
#- ControlGetHandle��������ȡָ���ؼ�ֵ�ľ��
#- ControlFocus�������������뽹�㵽ָ�����ڵ�ĳ���ؼ���
#- DealDownloadDialog�����������ļ����ضԻ���
#- DealPathDialog���������������ļ�·�����������أ�����ļ��Ѵ����򸲸Ǵ���
#- DealAlterDialog����������Alter�Ի���
#- DealConfirmDialog����������Confirm�Ի���
#- DealPromptDialog����������Prompt�Ի���
#- DealSecurity���������ҳ�����ӣ�ʹ������ȫ����Ի���
#- GetDialogTitle�������������ͻ�ȡ�����Ĵ��ڱ���
#- SendKey������ģ����������ַ�
#- WinExists�������жϴ����Ƿ����

module LibAutoit
  class AutoItApi
    include Singleton 
    #����˵�����������ͻ�ȡ�����Ĵ��ڱ��⣬��ΪIE���汾�����ĶԻ�������в��죬��Ҫ�������⴦��
    #
    #����˵����
    #type���������ͣ�����ֵ���£�
    #- type=1��ѡ���ļ����ڱ���
    #- type=2��Alter���ڱ���
    #- type=3��Prompt���ڱ���
    #- type=4����ȫ���洰�ڱ���
    #- type=5���ļ����ش��ڱ���
    #- type=6���ļ����Ϊ���ڱ���
    #
    #����ʾ���� GetDialogTitle(2)
    #
    #����ֵ˵����
    #- �ɹ������ػ�ȡ�ı���
    #- ʧ�ܣ�����false    
    def GetDialogTitle(type = 2)
      #$logger.log("���ú�����LibAutoit.rb�ļ��е�GetDialogTitle(#{type})" )

      dialog_title = ListDialogTitle(type)

      dialog_title.each do |title|
        if (WinExists(title,'') == 1)
          puts "��ȡ�Ĵ��ڣ�#{title}"
          return  title
        end
      end
      return false
    end

    def ListDialogTitle(type = 2)
      case type
      when 1 #ѡ���ļ����ڱ���
        dialog_title = ['ѡ���ļ�', 'Choose file', 'ѡ��Ҫ���ص��ļ�']
      when 2 #Alter���ڱ���
        dialog_title = ['Microsoft Internet Explorer','Windows Internet Explorer', '������ҳ����Ϣ']
      when 3 #Prompt���ڱ���
        dialog_title = ['Explorer �û���ʾ','Explorer User Prompt']
      when 4 #��ȫ���洰�ڱ���
        dialog_title = ['��ȫ����','Security Alert']
      when 5 #�ļ����ش��ڱ���
        dialog_title = ['�ļ����� - ��ȫ����','�ļ�����','File Download']
      when 6  #�ļ����Ϊ���ڱ���
        dialog_title = ['���Ϊ']
      end
      return dialog_title
    end

    #����˵���������ļ����ضԻ��򣬵���DealPathDialog��������·���������ļ�
    #
    #����˵����
    #- file_path���ļ����غ��ŵ�·������ʽ�磺c:\\test
    #- file_name���ļ������磺test.txt
    #- timeout���Ի�����ĳ�ʱʱ�䣬Ĭ��Ϊ20��
    #
    #����ʾ���� DealDownloadDialog(��c:\\test\test.txt��,15)
    #
    #����ֵ˵����
    #-  �ɹ�������ture
    #- ʧ�ܣ�����false
    def DealDownloadDialog(file_path,file_name,timeout = @DealDownloadDialogTimeOut )
      start_time = Time.now.to_i

      while 1
        if (Time.now.to_i-start_time < timeout)   #�жϴ���ʱ���Ƿ�ʱ

          win_title = GetDialogTitle(5) #��ȡ���ڱ���

          if (win_title)
            @autoit.WinActivate(win_title,'')
            sleep(1)
            ControlClick(win_title,'','Button2')

            DealPathDialog(file_path,file_name)

            '----------deal with download File dialog end----------'
            "���ú���������LibAutoit.rb�ļ��е�DealDownloadDialog()�����ؽ����true"
            return true
          end
          sleep 1
        else
          "Deal Download File Dialog Fail!"
          '----------deal with download File dialog end----------'
          "���ú���������LibAutoit.rb�ļ��е�DealDownloadDialog()�����ؽ����false"
          return false
        end
      end
    end


    #����˵�������������ļ�·�����������أ�����ļ��Ѵ����򸲸Ǵ���
    #
    #����˵����
    #- file_path���ļ����غ��ŵ�·������ʽ�磺c:\\test
    #- file_name���ļ������磺test.txt
    #- timeout���Ի�����ĳ�ʱʱ�䣬Ĭ��Ϊ20��
    #
    #����ʾ����
    #- DealPathDialog(��c:\\test��,"test.txt")
    #
    #����ֵ˵����
    #-  �ɹ�������true
    #- ʧ�ܣ�����false
    def DealPathDialog(file_path,file_name = '',timeout = @DealPathDialogTimeOut )
      "���ú�����LibAutoit.rb�ļ��е�DealPathDialog(#{file_path},#{file_name},#{timeout})"

      start_time = Time.now.to_i

      while 1
        if (Time.now.to_i-start_time < timeout)   #�жϴ���ʱ���Ƿ�ʱ
          win_title = GetDialogTitle(6) #��ȡ���ڱ���
          if (win_title)
            @autoit.WinActivate(win_title,'')

            if (!FileTest::exist?(file_path))
              FileUtils.makedirs(file_path)
            end

            file_full_path = "#{file_path}\\#{file_name}"
            
            real_file_path = LibAutoit::GetRealPath(file_full_path,'N')
            real_full_path = "#{real_file_path}\\#{file_name}"

            ControlSetText(win_title,'','Edit1',real_full_path)
            SendKey("!S")
            #ControlClick(win_title,'','Button2')

            if (WinExists(win_title,'�滻') == 1)
              @autoit.WinActivate(win_title,'�滻')
              ControlClick(win_title,'�滻','Button1')
            end

            "���ú���������LibAutoit.rb�ļ��е�DealPathDialog()"
            return true
          end
          sleep 1
        else
          "Deal File Path Dialog Fail!"
          "���ú���������LibAutoit.rb�ļ��е�DealPathDialog()"
          return false
        end
      end
    end

    #����˵��������ѡ���ļ��Ի��򴰿�
    #
    #����˵������
    #- file_path���ļ����غ��ŵ�·������ʽ��Ŀ¼+�ļ������磺c:\\test\\test.txt
    #- timeout���Ի�����ĳ�ʱʱ�䣬Ĭ��Ϊ20��
    #
    #����ʾ���� ChooseFileDialog(��c:\\test\\test.txt��,15)
    #
    #����ֵ˵����
    #-  �ɹ�������true
    #- ʧ�ܣ�����false
    def ChooseFileDialog(file_path,timeout = @ChooseFileDialogTimeOut)
      "���ú�����LibAutoit.rb�ļ��е�ChooseFileDialog(#{file_path},#{timeout})"

      '----------deal with Choose File dialog begin----------'
      start_time = Time.now.to_i

      while 1
        if (Time.now.to_i-start_time < timeout)   #�жϴ���ʱ���Ƿ�ʱ
          win_title = GetDialogTitle(1) #��ȡ���ڱ���
          if (win_title)
            @autoit.WinActivate(win_title,'')

            if (FileTest::exist?(file_path))
              real_file_path = LibAutoit::GetRealPath(file_path)  #��ȡ��ʵ·��

              ControlSetText(win_title,'','Edit1',real_file_path)
              
              #����deal_dialog�Ĵ��룬�����Ż�����
              buttons_info=Win32Helper._list_window_buttons(win_title)
              buttons_instance = []
              buttons_title = []
              for i in 0..buttons_info.length-1
                arr=buttons_info[i].split(":")
                buttons_instance << arr[0]
                buttons_title <<  arr[1]
              end
              if index = buttons_title.index("��(&O)")
                ControlClick(win_title,'',buttons_instance[index])
              else
                puts "�޷��ҵ���ť����(&O)"
              end

              '----------deal with Choose File dialog end----------'
              "���ú���������LibAutoit.rb�ļ��е�ChooseFileDialog(#{file_path},#{timeout})"

              return true
            else
              '----------deal with Choose File dialog end----------'
              "���ú���������LibAutoit.rb�ļ��е�ChooseFileDialog(#{file_path},#{timeout})"
              puts "�ϴ��ļ�·�������ڣ���ȷ���ļ�·���Ƿ���ȷ��ע��:�ļ�·������'\\\\'��'/'����"
              return false
            end
          end
          sleep 1
        else
          "Deal Choose File Dialog Fail!"
          '----------deal with Choose File dialog end----------'
          "���ú���������LibAutoit.rb�ļ��е�ChooseFileDialog(#{file_path},#{timeout})"
          return false
        end
      end
    end

    #����˵��������Alter�Ի���
    #
    #����˵����
    #- timeout���Ի�����ĳ�ʱʱ�䣬Ĭ��Ϊ20��
    #
    #����ʾ���� DealAlterDialog(15)
    #
    #����ֵ˵����
    #-  �ɹ������ضԻ����е��ı���ʾ����
    #- ʧ�ܣ�����false
    def DealAlterDialog(timeout = @DealAlterDialogTimeOut )
      "���ú�����LibAutoit.rb�ļ��е�DealAlterDialog(#{timeout})"
      '----------deal with alter dialog begin----------'

      start_time = Time.now.to_i

      while 1
        if (Time.now.to_i-start_time < timeout)   #�жϴ���ʱ���Ƿ�ʱ
          win_title = GetDialogTitle(2) #��ȡ���ڱ���
          if (win_title)
            @autoit.WinActivate(win_title,'')

            alter_content =  ControlGetText(win_title,'','Static2')
            SendKey('{ENTER}')
            #ControlClick('Windows Internet Explorer','','Button1')
            #puts "alter message:\n #{alter_content}"

            "the content of alter dialog�� #{alter_content}"
            '-----------deal with alter dialog end-----------'
            "���ú���������LibAutoit.rb�ļ��е�DealAlterDialog(#{timeout})"
            return alter_content
          end
          sleep 1
        else
          "deal with alter dialog fail!"
          '-----------deal with alter dialog end-----------'
          "���ú���������LibAutoit.rb�ļ��е�DealAlterDialog(#{timeout})"
          return false
        end
      end
    end

    #����˵��������Confirm�Ի���
    #
    #����˵����
    #- type�����ȷ����ȡ����ť��Y��ȷ��  N��ȡ��
    #- timeout���Ի�����ĳ�ʱʱ�䣬Ĭ��Ϊ20��
    #
    #����ʾ���� DealConfirmDialog()
    #
    #����ֵ˵����
    #-  �ɹ������ضԻ����е��ı���ʾ����
    #- ʧ�ܣ�����false
    def DealConfirmDialog(type="ȷ��",timeout = @DealConfirmDialogTimeOut)
      type="ȷ��" if(type.nil?)
      puts "���ú�����LibAutoit.rb�ļ��е�DealConfirmDialog()"
      puts '----------deal with confirm dialog begin----------'
      start_time = Time.now.to_i
      win_title = ""
      while 1
        if (Time.now.to_i-start_time < timeout)   #�жϴ���ʱ���Ƿ�ʱ
          win_title = GetDialogTitle(2) #��ȡ���ڱ���'
          #win_title = "��ӡ"
          #puts   win_title
          if (win_title)
            @autoit.WinActivate(win_title,'')
            buttons_info=AWatir::Win32Helper._list_window_buttons(win_title)
            buttons_instance = []
            buttons_title = []
            for i in 0..buttons_info.length-1
              arr=buttons_info[i].split(":")
              buttons_instance << arr[0]
              buttons_title <<  arr[1]
            end
            #if type.nil?
            # ControlClick(win_title, "", "[CLASS:Button; TEXT:ȷ��]")
            if type =~ /^Button/
              if  buttons_instance.include?(type)
                ControlClick(win_title,'',type)
              else
                puts "�ؼ���#{type}�����ڣ���У�������Button����Ƿ���ȷ��"
              end
            elsif index = buttons_title.index(type)
              ControlClick(win_title,'',buttons_instance[index])              
            else
              puts "�ؼ������ڣ���У������Ŀؼ������Ƿ���ȷ��"
              return false
            end
            puts  '-----------deal with confirm dialog end-----------'
            puts  "���ú���������LibAutoit.rb�ļ��е�DealConfirmDialog()"
            return true
          end
          sleep 1
        else
          puts "�޷��ñ��⣺#{ListDialogTitle(2)}����λ�Ի���"
          puts '-----------deal with confirm dialog end-----------'
          puts "���ú���������LibAutoit.rb�ļ��е�DealConfirmDialog()"
          return false
        end
      end
    end


    def DealConfirmContent(timeout = @DealConfirmDialogTimeOut)
      puts "���ú�����LibAutoit.DealConfirmContent()"
      puts '----------deal with confirm content begin----------'
      start_time = Time.now.to_i

      while 1
        if (Time.now.to_i-start_time < timeout)   #�жϴ���ʱ���Ƿ�ʱ
          win_title = GetDialogTitle(2) #��ȡ���ڱ���'
          if (win_title)
            @autoit.WinActivate(win_title,'')

            confirm_content =  ControlGetText(win_title,'','Static2')
            puts "the content of confirm dialog�� #{confirm_content} "
            puts  '-----------deal with confirm content end-----------'
            puts  "���ú���������LibAutoit.DealConfirmContent()()"

            return confirm_content
          end
          sleep 1
        else
          puts "Failed!!!! deal with confirm content fail!"
          puts '-----------deal with confirm content end-----------'
          puts "���ú���������LibAutoit.DealConfirmContent()()"
          return false
        end
      end
    end
    #����˵��������Prompt�Ի���
    #
    #����˵����
    #- string��������ı�����
    #- type�����ȷ����ȡ����ť��Y��ȷ��  N��ȡ��
    #- timeout���Ի�����ĳ�ʱʱ�䣬Ĭ��Ϊ20��
    #
    #����ʾ���� DealPromptDialog('test','Y',15)
    #
    #����ֵ˵����
    #-  �ɹ�������true
    #- ʧ�ܣ�����false
    def DealPromptDialog(string = '',type = 1,timeout = @DealPromptDialogTimeOut )
      "���ú�����LibAutoit.rb�ļ��е�DealPromptDialog(#{string},#{type},#{timeout})"

      puts '----------deal with prompt dialog begin----------'
      start_time = Time.now.to_i

      while 1
        if (Time.now.to_i-start_time < timeout)   #�жϴ���ʱ���Ƿ�ʱ
          win_title = GetDialogTitle(3) #��ȡ���ڱ���
          if (win_title)
            @autoit.WinActivate(win_title,'')

            ControlSetText(win_title,'','Edit1',string)

            if type == ControlGetText(win_title,'','Button1') || type == 1
              ControlClick(win_title,'','Button1')
            elsif type == ControlGetText(win_title,'','Button2') || type == 2
              ControlClick(win_title,'','Button2')
            else
              puts "can't find the button,pelease check it"
              return false
            end
            '-----------deal with prompt dialog end-----------'
            "���ú���������LibAutoit.rb�ļ��е�DealPromptDialog(#{string},#{type},#{timeout})"

            return true
          end
          sleep 1
        else
          "deal with prompt dialog fail!"
          '-----------deal with prompt dialog end-----------'
          "���ú���������LibAutoit.rb�ļ��е�DealPromptDialog(#{string},#{type},#{timeout})"

          return false
        end
      end
    end

    #����˵�������ҳ�����ӣ�ʹ������ȫ����Ի���
    #
    #����˵����
    #- win_title��IEҳ��ı���
    #- timeout���Ի�����ĳ�ʱʱ��
    #
    #����ʾ���� DealSecurity("ie����",15)
    #
    #����ֵ˵����
    #-  �ɹ�������true
    #- ʧ�ܣ�����false
    def DealSecurity(win_title,timeout = @DealSecurityTimeOut)
      puts "���ú�����LibAutoit.rb�ļ��е�DealSecurity(#{win_title},#{timeout})"

      start_time = Time.now.to_i

      if (Time.now.to_i-start_time < timeout)   #�жϴ���ʱ���Ƿ�ʱ
        while 1
          @autoit.ControlClick(win_title,'','Button1')
          sleep(1)
          SendKey('{DOWN}')
          SendKey('{ENTER}')
          sleep(1)

          clearSecurityAlert('Y')  #�����ȫ�򴰿�
          return true
        end
      else
        'Deal Security Fail!'
        "���ú���������LibAutoit.rb�ļ��е�DealSecurity(#{win_title},#{timeout})"

        return false
      end
    end

    #����˵��������ȫ����Ի���
    #
    #����˵����
    #- type��ѡ�����ĸ���ť��Y��ȷ��  N��ȡ��
    #- timeout���Ի�����ĳ�ʱʱ��
    #
    #����ʾ���� DealSecurity("ie����",15)
    #
    #����ֵ˵����
    #-  �ɹ������ذ�ȫ���洰���е���ʾ��Ϣ
    #- ʧ�ܣ�����false
    def clearSecurityAlert(type = 'Y',timeout = @clearSecurityAlertTimeOut)
      #      $logger.log("���ú�����LibAutoit.rb�ļ��е�clearSecurityAlert(#{type},#{timeout})" ,'N')
      #      $logger.log('----------deal with Security dialog begin----------')
      #����ȫ�Ի���
      start_time = Time.now.to_i

      while 1
        if (Time.now.to_i-start_time < timeout)   #�жϴ���ʱ���Ƿ�ʱ
          win_title = GetDialogTitle(4) #��ȡ���ڱ���
          if (win_title)
            alter_content =  ControlGetText(win_title,'','Static2')

            case type
            when 'Y'
              ControlClick(win_title,'','Button1')
            when 'N'
              ControlClick(win_title,'','Button2')
            end
            #puts "��ȫ������Ϣ��\n#{alter_content}"

            #            $logger.log("the content of Security dialog�� #{alter_content} ")
            #            $logger.log('-----------deal with Security dialog end-----------')
            #            $logger.log("���ú���������LibAutoit.rb�ļ��е�clearSecurityAlert(#{type},#{timeout})" ,'N')
            return alter_content
          end
          sleep 1
        else
          #          $logger.log("The Security Alert Windows is not exist!")
          #          $logger.log('-----------deal with Security dialog end-----------')
          #          $logger.log("���ú���������LibAutoit.rb�ļ��е�clearSecurityAlert(#{type},#{timeout})",'N' )

          return false
        end
      end
    end

    #����˵����ģ����������ַ�
    #
    #����˵����
    #- string��������ַ�����Ϣ��
    #- timeout���Ի�����ĳ�ʱʱ��
    #
    #����ʾ����
    #- Send("#r")  ������ Win+r,�⽫�򿪡����С��Ի���.
    #- Send("^!a")   ���Ͱ��� "CTRL+ALT+a".
    #- Send(" !a")    ����"ALT+a".
    #
    #����ֵ˵������
    def SendKey(string = '{ENTER}')
      @autoit.Send(string)
    end

    #����˵�������Ի����е�ĳ���ؼ�����ֵ
    #
    #����˵����
    #- win_title���Ի��򴰿ڵı���
    #- win_text:�Ի��򴰿�����ʾ���ı�
    #- id���Ի��򴰿���ĳ���ؼ���ID
    #- string���ؼ����õ�ֵ
    #
    #����ʾ���� ��
    #
    #����ֵ˵������
    def ControlSetText(win_title,win_text,id,string = '',flag = 1)
      #�޸�ָ���ؼ����ı�
      @autoit.WinActivate(win_title,win_text)

      if (ControlFocus(win_title,win_text,id) == 1)
        @autoit.ControlSetText(win_title,win_text,id,string)
      end
    end

    #����˵������ָ���ؼ��������������
    #
    #����˵����
    #- win_title��Ŀ�괰�ڱ���.
    #- win_text��Ŀ�괰���ı�.
    #- id��Ŀ��ؼ�ID
    #- button_type������ [��ѡ����] Ҫ����İ�ť, ������"left", "right", "middle", "main", "menu", "primary", "secondary". Ĭ��Ϊleft(���).
    #- click_time ��Ҫ�����갴ť�Ĵ���. Ĭ��ֵΪ 1.
    #
    #����ʾ���� ��
    #
    #����ֵ˵������
    def ControlClick(win_title,win_text,id,button_type =1,click_time = 1)
      @autoit.AutoItSetOption("WinTitleMatchMode", 3)

      @autoit.WinActivate(win_title,win_text)

      case button_type
      when 1 #���������
        button_type = 'left'
      when 2  #�������Ҽ�
        button_type = 'right'
      when 3 #�������м��
        button_type = 'middle'
      end

      @autoit.ControlClick(win_title,win_text,id,button_type,click_time)
    end

    #����˵������ȡָ���ؼ�ֵ
    #
    #����˵����
    #- win_title��Ŀ�괰�ڱ���.
    #- win_text��Ŀ�괰���ı�.
    #- id��Ŀ��ؼ�ID
    #
    #����ʾ���� ��
    #
    #����ֵ˵����
    #- ���ػ�ȡ���ı�����
    def ControlGetText(win_title,win_text,id)
      if (ControlGetHandle(win_title,win_text,id) != "")
        control_text =  @autoit.ControlGetText(win_title,win_text,id)

        return control_text
      end
    end

    #����˵������ȡָ���ؼ�ֵ�ľ��
    #
    #����˵����
    #- win_title��Ŀ�괰�ڱ���.
    #- win_text��Ŀ�괰���ı�.
    #- id��Ŀ��ؼ�ID
    #
    #����ʾ���� ��
    #
    #����ֵ˵����
    #- ���ػ�ȡ�Ŀؼ����
    def ControlGetHandle(win_title,win_text,id)
      ret = @autoit.ControlGetHandle(win_title,win_text,id)
      return ret
    end

    #����˵�����������뽹�㵽ָ�����ڵ�ĳ���ؼ���
    #
    #����˵����
    #- win_title��Ŀ�괰�ڱ���.
    #- win_text��Ŀ�괰���ı�.
    #- id��Ŀ��ؼ�ID
    #
    #����ʾ���� ��
    #
    #����ֵ˵������
    def ControlFocus(win_title,win_text,id)
      #�������뽹�㵽ָ�����ڵ�ĳ���ؼ���
      ret = @autoit.ControlFocus(win_title,win_text,id)
      return ret
    end


    #����˵�����жϴ����Ƿ����
    #
    #����˵����
    #- win_title��Ŀ�괰�ڱ���.
    #- win_text��Ŀ�괰���ı���Ĭ��Ϊ��
    #
    #����ʾ���� ��
    #
    #����ֵ˵�������ش��ڶ���
    def WinExists(win_title,win_text = '')
      #���ָ���Ĵ����Ƿ����
      ret = @autoit.WinExists(win_title,win_text = '')
      return ret
    end

    private
    def initialize
      require 'win32ole'
      require 'watir/windowhelper'
      WindowHelper.check_autoit_installed
      @autoit = WIN32OLE.new("AutoItX3.Control")

      @DealDownloadDialogTimeOut  = 60
      @DealPathDialogTimeOut        = 60
      @ChooseFileDialogTimeOut      = 60
      @DealAlterDialogTimeOut        = 60
      @DealConfirmDialogTimeOut    = 60       #60��ĵȴ�ʱ��
      @DealPromptDialogTimeOut     = 60
      @DealSecurityTimeOut           = 60
      @clearSecurityAlertTimeOut    = 60
      @getDialogContent           =60
    end #def initialize end   
  end

#
#  def self.RenameFile(from,to =  nil)
#    begin
#      if (FileTest::exist?(from)) and (File.basename(from) =~ /.*\..*/ )
#        if (to == nil)
#          extname = File.extname(from)
#          filename = File.basename(from,extname)
#          new_filename = filename + '.' + Time.now.strftime("%Y%m%d%H%M%S") + extname
#          to = File.dirname(from) + '/'+ new_filename
#        end
#
#        File.rename(from, to)
#        return true
#      else
#        puts "�������ļ�ʧ�ܣ�ԭ���ļ������ڣ�·��Ϊ#{from}"
#        return false
#      end
#    rescue StandardError => bang
#      puts "Error running script: " + bang
#      return false
#    end
#  end

  #����˵����
  #- ��ȡ�ļ�����ʵ·��
  #
  #����˵����
  #- file_path��ԭ�ļ�·�������ԭ�ļ�·�������ڣ�ϵͳ�Զ�������Ӧ·��
  #- return_file���Ƿ񷵻�·���е��ļ�����Ĭ��δ����
  #
  #����ʾ����
  #- LibAutoit::GetRealPath("#{File.dirname(__FILE__)}/http://www.cnblogs.com/input/data.xls"  )
  #
  #����ֵ˵����
  #- �ɹ���������ʵ��·��
  #- ʧ�ܣ�����false
  def self.GetRealPath(file_path,return_file = 'Y')
    begin
      @@file_name = ''
      @@real_dir_row = []

      if (file_path.include?("\\"))
        file_path = file_path.to_s.gsub('\\','/')
      end

      if (file_path.include?("/"))

        file_basename = File.basename(file_path)  #��ȡ�ļ���
        file_dirname = File.dirname(file_path)

        if (file_basename =~ /.*\..*/)
          file_dirname = File.dirname(file_path)
        else
          file_basename = ''
          file_dirname = file_path
        end

        if (!FileTest::exist?(file_dirname))  #�ж�Ŀ¼�Ƿ���ڣ��������򴴽���ӦĿ¼
          FileUtils.makedirs(file_dirname)
        end

        if (file_dirname[0,2] == './')
          real_dir = Pathname.new(File.dirname(File.dirname(file_dirname[0,2]))).realpath
          real_path = File.join(real_dir,file_dirname[2,file_dirname.length] )
        else
          real_path = file_dirname
        end

        if (real_path.include?(".."))
          temp_row = real_path.split('/')

          temp_row.each do |dir|
            if(dir == "..")
              @@real_dir_row.pop
            else
              @@real_dir_row.push(dir)
            end
          end

          real_path = @@real_dir_row.join('/')
        end

        if (return_file.upcase == 'Y')
          result = File.join(real_path,file_basename)
        else
          result = real_path
        end

        result = result.to_s.gsub('/','\\')
        return  result
      else
        puts "��ȡ�ļ�·��ʧ�ܣ�ԭ��#{real_path}·����ʽ����ȷ��"
        return false
      end
    rescue StandardError => bang
      puts "Error running script: " + bang
      return false
    end
  end #def GetRealPath


end
