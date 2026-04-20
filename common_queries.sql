-- ============================================
-- COMMON SQL QUERIES
-- Treks and Camps Management System
-- ============================================

USE treks_camps_db;

-- ============================================
-- 1. SEARCH & BROWSE QUERIES
-- ============================================

-- 1.1 Get all available trek instances with details
SELECT 
    ti.InstanceID,
    t.Trek_Name,
    t.Difficulty_Level,
    ti.StartDate,
    ti.EndDate,
    t.Duration_Days,
    t.Price,
    ti.Max_Participants,
    ti.Current_Participants,
    (ti.Max_Participants - ti.Current_Participants) AS Available_Slots,
    ti.Location
FROM TrekInstance ti
JOIN Trek t ON ti.TrekID = t.TrekID
WHERE ti.Status = 'Upcoming' 
  AND ti.StartDate > CURDATE()
  AND ti.Current_Participants < ti.Max_Participants
ORDER BY ti.StartDate;

-- 1.2 Search treks by difficulty level
SELECT 
    t.TrekID,
    t.Trek_Name,
    t.Difficulty_Level,
    t.Price,
    t.Duration_Days,
    COUNT(ti.InstanceID) AS Upcoming_Instances
FROM Trek t
LEFT JOIN TrekInstance ti ON t.TrekID = ti.TrekID AND ti.Status = 'Upcoming'
WHERE t.Difficulty_Level = 'Moderate'  -- Change as needed
GROUP BY t.TrekID
ORDER BY t.Trek_Name;

-- 1.3 Search treks by price range
SELECT 
    TrekID,
    Trek_Name,
    Price,
    Difficulty_Level,
    Duration_Days
FROM Trek
WHERE Price BETWEEN 5000 AND 15000
ORDER BY Price;

-- 1.4 Get trek details with all camps
SELECT 
    t.Trek_Name,
    ti.InstanceID,
    ti.StartDate,
    ti.EndDate,
    c.CampName,
    c.Location,
    c.Altitude_Meters,
    i.Arrival_Order,
    i.Nights
FROM TrekInstance ti
JOIN Trek t ON ti.TrekID = t.TrekID
JOIN Includes i ON ti.InstanceID = i.InstanceID
JOIN Camp c ON i.CampID = c.CampID
WHERE ti.InstanceID = 'INS001'  -- Change instance ID as needed
ORDER BY i.Arrival_Order;

-- ============================================
-- 2. BOOKING QUERIES
-- ============================================

-- 2.1 Get booking details with participant information
SELECT 
    b.BookingID,
    b.Booking_Date,
    b.Status,
    t.Trek_Name,
    ti.StartDate,
    ti.EndDate,
    p.Name AS Participant_Name,
    p.Age,
    p.Gender,
    p.Contact,
    pi.Role
FROM Booking b
JOIN TrekInstance ti ON b.InstanceID = ti.InstanceID
JOIN Trek t ON ti.TrekID = t.TrekID
JOIN ParticipatesIn pi ON b.BookingID = pi.BookingID
JOIN Participant p ON pi.ParticipantID = p.ParticipantID
WHERE b.BookingID = 'BKG001'  -- Change booking ID as needed
ORDER BY pi.Role DESC, p.Name;

-- 2.2 Get all bookings for a specific trek instance
SELECT 
    b.BookingID,
    b.Status,
    b.Number_of_Participants,
    b.Total_Amount,
    b.Booking_Date,
    GROUP_CONCAT(p.Name SEPARATOR ', ') AS Participants
FROM Booking b
JOIN ParticipatesIn pi ON b.BookingID = pi.BookingID
JOIN Participant p ON pi.ParticipantID = p.ParticipantID
WHERE b.InstanceID = 'INS001'
GROUP BY b.BookingID
ORDER BY b.Booking_Date;

-- 2.3 Check booking payment status
SELECT 
    b.BookingID,
    b.Total_Amount,
    COALESCE(SUM(CASE WHEN p.Payment_Status = 'Success' THEN p.Amount ELSE 0 END), 0) AS Paid_Amount,
    (b.Total_Amount - COALESCE(SUM(CASE WHEN p.Payment_Status = 'Success' THEN p.Amount ELSE 0 END), 0)) AS Balance,
    CASE 
        WHEN COALESCE(SUM(CASE WHEN p.Payment_Status = 'Success' THEN p.Amount ELSE 0 END), 0) >= b.Total_Amount 
        THEN 'Fully Paid' 
        ELSE 'Partially Paid' 
    END AS Payment_Status
