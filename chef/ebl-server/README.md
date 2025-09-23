# EBL Server Chef Cookbook

This Chef cookbook provides automated deployment and configuration of the EBL (Enterprise Business Logic) server application on Windows Server 2022.

## Description

The EBL Server cookbook handles:
- EBL application installation and configuration
- SSL certificate management via AWS Secrets Manager
- Active Directory domain integration
- Windows service configuration
- Firewall rule management
- Health monitoring and logging
- Maintenance automation

## Supported Platforms

- Windows Server 2022
- Windows Server 2019 (tested compatibility)

## Requirements

### Chef Version
- Chef >= 16.0

### Platform Dependencies
- Windows operating system
- PowerShell 5.1 or later
- .NET Framework 4.8
- AWS CLI (installed automatically)

### Cookbooks
- `ad_join` ~> 1.0 - For Active Directory integration
- `windows` ~> 4.0 - For Windows-specific resources
- `chef-vault` ~> 4.0 - For secrets management

## Attributes

### Application Settings
- `node['ebl_server']['app_name']` - Application name (default: 'EBL Application')
- `node['ebl_server']['version']` - Application version (default: '1.0.0')
- `node['ebl_server']['install_dir']` - Installation directory (default: 'C:\\Program Files\\EBL')
- `node['ebl_server']['service_name']` - Windows service name (default: 'EBLService')

### Certificate Management
- `node['ebl_server']['certificates']['enabled']` - Enable certificate management (default: true)
- `node['ebl_server']['certificates']['ssl_cert_secret']` - AWS Secrets Manager secret name
- `node['ebl_server']['certificates']['aws_region']` - AWS region for Secrets Manager

### Active Directory
- `node['ebl_server']['ad_integration']['enabled']` - Enable AD integration (default: false)
- `node['ebl_server']['ad_integration']['domain']` - Domain to join
- `node['ebl_server']['ad_integration']['admin_groups']` - Domain groups to add to local administrators

### Firewall
- `node['ebl_server']['firewall']['enabled']` - Enable firewall configuration (default: true)
- `node['ebl_server']['firewall']['ports']` - Array of ports to open

## Usage

### Basic Usage

Include the default recipe in your node's run list:

```ruby
{
  "run_list": ["recipe[ebl-server::default]"]
}
```

### Advanced Configuration

```ruby
{
  "ebl_server": {
    "app_name": "MyEBLApp",
    "version": "2.0.0",
    "certificates": {
      "enabled": true,
      "ssl_cert_secret": "myapp/ssl-certificate",
      "aws_region": "us-west-2"
    },
    "ad_integration": {
      "enabled": true,
      "domain": "mydomain.local",
      "admin_groups": ["Domain Admins", "MyApp Administrators"]
    },
    "firewall": {
      "enabled": true,
      "ports": [
        {"name": "MyApp-HTTP", "port": 8080, "protocol": "TCP"},
        {"name": "MyApp-HTTPS", "port": 8443, "protocol": "TCP"}
      ]
    }
  }
}
```

## Recipes

### default
Main orchestration recipe that includes all necessary sub-recipes based on configuration.

### prerequisites
Sets up Windows features, directories, and service user account.

### install
Downloads and installs the EBL application, creates Windows service.

### configure
Configures application settings, logging, and maintenance tasks.

### EBL
Core EBL application management, performance monitoring, and health checks.

### certificates
Manages SSL certificates from AWS Secrets Manager.

### ad_join
Handles Active Directory domain join and group management.

### firewall
Configures Windows Firewall rules for the EBL application.

## Test Kitchen

This cookbook includes Test Kitchen configuration for testing on AWS EC2 Windows Server 2022 instances.

### Prerequisites for Testing
- AWS credentials configured
- Appropriate AWS subnet and security group IDs
- Windows AMI access in your AWS account

