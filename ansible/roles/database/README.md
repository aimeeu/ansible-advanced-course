# Ansible Role: Database

## Description

This role installs and configures MySQL database server for a Flask web application. It handles MySQL installation, service management, database creation, and user configuration with appropriate privileges.

## Requirements

- Target system: Ubuntu/Debian-based Linux distributions
- Ansible version: 2.2 or higher
- Privilege escalation: This role requires `become: true` (sudo access)
- **Role Dependencies**: This role depends on the `os-config` role, which will be automatically executed first

## Role Dependencies

This role has a dependency on the `os-config` role, which installs required system packages including:
- Python 3 and development tools
- PyMySQL connector
- MySQL client development libraries

The dependency is automatically handled through the role's `meta/main.yml` file, so you don't need to explicitly include the `os-config` role when using this role.

## Role Variables

This role uses the following variables that should be defined in your playbook or vars file:

### Required Variables

- `db_name` - Name of the database to create
  - Default: None (must be provided)
  - Example: `employee_db`

- `db_user` - Database username to create
  - Default: None (must be provided)
  - Example: `app_user`

- `db_password` - Password for the database user
  - Default: None (must be provided)
  - Example: `Passw0rd`
  - **Security Note**: Use Ansible Vault for production passwords

### Example Variable Definition

```yaml
# vars.yml
---
db_name: employee_db
db_user: app_user
db_password: Passw0rd
```

## What This Role Does

### 1. Install Database Packages
Installs MySQL server and client packages:
- `mysql-server` - MySQL database server
- `mysql-client` - MySQL command-line client

### 2. Start Database Services
- Starts the MySQL service
- Enables MySQL to start on boot
- Ensures the service is running

### 3. Create Application Database
- Creates the database specified by `{{ db_name }}`
- Uses Unix socket authentication for secure local connection
- Idempotent - safe to run multiple times

### 4. Create Database User
- Creates user specified by `{{ db_user }}`
- Sets password specified by `{{ db_password }}`
- Grants ALL privileges on the application database
- Allows connections from any host (`%`)
- Uses Unix socket for secure authentication during setup

## Example Playbook

### Basic Usage

```yaml
---
- name: Deploy database
  hosts: database_servers
  vars_files:
    - vars.yml
  roles:
    - database
```

### With Explicit Variables

```yaml
---
- name: Deploy database with inline vars
  hosts: database_servers
  vars:
    db_name: myapp_db
    db_user: myapp_user
    db_password: SecurePassword123
  roles:
    - database
```

### Complete Application Deployment

```yaml
---
- name: Deploy complete web application
  hosts: web_servers
  vars_files:
    - vars.yml
  roles:
    - database  # os-config role runs automatically first
    - web
```

### With Pre-tasks

```yaml
---
- name: Deploy with system preparation
  hosts: database_servers
  vars_files:
    - vars.yml
  pre_tasks:
    - name: Update apt cache
      ansible.builtin.apt:
        update_cache: true
        cache_valid_time: 3600
      become: true
  roles:
    - database
```

## Role Structure

```
database/
├── README.md             # This file
├── defaults/
│   └── main.yml          # Default variables (currently empty)
├── files/                # Static files (currently empty)
├── handlers/
│   └── main.yml          # Handlers (currently empty)
├── meta/
│   └── main.yml          # Role metadata and dependencies
├── tasks/
│   └── main.yml          # Main task file with database setup
├── templates/            # Jinja2 templates (currently empty)
├── tests/
│   └── test.yml          # Test playbook
└── vars/
    └── main.yml          # Role variables (currently empty)
```

## Tasks Overview

### 1. Install database
- Uses `apt` module to install MySQL packages
- Requires privilege escalation
- Installs both server and client

### 2. Start database services
- Uses `service` module to manage MySQL
- Sets `state: started` to ensure service is running
- Sets `enabled: true` to start on boot

### 3. Create application database
- Uses `ansible.mysql.mysql_db` module
- Connects via Unix socket for security
- Creates database if it doesn't exist

### 4. Create database user
- Uses `ansible.mysql.mysql_user` module
- Creates user with specified credentials
- Grants full privileges on application database
- Allows remote connections

## Security Considerations

### Password Management

**Development:**
```yaml
# vars.yml (not encrypted)
db_password: Passw0rd
```

**Production:**
```bash
# Encrypt the vars file
ansible-vault encrypt vars.yml

# Run playbook with vault password
ansible-playbook -i inventory playbook.yml --ask-vault-pass
```

### Database User Privileges

The role grants `ALL` privileges on the application database. For production, consider:

```yaml
# More restrictive privileges
priv: "{{ db_name }}.*:SELECT,INSERT,UPDATE,DELETE"
```

### Remote Access

The role allows connections from any host (`host: "%"`). For production:

```yaml
# Restrict to specific hosts
host: "192.168.1.%"  # Subnet
host: "app-server.example.com"  # Specific host
```

## Platform Support

### Tested On

