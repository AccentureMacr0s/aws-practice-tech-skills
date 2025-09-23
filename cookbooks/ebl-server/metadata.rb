name 'ebl-server'
maintainer 'AWS Practice Team'
maintainer_email 'aws-practice@company.com'
license 'MIT'
description 'Configures Windows Server 2022 for EBL application with AD integration'
version '1.0.0'
chef_version '>= 16.0'

supports 'windows'

depends 'windows'
depends 'powershell'

# AD integration dependency - assuming this cookbook exists
depends 'ad_join'

source_url 'https://github.com/AccentureMacr0s/aws-practice-tech-skills'
issues_url 'https://github.com/AccentureMacr0s/aws-practice-tech-skills/issues'

gem 'aws-sdk-secretsmanager', '~> 1.0'