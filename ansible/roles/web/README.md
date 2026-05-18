# Ansible Role: Web

## Description

This role deploys a Flask web application with MySQL database connectivity. It handles the installation of Python Flask dependencies, copies the application source code, and manages the Flask application lifecycle.

## Requirements

- Target system: Ubuntu/Debian-based Linux distributions
- Ansible version: 2.2 or higher
- Python 3.12+ (for PEP 668 compliance)
- Application source file: `app.py` must exist in the role's files directory or playbook directory

## Role Dependencies

This role has no explicit dependencies, but it requires:
- Python 3 and pip (typically provided by the `os-config` role)
- MySQL database (typically provided by the `database` role)

For a complete deployment, use this role after the `database` role.

## What This Role Does

### 1. Install Python Flask Dependencies
Installs Flask and Flask-MySQLDB packages using pip:
- **Flask** - Python web framework
- **Flask-MySQLDB** - MySQL database connector for Flask
- Uses `break_system_packages: true` for Python 3.12+ compatibility (PEP 668)

### 2. Copy Application Source Code
- Copies `app.py` to `/opt/app.py`
- Sets file permissions to `0644`
- Requires privilege escalation

### 3. Check Flask Process
- Checks if Flask is already running
- Uses `pgrep` to find Flask processes
- Prevents duplicate application instances

### 4. Start Flask Application
- Starts Flask development server if not already running
- Runs on all interfaces (`0.0.0.0:5000`)
- Logs output to `/tmp/flask.log`
- Runs in background using `nohup`

## Role Variables

This role does not define any variables. All configuration is handled through the application code (`app.py`).

## Application Requirements

The Flask application (`app.py`) should be structured to work with this deployment. Example structure:

```python
import os
from flask import Flask
from flask_mysqldb import MySQL

app = Flask(__name__)

# MySQL Configuration
app.config['MYSQL_USER'] = 'app_user'
app.config['MYSQL_PASSWORD'] = 'Passw0rd'
app.config['MYSQL_DB'] = 'employee_db'
app.config['MYSQL_HOST'] = 'localhost'

mysql = MySQL(app)

@app.route("/")
def main():
    return "Welcome!"

if __name__ == "__main__":
    app.run()
```

## Example Playbook

### Basic Usage

```yaml
---
- name: Deploy Flask application
  hosts: web_servers
  roles:
    - web
```

### Complete Deployment Stack

```yaml
---
- name: Deploy complete web application
  hosts: web_servers
  roles:
    - database  # Installs MySQL and creates database
    - web       # Deploys Flask application
```

### With Pre-tasks

```yaml
---
- name: Deploy with preparation
  hosts: web_servers
  pre_tasks:
    - name: Ensure app.py exists
      ansible.builtin.stat:
        path: app.py
      register: app_file
      delegate_to: localhost

    - name: Fail if app.py not found
      ansible.builtin.fail:
        msg: "app.py not found in playbook directory"
      when: not app_file.stat.exists
  roles:
    - web
```

## Role Structure

```
web/
├── README.md              # This file
├── defaults/
│   └── main.yml          # Default variables (currently empty)
├── files/                # Static files (app.py should be here or in playbook dir)
├── handlers/
│   └── main.yml          # Handlers (currently empty)
├── meta/
│   └── main.yml          # Role metadata
├── tasks/
│   └── main.yml          # Main task file
├── templates/            # Jinja2 templates (currently empty)
├── tests/
│   └── test.yml          # Test playbook
└── vars/
    └── main.yml          # Role variables (currently empty)
```

## Tasks Overview

### 1. Install Python Flask dependencies
- Uses `pip` module with `break_system_packages: true`
- Required for Python 3.12+ (PEP 668 compliance)
- Installs Flask and Flask-MySQLDB

### 2. Copy source code
- Uses `copy` module with privilege escalation
- Copies to `/opt/app.py`
- Sets permissions to `0644` (readable by all, writable by owner)

