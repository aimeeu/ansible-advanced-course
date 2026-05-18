# Section 03: Ansible Playbook Refactoring - Modular Task Organization

## Overview

This section demonstrates refactoring a monolithic Ansible playbook into a modular structure using separate task files and external variables. This approach improves maintainability, reusability, and follows Ansible best practices.

## Project Structure

```
ansible/
├── playbook.yml                      # Main playbook (orchestrator)
├── vars.yml                          # External variables file
├── inventory.ini                     # Ansible inventory
├── ansible.cfg                       # Ansible configuration
├── app.py                           # Flask application
└── tasks/                           # Modular task files
    ├── install-dependencies.yml     # System dependencies installation
    ├── deploy-database.yml          # Database setup and configuration
    └── deploy-web.yml               # Web application deployment
```

## Refactoring Changes

### 1. Modular Task Files

The original monolithic playbook has been split into three focused task files:

#### [`tasks/install-dependencies.yml`](ansible/tasks/install-dependencies.yml)
- Installs Python 3 and development tools
- Installs build essentials
- Installs PyMySQL connector
- Installs MySQL client development libraries

#### [`tasks/deploy-database.yml`](ansible/tasks/deploy-database.yml)
- Installs MySQL server and client
- Starts and enables MySQL service
- Creates application database
- Creates database user with appropriate privileges

#### [`tasks/deploy-web.yml`](ansible/tasks/deploy-web.yml)
- Installs Flask and Flask-MySQLDB via pip
- Copies application source code
- Checks if Flask is already running
- Starts the Flask application

### 2. External Variables File

Created [`vars.yml`](ansible/vars.yml) to centralize configuration:

```yaml
---
# Database configuration variables
db_name: employee_db
db_user: app_user
db_password: Passw0rd
```

### 3. Main Playbook Structure

The [`playbook.yml`](ansible/playbook.yml) now serves as an orchestrator:

```yaml
---
- name: Deploy a web application
  hosts: web01
  vars_files:
    - vars.yml
  tasks:
    - name: Include install dependencies tasks
      ansible.builtin.include_tasks: tasks/install-dependencies.yml

    - name: Include deploy database tasks
      ansible.builtin.include_tasks: tasks/deploy-database.yml

    - name: Include deploy web tasks
      ansible.builtin.include_tasks: tasks/deploy-web.yml
```

## Benefits of Modular Structure

### 1. **Improved Maintainability**
- Each task file focuses on a single responsibility
- Easier to locate and update specific functionality
- Reduced cognitive load when working with the code

### 2. **Enhanced Reusability**
- Task files can be included in multiple playbooks
- Variables can be shared across different deployments
- Common patterns can be extracted and reused

### 3. **Better Testing**
- Individual task files can be tested in isolation
- Easier to debug specific components
- Faster iteration during development

### 4. **Team Collaboration**
- Multiple team members can work on different task files simultaneously
- Clear separation of concerns reduces merge conflicts
- Easier code reviews with focused changes

### 5. **Flexibility**
- Easy to add, remove, or reorder tasks
- Conditional inclusion of task files based on requirements
- Simple to create environment-specific variations

## Ansible Lint Compliance

All files pass ansible-lint validation with production profile standards:

### Fixed Issues

1. **FQCN (Fully Qualified Collection Names)**
   - Changed `include_tasks` to `ansible.builtin.include_tasks`
   - Ensures compatibility across different Ansible versions

2. **Task Naming**
   - Added descriptive names to all include_tasks
   - Improves playbook readability and logging

3. **YAML Formatting**
   - Removed trailing spaces
   - Added proper newline at end of files
   - Removed extra blank lines

4. **File Organization**
   - Proper indentation throughout
   - Consistent formatting across all files

### Validation Results
```
✅ playbook.yml - 0 failures, 0 warnings
✅ tasks/install-dependencies.yml - 0 failures, 0 warnings
✅ tasks/deploy-database.yml - 0 failures, 0 warnings
✅ tasks/deploy-web.yml - 0 failures, 0 warnings
✅ vars.yml - 0 failures, 0 warnings
```

