import os
from flask import Flask
from flask_mysqldb import MySQL

app = Flask(__name__)

mysql = MySQL()

mysql_database_host = os.environ.get('MYSQL_DATABASE_HOST', 'localhost')

# MySQL configurations
app.config['MYSQL_USER'] = 'app_user'
app.config['MYSQL_PASSWORD'] = 'Passw0rd'
app.config['MYSQL_DB'] = 'employee_db'
app.config['MYSQL_HOST'] = mysql_database_host
mysql.init_app(app)

@app.route("/")
def main():
    return "Welcome!"

@app.route('/how are you')
def hello():
    return 'I am good, how about you?'

@app.route('/read from database')
def read():
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT * FROM employees")
    row = cursor.fetchone()
    result = []
    while row is not None:
        result.append(row[0])
        row = cursor.fetchone()
    cursor.close()
    return ",".join(result)

if __name__ == "__main__":
    app.run()