### 3. Check if Flask is already running
- Uses `command` module with `pgrep`
- Registers result for conditional execution
- Ignores errors if no process found
- Marked as not changed

### 4. Start application
- Uses `shell` module for complex command
- Only runs if Flask is not already running
- Sets `FLASK_APP` environment variable
- Redirects output to `/tmp/flask.log`

## Platform Support

### Tested On

- Ubuntu 20.04 LTS (Focal Fossa)
- Ubuntu 22.04 LTS (Jammy Jellyfish)
- Ubuntu 24.04 LTS (Noble Numbat)
- Debian 11 (Bullseye)
- Debian 12 (Bookworm)

### Python Versions

- Python 3.8+
- Python 3.12+ (with PEP 668 support)

## Application Access

After deployment, the Flask application is accessible at:

```
http://<server-ip>:5000
```

### Available Routes

The default application provides:
- `/` - Welcome page
- `/how are you` - Greeting response
- `/read from database` - Database query results

### Browser Compatibility Note

⚠️ **Important**: The application works in **Safari** and **Firefox** but may not be accessible in **Chrome** or **Brave** browsers due to stricter security policies. See troubleshooting section for workarounds.

## Troubleshooting

### Flask Not Starting

Check the application logs:
```bash
cat /tmp/flask.log
```

Common issues:
- Port 5000 already in use
- Missing dependencies
- Application code errors
- Database connection failures

### Import Errors

If you see "ModuleNotFoundError":
```bash
# Verify Flask is installed
python3 -m pip list | grep -i flask

# Reinstall if needed
python3 -m pip install Flask Flask-MySQLDB --break-system-packages
```

### Database Connection Errors

If the application can't connect to MySQL:
1. Verify MySQL is running: `systemctl status mysql`
2. Check database exists: `sudo mysql -e "SHOW DATABASES;"`
3. Verify user credentials in `app.py`
4. Check MySQL logs: `sudo tail -f /var/log/mysql/error.log`

### Permission Denied

If you see permission errors:
1. Ensure `become: true` is set in playbook
2. Verify `/opt` directory permissions
3. Check if SELinux is blocking (if applicable)

### Application Already Running

If Flask is already running but not responding:
```bash
# Find the process
ps aux | grep flask

# Kill the process
pkill -f "flask run"

# Re-run the playbook
ansible-playbook -i inventory playbook.yml
```

### Browser Access Issues (Chrome/Brave)

If you cannot access the application in Chrome or Brave:

1. **Use Incognito/Private Mode**
2. **Clear HSTS Settings**:
   - Chrome: Visit `chrome://net-internals/#hsts`
   - Brave: Visit `brave://net-internals/#hsts`
3. **Type HTTP explicitly**: `http://192.168.252.15:5000`
4. **Use Alternative Browser**: Safari or Firefox

## Security Considerations

### Development Server Warning

⚠️ **This role uses Flask's development server, which is NOT suitable for production use.**

For production, use a WSGI server:
- **Gunicorn**
- **uWSGI**
- **mod_wsgi**

### Exposed Credentials

The application may contain hardcoded credentials. For production:

1. Use environment variables
2. Implement Ansible Vault
3. Use secrets management (HashiCorp Vault, AWS Secrets Manager)

### Network Exposure

The application listens on all interfaces (`0.0.0.0`). For production:

1. Use a reverse proxy (Nginx, Apache)
2. Implement SSL/TLS
3. Configure firewall rules
4. Use application-level authentication

## Customization

### Using Different Application File

To use a different application file:

```yaml
# tasks/main.yml
- name: Copy source code
  become: true
  ansible.builtin.copy:
    src: my_app.py
    dest: /opt/app.py
    mode: '0644'
```

### Changing Application Port

Modify the start command:

