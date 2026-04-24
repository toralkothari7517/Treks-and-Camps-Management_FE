-- ============================================
-- TREKS AND CAMPS MANAGEMENT SYSTEM (FINAL)
-- ============================================
DROP DATABASE IF EXISTS treks_camps_db;
CREATE DATABASE treks_camps_db;
USE treks_camps_db;

-- ============================================
-- TABLE: Admin
-- ============================================
CREATE TABLE Admin (
    AdminID VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Contact VARCHAR(15) NOT NULL UNIQUE,
    Email VARCHAR(100) UNIQUE,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: Participant
-- ============================================
CREATE TABLE Participant (
    ParticipantID VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Age INT NOT NULL CHECK (Age > 0 AND Age < 120),
    Gender ENUM('Male', 'Female', 'Other') NOT NULL,
    Contact VARCHAR(15) NOT NULL,
    Email VARCHAR(100),
    Medical_Condition TEXT,
    Emergency_Contact VARCHAR(15),
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: Guide
-- ============================================
CREATE TABLE Guide (
    GuideID VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Contact VARCHAR(15) NOT NULL UNIQUE,
    Email VARCHAR(100),
    Experience_Years INT NOT NULL CHECK (Experience_Years >= 0),
    Specialization VARCHAR(100),
    Certification VARCHAR(100),
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- AUTH TABLE (FIXED)
-- ============================================
CREATE TABLE UserAuth (
    UserID VARCHAR(10) PRIMARY KEY,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Password VARCHAR(256) NOT NULL,
    Role ENUM('Admin', 'Participant', 'Guide') NOT NULL,
    LinkedID VARCHAR(10) NOT NULL,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- REST OF YOUR ORIGINAL SCHEMA (UNCHANGED)
-- ============================================

CREATE TABLE Trek (
    TrekID VARCHAR(10) PRIMARY KEY,
    Trek_Name VARCHAR(150) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL CHECK (Price >= 0),
    Difficulty_Level ENUM('Easy', 'Moderate', 'Difficult', 'Extreme') NOT NULL,
    Description TEXT,
    Inclusions TEXT,
    Duration_Days INT NOT NULL CHECK (Duration_Days > 0),
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Camp (
    CampID VARCHAR(10) PRIMARY KEY,
    CampName VARCHAR(100) NOT NULL,
    Location VARCHAR(200) NOT NULL,
    Capacity INT NOT NULL CHECK (Capacity > 0),
    Facilities TEXT,
    Altitude_Meters INT,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Transport (
    TransportID VARCHAR(10) PRIMARY KEY,
    Vehicle_Type ENUM('Bus', 'Minivan', 'Jeep', 'Tempo Traveller') NOT NULL,
    Pickup_Location VARCHAR(200) NOT NULL,
    Departure_Time TIME NOT NULL,
    Vehicle_Number VARCHAR(20),
    Capacity INT NOT NULL CHECK (Capacity > 0),
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE TrekInstance (
    InstanceID VARCHAR(10) PRIMARY KEY,
    TrekID VARCHAR(10) NOT NULL,
    AdminID VARCHAR(10) NOT NULL,
    TransportID VARCHAR(10),
    Location VARCHAR(200) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    Max_Participants INT NOT NULL CHECK (Max_Participants > 0),
    Current_Participants INT DEFAULT 0 CHECK (Current_Participants >= 0),
    Status ENUM('Upcoming', 'Ongoing', 'Completed', 'Cancelled') DEFAULT 'Upcoming',
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (TrekID) REFERENCES Trek(TrekID) ON DELETE CASCADE,
    FOREIGN KEY (AdminID) REFERENCES Admin(AdminID) ON DELETE RESTRICT,
    FOREIGN KEY (TransportID) REFERENCES Transport(TransportID) ON DELETE SET NULL,
    CHECK (EndDate >= StartDate),
    CHECK (Current_Participants <= Max_Participants)
);

CREATE TABLE Booking (
    BookingID VARCHAR(10) PRIMARY KEY,
    InstanceID VARCHAR(10) NOT NULL,
    Booking_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('Pending', 'Confirmed', 'Cancelled', 'Completed') DEFAULT 'Pending',
    Total_Amount DECIMAL(10, 2) NOT NULL CHECK (Total_Amount >= 0),
    Number_of_Participants INT NOT NULL CHECK (Number_of_Participants > 0),
    Special_Requirements TEXT,
    FOREIGN KEY (InstanceID) REFERENCES TrekInstance(InstanceID) ON DELETE RESTRICT
);

CREATE TABLE ParticipatesIn (
    ParticipantID VARCHAR(10),
    BookingID VARCHAR(10),
    Role ENUM('Leader','Member') DEFAULT 'Member',
    PRIMARY KEY (ParticipantID, BookingID),
    FOREIGN KEY (ParticipantID) REFERENCES Participant(ParticipantID) ON DELETE CASCADE,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE
);

CREATE TABLE AssignedTo (
    GuideID VARCHAR(10),
    BookingID VARCHAR(10),
    Assignment_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (GuideID, BookingID),
    FOREIGN KEY (GuideID) REFERENCES Guide(GuideID) ON DELETE CASCADE,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE
);

CREATE TABLE Includes (
    InstanceID VARCHAR(10),
    CampID VARCHAR(10),
    Arrival_Order INT,
    Nights INT DEFAULT 1,
    PRIMARY KEY (InstanceID, CampID),
    FOREIGN KEY (InstanceID) REFERENCES TrekInstance(InstanceID) ON DELETE CASCADE,
    FOREIGN KEY (CampID) REFERENCES Camp(CampID) ON DELETE CASCADE
);

CREATE TABLE Payment (
    PaymentID VARCHAR(10) PRIMARY KEY,
    BookingID VARCHAR(10),
    Amount DECIMAL(10,2),
    Payment_Method ENUM('Cash','Card','UPI','Net Banking'),
    Payment_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Transaction_ID VARCHAR(50),
    Payment_Status ENUM('Pending','Success','Failed','Refunded') DEFAULT 'Pending',
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE
);

CREATE TABLE Feedback (
    FeedbackID VARCHAR(10) PRIMARY KEY,
    BookingID VARCHAR(10) UNIQUE,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comments TEXT,
    Feedback_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE
);
