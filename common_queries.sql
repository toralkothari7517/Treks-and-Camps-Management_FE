-- common_queries.sql
USE treks_camps_db;

-- 1. List all upcoming treks with available slots
SELECT * FROM Available_TrekInstances;

-- 2. Search treks by difficulty and date range
CALL GetAvailableTreks('2026-05-01', '2026-12-31', 'Moderate');

-- 3. Booking history for a participant
SELECT p.Name, b.BookingID, t.Trek_Name, ti.StartDate, b.Status
FROM Participant p
JOIN ParticipatesIn pi ON p.ParticipantID = pi.ParticipantID
JOIN Booking b ON pi.BookingID = b.BookingID
JOIN TrekInstance ti ON b.InstanceID = ti.InstanceID
JOIN Trek t ON ti.TrekID = t.TrekID
WHERE p.ParticipantID = 'PRT001'
ORDER BY ti.StartDate DESC;

-- 4. Revenue by trek
SELECT * FROM Trek_Revenue;

-- 5. Guide performance report
SELECT * FROM Guide_Performance ORDER BY Average_Rating DESC;

-- 6. Booking summary for confirmed trips
SELECT * FROM Booking_Summary WHERE Booking_Status = 'Confirmed';

-- 7. Current occupancy percentages
SELECT t.Trek_Name, ti.StartDate, ti.Current_Participants, ti.Max_Participants,
       ROUND((ti.Current_Participants * 100.0 / ti.Max_Participants), 2) AS Occupancy_Percent
FROM TrekInstance ti
JOIN Trek t ON ti.TrekID = t.TrekID
WHERE ti.Status = 'Upcoming';

-- 8. Treks within price range
SELECT Trek_Name, Price, Difficulty_Level, Duration_Days
FROM Trek
WHERE Price BETWEEN 5000 AND 15000
ORDER BY Price;
