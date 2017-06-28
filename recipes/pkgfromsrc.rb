# install squid pkg from src
# Technically, these diladele people have a repo with the packages in them
# but who knows whether they've put nasty stuff in their build, so we are
# building this ourselves.  They have two patches which are safe and ought
# to be easy to audit later on.

remote_file "#{Chef::Config['file_cache_path']}/scripts.squid3.zip" do
  source 'https://docs.diladele.com/_downloads/scripts.squid3.zip'
end

package 'unzip'

execute 'unzip scripts.squid3.zip' do
  cwd Chef::Config['file_cache_path']
  creates "#{Chef::Config['file_cache_path']}/scripts.squid3"
end

# their scripts do some silly reboots, so clean them out.
execute 'grep -v reboot 02_tools.sh > 02_tools.sh.new ; mv 02_tools.sh.new 02_tools.sh'
    cwd "#{Chef::Config['file_cache_path']}/scripts.squid3"
end

# execute the build/install scripts
%w{ 02_tools.sh  03_build_ecap.sh  04_install_ecap.sh  05_build_squid.sh  06_install_squid.sh }.each do |s|
  execute "/bin/sh ./#{s}" do
    cwd "#{Chef::Config['file_cache_path']}/scripts.squid3"
  end
end

