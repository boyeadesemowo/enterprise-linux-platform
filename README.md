# Enterprise Linux Infrastructure Automation Platform

A hands-on enterprise Linux infrastructure project demonstrating automated provisioning, configuration management, centralized identity, high availability, monitoring, security hardening, and CI validation.

The environment uses RHEL, VMware vSphere, Terraform, Ansible, Active Directory, HAProxy, Zabbix, and GitHub Actions.

## Architecture

```text
GitHub
  |
GitHub Actions CI
  |
Terraform + Ansible
  |
VMware vSphere
  |
  +-- lb01 ---- HAProxy Load Balancer
  |     |
  |     +-- web01 ---- Apache
  |     +-- web02 ---- Apache
  |
  +-- app01 -------- Application Server
  |
  +-- db01 --------- MariaDB

Active Directory
  |
dc01
  |
RHEL Server Fleet

Zabbix
  |
Linux Infrastructure Monitoring
```

## Technologies

- Red Hat Enterprise Linux
- Red Hat Satellite
- VMware vSphere / ESXi
- Terraform
- Ansible
- Microsoft Active Directory
- SSSD / Kerberos / realmd
- HAProxy
- Apache HTTP Server
- MariaDB
- Zabbix
- firewalld
- SELinux
- auditd
- Git
- GitHub Actions

## Infrastructure Provisioning

Terraform provisions the Linux infrastructure on VMware vSphere using reusable VM definitions and static network configuration.

| Server | Function |
|---|---|
| lb01 | HAProxy load balancer |
| web01 | Apache web server |
| web02 | Apache web server |
| app01 | Application server |
| db01 | MariaDB database server |

Infrastructure configuration includes CPU, memory, networking, VMware template cloning, EFI firmware, and VM customization.

## Configuration Management

Ansible provides repeatable configuration management across the Linux server fleet.

Implemented roles include:

- Linux baseline configuration
- Apache web server deployment
- Application service deployment
- MariaDB configuration
- HAProxy load balancing
- Active Directory integration
- Zabbix agent deployment
- Security hardening
- Red Hat Satellite registration
- MariaDB backup automation

The roles are designed to be idempotent so repeated executions maintain the desired configuration without unnecessary changes.

## High Availability

HAProxy distributes HTTP traffic between `web01` and `web02`.

The configuration includes:

- Round-robin load balancing
- Backend HTTP health checks
- Automatic removal of unavailable web servers
- Automatic recovery when a backend becomes healthy again

Failover was validated by stopping Apache on one backend and confirming that traffic continued through the remaining healthy web server.

## Active Directory Integration

The RHEL server fleet is integrated with the `ad.homelab.local` Active Directory domain using SSSD, Kerberos, realmd, and adcli.

A dedicated domain-join service account is used with delegated permissions rather than Domain Administrator privileges.

The integration provides:

- Centralized Active Directory identity resolution
- Kerberos-based domain integration
- Automatic home-directory configuration
- AD group-based sudo authorization
- Automated domain-join configuration through Ansible
- Sensitive join credentials protected with Ansible Vault

## Monitoring

Zabbix Agent 2 is deployed across the Linux server fleet through Ansible.

Monitoring includes:

- Linux operating system monitoring
- Service availability monitoring
- Apache service monitoring
- Trigger-based outage detection
- Recovery detection

Apache failure and recovery were validated by intentionally stopping and restoring the service on a monitored web server.

## Security Hardening

An Ansible security-hardening role applies a custom security baseline across the RHEL server fleet.

Implemented controls include:

- Direct root SSH login disabled
- SSH authentication attempts limited
- SELinux maintained in enforcing mode
- firewalld enabled
- Zabbix agent access restricted by source IP
- auditd enabled
- Persistent auditing of identity files
- Sudo configuration auditing
- SSH configuration auditing

A separate Ansible security-compliance playbook validates the custom baseline across the server fleet.

Audit event capture was also tested to verify that privileged configuration changes can be traced back to the authenticated user.


## Red Hat Satellite Patch Management

The five-node RHEL fleet is centrally registered with Red Hat Satellite using an idempotent Ansible registration role.

The implementation includes:

- Activation-key based host registration
- RHEL 8 BaseOS and AppStream repositories
- Versioned Content Views
- DEV lifecycle promotion
- Centralized repository delivery
- Security-update discovery
- Pilot patch deployment
- Fleet-wide security remediation
- Post-patch validation

Repository content was synchronized and published as a new version of `cv_RHEL8`. The updated Content View was promoted to DEV before security updates were deployed.

Security updates were first applied to a pilot server before rollout across the fleet. Final validation confirmed that no applicable security updates remained against the promoted content.

## Backup and Recovery

MariaDB backup and recovery is automated through Ansible for the `enterprise_app` database on `db01`.

The workflow provides:

- Daily scheduled backups at 2:00 AM
- Compressed SQL database dumps
- Root-protected backup storage
- Seven-day retention
- SHA-256 integrity verification

Recoverability was validated by restoring a generated backup into an isolated temporary database. The restored database was verified before the temporary database was removed, leaving the production `enterprise_app` database unchanged.

## CI Pipeline

GitHub Actions automatically validates infrastructure code on pushes and pull requests.

The CI pipeline performs:

1. Terraform formatting validation
2. Terraform initialization
3. Terraform configuration validation
4. Ansible dependency installation
5. Ansible playbook syntax validation
6. Ansible static analysis with `ansible-lint`

The `main` branch is protected. Changes are submitted through pull requests and the `Validate Infrastructure Code` CI check must pass before merging.

## Repository Structure

```text
enterprise-linux-platform/
├── .github/
│   └── workflows/
│       └── ci.yml
├── ansible/
│   ├── inventory/
│   ├── playbooks/
│   ├── roles/
│   └── requirements.yml
├── scripts/
│   └── validate.sh
├── terraform/
├── .ansible-lint
├── .gitignore
└── README.md
