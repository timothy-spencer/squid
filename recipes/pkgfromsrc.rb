# install squid pkg from src
# Technically, these diladele people have a repo with the packages in them
# but who knows whether they've put nasty stuff in their build, so we are
# building this ourselves.  They have two patches which are safe and ought
# to be easy to audit any time we want to.

package 'git'

directory "#{Chef::Config['file_cache_path']}/squid-ubuntu" do
  user 'ubuntu'
end

git "#{Chef::Config['file_cache_path']}/squid-ubuntu" do
  repository 'https://github.com/timothy-spencer/squid-ubuntu'
  user 'ubuntu'
end


# execute the build/install scripts (some need root, some !root)
execute "/bin/bash ./02_tools.sh" do
  cwd "#{Chef::Config['file_cache_path']}/squid-ubuntu/src/ubuntu14/scripts.squid3"
end

execute "/bin/bash ./03_build_ecap.sh" do
  cwd "#{Chef::Config['file_cache_path']}/squid-ubuntu/src/ubuntu14/scripts.squid3"
  user 'ubuntu'
end

execute "/bin/bash ./04_install_ecap.sh" do
  cwd "#{Chef::Config['file_cache_path']}/squid-ubuntu/src/ubuntu14/scripts.squid3"
end

execute "/bin/bash ./05_build_squid.sh" do
  cwd "#{Chef::Config['file_cache_path']}/squid-ubuntu/src/ubuntu14/scripts.squid3"
  user 'ubuntu'
end

execute "/bin/bash ./06_install_squid.sh" do
  cwd "#{Chef::Config['file_cache_path']}/squid-ubuntu/src/ubuntu14/scripts.squid3"
end

