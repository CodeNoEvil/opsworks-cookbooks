require 'uri'
require 'net/http'
require 'net/https'

uri = URI.parse("https://api.wordpress.org/secret-key/1.1/salt/")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
request = Net::HTTP::Get.new(uri.request_uri)
response = http.request(request)
keys = response.body

node[:deploy].each do |app_name, deploy|

        template "#{deploy[:deploy_to]}/current/composer.json" do
                source "composer.json.erb"
                mode 0660
                group deploy[:group]

                if platform?("ubuntu")
                  owner "www-data"
                elsif platform?("amazon")
                  owner "apache"
                end
        end

        script "install_composer" do
                interpreter "bash"
                user "root"
                cwd "#{deploy[:deploy_to]}/current"
                code <<-EOH
                curl -s https://getcomposer.org/installer | php
                php composer.phar install
                EOH
        end

        #mount glusterfs share
        absolute_document_root = "#{deploy[:deploy_to]}/current/#{deploy[:document_root]}"
        if not File.directory?(absolute_document_root)
            directory absolute_document_root do
            action :create
            recursive true
          end
        end

        # mount -t glusterfs -o log-level=WARNING,log-file=/var/log/gluster.log 10.200.1.11:/test /mnt
        layer = node[:opsworks][:instance][:layers].first
        server =  node[:opsworks][:layers].fetch(layer)[:instances].sort_by{|k,v| v[:booted_at] }[0][1][:private_dns_name]
        mount mount_to do
            device "#{server}:/#{app_name}"
            fstype "glusterfs"
            options "log-level=WARNING,log-file=/var/log/gluster.log"
            action :enable
        end

        template "#{[:absolute_document_root]}/wp-config.php" do
                source "wp-config.php.erb"
                mode 0660
                group deploy[:group]

                if platform?("ubuntu")
                  owner "www-data"
                elsif platform?("amazon")
                  owner "apache"
                end

                variables(
                        :database        => (deploy[:database][:database] rescue nil),
                        :user            => (deploy[:database][:username] rescue nil),
                        :password        => (deploy[:database][:password] rescue nil),
                        :host            => (deploy[:database][:host] rescue nil),
                        :keys            => (keys rescue nil)
                )
        end

end