- Ubuntu 20.04 LTS (Focal Fossa)
- Ubuntu 22.04 LTS (Jammy Jellyfish)
- Ubuntu 24.04 LTS (Noble Numbat)
- Debian 11 (Bullseye)
- Debian 12 (Bookworm)

### MySQL Versions

- MySQL 8.0 (Ubuntu 22.04+, Debian 12+)
- MySQL 5.7 (Ubuntu 20.04, Debian 11)

## Customization

### Using Different Database Names

```yaml
# Development environment
db_name: myapp_dev
db_user: dev_user
db_password: dev_password

# Production environment
db_name: myapp_prod
db_user: prod_user
db_password: "{{ vault_db_password }}"
```

### Adding Database Configuration

Create a template for MySQL configuration:

```yaml
# tasks/main.yml
- name: Configure MySQL
  ansible.builtin.template:
    src: my.cnf.j2
    dest: /etc/mysql/mysql.conf.d/custom.cnf
  notify: restart mysql
```

### Adding Handlers

```yaml
# handlers/main.yml
---
- name: restart mysql
  ansible.builtin.service:
    name: mysql
    state: restarted
  become: true
```

## Troubleshooting

### MySQL Service Won't Start

Check MySQL logs:
```bash
sudo journalctl -u mysql -n 50
sudo tail -f /var/log/mysql/error.log
```

Common issues:
- Port 3306 already in use
- Insufficient disk space
- Corrupted data files

### Authentication Errors

If you see "Access denied" errors:

1. Check if MySQL is using Unix socket authentication:
```bash
sudo mysql -e "SELECT user, host, plugin FROM mysql.user;"
```

2. Verify the user was created:
```bash
sudo mysql -e "SELECT user, host FROM mysql.user WHERE user='app_user';"
```

3. Test connection:
```bash
mysql -u app_user -p -h localhost employee_db
```

### Database Not Created

Verify database exists:
```bash
sudo mysql -e "SHOW DATABASES;"
```

Check for errors in task output:
```bash
ansible-playbook -i inventory playbook.yml -vvv
```

### Permission Issues

If the role fails with permission errors:
1. Ensure `become: true` is set in the playbook
2. Verify sudo access: `sudo -v`
3. Check if passwordless sudo is configured

## Performance Considerations

### MySQL Configuration

For production, tune MySQL settings in `/etc/mysql/mysql.conf.d/mysqld.cnf`:

```ini
[mysqld]
max_connections = 200
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M
```

### Connection Pooling

Consider using connection pooling in your application:
- SQLAlchemy pool settings
- Flask-MySQLDB connection pooling

## Testing

### Manual Testing

```bash
# Test role execution
ansible-playbook -i inventory tests/test.yml

# Verify MySQL is running
ansible database_servers -m shell -a "systemctl status mysql"

# Check database exists
ansible database_servers -m shell -a "sudo mysql -e 'SHOW DATABASES;'"

# Test user access
ansible database_servers -m shell -a "mysql -u app_user -pPassw0rd -e 'USE employee_db; SHOW TABLES;'"
```

### Automated Testing with Molecule

```bash
# Install molecule
pip install molecule molecule-docker

# Run tests
cd roles/database
molecule test
```

## Integration with Other Roles

### OS Config Role

The `os-config` role is automatically executed before this role due to the dependency declaration in `meta/main.yml`. It installs:
- Python 3 and pip
- PyMySQL connector
- MySQL development libraries

### Web Role

The `web` role typically depends on this role:

```yaml
# roles/web/meta/main.yml
dependencies:
  - role: database
```

## Backup and Recovery

### Creating Backups

Add a backup task:

```yaml
- name: Backup database
  ansible.builtin.shell: |
    mysqldump -u root {{ db_name }} > /backup/{{ db_name }}_$(date +%Y%m%d).sql
  become: true
```

### Restoring from Backup

```yaml
- name: Restore database
  ansible.builtin.shell: |
    mysql -u root {{ db_name }} < /backup/{{ db_name }}_backup.sql
  become: true
```

## Monitoring

### Health Checks

```yaml
- name: Check MySQL status
  ansible.builtin.command: mysqladmin ping
  register: mysql_ping
  changed_when: false
```

### Performance Monitoring

```yaml
- name: Get MySQL status
  ansible.builtin.shell: mysql -e "SHOW STATUS;"
  register: mysql_status
  changed_when: false
```

## Migration Considerations

### From MySQL 5.7 to 8.0

- Authentication plugin changes
- SQL mode differences
- Character set defaults

### Schema Migrations

Consider using:
- Alembic (Python)
- Flyway
- Liquibase

## License

MIT

## Author Information

This role was created as part of an Ansible Advanced Course for educational purposes.

## Contributing

To contribute to this role:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Changelog

### Version 1.0.0 (Current)

- Initial release
- MySQL installation and configuration
- Database and user creation
- Dependency on dependencies role
- Ansible-lint compliant

## Related Roles

- **os-config** - Installs system dependencies (automatically included)
- **web** - Deploys Flask web application

## Support

For issues, questions, or contributions, please refer to the course materials or contact the instructor.
