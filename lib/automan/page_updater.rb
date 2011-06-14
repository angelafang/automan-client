$:.unshift(File.dirname(__FILE__))
module Automan
  # �ṩPageModel���߸��¹���
  module Version

    require 'open-uri'
    require 'yaml'
    require 'fileutils'
    require 'automan/codegen/pagemodel_generator'

    require 'htmlentities'

    # ҳ����Ϣ�������ڵ�    
    class VersionNode
      # @return [String] �汾��
      attr_accessor :version
      # @return [String] ����
      attr_accessor :name
      # @return [VersionNode] ���ڵ�
      attr_accessor :parent
      def to_s
        return "#{name} #{version}: #{path}"
      end
      # @param [String] version_number �汾��
      # @param [String] name ����
      def initialize(version_number, name)
        @version = version_number
        @name = name
      end
      def ver_eql(node)
        return false unless(node)
        return node.version.eql?(self.version)
      end
      # ƴװȫ·��
      # @return [String]
      def path
        return File.join(@parent.path, @name)
      end
      # ������Ҫ���µ��ļ����ļ����б�
      # @param [VersionNode] local_node ���ؽڵ�
      # @abstract override by {FolderNode#need_update} and {FileNode#need_update}
      # @return [Array<Hash>]
      # @example ����ֵΪ[
      #   {:AddFile=>[FileNode]}
      #   {:AddDir=>"c:/automan/base/page/testfolder"}
      #   ]
      def need_update(local_node)
        raise NotImplementedError.new("#{self.class.name}#area�ǳ��󷽷�")
      end
    end
    # ҳ����Ϣ���ļ��ڵ�
    class FileNode < VersionNode
      # @param (see VersionNode#initialize)
      # @param [String] file_url �ļ����ص�ַ
      def initialize(version_number, name, file_url)
        super(version_number, name)
        @url = file_url
      end
      # @return [String] �ļ����ص�ַ
      attr_accessor :url
      # ������Ҫ���µ��ļ��б�
      # @param (see VersionNode#need_update)
      # @return (see VersionNode#need_update)
      def need_update(local_node)
        result = []
        unless local_node
          result << {:AddFile => self}
        else
          unless(ver_eql(local_node))
            result << {:UpdateFile => self}
          end
        end
        return result
      end
    end
    # ҳ����Ϣ��Ŀ¼
    class FolderNode < VersionNode
      # @param (see VersionNode#initialize)
      def initialize(version_number, name)
        super
        @sub_nodes = []
      end
      # @return [Array<VersionNode>] �ӽڵ�
      attr_reader :sub_nodes
      # ����ӽڵ�
      # @param [Array<VersionNode>] nodes �ӽڵ�
      def add_nodes(nodes)
        Array(nodes).each { |n|
          n.parent = self
          @sub_nodes << n
        }
      end
      # ���ӽڵ��в���ͬ���ڵ�
      # @return [VersionNode, nil] �ҵ��Ľڵ�
      def find_same_name(node)
        @sub_nodes.each{|n|
          if(n.name == node.name)
            return n
          end
        }
        return nil
      end

      # ������Ҫ���µ��ļ����б�
      # @param (see VersionNode#need_update)
      # @return (see VersionNode#need_update)
      def need_update(local_node)
        result = []
        unless(local_node)#���ز�����
          result << {:AddDir=>File.join(self.path)}          

          @sub_nodes.each { |n|
            result.concat(n.need_update(nil))
          }
        else
          unless(ver_eql(local_node))
            #��ʼ���������ﲻһ��
            local_sub = local_node.sub_nodes

            @sub_nodes.each { |n|
              ln = local_node.find_same_name(n) #���ҵ����صĽڵ�
              if(ln)
                #�ҵ��˱��صĽڵ�
                unless(ln.ver_eql(n))
                  result.concat(n.need_update(ln))
                end
              else
                #�Ҳ������صĽڵ�
                result.concat(n.need_update(nil))
              end
            }
          
            local_sub.each{|ln|
              sn = self.find_same_name(ln) #���ҷ������Ľڵ�
              #�Ҳ����������ϵĽڵ�
              unless(sn)
                if(ln.is_a? FolderNode)
                  result << {:DelDir=>File.join(self.path, ln.name)}
                elsif(ln.is_a? FileNode)
                  result << {:DelFile=>File.join(self.path, ln.name)}
                else
                  raise "not supported"
                end
              end
            }
          end
        end
        return result
      end
    end
    # ҳ����Ϣ����Ŀ¼
    class VersionRoot < FolderNode
      # @param [String] project_name ��Ŀ����
      # @param (see VersionNode#initialize)
      def initialize(version_number, name, project_name=name)
        super(version_number, name)
        @project_name = project_name
      end
      # @return [String] ��Ŀ����
      attr_accessor :project_name
      attr_reader :root_path
      def get_list(local_node, root_path)
        @root_path = root_path
        return need_update(local_node)
      end
      def path
        return @root_path
      end
    end

    class VersionHelper
      @MaxNumber = 50

      # ������Ϣ��ӡ���û���
      def self.show_hash(hash)
        value = hash.values[0]
        if(value.is_a?(FileNode))
          result = "#{value.path}=>#{value.url}"
        else 
          result = value
        end
        puts "#{hash.keys[0]}=>#{result}"
      end
      def self.process_file(file_list_hash_array)
        file_list_hash_array.each { |hash|
          show_hash(hash)
          if(hash[:AddDir])
            value = hash[:AddDir]
            unless(File.exist?(value))
              Dir.mkdir(value)
            end
          elsif(hash[:DelDir])
            value = hash[:DelDir]
            #ɾ�������ڵ��ļ���ʱ�����ᱨ��
            FileUtils.rm_rf(value)
          elsif(hash[:DelFile])
            value = hash[:DelFile]
            File.delete(value) if File.exist?(value)
            ruby_file = value.sub(/\.xml$/,".rb")
            File.delete(ruby_file) if File.exist?(ruby_file)
          elsif(hash[:UpdateFile])
            file_node = hash[:UpdateFile]
            write_to_file(file_node)
          elsif(hash[:AddFile])
            file_node = hash[:AddFile]
            write_to_file(file_node)
          end
        }
      end
      # @param [String] url ҳ��ģ����Ϣxml�ļ�url���� url='http://t-taichan:3000/pm_libs/object_lib-one.xml'
      # @return [VersionRoot] �ӷ��������õ���ҳ��ģ�Ͱ汾��Ϣ�ļ�
      def self.get_server_version(url)
        version_server = YAML.load(http_get(url))
        return version_server
      end

   
      def self.http_get(url)
        begin
          open(url,:proxy=>nil).read
        rescue StandardError => e
          raise "Error raised when reading url: #{url}, message is : \n\t#{e.message}"
        end
      end
      # �����ļ���
      # @return [nil]
      # @example ʹ��ʾ��
      #   parent_folder = File.dirname(__FILE__)+ "/page"
      #   VersionHelper.process('http://t-taichan:3000/pm_libs/object_lib-one.xml', parent_folder)
      def self.process(root_url, parent_folder)        
        server_version = get_server_version(root_url)
        name = server_version.name
        
        local = File.join(parent_folder , "#{name}.info")
        file_list = File.join(parent_folder , "#{name}.list")
        file_list_temp = File.join(parent_folder , "#{name}.list_temp")
        server_target = File.join(parent_folder , "#{name}.target")

        unless(File.exist?(file_list))
          #��ȡҪ���µ�file list��д���ļ�����������������ļ�
          process_folder = parent_folder
          local_version = nil
          if(File.exist?(local))
            File.open(local) do |file|
              local_version = YAML.load(file)
            end
          end
          list = server_version.get_list(local_version, process_folder)
          if(list.length < @MaxNumber)
            #�����ĿС�ͼ򵥴�����ԭ�����߼�һ��������дlist�ļ�
            #�󲿷ָ��»���������߼���
            if(list.empty?)
              return nil
            end
            process_file(list)
            File.open(local, 'w') { |file| YAML.dump(server_version, file) }
            return nil
          end
          File.open(file_list, 'w') { |file| YAML.dump(list, file) }
          File.open(server_target, 'w') { |file| YAML.dump(server_version, file) }
        end
        #����Ҫ���µ�file list�ļ����������ѷ��������ļ����ǵ������ļ�
        list_load = []
        File.open(file_list){|file| list_load = YAML.load(file)}
        while(!list_load.empty?)
          current_list = list_load.slice!(0, @MaxNumber)
          process_file(current_list)
          File.open(file_list_temp, 'w') { |file| YAML.dump(list_load, file) }
          # Overwrite original file with temp file
          File.rename(file_list_temp, file_list)
        end
        FileUtils.rm(file_list, :force => true)
        FileUtils.copy_file(server_target, local)
        FileUtils.rm(server_target, :force => true)
        return nil
      end

      def self.write_share(path,url)
        File.open(path, 'w') { |file|
          open(url,:proxy=>nil){|io|
            result = io.readlines
            result.each do |line|
              line = HTMLEntities.new.decode(line)
              file << line
            end
          }
        }
      end

      private
      def self.write_to_file(file_node)
        dir = File.dirname(file_node.path)
        FileUtils.mkdir_p(dir) unless File.exist?(dir)
        File.open(file_node.path, 'w') { |file|
          url = file_node.url
          open(url,:proxy=>nil){|io|
            result = io.readlines
            result.each do |line|
              line = HTMLEntities.new.decode(line)
              file << line
            end
          }
        }
        xml_file = file_node.path
        ruby_file = xml_file.sub(/\.xml$/,".rb")
        output = Codegen::PageModelGenerator.new(xml_file).run
        File.open(ruby_file,"w"){|f|f<<output} #dup code
      end
    end
  end
end
