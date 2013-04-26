node[:wordpress][:bind_mounts][:mounts].each do |dir, source|
	directory source do
		recursive true
		action :create
		mode "0755"
	end

	# mount -t glusterfs -o log-level=WARNING,log-file=/var/log/gluster.log 10.200.1.11:/test /mnt
	server =  node[:opsworks][:layers].fetch("gluster")[:instances].sort_by{|k,v| v[:booted_at] }[0][1][:private_ip]
	mount absolute_document_root do
	    device "#{server}:/#{app_name}"
	    fstype "glusterfs"
	    options "log-level=WARNING,log-file=/var/log/gluster.log"
	    action :enable
	end
end

include_recipe 'wordpress::autofs'
