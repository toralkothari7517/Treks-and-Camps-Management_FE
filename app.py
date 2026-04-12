from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
import time

app = Flask(__name__)
app.secret_key = 'replace-this-with-a-secure-secret'
CORS(app)

DB_CONFIG = {
    'host': 'localhost',
    'database': 'treks_camps_db',
    'user': 'root',
    'password': ''
}


def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)


@app.route('/')
def index():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute('SELECT * FROM Available_TrekInstances ORDER BY StartDate LIMIT 8;')
        treks = cursor.fetchall()
    except Error as e:
        treks = []
        print('DB error:', e)
    finally:
        cursor.close()
        conn.close()
    return render_template('index.html', treks=treks)


@app.route('/treks')
def treks():
    difficulty = request.args.get('difficulty', '')
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        if difficulty:
            cursor.execute('SELECT * FROM Available_TrekInstances WHERE Difficulty_Level = %s ORDER BY StartDate;', (difficulty,))
        else:
            cursor.execute('SELECT * FROM Available_TrekInstances ORDER BY StartDate;')
        treks = cursor.fetchall()
    except Error as e:
        treks = []
        print('DB error:', e)
    finally:
        cursor.close()
        conn.close()
    return render_template('treks.html', treks=treks, selected_difficulty=difficulty)


@app.route('/trek/<instance_id>')
def trek_detail(instance_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            'SELECT ti.*, t.Trek_Name, t.Description, t.Price, t.Difficulty_Level, t.Duration_Days '
            'FROM TrekInstance ti '
            'JOIN Trek t ON ti.TrekID = t.TrekID '
            'WHERE ti.InstanceID = %s;', (instance_id,)
        )
        trek = cursor.fetchone()
        cursor.execute(
            'SELECT c.* FROM Includes i JOIN Camp c ON i.CampID = c.CampID WHERE i.InstanceID = %s ORDER BY i.Arrival_Order;', (instance_id,)
        )
        camps = cursor.fetchall()
    except Error as e:
        trek = None
        camps = []
        print('DB error:', e)
    finally:
        cursor.close()
        conn.close()
    return render_template('trek_detail.html', trek=trek, camps=camps)


@app.route('/book/<instance_id>', methods=['GET', 'POST'])
def book_trek(instance_id):
    if request.method == 'POST':
        name = request.form.get('name')
        age = request.form.get('age')
        gender = request.form.get('gender')
        contact = request.form.get('contact')
        email = request.form.get('email')
        participants = int(request.form.get('participants', 1))
        requirements = request.form.get('requirements')

        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            timestamp = int(time.time())
            participant_id = f'PRT{timestamp}'
            booking_id = f'BKG{timestamp}'
            cursor.execute('INSERT INTO Participant (ParticipantID, Name, Age, Gender, Contact, Email) VALUES (%s, %s, %s, %s, %s, %s);',
                           (participant_id, name, age, gender, contact, email))
            cursor.execute('SELECT Price FROM TrekInstance ti JOIN Trek t ON ti.TrekID = t.TrekID WHERE ti.InstanceID = %s;', (instance_id,))
            price_row = cursor.fetchone()
            total_amount = (price_row[0] if price_row else 0) * participants
            cursor.execute('INSERT INTO Booking (BookingID, InstanceID, Status, Total_Amount, Number_of_Participants, Special_Requirements) VALUES (%s, %s, %s, %s, %s, %s);',
                           (booking_id, instance_id, 'Pending', total_amount, participants, requirements))
            cursor.execute('INSERT INTO ParticipatesIn (ParticipantID, BookingID, Role) VALUES (%s, %s, %s);',
                           (participant_id, booking_id, 'Leader'))
            conn.commit()
            flash('Booking request received. Please proceed to payment to confirm.', 'success')
            return redirect(url_for('booking_detail', booking_id=booking_id))
        except Error as e:
            conn.rollback()
            flash('Unable to create booking. Please try again later.', 'danger')
            print('DB error:', e)
        finally:
            cursor.close()
            conn.close()

    return render_template('book_trek.html', instance_id=instance_id)


@app.route('/booking/<booking_id>')
def booking_detail(booking_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute('SELECT * FROM Booking WHERE BookingID = %s;', (booking_id,))
        booking = cursor.fetchone()
        cursor.execute('SELECT * FROM Payment WHERE BookingID = %s;', (booking_id,))
        payment = cursor.fetchone()
    except Error as e:
        booking = None
        payment = None
        print('DB error:', e)
    finally:
        cursor.close()
        conn.close()
    return render_template('booking_detail.html', booking=booking, payment=payment)


@app.route('/my-bookings')
def my_bookings():
    participant_id = request.args.get('participant_id', '')
    bookings = []
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        if participant_id:
            cursor.execute(
                'SELECT b.* FROM Booking b '
                'JOIN ParticipatesIn pi ON b.BookingID = pi.BookingID '
                'WHERE pi.ParticipantID = %s ORDER BY b.CreatedAt DESC;', (participant_id,)
            )
            bookings = cursor.fetchall()
    except Error as e:
        print('DB error:', e)
    finally:
        cursor.close()
        conn.close()
    return render_template('my_bookings.html', bookings=bookings, participant_id=participant_id)


@app.route('/admin')
def admin_dashboard():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute('SELECT * FROM Trek ORDER BY Trek_Name;')
        treks = cursor.fetchall()
        cursor.execute('SELECT * FROM Booking ORDER BY CreatedAt DESC LIMIT 10;')
        bookings = cursor.fetchall()
    except Error as e:
        treks = []
        bookings = []
        print('DB error:', e)
    finally:
        cursor.close()
        conn.close()
    return render_template('admin_dashboard.html', treks=treks, bookings=bookings)


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        if email and password:
            session['user'] = email
            flash('Logged in successfully.', 'success')
            return redirect(url_for('admin_dashboard'))
        flash('Please enter email and password.', 'warning')
    return render_template('login.html')


@app.errorhandler(404)
def not_found(error):
    return render_template('index.html', treks=[]), 404


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
