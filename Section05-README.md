# Section 05: Ansible Roles - Complete Role-Based Architecture

## Overview

This section demonstrates the transformation of a modular playbook into a complete role-based architecture. All tasks have been organized into reusable Ansible roles with proper dependencies, variables, and documentation.

## Project Structure

```
ansible/
├── playbook.yml                          # Main orchestrator playbook
├── ansible-connectivity.yml              # Connectivity test playbook
├── inventory.ini                         # Ansible inventory
├── ansible.cfg                           # Ansible configuration
├── app.py                               # Flask application source
├── tasks/                               # Remaining task files
│   └── deploy-web.yml                   # Web deployment tasks (to be moved)
└── roles/                               # Ansible roles directory
    ├── os-config/                       # OS configuration role
    │   ├── README.md                    # Comprehensive documentation
    │   ├── tasks/
    │   │   └── main.yml                 # System package installation
    │   ├── meta/
    │   │   └── main.yml                 # Role metadata
    │   ├── defaults/
    │   ├── handlers/
    │   ├── vars/
    │   └── ...
    ├── database/                        # Database role
    │   ├── README.md                    # Comprehensive documentation
    │   ├── tasks/
    │   │   └── main.yml                 # MySQL setup and configuration
    │   ├── meta/
    │   │   └── main.yml                 # Depends on os-config
    │   ├── vars/
    │   │   └── main.yml                 # Database variables
    │   ├── defaults/
    │   ├── handlers/
    │   └── ...
    └── web/                             # Web application role
        ├── README.md                    # Comprehensive documentation
        ├── tasks/
        │   └── main.yml                 # Flask app deployment
        ├── meta/
        │   └── main.yml                 # Role metadata
        ├── defaults/
        ├── handlers/
        ├── vars/
        └── ...
```

## Role Architecture

### Role Hierarchy and Dependencies

```
┌─────────────────┐
│   os-config     │  ← Base role (no dependencies)
│  (System Deps)  │
└────────┬────────┘
         │
         │ depends on
         ↓
┌─────────────────┐
│    database     │  ← Depends on os-config
│  (MySQL Setup)  │
└─────────────────┘

┌─────────────────┐
│      web        │  ← Independent (but requires database)
│  (Flask App)    │
└─────────────────┘
```

### Execution Flow

When you run the playbook:

1. **Connectivity Test** - `ansible-connectivity.yml` verifies all hosts are reachable
2. **OS Config Role** - Automatically executed (dependency of database role)
   - Installs Python 3, pip, build tools
   - Installs PyMySQL connector
   - Installs MySQL development libraries
3. **Database Role** - Explicitly called in playbook
   - Installs MySQL server and client
   - Starts and enables MySQL service
   - Creates application database
   - Creates database user with privileges
4. **Web Tasks** - Included from tasks file
   - Installs Flask and Flask-MySQLDB
   - Copies application source code
   - Starts Flask application

## Roles Overview

### 1. OS Config Role (`os-config`)

**Purpose**: Configure operating system and install system-level dependencies

**Key Features**:
- Installs Python 3 ecosystem
- Installs build essentials
- Installs MySQL client libraries
- No dependencies on other roles

**Variables**: None (uses fixed package list)

**Documentation**: [`roles/os-config/README.md`](ansible/roles/os-config/README.md)

**Tasks**:
```yaml
- Install web app dependencies (Python, pip, build tools, MySQL libs)
```

### 2. Database Role (`database`)

**Purpose**: Install and configure MySQL database server

**Key Features**:
- Automatic dependency on `os-config` role
- Self-contained with own variables
- Creates database and user
- Uses Unix socket authentication

**Variables** (in `roles/database/vars/main.yml`):
- `database_db_name: employee_db`
- `database_db_user: app_user`
- `database_db_password: Passw0rd`

**Documentation**: [`roles/database/README.md`](ansible/roles/database/README.md)

**Tasks**:
```yaml
- Install MySQL server and client
- Start and enable MySQL service
- Create application database
- Create database user with privileges
```

**Role Dependency**:
```yaml
# roles/database/meta/main.yml
dependencies:
  - role: os-config
```

### 3. Web Role (`web`)

**Purpose**: Deploy Flask web application

**Key Features**:
- Installs Flask dependencies via pip
- Handles PEP 668 compliance (Python 3.12+)
- Manages application lifecycle
- Prevents duplicate instances

