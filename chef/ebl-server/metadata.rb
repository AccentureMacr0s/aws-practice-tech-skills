name 'ebl-server'
maintainer 'AWS Practice Team'
maintainer_email 'practice@example.com'
license 'Apache-2.0'
description 'Installs/Configures EBL server application on Windows'
long_description 'Chef cookbook for deploying and configuring EBL server application with certificate management and Active Directory integration'
version '0.1.0'
chef_version '>= 16.0'

# Platform support
supports 'windows'

# Cookbook dependencies
depends 'ad_join', '~> 1.0'
depends 'windows', '~> 4.0'
depends 'chef-vault', '~> 4.0'

# Issues URL
issues_url 'https://github.com/AccentureMacr0s/aws-practice-tech-skills/issues'

# Source URL
source_url 'https://github.com/AccentureMacr0s/aws-practice-tech-skills'