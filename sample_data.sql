-- sample_data.sql
USE treks_camps_db;

INSERT INTO Admin (AdminID, Name, Contact, Email, PasswordHash) VALUES
('ADM001', 'Priya Sharma', '9876543210', 'priya@example.com', ''),
('ADM002', 'Rohan Mehta', '9123456780', 'rohan@example.com', '');

INSERT INTO Trek (TrekID, Trek_Name, Price, Difficulty_Level, Description, Duration_Days) VALUES
('TRK001', 'Mountain Sunrise Trail', 12000.00, 'Moderate', 'A scenic trek with sunrise views and campfire nights.', 5),
('TRK002', 'Forest Adventure Trek', 9000.00, 'Easy', 'Beginner-friendly forest trek with rich biodiversity.', 3),
('TRK003', 'High Altitude Peak Trek', 22000.00, 'Difficult', 'Challenging trek to a high-altitude peak with experienced guides.', 7);

INSERT INTO Transport (TransportID, Vehicle_Type, Pickup_Location, Departure_Time, Vehicle_Number, Capacity) VALUES
('TRN001', 'Bus', 'Downtown Bus Stand', '06:00:00', 'MH12AB1234', 40),
('TRN002', 'Jeep', 'City Outskirts', '08:30:00', 'MH14CD5678', 12);

INSERT INTO TrekInstance (InstanceID, TrekID, AdminID, TransportID, Location, StartDate, EndDate, Max_Participants, Current_Participants, Status) VALUES
('INS001', 'TRK001', 'ADM001', 'TRN001', 'Himalayan Foothills', '2026-05-10', '2026-05-14', 20, 8, 'Upcoming'),
('INS002', 'TRK002', 'ADM001', 'TRN002', 'Western Ghats', '2026-06-02', '2026-06-04', 15, 5, 'Upcoming'),
('INS003', 'TRK003', 'ADM002', 'TRN001', 'Zanskar Valley', '2026-07-15', '2026-07-21', 12, 10, 'Upcoming');

INSERT INTO Camp (CampID, CampName, Location, Capacity, Facilities, Altitude_Meters) VALUES
('CMP001', 'Riverside Camp', 'Himalayan Foothills', 40, 'Tents, Bonfire, Food, First Aid', 1450),
('CMP002', 'Misty Woods Camp', 'Western Ghats', 30, 'Tents, Guided Walks, Meals', 900),
('CMP003', 'Highland Camp', 'Zanskar Valley', 20, 'Heaters, Meals, Oxygen Support', 3600);

INSERT INTO Participant (ParticipantID, Name, Age, Gender, Contact, Email, Medical_Condition, Emergency_Contact) VALUES
('PRT001', 'Anjali Patel', 29, 'Female', '9988776655', 'anjali@example.com', 'None', 'Mr. Patel - 9988773344'),
('PRT002', 'Ravi Kumar', 35, 'Male', '9898989898', 'ravi@example.com', 'Asthma', 'Mrs. Kumar - 9898981234'),
('PRT003', 'Meera Joshi', 24, 'Female', '9777766655', 'meera@example.com', 'None', 'Mr. Joshi - 9777761122');

INSERT INTO Booking (BookingID, InstanceID, Status, Total_Amount, Number_of_Participants, Special_Requirements) VALUES
('BKG001', 'INS001', 'Confirmed', 24000.00, 2, 'Vegetarian meals'),
('BKG002', 'INS002', 'Pending', 9000.00, 1, 'Requires single tent'),
('BKG003', 'INS003', 'Confirmed', 44000.00, 2, 'Oxygen support equipment');

INSERT INTO ParticipatesIn (ParticipantID, BookingID, Role) VALUES
('PRT001', 'BKG001', 'Leader'),
('PRT002', 'BKG001', 'Member'),
('PRT003', 'BKG002', 'Leader');

INSERT INTO Guide (GuideID, Name, Contact, Email, Experience_Years, Specialization, Certification) VALUES
('GDE001', 'Vikram Singh', '9123450000', 'vikram@example.com', 8, 'Mountain Trekking', 'Wilderness Safety Certified'),
('GDE002', 'Sana Ali', '9123451111', 'sana@example.com', 5, 'Forest Trails', 'First Aid & Rescue');

INSERT INTO AssignedTo (GuideID, BookingID) VALUES
('GDE001', 'BKG001'),
('GDE002', 'BKG003');

INSERT INTO Includes (InstanceID, CampID, Arrival_Order, Nights) VALUES
('INS001', 'CMP001', 1, 4),
('INS002', 'CMP002', 1, 2),
('INS003', 'CMP003', 1, 6);

INSERT INTO Payment (PaymentID, BookingID, Amount, Payment_Method, Transaction_ID, Payment_Status) VALUES
('PAY001', 'BKG001', 24000.00, 'UPI', 'TXN20260510001', 'Success'),
('PAY002', 'BKG003', 44000.00, 'Card', 'TXN20260615002', 'Success');

INSERT INTO Feedback (FeedbackID, BookingID, Rating, Comments) VALUES
('FDB001', 'BKG001', 5, 'Fantastic experience with great support from the guide.'),
('FDB002', 'BKG003', 4, 'Beautiful trek, slightly challenging but worth it.');
