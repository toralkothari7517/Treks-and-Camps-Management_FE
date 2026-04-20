from flask import Flask, render_template, request, redirect, url_for, session, flash
import mysql.connector
from functools import wraps
import hashlib
import os

from dotenv import load_dotenv
load_dotenv()

app = Flask(__name__)
app.secret_key = 'treks_camps_secret_key_2024'

# DB CONFIG
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': os.getenv('DB_PASSWORD'),
    'database': 'treks_camps_db'
}

def get_db():
    return mysql.connector.connect(**db_config)

def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()

# AUTH CHECK
def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if not session.get('logged_in'):
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated

# HOME
@app.route('/')
def index():
    return redirect(url_for('login'))

# LOGIN
@app.route('/login', methods=['GET', 'POST'])
def login():

    if request.method == 'POST':
        email = request.form.get('email')
        password = hash_password(request.form.get('password'))

        db = get_db()
        cur = db.cursor(dictionary=True)

        cur.execute("""
            SELECT * FROM UserAuth 
            WHERE Email=%s AND Password=%s
        """, (email, password))

        user = cur.fetchone()
        cur.close()
        db.close()

        if user:
            session['logged_in'] = True
            session['user_id'] = user['UserID']
            return redirect(url_for('dashboard'))
        else:
            flash("Invalid credentials")

    return render_template('login.html')


# ✅ SIGNUP (FIXED PROPERLY)
@app.route('/signup', methods=['GET', 'POST'])
def signup():

    if request.method == 'POST':
        name = request.form.get('name')
        age = request.form.get('age')
        gender = request.form.get('gender')
        phone = request.form.get('phone')
        email = request.form.get('email')
        password = request.form.get('password')
        confirm = request.form.get('confirm_password')

        # VALIDATION
        if password != confirm:
            flash("Passwords do not match")
            return render_template('signup.html')

        if not age.isdigit() or int(age) < 1 or int(age) > 120:
            flash("Enter valid age")
            return render_template('signup.html')

        db = get_db()
        cur = db.cursor(dictionary=True)

        # CHECK EXISTING
        cur.execute("SELECT * FROM UserAuth WHERE Email=%s", (email,))
        if cur.fetchone():
            flash("Email already exists")
            return render_template('signup.html')

        # CREATE ID
        cur.execute("SELECT COUNT(*) as c FROM Participant")
        pid = f"PRT{str(cur.fetchone()['c']+1).zfill(3)}"

        # INSERT PARTICIPANT
        cur.execute("""
            INSERT INTO Participant
            (ParticipantID, Name, Age, Gender, Contact, Email)
            VALUES (%s,%s,%s,%s,%s,%s)
        """, (pid, name, int(age), gender, phone, email))

        # INSERT AUTH
        cur.execute("""
            INSERT INTO UserAuth
            (UserID, Email, Password, Role, LinkedID)
            VALUES (%s,%s,%s,'Participant',%s)
        """, (pid, email, hash_password(password), pid))

        db.commit()
        cur.close()
        db.close()

        flash("Account created! Please login")
        return redirect(url_for('login'))

    return render_template('signup.html')


# LOGOUT
@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))


# DASHBOARD
@app.route('/dashboard')
@login_required
def dashboard():

    db = get_db()
    cur = db.cursor(dictionary=True)

    cur.execute("""
        SELECT t.Trek_Name, ti.StartDate, ti.EndDate,
        (ti.Max_Participants - ti.Current_Participants) AS slots
        FROM TrekInstance ti
        JOIN Trek t ON ti.TrekID = t.TrekID
        WHERE ti.Status='Upcoming'
        ORDER BY ti.StartDate
    """)

    upcoming = cur.fetchall()

    cur.close()
    db.close()

    return render_template('dashboard.html', upcoming=upcoming)


if __name__ == '__main__':
    app.run(debug=True)
