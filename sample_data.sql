USE treks_camps_db;

-- ============================================
-- ADMINS (Expanded)
-- ============================================
INSERT INTO Admin VALUES
('ADM001','Rajesh Kumar','9876543210','rajesh@trekcamp.com',NOW()),
('ADM002','Priya Sharma','9876543211','priya@trekcamp.com',NOW()),
('ADM003','Amit Patel','9876543212','amit@trekcamp.com',NOW()),
('ADM004','Neha Joshi','9876543213','neha@trekcamp.com',NOW()),
('ADM005','Rohit Mehta','9876543214','rohit@trekcamp.com',NOW());

-- ============================================
-- MORE PARTICIPANTS (
-- ============================================
INSERT INTO Participant VALUES
('PRT001','Amit Verma',28,'Male','9123456789','amit@email.com',NULL,'9123',NOW()),
('PRT002','Sneha Kapoor',25,'Female','9123456790','sneha@email.com',NULL,'9124',NOW()),
('PRT003','Rahul Desai',32,'Male','9123456792','rahul@email.com','Asthma','9125',NOW()),
('PRT004','Pooja Singh',27,'Female','9123456794','pooja@email.com',NULL,'9126',NOW()),
('PRT005','Vikram Rao',35,'Male','9123456796','vikram@email.com',NULL,'9127',NOW());

-- ============================================
-- GUIDE ASSIGNMENTS
-- ============================================
INSERT INTO Guide VALUES
('GID001','Tenzing Norgay','9998887770','tenzing@g.com',15,'High Altitude','Advanced',NOW()),
('GID002','Lakshmi Devi','9998887771','lakshmi@g.com',8,'Valley','Basic',NOW()),
('GID003','Arun Singh','9998887772','arun@g.com',12,'Winter','WFA',NOW()),
('GID004','Meera Joshi','9998887773','meera@g.com',5,'Easy','TLC',NOW());

-- ============================================
-- EXTRA TREKS
-- ============================================
INSERT INTO Trek VALUES
('TRK001','Everest Base Camp',45000,'Difficult','Everest trek',12,NOW()),
('TRK002','Kedarkantha',8500,'Moderate','Winter trek',6,NOW()),
('TRK003','Valley of Flowers',12000,'Moderate','Flowers',7,NOW()),
('TRK004','Hampta Pass',9500,'Moderate','Pass trek',5,NOW()),
('TRK005','Roopkund',11000,'Difficult','Skeleton lake',8,NOW()),
('TRK006','Triund',3500,'Easy','Weekend trek',2,NOW()),
('TRK007','Chadar Trek',25000,'Extreme','Frozen river',9,NOW()),
('TRK008','Sandakphu',14000,'Moderate','WB peak',7,NOW()),
('TRK009','Tarsar Marsar',16000,'Moderate','Kashmir lakes',8,NOW());

-- ============================================
-- EXTRA CAMPS
-- ============================================
INSERT INTO Camp VALUES
('CMP001','Lobuche','Nepal',50,'Tents',4940,NOW()),
('CMP002','Gorak Shep','Nepal',40,'Oxygen',5164,NOW()),
('CMP003','Juda Ka Talab','UK',60,'Bonfire',2800,NOW()),
('CMP004','Base Camp','UK',80,'Kitchen',3400,NOW()),
('CMP005','Ghangaria','UK',100,'Hotel',3050,NOW());

-- ============================================
-- Transport
-- ============================================
INSERT INTO Transport VALUES
('TRP001','Bus','Delhi','05:00:00','DL1',45,NOW()),
('TRP002','Tempo Traveller','Delhi','06:00:00','DL2',12,NOW()),
('TRP003','Jeep','Manali','07:00:00','HP1',7,NOW()),
('TRP004','Minivan','Delhi','05:30:00','DL3',10,NOW());

-- ============================================
-- MORE TREK INSTANCES
-- ============================================
INSERT INTO TrekInstance VALUES
('INS001','TRK002','ADM001','TRP001','UK','2026-12-15','2026-12-20',40,0,'Upcoming',NOW()),
('INS002','TRK003','ADM002','TRP002','UK','2026-07-01','2026-07-07',35,0,'Upcoming',NOW()),
('INS003','TRK004','ADM001','TRP003','HP','2026-06-10','2026-06-14',30,0,'Upcoming',NOW()),
('INS004','TRK006','ADM003','TRP002','HP','2026-05-01','2026-05-02',25,0,'Upcoming',NOW()),
('INS005','TRK007','ADM002','TRP004','Ladakh','2027-01-10','2027-01-18',20,0,'Upcoming',NOW());



-- ============================================
-- MORE BOOKINGS (IMPORTANT)
-- ============================================
INSERT INTO Booking VALUES
('BKG001','INS001',NOW(),'Confirmed',17000,2,NULL),
('BKG002','INS002',NOW(),'Confirmed',12000,1,NULL);

-- ============================================
-- PARTICIPATES IN (MASS DATA)
-- ============================================
INSERT INTO ParticipatesIn VALUES
('PRT001','BKG001','Leader'),
('PRT002','BKG001','Member'),
('PRT003','BKG002','Leader');

-- ============================================
-- ASSIGNEDTO
-- ============================================
INSERT INTO AssignedTo VALUES
('GID001','BKG001',NOW()),
('GID002','BKG002',NOW());

-- ============================================
-- PAYMENTS (IMPORTANT FOR VIEWS)
-- ============================================
INSERT INTO Payment VALUES
('PAY001','BKG001',17000,'UPI',NOW(),'TXN1','Success'),
('PAY002','BKG002',12000,'Card',NOW(),'TXN2','Success');

-- ============================================
-- FEEDBACK (NOW ENABLED)
-- ============================================
INSERT INTO Feedback VALUES
('FBK001','BKG001',5,'Excellent!',NOW());

-- ============================================
-- EXTRA CAMP MAPPING
-- ============================================
INSERT INTO Includes VALUES
('INS001','CMP003',1,1),
('INS001','CMP004',2,2),
('INS002','CMP005',1,3),
('INS003','CMP003',1,2),
('INS004','CMP004',1,1);
