import mysql.connector
import os
from dotenv import load_dotenv

def main():
    # Load environment variables from .env
    load_dotenv()

    # Get DB credentials
    db_host = os.getenv("DB_HOST", "localhost")
    db_user = os.getenv("DB_USER", "root")
    db_password = os.getenv("DB_PASSWORD", "7517")
    db_name = os.getenv("DB_NAME", "treks_camps_db")

    print(f"Connecting to MySQL server at {db_host}...")
    
    try:
        # First connect without specifying database, to ensure we can create it if needed
        conn = mysql.connector.connect(
            host=db_host,
            user=db_user,
            password=db_password
        )
        cursor = conn.cursor()

        # Create Database and Use it
        print(f"Creating database '{db_name}' if it doesn't exist...")
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {db_name}")
        cursor.execute(f"USE {db_name}")

        # Execute Schema
        print("Loading schema from 'treks_camps_schema.sql'...")
        with open("treks_camps_schema.sql", "r", encoding="utf-8") as f:
            schema_sql = f.read()
            # multi=True is critical to run multiple statements separated by ';'
            for result in cursor.execute(schema_sql, multi=True):
                pass
        
        # Execute Sample Data
        print("Loading sample data from 'sample_data.sql'...")
        with open("sample_data.sql", "r", encoding="utf-8") as f:
            data_sql = f.read()
            for result in cursor.execute(data_sql, multi=True):
                pass

        # Commit our transaction
        conn.commit()
        print("\nSuccess! The data is now connected to your app.")
        print("You can run your Flask app by typing: python app.py")

    except mysql.connector.Error as err:
        print(f"MySQL Error: {err}")
    except FileNotFoundError as err:
        print(f"File Error: Could not find the sql file. ({err})")
    except Exception as err:
        print(f"Unexpected Error: {err}")
    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()
            print("MySQL connection closed.")

if __name__ == "__main__":
    main()