### Environment Variables
```bash
export AWS_SUBNET_ID="subnet-12345678"
export AWS_SECURITY_GROUP_ID="sg-12345678"
export KITCHEN_PASSWORD="YourTestPassword123!"
export AD_DOMAIN="test.local"
export AD_USERNAME="admin"
export AD_PASSWORD="password"
export SSL_CERT_SECRET="test/ssl-certificate"
```

### Running Tests
```bash
# List available instances
kitchen list

# Converge a specific instance
kitchen converge windows-2022

# Run tests
kitchen verify windows-2022

# Destroy instance
kitchen destroy windows-2022
```

## PowerShell Management Scripts

The cookbook installs several PowerShell scripts for ongoing management:

### Maintenance Script
Location: `C:\Program Files\EBL\scripts\maintenance.ps1`
```powershell
# Start the service
.\maintenance.ps1 -Action Start

# Backup application data
.\maintenance.ps1 -Action Backup

# Cleanup old files
.\maintenance.ps1 -Action Cleanup
```

### Health Check Script
Location: `C:\Program Files\EBL\scripts\health_check.ps1`
```powershell
# Quick health check
.\health_check.ps1

# Detailed health check with event logging
.\health_check.ps1 -Detailed -WriteToEventLog
```

### Active Directory Management
Location: `C:\Program Files\EBL\scripts\ad_management.ps1`
```powershell
# Check domain status
.\ad_management.ps1 -Action Status

# Test domain connectivity
.\ad_management.ps1 -Action TestConnection

# Manage admin groups
.\ad_management.ps1 -Action ManageGroups
```

### Firewall Management
Location: `C:\Program Files\EBL\scripts\firewall_management.ps1`
```powershell
# Check firewall status
.\firewall_management.ps1 -Action Status

# Test application ports
.\firewall_management.ps1 -Action TestPorts

# Add EBL firewall rules
.\firewall_management.ps1 -Action AddRules
```

### EBL Application Control Scripts
Location: `C:\Program Files\EBL\scripts\`

#### Start EBL
```powershell
# Start EBL application with prerequisites check
.\start_ebl.ps1

# Force restart if already running
.\start_ebl.ps1 -Force

# Verbose startup with detailed logging
.\start_ebl.ps1 -Verbose
```

#### Stop EBL
```powershell
# Graceful shutdown
.\stop_ebl.ps1

# Force immediate shutdown
.\stop_ebl.ps1 -Force

# Shutdown with custom timeout
.\stop_ebl.ps1 -Timeout 60
```

#### Restart EBL
```powershell
# Simple restart
.\restart_ebl.ps1

# Restart with dependency checks
.\restart_ebl.ps1 -CheckDependencies

# Force restart with dependency validation
.\restart_ebl.ps1 -Force -CheckDependencies -Timeout 120
```
```

## Security Considerations

1. **Service Account**: The EBL service runs under a dedicated service account with minimal privileges
2. **Firewall**: Only necessary ports are opened, with specific rules for the EBL application
3. **Certificates**: SSL certificates are retrieved securely from AWS Secrets Manager
4. **Logging**: Comprehensive logging with both file and Windows Event Log integration
5. **Active Directory**: Domain integration follows security best practices

## Troubleshooting

### Common Issues

1. **Service Won't Start**
   - Check service account permissions
   - Verify application dependencies are installed
   - Review Windows Event Log for error details

2. **Certificate Issues**
   - Ensure AWS credentials are configured
   - Verify Secrets Manager secret exists and contains valid certificate data
   - Check certificate store permissions

3. **Domain Join Problems**
   - Verify network connectivity to domain controllers
   - Check domain credentials
   - Ensure time synchronization with domain

### Log Locations
- Application logs: `C:\ProgramData\EBL\logs\`
- Chef logs: `C:\chef\cache\chef-client.log`
- Windows Event Log: Application log, source "EBL Application"

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

Licensed under the Apache License, Version 2.0.

## Author

AWS Practice Team