**Variables**: None (configuration in app.py)

**Documentation**: [`roles/web/README.md`](ansible/roles/web/README.md)

**Tasks**:
```yaml
- Install Flask and Flask-MySQLDB
- Copy application source code
- Check if Flask is running
- Start Flask application
```

## Main Playbook Structure

```yaml
---
# Test connectivity first
- name: Test Ansible connectivity
  ansible.builtin.import_playbook: ansible-connectivity.yml

# Deploy application
- name: Deploy a web application
  hosts: web01
  roles:
    - database  # os-config runs automatically as dependency
  tasks:
    - name: Include deploy web tasks
      ansible.builtin.include_tasks: tasks/deploy-web.yml
```

## Key Improvements from Previous Sections

### Section 02 → Section 03
- Moved from monolithic playbook to modular task files
- Introduced external variables file
- Improved maintainability

### Section 03 → Section 05
- Converted task files to reusable roles
- Implemented role dependencies
- Moved variables into roles
- Added comprehensive documentation
- Renamed `dependencies` → `os-config` for clarity
- Followed Ansible best practices

## Variable Management

### Role Variable Naming Convention

Variables within roles must be prefixed with the role name to prevent conflicts:

```yaml
# ✅ Correct (in database role)
database_db_name: employee_db
database_db_user: app_user
database_db_password: Passw0rd

# ❌ Incorrect (would fail ansible-lint)
db_name: employee_db
db_user: app_user
db_password: Passw0rd
```

### Variable Precedence

Variables are now contained within roles:
1. Role defaults (`defaults/main.yml`) - Lowest priority
2. Role vars (`vars/main.yml`) - Higher priority
3. Playbook vars - Highest priority

## Running the Playbook

### Basic Execution

```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml
```

### Execution Flow

```
1. Import ansible-connectivity.yml
   └─ Test connectivity to all hosts

2. Execute database role on web01
   ├─ Auto-execute os-config role (dependency)
   │  └─ Install system packages
   ├─ Install MySQL
   ├─ Start MySQL service
   ├─ Create database
   └─ Create database user

3. Include deploy-web.yml tasks
   ├─ Install Flask dependencies
   ├─ Copy application code
   └─ Start Flask application
```

### Selective Execution

Run only specific roles using tags (if implemented):

```bash
# Only database setup
ansible-playbook -i inventory.ini playbook.yml --tags database

# Skip database setup
ansible-playbook -i inventory.ini playbook.yml --skip-tags database
```

## Role Benefits

### 1. Reusability
- Roles can be used across multiple playbooks
- Easy to share between projects
- Can be published to Ansible Galaxy

### 2. Encapsulation
- Each role is self-contained
- Variables scoped to roles
- Clear dependencies

### 3. Maintainability
- Easier to update individual components
- Clear separation of concerns
- Better organization

### 4. Testing
- Roles can be tested independently
- Use Molecule for automated testing
- Easier to debug issues

### 5. Documentation
- Each role has comprehensive README
- Clear usage examples
- Troubleshooting guides

### 6. Dependency Management
- Automatic dependency resolution
- No need to manually order roles
- Prevents missing dependencies

## Ansible Lint Compliance

All roles and playbooks pass ansible-lint validation:

```bash
cd ansible
ansible-lint playbook.yml
```

**Results**:
- ✅ 0 failures
- ✅ 0 warnings
- ✅ Production profile standards met

### Key Compliance Features

1. **FQCN (Fully Qualified Collection Names)**
   - All modules use `ansible.builtin.*` prefix
   - Example: `ansible.builtin.apt`, `ansible.builtin.service`

2. **Task Naming**
   - All tasks have descriptive names
   - Include tasks have names

3. **Variable Naming**
   - Role variables prefixed with role name
   - Example: `database_db_name`

4. **Comment Formatting**
   - All comments have space after `#`
   - Example: `# SPDX-License-Identifier: MIT-0`

5. **Metadata Standards**
   - Proper author, description, license
   - String format for version numbers
   - Example: `min_ansible_version: "2.2"`

6. **YAML Formatting**
   - Proper indentation (2 spaces)
   - Newline at end of files
   - No trailing spaces

## Security Considerations

### Development vs Production

⚠️ **This setup is for development/learning purposes**

For production, implement:

