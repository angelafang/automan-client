module Taojianghu
	module Portal
		module Home
 
      include AWatir
	  
		  
		  #��ҳ
		  class HomePage < HtmlRootModel
			
			 #��������
			 def comment
		      return  find_model(Comment,"#J_commentBox", :name=>"comment", :description=>"��������")
			 end
			
			 #��ע�Ȳ���
			 def follow_act
		      return  find_model(FollowAct,"div.follow-act", :name=>"follow_act", :description=>"��ע�Ȳ���")
			 end
			

          include AWatir
           

          #��������
          class Comment < HtmlModel
            
             #���Կ�
             def comment_box
                return  find_model(CommentBox,".reply-form", :name=>"comment_box", :description=>"���Կ�")
             end
            
             #�����б�
             def comment_lists
                return  find_models(CommentList,".reply-list", :name=>"comment_lists", :description=>"�����б�")
             end
            
             #��ʾ������
             def popup
                return  find_model(Popup,"div.sns-panel-content>div.bd", :name=>"popup", :description=>"��ʾ������")
             end
            
          end
                  

          #���Կ�
          class CommentBox < HtmlModel
            
             #�����
             def txt_input
                return  find_element(AWatir::ATextField,".J_Suggest", :name=>"txt_input", :description=>"�����")
             end
            
             #����
             def lnk_face
                return  find_element(AWatir::ALink,"#J_viewMoreSmile", :name=>"lnk_face", :description=>"����")
             end
            
             #д����
             def btn_submit
                return  find_element(AWatir::AButton,"a.post", :name=>"btn_submit", :description=>"д����")
             end
            
          end
                  

          #�����б�
          class CommentList < HtmlModel
            
             #�ظ�����
             def lnk_reply
                return  find_element(AWatir::ALink,".sns-icon\\ icon-comment", :name=>"lnk_reply", :description=>"�ظ�����")
             end
            
             #ɾ������
             def lnk_delete
                return  find_element(AWatir::ALink,".sns-icon\\ icon-del", :name=>"lnk_delete", :description=>"ɾ������")
             end
            
          end
                  

          #��ʾ������
          class Popup < HtmlModel
            
          end
                  

          #��ע�Ȳ���
          class FollowAct < HtmlModel
            
             #��ע��ť
             def lnk_follow
                return  find_element(AWatir::ALink,"a.add-link", :name=>"lnk_follow", :description=>"��ע��ť")
             end
            
             #��һ��
             def lnk_poke
                return  find_element(AWatir::ALink,"#J_touch", :name=>"lnk_poke", :description=>"��һ��")
             end
            
             #�Ƽ�������
             def lnk_recfriend
                return  find_element(AWatir::ALink,"#J_recommend", :name=>"lnk_recfriend", :description=>"�Ƽ�������")
             end
            
             #������
             def lnk_gift
                return  find_element(AWatir::ALink,"a.sns-icon\\ icon-gift-send", :name=>"lnk_gift", :description=>"������")
             end
            
          end
                  
		  end
	  
		end
	end
end