## Running the Playbook

The execution command remains the same:

```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml
```

The playbook will automatically:
1. Load variables from `vars.yml`
2. Execute tasks from `install-dependencies.yml`
3. Execute tasks from `deploy-database.yml`
4. Execute tasks from `deploy-web.yml`

## Variable Management

### Current Variables

The `vars.yml` file contains:
- `db_name`: Database name (employee_db)
- `db_user`: Database username (app_user)
- `db_password`: Database password (Passw0rd)

### Using Variables

Variables are referenced using Jinja2 syntax:
```yaml
name: "{{ db_name }}"
password: "{{ db_password }}"
```

### Security Best Practices

For production environments, encrypt sensitive variables using Ansible Vault:

```bash
# Encrypt the variables file
ansible-vault encrypt vars.yml

# Run playbook with vault password
ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass

# Or use a password file
ansible-playbook -i inventory.ini playbook.yml --vault-password-file ~/.vault_pass
```

## Advanced Usage

### Selective Task Execution

You can use tags to run specific task files:

```yaml
# Add tags to include_tasks
- name: Include install dependencies tasks
  ansible.builtin.include_tasks: tasks/install-dependencies.yml
  tags: dependencies

- name: Include deploy database tasks
  ansible.builtin.include_tasks: tasks/deploy-database.yml
  tags: database

- name: Include deploy web tasks
  ansible.builtin.include_tasks: tasks/deploy-web.yml
  tags: web
```

Then run specific sections:
```bash
# Only install dependencies
ansible-playbook -i inventory.ini playbook.yml --tags dependencies

# Skip database setup
ansible-playbook -i inventory.ini playbook.yml --skip-tags database
```

### Environment-Specific Variables

Create multiple variable files for different environments:

```
ansible/
├── vars/
│   ├── dev.yml
│   ├── staging.yml
│   └── production.yml
```

Then specify which to use:
```bash
ansible-playbook -i inventory.ini playbook.yml -e @vars/production.yml
```

## Comparison: Before vs After

### Before (Monolithic)
- Single 80+ line playbook file
- Hardcoded values throughout
- Difficult to maintain and test
- Poor reusability

### After (Modular)
- Main playbook: ~15 lines (orchestration only)
- 3 focused task files: ~20-30 lines each
- Centralized variables in separate file
- Easy to maintain, test, and reuse
- Follows Ansible best practices

## Browser Compatibility Note

⚠️ **Important**: The Flask application works in **Safari** and **Firefox** but may not be accessible in **Chrome** or **Brave** browsers due to stricter security policies. See [Section02-README.md](Section02-README.md) for detailed workarounds.

## Accessing the Application

After successful deployment:
```
http://192.168.252.15:5000
```

Available routes:
- `/` - Welcome message
- `/how are you` - Greeting response
- `/read from database` - Database query results

## Next Steps

Consider these additional improvements:

1. **Add Error Handling**
   - Use `block/rescue/always` for error handling
   - Add validation checks before critical operations

2. **Implement Idempotency Checks**
   - Add `changed_when` conditions
   - Use `creates` or `removes` parameters where appropriate

3. **Add Handlers**
   - Create handlers for service restarts
   - Notify handlers only when changes occur

4. **Implement Roles**
   - Convert task files into Ansible roles
   - Add role dependencies and metadata

5. **Add Testing**
   - Implement Molecule for testing
   - Add integration tests
   - Create CI/CD pipeline

## Troubleshooting

### Task File Not Found
Ensure task files are in the correct location relative to the playbook:
```bash
ls -la ansible/tasks/
```

### Variables Not Loaded
Verify `vars.yml` exists and is properly formatted:
```bash
ansible-playbook -i inventory.ini playbook.yml --syntax-check
```

### Include Tasks Fails
Check for YAML syntax errors in task files:
```bash
ansible-lint tasks/*.yml
```

## Resources

- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Ansible Lint Documentation](https://ansible-lint.readthedocs.io/)
- [Ansible Variables](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html)
- [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)

## License

This project is part of an Ansible advanced course and is provided for educational purposes.