# XXX  This has only been tested in ubuntu 14.04.  Paths/packages may not work on other distros/versions.

#################################################
# set up build dependencies
execute 'apt-get update'

%w{ libecap2-dev libecap2 }.each do |p|
  package p do
    action [:remove,:purge]
  end
end

%w{ libpam0g-dev libldap2-dev libsasl2-dev libdb-dev cdbs debhelper libcppunit-dev libkrb5-dev comerr-dev libcap2-dev libexpat1-dev libxml2-dev autotools-dev libltdl-dev dpkg-dev pkg-config libnetfilter-conntrack-dev lsb-release devscripts build-essential fakeroot debhelper dh-autoreconf cdbs nettle-dev libgnutls28-dev libssl-dev libdbi-perl }.each do |p|
  package p
end

#################################################
# install modern libecap
remote_file "#{Chef::Config['file_cache_path']}/libecap.tar.gz" do
  source node['squid']['libecap_source_tarball']
end

execute "tar zxpf #{Chef::Config['file_cache_path']}/libecap.tar.gz" do
  cwd Chef::Config['file_cache_path']
end

libecapversion = node['squid']['libecap_source_tarball'].gsub(/.*\/(libecap.*).tar.gz/,'\1')
libecapdir = "#{Chef::Config['file_cache_path']}/#{libecapversion}"

execute "./configure" do
  cwd libecapdir
  creates "#{libecapdir}/Makefile"
end

execute 'make' do
  cwd libecapdir
  creates "#{libecapdir}/src/libecap/libecap.la"
end

execute 'make install' do
  cwd libecapdir
  creates '/usr/local/lib/libecap.a'
end


#################################################
# install modern squid using libecap
remote_file "#{Chef::Config['file_cache_path']}/squid.tar.gz" do
  source node['squid']['source_tarball']
end

execute "tar zxpf #{Chef::Config['file_cache_path']}/squid.tar.gz" do
  cwd Chef::Config['file_cache_path']
end

# Got this from the existing squid 3.3 'squid -v', removed MSNT auth option, added openssl/crtd options.
options = "'--build=x86_64-linux-gnu' '--prefix=/usr' '--includedir=${prefix}/include' '--mandir=${prefix}/share/man' '--infodir=${prefix}/share/info' '--sysconfdir=/etc' '--localstatedir=/var' '--libexecdir=${prefix}/lib/squid3' '--srcdir=.' '--disable-maintainer-mode' '--disable-dependency-tracking' '--disable-silent-rules' '--datadir=/usr/share/squid3' '--sysconfdir=/etc/squid3' '--mandir=/usr/share/man' '--enable-inline' '--enable-async-io=8' '--enable-storeio=ufs,aufs,diskd,rock' '--enable-removal-policies=lru,heap' '--enable-delay-pools' '--enable-cache-digests' '--enable-underscores' '--enable-icap-client' '--enable-follow-x-forwarded-for' '--enable-auth-basic=DB,fake,getpwnam,LDAP,NCSA,NIS,PAM,POP3,RADIUS,SASL,SMB' '--enable-auth-digest=file,LDAP' '--enable-auth-negotiate=kerberos,wrapper' '--enable-auth-ntlm=fake,smb_lm' '--enable-external-acl-helpers=file_userip,kerberos_ldap_group,LDAP_group,session,SQL_session,unix_group,wbinfo_group' '--enable-url-rewrite-helpers=fake' '--enable-eui' '--enable-esi' '--enable-icmp' '--enable-zph-qos' '--enable-ecap' '--disable-translation' '--with-swapdir=/var/spool/squid3' '--with-logdir=/var/log/squid3' '--with-pidfile=/var/run/squid3.pid' '--with-filedescriptors=65536' '--with-large-files' '--with-default-user=proxy' '--enable-linux-netfilter' 'build_alias=x86_64-linux-gnu' 'CFLAGS=-g -O2 -fPIE -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wall' 'LDFLAGS=-Wl,-Bsymbolic-functions -fPIE -pie -Wl,-z,relro -Wl,-z,now' 'CPPFLAGS=-D_FORTIFY_SOURCE=2' 'CXXFLAGS=-g -O2 -fPIE -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security' --with-openssl --enable-ssl-crtd"

squidversion = node['squid']['source_tarball'].gsub(/.*\/(squid.*).tar.gz/,'\1')
squiddir = "#{Chef::Config['file_cache_path']}/#{squidversion}"

execute "./configure #{options}" do
  cwd squiddir
  creates "#{squiddir}/Makefile"
end

execute 'make' do
  cwd squiddir
  creates "#{squiddir}/tools/cachemgr.cgi"
end

execute 'make install' do
  cwd squiddir
  creates "/etc/squid3/cachemgr.conf.default"
end

execute '/bin/cp tools/sysvinit/squid.rc /etc/init.d/squid3 ; chmod +x /etc/init.d/squid3' do
  cwd squiddir
  creates '/etc/init.d/squid3'
end

user 'proxy'

directory '/var/log/squid3' do
  owner 'proxy'
end

execute "#{node['squid']['ssl_crtd_path']} -c -s /var/lib/ssl_db ; chown proxy /var/lib/ssl_db" do
  creates '/var/lib/ssl_db'
end

