instances = node[:opsworks][:layers].fetch("gluster")[:instances]
puts instances.inspect
if instances.count > 0 then
        server = instances.sort_by{|k,v| v[:booted_at] }[0][1][:private_ip]

        node[:wordpress][:bind_mounts][:mounts].each do |dir, source|
                directory source do
                        recursive true
                        action :create
                        mode "0755"
                end

                # mount -t glusterfs -o log-level=WARNING,log-file=/var/log/gluster.log 10.200.1.11:/test /mnt
                mount "glusterfs mount point"  do
                    device "#{server}:/#{source}"
                    fstype "glusterfs"
                    options "log-level=WARNING,log-file=/var/log/gluster.log"
                    action :enable
                end
        end

        include_recipe 'wordpress::autofs'
end