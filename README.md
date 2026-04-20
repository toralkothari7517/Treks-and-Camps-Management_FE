# Treks and Camps Management

This repository contains a Flask-based frontend/backend scaffold for a trekking and camping management system. It includes database schema, sample data, frontend templates, and a simple Flask app.

## Project Structure

- `treks_camps_schema.sql` - Complete MySQL database schema with tables, triggers, views, and stored procedures.
- `sample_data.sql` - Sample dataset for testing with admins, treks, bookings, participants, payments, and feedback.
- `common_queries.sql` - Useful SQL queries for reporting and operations.
- `app.py` - Flask application with minimal routes for browsing and booking treks.
- `requirements.txt` - Python package dependencies.
- `templates/` - HTML pages for index, trek listings, booking, admin dashboard, and login.
- `static/` - CSS and JS assets.

## Setup Instructions

1. Install dependencies:

```bash
pip install -r requirements.txt
```

2. Start MySQL and load schema/data:

```bash
mysql -u root -p < treks_camps_schema.sql
mysql -u root -p < sample_data.sql
```

3. Update database credentials in `app.py` if needed.

4. Run the Flask app:

```bash
python app.py
```

5. Open `http://localhost:5000` in your browser.

## Notes

- The app includes a simple booking workflow and basic admin pages.
- Use the SQL scripts to manage database objects and generate reports.
- For production, replace the Flask secret key and use secure credentials.
- For backend handoff after recent UI updates, see `HANDOFF_BACKEND_INTEGRATION.md`.
