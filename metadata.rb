name             'postfix-config'
maintainer       'John Ko'
maintainer_email 'git@johnko.ca'
license          'Apache 2.0'
description      'Configures postfix'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

recipe           'postfix-config', 'Configures postfix'
depends          'postfix'
depends          'svc'

%w(freebsd).each do |os|
  supports os
end