FROM Booking b
LEFT JOIN Payment p ON b.BookingID = p.BookingID
WHERE b.BookingID = 'BKG001'
GROUP BY b.BookingID;

-- 2.4 Get participant's booking history
SELECT 
    b.BookingID,
    t.Trek_Name,
    ti.StartDate,
    ti.EndDate,
    b.Status,
    b.Total_Amount
FROM Participant p
JOIN ParticipatesIn pi ON p.ParticipantID = pi.ParticipantID
JOIN Booking b ON pi.BookingID = b.BookingID
JOIN TrekInstance ti ON b.InstanceID = ti.InstanceID
JOIN Trek t ON ti.TrekID = t.TrekID
WHERE p.ParticipantID = 'PRT001'
ORDER BY ti.StartDate DESC;

-- ============================================
-- 3. GUIDE QUERIES
-- ============================================

-- 3.1 Get guides assigned to a trek instance
SELECT 
    g.GuideID,
    g.Name,
    g.Experience_Years,
    g.Specialization,
    g.Contact,
    COUNT(DISTINCT at.BookingID) AS Assigned_Bookings
FROM Guide g
JOIN AssignedTo at ON g.GuideID = at.GuideID
JOIN Booking b ON at.BookingID = b.BookingID
WHERE b.InstanceID = 'INS001'
GROUP BY g.GuideID;

-- 3.2 Get guide schedule
SELECT 
    g.Name AS Guide_Name,
    t.Trek_Name,
    ti.StartDate,
    ti.EndDate,
    ti.Location,
    b.BookingID,
    b.Status
FROM Guide g
JOIN AssignedTo at ON g.GuideID = at.GuideID
JOIN Booking b ON at.BookingID = b.BookingID
JOIN TrekInstance ti ON b.InstanceID = ti.InstanceID
JOIN Trek t ON ti.TrekID = t.TrekID
WHERE g.GuideID = 'GID002'
  AND ti.StartDate >= CURDATE()
ORDER BY ti.StartDate;

-- 3.3 Find available guides for a date range
SELECT 
    g.GuideID,
    g.Name,
    g.Experience_Years,
    g.Specialization
FROM Guide g
WHERE g.GuideID NOT IN (
    SELECT DISTINCT at.GuideID
    FROM AssignedTo at
    JOIN Booking b ON at.BookingID = b.BookingID
    JOIN TrekInstance ti ON b.InstanceID = ti.InstanceID
    WHERE ti.StartDate <= '2026-12-20'  -- End date of new trek
      AND ti.EndDate >= '2026-12-15'    -- Start date of new trek
      AND b.Status != 'Cancelled'
);

-- ============================================
-- 4. PAYMENT QUERIES
-- ============================================

-- 4.1 Get all payments for a booking
SELECT 
    p.PaymentID,
    p.Amount,
    p.Payment_Method,
    p.Payment_Date,
    p.Transaction_ID,
    p.Payment_Status
FROM Payment p
WHERE p.BookingID = 'BKG001'
ORDER BY p.Payment_Date;

-- 4.2 Daily revenue report
SELECT 
    DATE(p.Payment_Date) AS Payment_Day,
    COUNT(DISTINCT p.PaymentID) AS Total_Transactions,
    SUM(p.Amount) AS Total_Revenue,
    AVG(p.Amount) AS Average_Transaction
FROM Payment p
WHERE p.Payment_Status = 'Success'
  AND p.Payment_Date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DATE(p.Payment_Date)
ORDER BY Payment_Day DESC;

-- 4.3 Payment method distribution
SELECT 
    Payment_Method,
    COUNT(*) AS Transaction_Count,
    SUM(Amount) AS Total_Amount,
    ROUND(SUM(Amount) * 100.0 / (SELECT SUM(Amount) FROM Payment WHERE Payment_Status = 'Success'), 2) AS Percentage
FROM Payment
WHERE Payment_Status = 'Success'
GROUP BY Payment_Method
ORDER BY Total_Amount DESC;

-- ============================================
-- 5. REPORTING QUERIES
-- ============================================

