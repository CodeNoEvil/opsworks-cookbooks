# require 'net/http'

# uri = URI('https://api.wordpress.org/secret-key/1.1/salt/')
# keys = Net::HTTP.get(uri)
# notifies :write, "log[Keys: ${keys}]"

node[:deploy].each do |app_name, deploy|

# 	script "install_composer" do
# 		interpreter "bash"
# 		user "root"
# 		cwd "#{deploy[:deploy_to]}/current"
# 		code <<-EOH
# 		curl -s https://getcomposer.org/installer | php
# 		php composer.phar install
# 		EOH
# 	end
  
# 	template "#{deploy[:deploy_to]}/current/wp-config.php" do
# 		source "wp-config.php.erb"
# 		mode 0660
# 		group deploy[:group]

# 		if platform?("ubuntu")
# 		  owner "www-data"
# 		elsif platform?("amazon")   
# 		  owner "apache"
# 		end

# 		variables(
# 			:database        => (deploy[:database][:database] rescue nil),
# 			:user            => (deploy[:database][:username] rescue nil),
# 			:password        => (deploy[:database][:password] rescue nil),
# 			:host			 => (deploy[:database][:host] rescue nil),
# 			:keys        	 => (keys rescue nil)
# 		)
# 	end		  
	  
end

# notifies :write, "log[Navigate to 'http://#{node[:opsworks][:layers][:lb][:instances].first[:public_dns_name]}/wp-admin/install.php' to complete wordpress installation]"
