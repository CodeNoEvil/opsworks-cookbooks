# gluster server configure recipe
# copyright 2013 Code No Evil, LLC

aws_instance_id         = node[:opsworks][:instance][:aws_instance_id]
layer                   = node[:opsworks][:instance][:layers].first
hostname                = node[:opsworks][:instance][:hostname]
instances               = node[:opsworks][:layers].fetch(layer)[:instances].sort_by{|k,v| v[:booted_at] }
is_first_node           = instances.index{|i|i[0] == hostname} == 0

Chef::Log.debug("aws_instance_id: #{aws_instance_id}")
Chef::Log.debug("layer: #{layer}")
Chef::Log.debug("instances: #{instances.map{|i| i[0] }.join(', ')}")
Chef::Log.debug("is_first_node: #{is_first_node}")
Chef::Log.debug("hostname: #{hostname}")

if is_first_node then
    Chef::Log.info("First Node; Probing peers")

    instances.each do |i|
        instance = i[1]
        private_dns_name = instance[:private_dns_name]
        is_self = instance[:aws_instance_id] == aws_instance_id;

        Chef::Log.debug("Peer private_dns_name: #{private_dns_name}")

        execute "gluster peer probe #{private_dns_name}" do
            not_if "gluster peer status | grep '^Hostname: #{private_dns_name}'"
            not_if { is_self }
        end

    end

    #node[:glusterfs][:server][:volumes].each do |application|
    node[:deploy].each do |application, deploy|

        Chef::Log.info("Gluster Volume: #{application}")

        execute "gluster volume setup" do
            not_if "gluster volume info #{application} | grep '^Volume Name: #{application}'"
            bricks = instances.map{|i| i[1][:private_dns_name] + ":#{node[:glusterfs][:server][:export_directory]}/" + application}.join(' ')
            command "gluster volume create #{application} replica #{instances.count} transport tcp #{bricks}"
            action :run
        end

        execute "gluster volume start #{application}" do
            not_if "gluster volume info #{application} | grep '^Status: Started'"
            action :run
        end
    end
end