-- 5.1 Trek popularity report
SELECT 
    t.Trek_Name,
    t.Difficulty_Level,
    COUNT(DISTINCT ti.InstanceID) AS Total_Instances,
    COUNT(DISTINCT b.BookingID) AS Total_Bookings,
    SUM(b.Number_of_Participants) AS Total_Participants,
    ROUND(AVG(f.Rating), 2) AS Average_Rating
FROM Trek t
LEFT JOIN TrekInstance ti ON t.TrekID = ti.TrekID
LEFT JOIN Booking b ON ti.InstanceID = b.InstanceID AND b.Status != 'Cancelled'
LEFT JOIN Feedback f ON b.BookingID = f.BookingID
GROUP BY t.TrekID
ORDER BY Total_Participants DESC;

-- 5.2 Monthly revenue report
SELECT 
    DATE_FORMAT(p.Payment_Date, '%Y-%m') AS Month,
    COUNT(DISTINCT b.BookingID) AS Bookings,
    SUM(b.Number_of_Participants) AS Total_Participants,
    SUM(p.Amount) AS Total_Revenue
FROM Payment p
JOIN Booking b ON p.BookingID = b.BookingID
WHERE p.Payment_Status = 'Success'
GROUP BY DATE_FORMAT(p.Payment_Date, '%Y-%m')
ORDER BY Month DESC;

-- 5.3 Occupancy report by trek instance
SELECT 
    t.Trek_Name,
    ti.InstanceID,
    ti.StartDate,
    ti.Max_Participants,
    ti.Current_Participants,
    ROUND((ti.Current_Participants * 100.0 / ti.Max_Participants), 2) AS Occupancy_Percentage,
    CASE 
        WHEN ti.Current_Participants >= ti.Max_Participants THEN 'Full'
        WHEN ti.Current_Participants >= ti.Max_Participants * 0.75 THEN 'Almost Full'
        WHEN ti.Current_Participants >= ti.Max_Participants * 0.50 THEN 'Half Full'
        ELSE 'Available'
    END AS Status
FROM TrekInstance ti
JOIN Trek t ON ti.TrekID = t.TrekID
WHERE ti.Status = 'Upcoming'
ORDER BY ti.StartDate;

-- 5.4 Guide performance report
SELECT 
    g.Name,
    g.Experience_Years,
    COUNT(DISTINCT at.BookingID) AS Total_Assignments,
    COUNT(DISTINCT f.FeedbackID) AS Feedbacks_Received,
    ROUND(AVG(f.Rating), 2) AS Average_Rating
FROM Guide g
LEFT JOIN AssignedTo at ON g.GuideID = at.GuideID
LEFT JOIN Feedback f ON at.BookingID = f.BookingID
GROUP BY g.GuideID
ORDER BY Average_Rating DESC, Total_Assignments DESC;

-- 5.5 Customer demographics
SELECT 
    Gender,
    COUNT(*) AS Total_Participants,
    ROUND(AVG(Age), 1) AS Average_Age,
    MIN(Age) AS Youngest,
    MAX(Age) AS Oldest
FROM Participant
GROUP BY Gender;

-- 5.6 Camp utilization report
SELECT 
    c.CampName,
    c.Location,
    c.Capacity,
    COUNT(DISTINCT i.InstanceID) AS Times_Used,
    SUM(i.Nights) AS Total_Nights
FROM Camp c
LEFT JOIN Includes i ON c.CampID = i.CampID
GROUP BY c.CampID
ORDER BY Times_Used DESC;

-- ============================================
-- 6. ADMINISTRATIVE QUERIES
-- ============================================

-- 6.1 Upcoming treks requiring attention (low bookings)
SELECT 
    t.Trek_Name,
    ti.InstanceID,
    ti.StartDate,
    ti.Max_Participants,
    ti.Current_Participants,
    DATEDIFF(ti.StartDate, CURDATE()) AS Days_Until_Trek
FROM TrekInstance ti
JOIN Trek t ON ti.TrekID = t.TrekID
WHERE ti.Status = 'Upcoming'
  AND ti.Current_Participants < ti.Max_Participants * 0.3  -- Less than 30% booked
  AND DATEDIFF(ti.StartDate, CURDATE()) <= 30  -- Within 30 days
ORDER BY Days_Until_Trek;

