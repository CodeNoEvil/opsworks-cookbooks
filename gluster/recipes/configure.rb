# gluster server configure recipe
# copyright 2013 Code No Evil, LLC

aws_instance_id         = node[:opsworks][:instance][:aws_instance_id]
layer                   = node[:opsworks][:instance][:layers].first
hostname                = node[:opsworks][:instance][:hostname]
instances               = node[:opsworks][:layers].fetch(layer)[:instances]
is_first_node           = instances.keys.index(hostname) == 0

# print "AWS Instance ID: #{aws_instance_id}\n"
# print "Layer: #{layer}\n"
# print "Keys: #{instances.keys}\n"
# print "Is First: #{is_first_node}\n"
# print "Hostname: #{hostname}\n"

if is_first_node then
        instances.each_value do |instance|
                private_dns_name = instance[:private_dns_name]
# print "Private IP: #{private_dns_name}\n"
                execute "peer probing" do
                        command "echo 'Probing #{private_dns_name}'; gluster peer probe #{private_dns_name}"
                        not_if "gluster peer status | grep '^Hostname: #{private_dns_name}'"
                        not_if { instance[:aws_instance_id] == aws_instance_id }
                end
        end
end