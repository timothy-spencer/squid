
# generate the ssl cert
squidkey = node['squid']['sslbumpkey']
squidcert = node['squid']['sslbumpcert']
squidssldir = node['squid']['config_dir']

execute 'apt-get update'
package 'gnutls-bin'

directory squidssldir
template "#{squidssldir}/cert.cfg"

execute "certtool --generate-privkey --outfile #{squidkey}" do
  cwd squidssldir
  creates squidkey
end

execute "certtool --generate-self-signed --load-privkey #{squidkey} --outfile #{squidcert} --template cert.cfg" do
  cwd squidssldir
  creates squidcert
end

execute "cat #{squidkey} #{squidcert} > #{squidcert}.ca" do
  cwd squidssldir
  creates "#{squidcert}.ca"
end

# write pubkey into node
ruby_block 'storepubkey' do
  block do
    node.default['sslbump']['pubkey'] = File.read(squidcert)
  end
end

