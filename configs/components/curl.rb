component 'curl' do |pkg, settings, platform|
  pkg.version '7.57.0'
  pkg.md5sum 'c7aab73aaf5e883ca1d7518f93649dc2'
  pkg.url "https://curl.haxx.se/download/curl-#{pkg.get_version}.tar.gz"
  pkg.mirror "#{settings[:buildsources_url]}/curl-#{pkg.get_version}.tar.gz"

  if platform.is_aix?
    # Patch to disable _ALL_SOURCE when including select.h from multi.c. See patch for details.
    pkg.apply_patch 'resources/patches/curl/curl-7.55.1-aix-poll.patch'
  end

  pkg.build_requires "openssl"
  pkg.build_requires "puppet-ca-bundle"

  if platform.is_cross_compiled_linux?
    pkg.build_requires 'runtime'
    pkg.environment "PATH" => "/opt/pl-build-tools/bin:$$PATH:#{settings[:bindir]}"
    pkg.environment "PKG_CONFIG_PATH" => "/opt/puppetlabs/puppet/lib/pkgconfig"
    pkg.environment "PATH" => "/opt/pl-build-tools/bin:$$PATH"
  elsif platform.is_windows?
    pkg.build_requires "runtime"

    pkg.environment "PATH" => "$$(cygpath -u #{settings[:gcc_bindir]}):$$PATH"
    pkg.environment "CYGWIN" => settings[:cygwin]
  else
    pkg.environment "PATH" => "/opt/pl-build-tools/bin:$$PATH:#{settings[:bindir]}"
  end

  pkg.configure do
    ["CPPFLAGS='#{settings[:cppflags]}' \
      LDFLAGS='#{settings[:ldflags]}' \
     ./configure --prefix=#{settings[:prefix]} \
        --with-ssl=#{settings[:prefix]} \
        --enable-threaded-resolver \
        --disable-ldap \
        --disable-ldaps \
        --with-ca-bundle=#{settings[:prefix]}/ssl/cert.pem \
        #{settings[:host]}"]
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"]
  end
end
