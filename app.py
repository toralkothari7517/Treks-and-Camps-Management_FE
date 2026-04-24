from flask import Flask, jsonify, render_template, request, send_from_directory
import hashlib
import json
import mysql.connector
import os
from datetime import datetime

from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.secret_key = "treks_camps_secret_key_2024"

db_config = {
    "host": os.getenv("DB_HOST", "localhost"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD"),
    "database": os.getenv("DB_NAME", "treks_camps_db"),
}


def get_db():
    return mysql.connector.connect(**db_config)


def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()


def make_id(prefix, latest_id):
    if not latest_id or len(latest_id) < 3:
        return f"{prefix}001"
    number = int(latest_id[-3:]) + 1
    return f"{prefix}{str(number).zfill(3)}"


def format_display_date(date_value):
    if not date_value:
        return ""
    return date_value.strftime("%b %-d") if os.name != "nt" else date_value.strftime("%b %#d")


def difficulty_badge(difficulty):
    if difficulty == "Easy":
        return "avail-green"
    if difficulty == "Moderate":
        return "avail-yellow"
    return "avail-red"


def parse_display_date_to_sql(display_date):
    if not display_date:
        return None
    cleaned = display_date.strip()
    for fmt in ("%b %d", "%b %d, %Y", "%Y-%m-%d"):
        try:
            parsed = datetime.strptime(cleaned, fmt)
            if fmt == "%b %d":
                parsed = parsed.replace(year=datetime.now().year)
            return parsed.strftime("%Y-%m-%d")
        except ValueError:
            continue
    return None


def image_for_trek(difficulty):
    mapping = {
        "Easy": "https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=900&q=80",
        "Moderate": "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=900&q=80",
        "Difficult": "https://images.unsplash.com/photo-1516912481808-3406841bd33c?w=900&q=80",
        "Extreme": "https://images.unsplash.com/photo-1454496522488-7a8e488e8606?w=900&q=80",
    }
    return mapping.get(difficulty, mapping["Moderate"])


def map_trek_row(base_row, instance_rows, camp_rows):
    slots_left = sum(max(0, i["Max_Participants"] - i["Current_Participants"]) for i in instance_rows)
    avail = f"{slots_left} spots left" if slots_left > 0 else "Sold Out"
    img = image_for_trek(base_row["Difficulty_Level"])
    return {
        "id": base_row["TrekID"],
        "name": base_row["Trek_Name"],
        "region": instance_rows[0]["Location"] if instance_rows else "General",
        "difficulty": base_row["Difficulty_Level"],
        "days": int(base_row["Duration_Days"]),
        "price": float(base_row["Price"]),
        "altitude": f'{max([c["Altitude_Meters"] or 0 for c in camp_rows], default=0):,} m' if camp_rows else "-",
        "maxGroup": int(max([i["Max_Participants"] for i in instance_rows], default=20)),
        "rating": 4.7,
        "img": img,
        "thumb": img.replace("w=900", "w=500"),
        "avail": avail,
        "availClass": difficulty_badge(base_row["Difficulty_Level"]),
        "desc": base_row["Description"] or "Detailed trek information will be shared before departure.",
        "inclusions": json.loads(base_row["Inclusions"]) if base_row.get("Inclusions") else [],
        "tags": ["Mountain", base_row["Difficulty_Level"], "Guided Trek"],
        "itinerary": [{"title": "Trek Plan", "desc": "Final itinerary and route details are shared after booking confirmation."}],
        "camps": [
            {
                "name": c["CampName"],
                "alt": f'{c["Altitude_Meters"]:,} m' if c["Altitude_Meters"] else "-",
                "cap": int(c["Capacity"]),
                "fac": c["Facilities"] or "Standard camp facilities",
            }
            for c in camp_rows
        ] or [{"name": "Base Camp", "alt": "-", "cap": 20, "fac": "Standard facilities"}],
        "guide": {"name": "Assigned Guide", "exp": "5 yrs", "spec": "Mountain Trails", "cert": "First Aid Certified"},
        "transport": "Base City",
        "instances": [
            {
                "id": i["InstanceID"],
                "start": format_display_date(i["StartDate"]),
                "end": format_display_date(i["EndDate"]),
                "slots": max(0, i["Max_Participants"] - i["Current_Participants"]),
            }
            for i in instance_rows
        ],
    }


@app.route("/")
def home():
    return render_template("login.html")


@app.route("/login")
def login_page():
    return render_template("login.html")


@app.route("/index")
def index_page():
    return render_template("index.html")


@app.route("/treks")
def treks_page():
    return render_template("treks.html")


@app.route("/trek/<trek_id>")
def trek_detail_page(trek_id):
    return render_template("trek_detail.html")


@app.route("/book")
def book_page():
    return render_template("book_trek.html")


@app.route("/bookings")
def bookings_page():
    return render_template("my_bookings.html")


@app.route("/booking/<booking_id>")
def booking_detail_page(booking_id):
    return render_template("booking_detail.html")


@app.route("/admin")
def admin_page():
    return render_template("admin_dashboard.html")


@app.route("/<path:page>")
def serve_page(page):
    if page in {"shared.js", "shared.css"}:
        return send_from_directory("templates", page)
    allowed = {
        "index.html",
        "treks.html",
        "trek_detail.html",
        "book_trek.html",
        "my_bookings.html",
        "booking_detail.html",
        "admin_dashboard.html",
        "login.html",
    }
    if page in allowed:
        return render_template(page)
    return jsonify({"error": "Not found"}), 404


@app.route("/api/treks", methods=["GET"])
def get_treks():
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT * FROM Trek ORDER BY TrekID")
    treks = cur.fetchall()
    results = []
    for trek in treks:
        cur.execute("SELECT * FROM TrekInstance WHERE TrekID=%s ORDER BY StartDate", (trek["TrekID"],))
        instances = cur.fetchall()
        cur.execute(
            """
            SELECT c.* FROM Camp c
            JOIN Includes inc ON inc.CampID = c.CampID
            JOIN TrekInstance ti ON ti.InstanceID = inc.InstanceID
            WHERE ti.TrekID=%s
            ORDER BY inc.Arrival_Order
            """,
            (trek["TrekID"],),
        )
        camps = cur.fetchall()
        results.append(map_trek_row(trek, instances, camps))
    cur.close()
    db.close()
    return jsonify(results)


@app.route("/api/treks/<trek_id>", methods=["GET"])
def get_trek(trek_id):
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT * FROM Trek WHERE TrekID=%s", (trek_id,))
    trek = cur.fetchone()
    if not trek:
        cur.close()
        db.close()
        return jsonify({"error": "Trek not found"}), 404
    cur.execute("SELECT * FROM TrekInstance WHERE TrekID=%s ORDER BY StartDate", (trek_id,))
    instances = cur.fetchall()
    cur.execute(
        """
        SELECT c.* FROM Camp c
        JOIN Includes inc ON inc.CampID = c.CampID
        JOIN TrekInstance ti ON ti.InstanceID = inc.InstanceID
        WHERE ti.TrekID=%s
        ORDER BY inc.Arrival_Order
        """,
        (trek_id,),
    )
    camps = cur.fetchall()
    response = map_trek_row(trek, instances, camps)
    cur.close()
    db.close()
    return jsonify(response)


@app.route("/api/treks", methods=["POST"])
def create_trek():
    payload = request.get_json(force=True)
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT TrekID FROM Trek ORDER BY TrekID DESC LIMIT 1")
    trek_id = make_id("TRK", (cur.fetchone() or {}).get("TrekID"))
    cur.execute(
        """
        INSERT INTO Trek (TrekID, Trek_Name, Price, Difficulty_Level, Description, Duration_Days, Inclusions)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """,
        (
            trek_id,
            payload.get("name"),
            payload.get("price", 0),
            payload.get("difficulty", "Moderate"),
            payload.get("desc", ""),
            payload.get("days", 1),
            json.dumps(payload.get("inclusions") or []),
        ),
    )
    cur.execute("SELECT AdminID FROM Admin ORDER BY AdminID LIMIT 1")
    admin_id = (cur.fetchone() or {}).get("AdminID", "ADM001")

    instances = payload.get("instances", []) or []
    if not instances:
        instances = [{"start": "Jun 1", "end": "Jun 1", "slots": int(payload.get("maxGroup", 20))}]

    instance_ids = []
    for inst in instances:
        cur.execute("SELECT InstanceID FROM TrekInstance ORDER BY InstanceID DESC LIMIT 1")
        instance_id = make_id("INS", (cur.fetchone() or {}).get("InstanceID"))
        start_sql = parse_display_date_to_sql(inst.get("start")) or datetime.now().strftime("%Y-%m-%d")
        end_sql = parse_display_date_to_sql(inst.get("end")) or start_sql
        location = payload.get("region") or "General"
        max_participants = int(inst.get("slots") or payload.get("maxGroup") or 20)
        cur.execute(
            """
            INSERT INTO TrekInstance (InstanceID, TrekID, AdminID, TransportID, Location, StartDate, EndDate, Max_Participants, Current_Participants, Status)
            VALUES (%s, %s, %s, NULL, %s, %s, %s, %s, 0, 'Upcoming')
            """,
            (instance_id, trek_id, admin_id, location, start_sql, end_sql, max_participants),
        )
        instance_ids.append(instance_id)

    camps = payload.get("camps", []) or []
    for index, camp in enumerate(camps, start=1):
        cur.execute("SELECT CampID FROM Camp ORDER BY CampID DESC LIMIT 1")
        camp_id = make_id("CMP", (cur.fetchone() or {}).get("CampID"))
        camp_alt = (camp.get("alt") or "").replace(",", "").replace(" m", "").strip()
        altitude = int(camp_alt) if camp_alt.isdigit() else None
        cur.execute(
            """
            INSERT INTO Camp (CampID, CampName, Location, Capacity, Facilities, Altitude_Meters)
            VALUES (%s, %s, %s, %s, %s, %s)
            """,
            (
                camp_id,
                camp.get("name", f"Camp {index}"),
                payload.get("region") or "General",
                int(camp.get("cap") or payload.get("maxGroup") or 20),
                camp.get("fac") or "Standard facilities",
                altitude,
            ),
        )
        for instance_id in instance_ids:
            cur.execute(
                "INSERT INTO Includes (InstanceID, CampID, Arrival_Order, Nights) VALUES (%s, %s, %s, %s)",
                (instance_id, camp_id, index, 1),
            )

    db.commit()
    cur.close()
    db.close()
    return jsonify({"id": trek_id}), 201


@app.route("/api/treks/<trek_id>", methods=["PUT"])
def update_trek_api(trek_id):
    payload = request.get_json(force=True)
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT 1 FROM Trek WHERE TrekID=%s", (trek_id,))
    if not cur.fetchone():
        cur.close()
        db.close()
        return jsonify({"error": "Trek not found"}), 404

    cur.execute(
        """
        UPDATE Trek
        SET Trek_Name=%s, Price=%s, Difficulty_Level=%s, Description=%s, Duration_Days=%s, Inclusions=%s
        WHERE TrekID=%s
        """,
        (
            payload.get("name"),
            payload.get("price", 0),
            payload.get("difficulty", "Moderate"),
            payload.get("desc", ""),
            payload.get("days", 1),
            json.dumps(payload.get("inclusions") or []),
            trek_id,
        ),
    )
    cur.execute(
        """
        SELECT COUNT(*) AS count_bookings
        FROM Booking b
        JOIN TrekInstance ti ON ti.InstanceID = b.InstanceID
        WHERE ti.TrekID=%s
        """,
        (trek_id,),
    )
    booking_count = int((cur.fetchone() or {}).get("count_bookings", 0))

    if booking_count == 0:
        cur.execute("DELETE FROM Includes WHERE InstanceID IN (SELECT InstanceID FROM TrekInstance WHERE TrekID=%s)", (trek_id,))
        cur.execute("DELETE FROM TrekInstance WHERE TrekID=%s", (trek_id,))
        cur.execute(
            """
            DELETE c FROM Camp c
            LEFT JOIN Includes i ON i.CampID = c.CampID
            WHERE i.CampID IS NULL
            """
        )
        cur.execute("SELECT AdminID FROM Admin ORDER BY AdminID LIMIT 1")
        admin_id = (cur.fetchone() or {}).get("AdminID", "ADM001")
        instances = payload.get("instances", []) or []
        if not instances:
            instances = [{"start": "Jun 1", "end": "Jun 1", "slots": int(payload.get("maxGroup", 20))}]
        instance_ids = []
        for inst in instances:
            cur.execute("SELECT InstanceID FROM TrekInstance ORDER BY InstanceID DESC LIMIT 1")
            instance_id = make_id("INS", (cur.fetchone() or {}).get("InstanceID"))
            start_sql = parse_display_date_to_sql(inst.get("start")) or datetime.now().strftime("%Y-%m-%d")
            end_sql = parse_display_date_to_sql(inst.get("end")) or start_sql
            location = payload.get("region") or "General"
            max_participants = int(inst.get("slots") or payload.get("maxGroup") or 20)
            cur.execute(
                """
                INSERT INTO TrekInstance (InstanceID, TrekID, AdminID, TransportID, Location, StartDate, EndDate, Max_Participants, Current_Participants, Status)
                VALUES (%s, %s, %s, NULL, %s, %s, %s, %s, 0, 'Upcoming')
                """,
                (instance_id, trek_id, admin_id, location, start_sql, end_sql, max_participants),
            )
            instance_ids.append(instance_id)

        camps = payload.get("camps", []) or []
        for index, camp in enumerate(camps, start=1):
            cur.execute("SELECT CampID FROM Camp ORDER BY CampID DESC LIMIT 1")
            camp_id = make_id("CMP", (cur.fetchone() or {}).get("CampID"))
            camp_alt = (camp.get("alt") or "").replace(",", "").replace(" m", "").strip()
            altitude = int(camp_alt) if camp_alt.isdigit() else None
            cur.execute(
                """
                INSERT INTO Camp (CampID, CampName, Location, Capacity, Facilities, Altitude_Meters)
                VALUES (%s, %s, %s, %s, %s, %s)
                """,
                (
                    camp_id,
                    camp.get("name", f"Camp {index}"),
                    payload.get("region") or "General",
                    int(camp.get("cap") or payload.get("maxGroup") or 20),
                    camp.get("fac") or "Standard facilities",
                    altitude,
                ),
            )
            for instance_id in instance_ids:
                cur.execute(
                    "INSERT INTO Includes (InstanceID, CampID, Arrival_Order, Nights) VALUES (%s, %s, %s, %s)",
                    (instance_id, camp_id, index, 1),
                )

    db.commit()
    cur.close()
    db.close()
    return jsonify({"ok": True, "instancesUpdated": booking_count == 0})


@app.route("/api/treks/<trek_id>", methods=["DELETE"])
def delete_trek_api(trek_id):
    db = get_db()
    cur = db.cursor()
    cur.execute("DELETE FROM Trek WHERE TrekID=%s", (trek_id,))
    db.commit()
    deleted = cur.rowcount > 0
    cur.close()
    db.close()
    if not deleted:
        return jsonify({"error": "Trek not found"}), 404
    return jsonify({"ok": True})


@app.route("/api/bookings", methods=["GET"])
def get_bookings():
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute(
        """
        SELECT b.BookingID, b.Status, b.Total_Amount, b.Number_of_Participants, b.Special_Requirements, b.Booking_Date,
               ti.InstanceID, ti.StartDate, ti.EndDate, ti.Location,
               t.TrekID, t.Trek_Name, t.Difficulty_Level, t.Duration_Days
        FROM Booking b
        JOIN TrekInstance ti ON ti.InstanceID = b.InstanceID
        JOIN Trek t ON t.TrekID = ti.TrekID
        ORDER BY b.Booking_Date DESC
        """
    )
    rows = cur.fetchall()
    out = []
    for r in rows:
        out.append(
            {
                "id": r["BookingID"],
                "trekId": r["TrekID"],
                "trekName": r["Trek_Name"],
                "region": r["Location"],
                "instanceId": r["InstanceID"],
                "batchText": f'{format_display_date(r["StartDate"])}{" - " + format_display_date(r["EndDate"]) if r["EndDate"] != r["StartDate"] else ""}',
                "numParticipants": int(r["Number_of_Participants"]),
                "total": float(r["Total_Amount"]),
                "status": r["Status"],
                "bookedOn": r["Booking_Date"].strftime("%d %b %Y"),
                "specialReq": r["Special_Requirements"] or "",
                "img": image_for_trek(r["Difficulty_Level"]).replace("w=900", "w=500"),
                "difficulty": r["Difficulty_Level"],
                "days": int(r["Duration_Days"]),
                "guide": "Assigned Guide",
                "transport": "Base City",
            }
        )
    cur.close()
    db.close()
    return jsonify(out)


@app.route("/api/bookings/<booking_id>", methods=["GET"])
def get_booking(booking_id):
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute(
        """
        SELECT b.BookingID, b.Status, b.Total_Amount, b.Number_of_Participants, b.Special_Requirements, b.Booking_Date,
               ti.InstanceID, ti.StartDate, ti.EndDate, ti.Location,
               t.TrekID, t.Trek_Name, t.Difficulty_Level, t.Duration_Days
        FROM Booking b
        JOIN TrekInstance ti ON ti.InstanceID = b.InstanceID
        JOIN Trek t ON t.TrekID = ti.TrekID
        WHERE b.BookingID=%s
        """,
        (booking_id,),
    )
    r = cur.fetchone()
    cur.close()
    db.close()
    if not r:
        return jsonify({"error": "Booking not found"}), 404
    return jsonify(
        {
            "id": r["BookingID"],
            "trekId": r["TrekID"],
            "trekName": r["Trek_Name"],
            "region": r["Location"],
            "instanceId": r["InstanceID"],
            "batchText": f'{format_display_date(r["StartDate"])}{" - " + format_display_date(r["EndDate"]) if r["EndDate"] != r["StartDate"] else ""}',
            "numParticipants": int(r["Number_of_Participants"]),
            "total": float(r["Total_Amount"]),
            "status": r["Status"],
            "bookedOn": r["Booking_Date"].strftime("%d %b %Y"),
            "specialReq": r["Special_Requirements"] or "",
            "img": image_for_trek(r["Difficulty_Level"]).replace("w=900", "w=500"),
            "difficulty": r["Difficulty_Level"],
            "days": int(r["Duration_Days"]),
            "guide": "Assigned Guide",
            "transport": "Base City",
        }
    )


@app.route("/api/bookings", methods=["POST"])
def create_booking():
    payload = request.get_json(force=True)
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT BookingID FROM Booking ORDER BY BookingID DESC LIMIT 1")
    booking_id = make_id("BKG", (cur.fetchone() or {}).get("BookingID"))
    cur.execute(
        """
        INSERT INTO Booking (BookingID, InstanceID, Status, Total_Amount, Number_of_Participants, Special_Requirements)
        VALUES (%s, %s, %s, %s, %s, %s)
        """,
        (
            booking_id,
            payload.get("instanceId"),
            payload.get("status", "Confirmed"),
            payload.get("total", 0),
            payload.get("numParticipants", 1),
            payload.get("specialReq", ""),
        ),
    )
    db.commit()
    cur.close()
    db.close()
    return jsonify({"id": booking_id}), 201


@app.route("/api/bookings/<booking_id>/cancel", methods=["PATCH"])
def cancel_booking(booking_id):
    db = get_db()
    cur = db.cursor()
    cur.execute("UPDATE Booking SET Status='Cancelled' WHERE BookingID=%s", (booking_id,))
    db.commit()
    ok = cur.rowcount > 0
    cur.close()
    db.close()
    if not ok:
        return jsonify({"error": "Booking not found"}), 404
    return jsonify({"ok": True})


if __name__ == "__main__":
    app.run(debug=True)