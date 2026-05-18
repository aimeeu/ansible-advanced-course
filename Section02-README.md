# Section 02: Ansible Playbook - Flask Web Application Deployment

## Overview

This section demonstrates deploying a Flask web application with MySQL database on a Multipass VM using Ansible. The playbook automates the complete setup including dependencies, database configuration, and application deployment.

## Project Structure

```
ansible/
├── playbook.yml          # Main Ansible playbook
├── app.py               # Flask web application
├── inventory.ini        # Ansible inventory file
└── ansible.cfg          # Ansible configuration
```

## Prerequisites

- Multipass VM running Ubuntu
- Ansible installed on your local machine
- SSH access to the target VM
- Python 3.12+ on the target VM

## Playbook Components

### 1. Install Web App Dependencies
Installs required system packages:
- Python 3 and development tools
- Build essentials
- PyMySQL connector
- pkg-config and MySQL client development libraries

### 2. Install Database
Installs MySQL server and client packages.

### 3. Start Database Services
Ensures MySQL service is running and enabled on boot.

### 4. Create Application Database
Creates the `employee_db` database for the application.

### 5. Create Database User
Creates `app_user` with password `Passw0rd` and grants privileges on `employee_db`.

### 6. Install Python Flask Dependencies
Installs Flask and Flask-MySQLDB using pip with `break_system_packages` flag for Python 3.12+ compatibility.

### 7. Copy Source Code
Copies the Flask application (`app.py`) to `/opt/app.py` with proper permissions.

### 8. Start Application
Launches the Flask application using `python3 -m flask run` on all interfaces (0.0.0.0:5000).

## Running the Playbook

```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml
```

## Accessing the Application

After successful deployment, the Flask application will be available at:

```
http://192.168.252.15:5000
```

### Available Routes

- `/` - Returns "Welcome!"
- `/how are you` - Returns "I am good, how about you?"
- `/read from database` - Reads and displays data from the employees table

## Browser Compatibility Note

⚠️ **Important**: The application works correctly in **Safari** and **Firefox** but may not be accessible in **Chrome** or **Brave** browsers.

### Why Chrome/Brave Don't Work

Chrome and Brave browsers have stricter security policies that may interfere with accessing local development servers:

1. **HTTPS Enforcement**: These browsers may force HTTPS on certain ports
2. **HSTS Policies**: Cached security policies may block HTTP connections
3. **Security Extensions**: Built-in ad blockers or security features may block the connection

### Workarounds for Chrome/Brave

1. **Use Incognito/Private Mode**: Try accessing the site in incognito mode
2. **Clear HSTS Settings**:
   - Chrome: Visit `chrome://net-internals/#hsts` and delete domain security policies
   - Brave: Visit `brave://net-internals/#hsts`
3. **Explicitly Type HTTP**: Ensure you type `http://` in the address bar (not just the IP)
4. **Disable Extensions**: Temporarily disable security extensions
5. **Use Alternative Browser**: Use Safari or Firefox for development

## Verification Commands

### Check if Flask is Running
```bash
multipass exec web01 -- ps aux | grep flask
```

### View Application Logs
```bash
multipass exec web01 -- cat /tmp/flask.log
```

### Test with curl
```bash
curl http://192.168.252.15:5000
```

### Check MySQL Service
```bash
multipass exec web01 -- sudo systemctl status mysql
```

## Key Fixes Applied

1. **Indentation Errors**: Fixed YAML indentation throughout the playbook
2. **MySQL Connector**: Replaced deprecated `python3-mysqldb` with `python3-pymysql`
3. **MySQL Authentication**: Configured Unix socket authentication with proper privileges
4. **PEP 668 Compliance**: Added `break_system_packages: true` for pip installations
5. **Build Dependencies**: Added `pkg-config` and `libmysqlclient-dev` for mysqlclient compilation
6. **Flask Import**: Fixed Flask-MySQLDB import from `flaskext.mysql` to `flask_mysqldb`
7. **Configuration Keys**: Updated MySQL config keys to match Flask-MySQLDB requirements
8. **Privilege Escalation**: Added `become: true` where system-level access is required
9. **Flask Startup**: Changed to `python3 -m flask run` for proper module execution
10. **Database Security**: Scoped user privileges to `employee_db` only

## Troubleshooting

### Flask Not Running
Check the logs for errors:
```bash
multipass exec web01 -- cat /tmp/flask.log
```

### Database Connection Issues
Verify MySQL is running and user exists:
```bash
multipass exec web01 -- sudo mysql -e "SELECT user, host FROM mysql.user WHERE user='app_user';"
```

### Permission Errors
Ensure the playbook runs with proper privileges and the target user has necessary permissions.

## Security Notes

- **Development Only**: This setup uses a development Flask server (not production-ready)
- **Weak Password**: The database password `Passw0rd` should be changed for production
- **Database Access**: User has full privileges on `employee_db` database
- **No SSL/TLS**: Application runs over HTTP (not HTTPS)

## Production Recommendations

For production deployment, consider:
1. Use a production WSGI server (Gunicorn, uWSGI)
2. Implement proper secret management (Ansible Vault, environment variables)
3. Configure SSL/TLS certificates
4. Set up proper firewall rules
5. Implement database backups
6. Use stronger authentication mechanisms
7. Enable MySQL SSL connections
8. Implement proper logging and monitoring

## Ansible Lint Compliance

The playbook passes ansible-lint validation with:
- ✅ 0 failures
- ✅ 0 warnings
- ✅ Production profile standards met

## License

This project is part of an Ansible advanced course and is provided for educational purposes.