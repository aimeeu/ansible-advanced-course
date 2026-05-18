# Ansible Role: OS Config

## Description

This role configures the operating system and installs all system-level dependencies required for deploying a Flask web application with MySQL database support. It handles the installation of Python 3, development tools, build essentials, and MySQL client libraries.

## Requirements

- Target system: Ubuntu/Debian-based Linux distributions
- Ansible version: 2.2 or higher
- Privilege escalation: This role requires `become: true` (sudo access)

## Role Variables

This role does not currently define any variables. All package installations are handled with fixed package names.

### Packages Installed

The role installs the following packages:

- **python3** - Python 3 interpreter
- **python3-setuptools** - Python package installation tools
- **python3-dev** - Python development headers
- **build-essential** - Compilation tools (gcc, make, etc.)
- **python3-pip** - Python package manager
- **python3-pymysql** - PyMySQL connector for Python
- **pkg-config** - Helper tool for compiling applications
- **libmysqlclient-dev** - MySQL client development libraries

## Dependencies

This role has no dependencies on other Ansible roles.

## Example Playbook

### Basic Usage

```yaml
---
- name: Deploy web application
  hosts: web_servers
  roles:
    - os-config
```

### With Other Roles

```yaml
---
- name: Complete web application deployment
  hosts: web_servers
  vars_files:
    - vars.yml
  roles:
    - dependencies
    - database
    - web
```

### With Pre-tasks

```yaml
---
- name: Deploy with system updates
  hosts: web_servers
  pre_tasks:
    - name: Update apt cache
      ansible.builtin.apt:
        update_cache: true
        cache_valid_time: 3600
      become: true
  roles:
    - dependencies
```

## Role Structure

```
dependencies/
├── README.md              # This file
├── defaults/
│   └── main.yml          # Default variables (currently empty)
├── files/                # Static files (currently empty)
├── handlers/
│   └── main.yml          # Handlers (currently empty)
├── meta/
│   └── main.yml          # Role metadata and dependencies
├── tasks/
│   └── main.yml          # Main task file with package installations
├── templates/            # Jinja2 templates (currently empty)
├── tests/
│   └── test.yml          # Test playbook
└── vars/
    └── main.yml          # Role variables (currently empty)
```

## Tasks Overview

### Install web app dependencies

The main task installs all required system packages using the `apt` module with a loop over the package list. The task:

- Uses `become: true` for privilege escalation
- Installs packages one at a time using `with_items`
- Ensures all packages are in `present` state
- Is idempotent - safe to run multiple times

## Platform Support

### Tested On

- Ubuntu 20.04 LTS (Focal Fossa)
- Ubuntu 22.04 LTS (Jammy Jellyfish)
- Ubuntu 24.04 LTS (Noble Numbat)
- Debian 11 (Bullseye)
- Debian 12 (Bookworm)

### Package Manager

This role uses the `apt` package manager and is designed for Debian-based distributions. For other distributions (RHEL, CentOS, Fedora), you would need to modify the tasks to use `yum` or `dnf`.

## Customization

### Adding Additional Packages

To add more packages, edit `tasks/main.yml` and add them to the `with_items` list:

```yaml
- name: Install web app dependencies
  become: true
  ansible.builtin.apt:
    name: "{{ item }}"
    state: present
  with_items:
    - python3
    - python3-setuptools
    # ... existing packages ...
    - your-new-package
```

### Using Variables for Package List

To make the package list configurable, you can move it to `defaults/main.yml`:

```yaml
# defaults/main.yml
---
dependency_packages:
  - python3
  - python3-setuptools
  - python3-dev
  - build-essential
  - python3-pip
  - python3-pymysql
  - pkg-config
  - libmysqlclient-dev
```

Then update `tasks/main.yml`:

```yaml
- name: Install web app dependencies
  become: true
  ansible.builtin.apt:
    name: "{{ item }}"
    state: present
  loop: "{{ dependency_packages }}"
```

## Troubleshooting

### Package Not Found

If a package is not found, ensure:
1. The apt cache is up to date: `apt update`
2. The package name is correct for your distribution
3. The required repositories are enabled

### Permission Denied

If you encounter permission errors:
1. Ensure the playbook uses `become: true`
2. Verify the user has sudo privileges
3. Check if a sudo password is required: use `--ask-become-pass`

### Network Issues

If package downloads fail:
1. Check internet connectivity
2. Verify DNS resolution
3. Check if a proxy is required
4. Ensure firewall allows outbound HTTP/HTTPS

## Performance Considerations

### Optimization Options

1. **Update Cache Once**: Add a pre-task to update apt cache before running the role
2. **Parallel Installation**: Consider using the `apt` module with a list instead of looping
3. **Cache Package Lists**: Use `cache_valid_time` to avoid unnecessary cache updates

### Example Optimized Task

```yaml
- name: Install web app dependencies (optimized)
  become: true
  ansible.builtin.apt:
    name:
      - python3
      - python3-setuptools
      - python3-dev
      - build-essential
      - python3-pip
      - python3-pymysql
      - pkg-config
      - libmysqlclient-dev
    state: present
    update_cache: true
    cache_valid_time: 3600
```

## Testing

### Manual Testing

```bash
# Run the role against a test host
ansible-playbook -i inventory tests/test.yml

# Check if packages are installed
ansible test_host -m shell -a "dpkg -l | grep python3"
```

### Molecule Testing

For automated testing with Molecule:

```bash
# Install molecule
pip install molecule molecule-docker

# Run tests
cd roles/dependencies
molecule test
```

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
- Support for Ubuntu/Debian systems
- Installation of Python 3 and MySQL development dependencies
- Ansible-lint compliant

## Related Roles

- **database** - Installs and configures MySQL database
- **web** - Deploys Flask web application

## Support

For issues, questions, or contributions, please refer to the course materials or contact the instructor.
