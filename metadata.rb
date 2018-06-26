# frozen_string_literal: true

name 'snu_graphite'
maintainer 'Socrata, Inc.'
maintainer_email 'sysadmin@socrata.com'
license 'Apache-2.0'
description 'Installs/configures snu_graphite'
long_description 'Installs/configures snu_graphite'
version '0.0.1'
chef_version '>= 12.14'

source_url 'https://github.com/socrata-cookbooks/snu_graphite'
issues_url 'https://github.com/socrata-cookbooks/snu_graphite/issues'

depends 'poise-python', '>= 1.5'
depends 'runit', '>= 1.2'

supports 'ubuntu'
supports 'debian'
# TODO: Additional platform support(?)
# supports 'redhat'
# supports 'centos'
# supports 'scientific'
# supports 'fedora'
# supports 'amazon'