```yaml
- name: Start application
  ansible.builtin.shell: |
    cd /opt
    nohup python3 -m flask run --host=0.0.0.0 --port=8080 > /tmp/flask.log 2>&1 &
  environment:
    FLASK_APP: /opt/app.py
```

### Adding Environment Variables

```yaml
- name: Start application
  ansible.builtin.shell: |
    cd /opt
    nohup python3 -m flask run --host=0.0.0.0 > /tmp/flask.log 2>&1 &
  environment:
    FLASK_APP: /opt/app.py
    FLASK_ENV: production
    DATABASE_URL: mysql://user:pass@localhost/dbname
```

### Using Systemd Service

For better process management, create a systemd service:

```yaml
# tasks/main.yml
- name: Create Flask systemd service
  become: true
  ansible.builtin.template:
    src: flask.service.j2
    dest: /etc/systemd/system/flask.service
  notify: restart flask

- name: Enable and start Flask service
  become: true
  ansible.builtin.systemd:
    name: flask
    enabled: true
    state: started
    daemon_reload: true
```

## Production Deployment

### Using Gunicorn

```yaml
- name: Install Gunicorn
  ansible.builtin.pip:
    name: gunicorn
    state: present
    break_system_packages: true

- name: Start application with Gunicorn
  ansible.builtin.shell: |
    cd /opt
    nohup gunicorn -w 4 -b 0.0.0.0:5000 app:app > /tmp/gunicorn.log 2>&1 &
```

### With Nginx Reverse Proxy

```yaml
- name: Install Nginx
  become: true
  ansible.builtin.apt:
    name: nginx
    state: present

- name: Configure Nginx
  become: true
  ansible.builtin.template:
    src: nginx.conf.j2
    dest: /etc/nginx/sites-available/flask-app
  notify: restart nginx
```

## Monitoring

### Health Check

```yaml
- name: Check Flask application health
  ansible.builtin.uri:
    url: http://localhost:5000/
    status_code: 200
  register: health_check
  until: health_check.status == 200
  retries: 5
  delay: 10
```

### Log Monitoring

```bash
# Watch application logs
tail -f /tmp/flask.log

# Check for errors
grep -i error /tmp/flask.log
```

## Testing

### Manual Testing

```bash
# Test role execution
ansible-playbook -i inventory tests/test.yml

# Verify Flask is running
ansible web_servers -m shell -a "ps aux | grep flask"

# Test application endpoint
ansible web_servers -m shell -a "curl http://localhost:5000"
```

### Automated Testing

```bash
# Install molecule
pip install molecule molecule-docker

# Run tests
cd roles/web
molecule test
```

## Performance Considerations

### Worker Processes

For production, use multiple worker processes:
```bash
gunicorn -w 4 app:app  # 4 workers
```

### Connection Pooling

Configure MySQL connection pooling in `app.py`:
```python
app.config['MYSQL_POOL_SIZE'] = 10
app.config['MYSQL_POOL_RECYCLE'] = 3600
```

### Caching

Implement caching for better performance:
```python
from flask_caching import Cache
cache = Cache(app, config={'CACHE_TYPE': 'simple'})
```

## Backup and Recovery

### Application Backup

```yaml
- name: Backup application
  ansible.builtin.copy:
    src: /opt/app.py
    dest: /backup/app.py.{{ ansible_date_time.date }}
    remote_src: true
```

### Log Rotation

```yaml
- name: Configure log rotation
  become: true
  ansible.builtin.copy:
    content: |
      /tmp/flask.log {
        daily
        rotate 7
        compress
        missingok
        notifempty
      }
    dest: /etc/logrotate.d/flask
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
- Flask application deployment
- MySQL database connectivity
- PEP 668 compliance
- Process management
- Ansible-lint compliant

## Related Roles

- **os-config** - Installs system dependencies
- **database** - Installs and configures MySQL database

## Support

For issues, questions, or contributions, please refer to the course materials or contact the instructor.
