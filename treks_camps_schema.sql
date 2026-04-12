-- treks_camps_schema.sql
-- Database schema for Trek and Camp Management System

DROP DATABASE IF EXISTS treks_camps_db;
CREATE DATABASE treks_camps_db;
USE treks_camps_db;

CREATE TABLE Admin (
    AdminID VARCHAR(20) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Contact VARCHAR(30),
    Email VARCHAR(100) UNIQUE,
    PasswordHash VARCHAR(255)
);

CREATE TABLE Trek (
    TrekID VARCHAR(20) PRIMARY KEY,
    Trek_Name VARCHAR(150) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Difficulty_Level ENUM('Easy','Moderate','Difficult','Extreme') NOT NULL,
    Description TEXT,
    Duration_Days INT NOT NULL
);

CREATE TABLE Transport (
    TransportID VARCHAR(20) PRIMARY KEY,
    Vehicle_Type VARCHAR(100) NOT NULL,
    Pickup_Location VARCHAR(150) NOT NULL,
    Departure_Time TIME NOT NULL,
    Vehicle_Number VARCHAR(50) UNIQUE,
    Capacity INT NOT NULL
);

CREATE TABLE TrekInstance (
    InstanceID VARCHAR(20) PRIMARY KEY,
    TrekID VARCHAR(20) NOT NULL,
    AdminID VARCHAR(20) NOT NULL,
    TransportID VARCHAR(20),
    Location VARCHAR(150) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    Max_Participants INT NOT NULL,
    Current_Participants INT DEFAULT 0,
    Status ENUM('Upcoming','Ongoing','Completed','Cancelled') DEFAULT 'Upcoming',
    FOREIGN KEY (TrekID) REFERENCES Trek(TrekID) ON DELETE CASCADE,
    FOREIGN KEY (AdminID) REFERENCES Admin(AdminID) ON DELETE SET NULL,
    FOREIGN KEY (TransportID) REFERENCES Transport(TransportID) ON DELETE SET NULL
);

CREATE TABLE Camp (
    CampID VARCHAR(20) PRIMARY KEY,
    CampName VARCHAR(150) NOT NULL,
    Location VARCHAR(150) NOT NULL,
    Capacity INT NOT NULL,
    Facilities TEXT,
    Altitude_Meters INT
);

CREATE TABLE Participant (
    ParticipantID VARCHAR(20) PRIMARY KEY,
    Name VARCHAR(150) NOT NULL,
    Age INT,
    Gender ENUM('Male','Female','Other'),
    Contact VARCHAR(30),
    Email VARCHAR(100),
    Medical_Condition TEXT,
    Emergency_Contact VARCHAR(150)
);

CREATE TABLE Booking (
    BookingID VARCHAR(20) PRIMARY KEY,
    InstanceID VARCHAR(20) NOT NULL,
    Status ENUM('Pending','Confirmed','Cancelled','Completed') DEFAULT 'Pending',
    Total_Amount DECIMAL(10,2) NOT NULL,
    Number_of_Participants INT NOT NULL,
    Special_Requirements TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (InstanceID) REFERENCES TrekInstance(InstanceID) ON DELETE CASCADE
);

CREATE TABLE Guide (
    GuideID VARCHAR(20) PRIMARY KEY,
    Name VARCHAR(150) NOT NULL,
    Contact VARCHAR(30),
    Email VARCHAR(100),
    Experience_Years INT DEFAULT 0,
    Specialization VARCHAR(150),
    Certification VARCHAR(255)
);

CREATE TABLE Payment (
    PaymentID VARCHAR(20) PRIMARY KEY,
    BookingID VARCHAR(20) NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Payment_Method ENUM('Cash','Card','UPI','Net Banking') NOT NULL,
    Payment_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Transaction_ID VARCHAR(100) UNIQUE,
    Payment_Status ENUM('Pending','Success','Failed','Refunded') DEFAULT 'Pending',
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE
);

CREATE TABLE Feedback (
    FeedbackID VARCHAR(20) PRIMARY KEY,
    BookingID VARCHAR(20) NOT NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comments TEXT,
    Feedback_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE
);

