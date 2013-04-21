


aws_instance_id = node[:opsworks][:instance][:instance_id]
layer = node[:opsworks][:instance][:layer].first
hostname = node[:opsworks][:instance][:hostname]
is_first_node = node[:opsworks][:layers][layer][:instances].index(hostname) == 0

if is_first_node then
	node[:opsworks][:layers][layer][:instances].each do |instance|

		execute "gluster peer probe #{instance[:private_ip]}" do
			not_if "gluster peer status | grep '^Hostname: #{peer}'" 
			not_if { instance[:private_ip] }
		end
	end
end