1. **Ansible Vault** for sensitive data:
```bash
ansible-vault encrypt roles/database/vars/main.yml
ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass
```

2. **Production WSGI Server** (not Flask dev server):
```yaml
- Gunicorn
- uWSGI
- mod_wsgi
```

3. **Reverse Proxy**:
```yaml
- Nginx
- Apache
- HAProxy
```

4. **SSL/TLS Certificates**:
```yaml
- Let's Encrypt
- Commercial certificates
```

5. **Firewall Configuration**:
```yaml
- UFW
- iptables
- Cloud security groups
```

## Testing

### Role Testing with Molecule

```bash
# Install Molecule
pip install molecule molecule-docker

# Test individual role
cd roles/database
molecule test

# Test all roles
for role in roles/*/; do
  cd "$role"
  molecule test
  cd ../..
done
```

### Integration Testing

```bash
# Test complete deployment
ansible-playbook -i inventory.ini playbook.yml --check

# Verify services
ansible web01 -i inventory.ini -m shell -a "systemctl status mysql"
ansible web01 -i inventory.ini -m shell -a "ps aux | grep flask"
```

## Troubleshooting

### Role Not Found

If you see "role not found" errors:
```bash
# Verify role directory structure
ls -la ansible/roles/

# Check role name in playbook matches directory name
```

### Variable Not Defined

If variables are undefined:
```bash
# Check variable names match in:
# - roles/database/vars/main.yml
# - roles/database/tasks/main.yml

# Verify variable prefix matches role name
```

### Dependency Not Executing

If role dependencies don't run:
```bash
# Check meta/main.yml has correct dependency
cat roles/database/meta/main.yml

# Verify dependency role exists
ls -la roles/os-config/
```

## Next Steps

### Future Enhancements

1. **Convert Web Tasks to Role**
   - Move `tasks/deploy-web.yml` to `roles/web/tasks/main.yml`
   - Update playbook to use web role

2. **Add Handlers**
   - Restart services on configuration changes
   - Reload applications on code updates

3. **Implement Tags**
   - Add tags for selective execution
   - Enable/disable specific components

4. **Add Templates**
   - Use Jinja2 templates for configuration files
   - Make configurations more flexible

5. **Create Role Collections**
   - Package roles as Ansible Collection
   - Publish to Ansible Galaxy

6. **Add CI/CD Pipeline**
   - Automated testing with Molecule
   - Lint checking in CI
   - Automated deployment

## Best Practices Applied

### ✅ Role Organization
- Clear directory structure
- Consistent naming conventions
- Proper file organization

### ✅ Documentation
- Comprehensive README for each role
- Usage examples
- Troubleshooting guides

### ✅ Variable Management
- Variables scoped to roles
- Proper naming with prefixes
- No global variables

### ✅ Dependency Management
- Explicit role dependencies
- Automatic dependency resolution
- No circular dependencies

### ✅ Idempotency
- All tasks are idempotent
- Safe to run multiple times
- No unintended side effects

### ✅ Error Handling
- Proper use of `ignore_errors`
- Conditional execution with `when`
- Process checking before starting

## Resources

### Official Documentation
- [Ansible Roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)
- [Role Dependencies](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#using-role-dependencies)
- [Ansible Galaxy](https://galaxy.ansible.com/)
- [Ansible Lint](https://ansible-lint.readthedocs.io/)

### Role Documentation
- [OS Config Role README](ansible/roles/os-config/README.md)
- [Database Role README](ansible/roles/database/README.md)
- [Web Role README](ansible/roles/web/README.md)

### Previous Sections
- [Section 02 README](Section02-README.md) - Initial playbook
- [Section 03 README](Section3-README.md) - Modular tasks

## Summary

This section demonstrates a complete role-based architecture with:

- ✅ Three well-organized roles (os-config, database, web)
- ✅ Automatic dependency management
- ✅ Role-scoped variables with proper naming
- ✅ Comprehensive documentation for each role
- ✅ Ansible-lint compliance (0 failures, 0 warnings)
- ✅ Production-ready structure
- ✅ Clear separation of concerns
- ✅ Reusable and maintainable code

The transformation from monolithic playbook to role-based architecture provides a solid foundation for scaling and maintaining complex Ansible projects.

## License

This project is part of an Ansible advanced course and is provided for educational purposes.

## Author

Created as part of an Ansible Advanced Course for educational purposes.