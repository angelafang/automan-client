module WangWangClient
	module WWLoginWindow
 
      include AWatir
	  
		  
		  #������¼����
		  class WWLoginWin < WinRootModel
			
			 #��ס����
			 def remember_password
		      return  find_element(AWatir::WinElement,".StandardButton:eq(4)", :name=>"remember_password", :description=>"��ס����")
			 end
			
			 #�Զ���¼
			 def auto_login
		      return  find_element(AWatir::WinElement,".StandardButton:eq(5)", :name=>"auto_login", :description=>"�Զ���¼")
			 end
			
			 #��¼��ť
			 def login
		      return  find_element(AWatir::WinElement,"*:contains(�� ¼)", :name=>"login", :description=>"��¼��ť")
			 end
			
			 #�ʺ�����
			 def account_type
		      return  find_element(AWatir::WinElement,".StandardButton:eq(1)", :name=>"account_type", :description=>"�ʺ�����")
			 end
			
			 #��Ա��
			 def txt_ww_username
		      return  find_element(AWatir::WinTextField,".EditComponent:eq(1)", :name=>"txt_ww_username", :description=>"��Ա��")
			 end
			
			 #����
			 def txt_password
		      return  find_element(AWatir::WinWWPassword,".ATL\\:Edit", :name=>"txt_password", :description=>"����")
			 end
			

          include AWatir
           
		  end
	  
	end
end
