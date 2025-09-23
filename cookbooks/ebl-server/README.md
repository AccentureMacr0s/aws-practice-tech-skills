# EBL Server Cookbook

This Chef cookbook configures Windows Server 2022 for the Enterprise Banking Layer (EBL) application with Active Directory integration and AWS Secrets Manager for certificate management.

## Description

The EBL Server cookbook provides a complete configuration management solution for deploying and configuring EBL.exe applications on Windows Server 2022 instances. It includes:

- EBL application deployment and service configuration
- Active Directory domain join and authentication
- Certificate management using AWS Secrets Manager
- Windows admin group configuration
- Security hardening and compliance settings
- Test Kitchen configuration for Windows 2022 AMI

## Requirements

### Platforms
- Windows Server 2022

### Chef
- Chef 16.0+

### Dependencies
- `windows` cookbook
- `powershell` cookbook  
- `ad_join` cookbook

### AWS Services
- AWS Secrets Manager (for certificates and AD credentials)
- EC2 (for Test Kitchen)

## Attributes

| Attribute | Default | Description |
|-----------|---------|-------------|
| `node['ebl_server']['application_path']` | `C:\Program Files\EBL` | EBL application installation path |
| `node['ebl_server']['service_name']` | `EBLService` | Windows service name for EBL |
| `node['ebl_server']['ad_domain']` | `bank.local` | Active Directory domain name |
| `node['ebl_server']['admin_group']` | `Bank Admins` | AD admin group for local administrators |
| `node['ebl_server']['secrets_manager']['region']` | `us-east-1` | AWS region for Secrets Manager |
| `node['ebl_server']['cert_secret_name']` | `ebl-server/certificates` | Secret name for certificates |
| `node['ebl_server']['ad_secret_name']` | `ebl-server/ad-credentials` | Secret name for AD credentials |

## Recipes

### `ebl-server::default`
Main recipe that includes all other recipes and configures IIS features, application directory, and firewall rules.

### `ebl-server::ebl_application`
Deploys the EBL.exe application, creates Windows service, configures logging, and sets up application user.

### `ebl-server::certificates`
Manages SSL/TLS certificates using AWS Secrets Manager, installs certificates to Windows certificate store, and sets up certificate renewal monitoring.

### `ebl-server::ad_join`
Joins the Windows server to Active Directory domain, configures Kerberos authentication, and sets up LDAP integration.

### `ebl-server::windows_admin_groups`
Creates and configures local Windows admin groups, sets user rights assignments, and configures audit policies.

## Usage

### Basic Usage
Add the cookbook to your node's run list:
```ruby
run_list 'recipe[ebl-server::default]'
```

### With Active Directory Integration
Use the named run list for AD integration:
```ruby
run_list 'recipe[ebl-server::ad_join]', 'recipe[ebl-server::default]'
```

### Test Kitchen
Use Test Kitchen to validate the cookbook:
```bash
kitchen converge
kitchen verify
kitchen destroy
```

## AWS Secrets Manager Configuration

The cookbook expects the following secrets in AWS Secrets Manager:

### Certificate Secret (`ebl-server/certificates`)
```json
{
  "server_cert": "base64_encoded_pfx_file",
  "server_cert_password": "certificate_password",
  "ca_cert": "base64_encoded_ca_certificate"
}
```

### AD Credentials Secret (`ebl-server/ad-credentials`)
```json
{
  "domain": "bank.local",
  "username": "domain_join_user",
  "password": "domain_join_password",
  "ou": "OU=Servers,DC=bank,DC=local"
}
```

## Security Features

- SSL/TLS certificate management with automatic renewal monitoring
- Active Directory authentication and authorization
- Windows audit policy configuration
- PowerShell execution policy hardening
- Firewall rule configuration
- User rights assignment management
- Certificate store security

## Testing

### Unit Tests
Run ChefSpec unit tests:
```bash
cd cookbooks/ebl-server
chef exec rspec
```

### Integration Tests
Run InSpec integration tests with Test Kitchen:
```bash
kitchen verify
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run tests to ensure they pass
6. Submit a pull request

## License

This cookbook is licensed under the MIT License.

## Support

For issues and questions, please create an issue in the GitHub repository.