CREATE TABLE ParticipatesIn (
    ParticipantID VARCHAR(20) NOT NULL,
    BookingID VARCHAR(20) NOT NULL,
    Role ENUM('Leader','Member') DEFAULT 'Member',
    PRIMARY KEY (ParticipantID, BookingID),
    FOREIGN KEY (ParticipantID) REFERENCES Participant(ParticipantID) ON DELETE CASCADE,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE
);

CREATE TABLE AssignedTo (
    GuideID VARCHAR(20) NOT NULL,
    BookingID VARCHAR(20) NOT NULL,
    Assignment_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (GuideID, BookingID),
    FOREIGN KEY (GuideID) REFERENCES Guide(GuideID) ON DELETE CASCADE,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE
);

CREATE TABLE Includes (
    InstanceID VARCHAR(20) NOT NULL,
    CampID VARCHAR(20) NOT NULL,
    Arrival_Order INT NOT NULL,
    Nights INT NOT NULL,
    PRIMARY KEY (InstanceID, CampID),
    FOREIGN KEY (InstanceID) REFERENCES TrekInstance(InstanceID) ON DELETE CASCADE,
    FOREIGN KEY (CampID) REFERENCES Camp(CampID) ON DELETE CASCADE
);

CREATE INDEX idx_trek_difficulty_price ON Trek (Difficulty_Level, Price);
CREATE INDEX idx_instance_dates_status ON TrekInstance (StartDate, EndDate, Status);
CREATE INDEX idx_booking_status ON Booking (Status);
CREATE INDEX idx_payment_status ON Payment (Payment_Status);

DELIMITER $$

CREATE TRIGGER before_booking_insert
BEFORE INSERT ON Booking
FOR EACH ROW
BEGIN
    DECLARE available_slots INT;
    SELECT Max_Participants - Current_Participants INTO available_slots
    FROM TrekInstance
    WHERE InstanceID = NEW.InstanceID;
    IF available_slots < NEW.Number_of_Participants THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot book more participants than available slots';
    END IF;
END$$

CREATE TRIGGER after_booking_insert
AFTER INSERT ON Booking
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Confirmed' THEN
        UPDATE TrekInstance
        SET Current_Participants = Current_Participants + NEW.Number_of_Participants
        WHERE InstanceID = NEW.InstanceID;
    END IF;
END$$

CREATE TRIGGER after_booking_update
AFTER UPDATE ON Booking
FOR EACH ROW
BEGIN
    IF OLD.Status <> NEW.Status THEN
        IF NEW.Status = 'Confirmed' THEN
            UPDATE TrekInstance
            SET Current_Participants = Current_Participants + NEW.Number_of_Participants
            WHERE InstanceID = NEW.InstanceID;
        ELSEIF OLD.Status = 'Confirmed' AND NEW.Status IN ('Cancelled','Pending') THEN
            UPDATE TrekInstance
            SET Current_Participants = Current_Participants - OLD.Number_of_Participants
            WHERE InstanceID = OLD.InstanceID;
        END IF;
    END IF;
END$$

CREATE TRIGGER before_trekinstance_update
BEFORE UPDATE ON TrekInstance
FOR EACH ROW
BEGIN
    IF NEW.StartDate > NEW.EndDate THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'StartDate cannot be later than EndDate';
    END IF;
    IF NEW.StartDate <= CURDATE() AND NEW.EndDate >= CURDATE() THEN
        SET NEW.Status = 'Ongoing';
    ELSEIF NEW.EndDate < CURDATE() THEN
        SET NEW.Status = 'Completed';
    ELSE
        SET NEW.Status = 'Upcoming';
    END IF;
END$$

DELIMITER ;

CREATE VIEW Available_TrekInstances AS
SELECT
    ti.InstanceID,
    t.Trek_Name,
    t.Difficulty_Level,
    t.Price,
    ti.Location,
    ti.StartDate,
    ti.EndDate,
    ti.Max_Participants - ti.Current_Participants AS Available_Slots,
    ti.Status
FROM TrekInstance ti
JOIN Trek t ON ti.TrekID = t.TrekID
WHERE ti.Status = 'Upcoming' AND ti.Max_Participants > ti.Current_Participants;

