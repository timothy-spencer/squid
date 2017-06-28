
# generate the ssl cert
squidkey = node['squid']['sslbumpkey']
squidcert = node['squid']['sslbumpcert']
squidssldir = node['squid']['config_dir']

package 'gnutls-bin'

template "#{squidssldir}/cert.cfg"

execute "certtool --generate-privkey --outfile #{squidkey}" do
  cwd squidssldir
  creates squidkey
end

execute "certtool --generate-self-signed --load-privkey #{squidkey} --outfile #{squidcert} --template cert.cfg" do
  cwd squidssldir
  creates squidcert
end

# write pubkey into node
ruby_block 'storepubkey' do
  block do
    node.default['sslbump']['pubkey'] = File.read(squidcert)
  end
end
