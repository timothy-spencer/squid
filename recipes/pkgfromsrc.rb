# install squid pkg from src

remote_file "#{Chef::Config['file_cache_path']}/scripts.squid3.zip" do
  source 'https://docs.diladele.com/_downloads/scripts.squid3.zip'
end

package 'unzip'

execute 'unzip scripts.squid3.zip' do
  cwd Chef::Config['file_cache_path']
end

%w{ 02_tools.sh  03_build_ecap.sh  04_install_ecap.sh  05_build_squid.sh  06_install_squid.sh }.each do |s|
  execute "/bin/sh ./#{s}" do
    cwd "#{Chef::Config['file_cache_path']}/scripts.squid3"
  end
end