CREATE VIEW Booking_Summary AS
SELECT
    b.BookingID,
    b.InstanceID,
    t.Trek_Name,
    b.Status AS Booking_Status,
    b.Total_Amount,
    b.Number_of_Participants,
    p.Payment_Status,
    p.Payment_Method,
    p.Transaction_ID,
    b.CreatedAt
FROM Booking b
LEFT JOIN Payment p ON b.BookingID = p.BookingID
LEFT JOIN TrekInstance ti ON b.InstanceID = ti.InstanceID
LEFT JOIN Trek t ON ti.TrekID = t.TrekID;

CREATE VIEW Guide_Performance AS
SELECT
    g.GuideID,
    g.Name,
    g.Experience_Years,
    COUNT(DISTINCT at.BookingID) AS Bookings_Assigned,
    ROUND(AVG(f.Rating),2) AS Average_Rating
FROM Guide g
LEFT JOIN AssignedTo at ON g.GuideID = at.GuideID
LEFT JOIN Booking b ON at.BookingID = b.BookingID
LEFT JOIN Feedback f ON b.BookingID = f.BookingID
GROUP BY g.GuideID;

CREATE VIEW Trek_Revenue AS
SELECT
    t.TrekID,
    t.Trek_Name,
    COUNT(DISTINCT b.BookingID) AS Total_Bookings,
    SUM(b.Total_Amount) AS Total_Revenue,
    AVG(b.Total_Amount) AS Average_Booking_Value
FROM Trek t
LEFT JOIN TrekInstance ti ON t.TrekID = ti.TrekID
LEFT JOIN Booking b ON ti.InstanceID = b.InstanceID
GROUP BY t.TrekID;

DELIMITER $$

CREATE PROCEDURE CreateBooking(
    IN p_BookingID VARCHAR(20),
    IN p_InstanceID VARCHAR(20),
    IN p_Status ENUM('Pending','Confirmed','Cancelled','Completed'),
    IN p_Total_Amount DECIMAL(10,2),
    IN p_Number_of_Participants INT,
    IN p_Special_Requirements TEXT
)
BEGIN
    INSERT INTO Booking (BookingID, InstanceID, Status, Total_Amount, Number_of_Participants, Special_Requirements)
    VALUES (p_BookingID, p_InstanceID, p_Status, p_Total_Amount, p_Number_of_Participants, p_Special_Requirements);
END$$

CREATE PROCEDURE ProcessPayment(
    IN p_PaymentID VARCHAR(20),
    IN p_BookingID VARCHAR(20),
    IN p_Amount DECIMAL(10,2),
    IN p_Payment_Method ENUM('Cash','Card','UPI','Net Banking'),
    IN p_Transaction_ID VARCHAR(100),
    IN p_Status ENUM('Pending','Success','Failed','Refunded')
)
BEGIN
    INSERT INTO Payment (PaymentID, BookingID, Amount, Payment_Method, Transaction_ID, Payment_Status)
    VALUES (p_PaymentID, p_BookingID, p_Amount, p_Payment_Method, p_Transaction_ID, p_Status);
    IF p_Status = 'Success' THEN
        UPDATE Booking SET Status = 'Confirmed' WHERE BookingID = p_BookingID;
    END IF;
END$$

CREATE PROCEDURE GetAvailableTreks(
    IN p_StartDate DATE,
    IN p_EndDate DATE,
    IN p_Difficulty VARCHAR(20)
)
BEGIN
    SELECT * FROM Available_TrekInstances
    WHERE StartDate BETWEEN p_StartDate AND p_EndDate
      AND (p_Difficulty = '' OR Difficulty_Level = p_Difficulty);
END$$

CREATE PROCEDURE CancelBooking(
    IN p_BookingID VARCHAR(20)
)
BEGIN
    UPDATE Booking SET Status = 'Cancelled' WHERE BookingID = p_BookingID;
    UPDATE Payment SET Payment_Status = 'Refunded' WHERE BookingID = p_BookingID AND Payment_Status = 'Success';
END$$

DELIMITER ;