-- 6.2 Pending payments report
SELECT 
    b.BookingID,
    p.Name AS Participant_Name,
    p.Contact,
    t.Trek_Name,
    ti.StartDate,
    b.Total_Amount,
    COALESCE(SUM(pay.Amount), 0) AS Paid_Amount,
    (b.Total_Amount - COALESCE(SUM(pay.Amount), 0)) AS Balance_Due,
    DATEDIFF(ti.StartDate, CURDATE()) AS Days_Until_Trek
FROM Booking b
JOIN TrekInstance ti ON b.InstanceID = ti.InstanceID
JOIN Trek t ON ti.TrekID = t.TrekID
JOIN ParticipatesIn pi ON b.BookingID = pi.BookingID AND pi.Role = 'Leader'
JOIN Participant p ON pi.ParticipantID = p.ParticipantID
LEFT JOIN Payment pay ON b.BookingID = pay.BookingID AND pay.Payment_Status = 'Success'
WHERE b.Status != 'Cancelled'
GROUP BY b.BookingID
HAVING Balance_Due > 0
ORDER BY Days_Until_Trek;

-- 6.3 Medical conditions summary
SELECT 
    p.ParticipantID,
    p.Name,
    p.Age,
    p.Medical_Condition,
    t.Trek_Name,
    ti.StartDate
FROM Participant p
JOIN ParticipatesIn pi ON p.ParticipantID = pi.ParticipantID
JOIN Booking b ON pi.BookingID = b.BookingID
JOIN TrekInstance ti ON b.InstanceID = ti.InstanceID
JOIN Trek t ON ti.TrekID = t.TrekID
WHERE p.Medical_Condition IS NOT NULL
  AND ti.Status = 'Upcoming'
  AND b.Status = 'Confirmed'
ORDER BY ti.StartDate;

-- ============================================
-- 7. ANALYTICS QUERIES
-- ============================================

-- 7.1 Trek difficulty distribution
SELECT 
    Difficulty_Level,
    COUNT(*) AS Trek_Count,
    ROUND(AVG(Price), 2) AS Average_Price,
    ROUND(AVG(Duration_Days), 1) AS Average_Duration
FROM Trek
GROUP BY Difficulty_Level
ORDER BY 
    FIELD(Difficulty_Level, 'Easy', 'Moderate', 'Difficult', 'Extreme');

-- 7.2 Booking conversion rate (by month)
SELECT 
    DATE_FORMAT(Booking_Date, '%Y-%m') AS Month,
    COUNT(*) AS Total_Bookings,
    SUM(CASE WHEN Status = 'Confirmed' THEN 1 ELSE 0 END) AS Confirmed_Bookings,
    SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled_Bookings,
    ROUND(SUM(CASE WHEN Status = 'Confirmed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Confirmation_Rate
FROM Booking
GROUP BY DATE_FORMAT(Booking_Date, '%Y-%m')
ORDER BY Month DESC;

-- 7.3 Average group size analysis
SELECT 
    t.Trek_Name,
    ROUND(AVG(b.Number_of_Participants), 1) AS Avg_Group_Size,
    MIN(b.Number_of_Participants) AS Min_Group,
    MAX(b.Number_of_Participants) AS Max_Group,
    COUNT(b.BookingID) AS Total_Bookings
FROM Trek t
JOIN TrekInstance ti ON t.TrekID = ti.TrekID
JOIN Booking b ON ti.InstanceID = b.InstanceID
WHERE b.Status != 'Cancelled'
GROUP BY t.TrekID
ORDER BY Avg_Group_Size DESC;

-- ============================================
-- 8. SEARCH & FILTER QUERIES
-- ============================================

-- 8.1 Search participants by name or contact
SELECT 
    ParticipantID,
    Name,
    Age,
    Gender,
    Contact,
    Email
FROM Participant
WHERE Name LIKE '%Amit%'  -- Change search term
   OR Contact LIKE '%9123%'
ORDER BY Name;

-- 8.2 Find trek instances by date range and location
SELECT 
    t.Trek_Name,
    ti.InstanceID,
    ti.Location,
    ti.StartDate,
    ti.EndDate,
    ti.Max_Participants,
    ti.Current_Participants
FROM TrekInstance ti
JOIN Trek t ON ti.TrekID = t.TrekID
WHERE ti.StartDate BETWEEN '2026-06-01' AND '2026-12-31'
  AND ti.Location LIKE '%Uttarakhand%'
  AND ti.Status = 'Upcoming'
ORDER BY ti.StartDate;

-- ============================================
-- END OF QUERIES
-- ============================================
