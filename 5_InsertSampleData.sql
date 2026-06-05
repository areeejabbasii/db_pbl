-- ============================================================================
-- Library Management System - Insert Sample Data
-- ============================================================================
USE LibraryManagementDB;
GO

-- Disable triggers temporarily for data insertion
DISABLE TRIGGER tr_UpdateBookAvailabilityOnBorrow ON Borrowing;
DISABLE TRIGGER tr_UpdateBookAvailabilityOnReturn ON Borrowing;
DISABLE TRIGGER tr_GenerateOverdueFine ON Borrowing;
DISABLE TRIGGER tr_PreventOverbooking ON Borrowing;
GO

-- ============================================================================
-- INSERT INTO CATEGORIES
-- ============================================================================
INSERT INTO Categories (CategoryName, Description) VALUES
('Fiction', 'Novels and fictional stories'),
('Non-Fiction', 'Educational and informational books'),
('Science Fiction', 'Science fiction and futuristic tales'),
('Mystery', 'Mystery and detective novels'),
('Romance', 'Romantic fiction and stories'),
('Biography', 'Life stories and memoirs'),
('History', 'Historical accounts and chronicles'),
('Technology', 'Technology and programming books'),
('Philosophy', 'Philosophical works and theories'),
('Self-Help', 'Personal development and self-help guides');
GO
PRINT 'Categories inserted: 10 records';

-- ============================================================================
-- INSERT INTO AUTHORS
-- ============================================================================
INSERT INTO Authors (FirstName, LastName, Email, Phone, DateOfBirth, Nationality) VALUES
('Agatha', 'Christie', 'agatha.christie@example.com', '1234567890', '1890-01-15', 'British'),
('Stephen', 'King', 'stephen.king@example.com', '1234567891', '1947-09-21', 'American'),
('J.K.', 'Rowling', 'jk.rowling@example.com', '1234567892', '1965-07-31', 'British'),
('George', 'Martin', 'george.martin@example.com', '1234567893', '1948-09-20', 'American'),
('Isaac', 'Asimov', 'isaac.asimov@example.com', '1234567894', '1920-01-02', 'American'),
('Carl', 'Sagan', 'carl.sagan@example.com', '1234567895', '1934-11-09', 'American'),
('Yuval', 'Harari', 'yuval.harari@example.com', '1234567896', '1976-02-24', 'Israeli'),
('Robert', 'Martin', 'robert.martin@example.com', '1234567897', '1952-12-05', 'American'),
('Dale', 'Carnegie', 'dale.carnegie@example.com', '1234567898', '1888-11-24', 'American'),
('Malcolm', 'Gladwell', 'malcolm.gladwell@example.com', '1234567899', '1966-09-03', 'Canadian');
GO
PRINT 'Authors inserted: 10 records';

-- ============================================================================
-- INSERT INTO BOOKS
-- ============================================================================
INSERT INTO Books (ISBN, Title, CategoryID, PublishYear, NumberOfPages, TotalCopies, AvailableCopies, PublisherName, Description) VALUES
('ISBN-001', 'Murder on the Orient Express', 4, 1934, 256, 5, 3, 'Christie Publications', 'A classic murder mystery featuring detective Hercule Poirot'),
('ISBN-002', 'The Shining', 3, 1977, 447, 4, 2, 'Doubleday', 'A psychological horror novel about a family isolated in a haunted hotel'),
('ISBN-003', 'Harry Potter and the Philosopher''s Stone', 3, 1997, 309, 6, 2, 'Bloomsbury', 'The first book in the magical Harry Potter series'),
('ISBN-004', 'A Game of Thrones', 1, 1996, 694, 3, 1, 'Bantam Spectra', 'Epic fantasy novel with complex characters and political intrigue'),
('ISBN-005', 'Foundation', 3, 1951, 255, 4, 3, 'Gnome Press', 'Science fiction classic about the foundation of a galactic empire'),
('ISBN-006', 'Cosmos', 2, 1980, 402, 5, 4, 'Random House', 'An exploration of the universe and human place in it'),
('ISBN-007', 'Sapiens', 2, 2011, 443, 5, 2, 'Harvill Secker', 'A brief history of humankind'),
('ISBN-008', 'Clean Code', 8, 2008, 464, 4, 3, 'Prentice Hall', 'Guide to writing maintainable and professional code'),
('ISBN-009', 'How to Win Friends and Influence People', 10, 1936, 288, 6, 4, 'Simon & Schuster', 'Timeless advice on human relations and personal development'),
('ISBN-010', 'The Tipping Point', 10, 2000, 301, 4, 2, 'Little Brown', 'How little things can make a big difference'),
('ISBN-011', 'The Great Gatsby', 1, 1925, 180, 5, 3, 'Scribner', 'A tale of wealth, love, and the American dream'),
('ISBN-012', 'To Kill a Mockingbird', 1, 1960, 310, 4, 2, 'J.B. Lippincott', 'A gripping tale of racial injustice in the American South'),
('ISBN-013', 'The Catcher in the Rye', 1, 1951, 277, 3, 1, 'Little Brown', 'Coming-of-age novel about teenage alienation'),
('ISBN-014', 'Jane Eyre', 5, 1847, 448, 4, 3, 'Smith Elder', 'Gothic romance with a strong female protagonist'),
('ISBN-015', 'Wuthering Heights', 5, 1847, 323, 3, 2, 'Thomas Cautley Newby', 'Passionate Victorian romance set on the moors'),
('ISBN-016', 'The Da Vinci Code', 4, 2003, 454, 5, 4, 'Doubleday', 'Thrilling mystery involving art, history, and conspiracy'),
('ISBN-017', 'I, Claudius', 6, 1934, 404, 3, 1, 'Methuen', 'Autobiography of a Roman emperor'),
('ISBN-018', 'The Selfish Gene', 2, 1976, 224, 4, 2, 'Oxford University Press', 'Revolutionary exploration of evolution and genetics'),
('ISBN-019', 'Educated', 6, 2018, 352, 5, 3, 'Random House', 'Memoir about a woman who grows up isolated'),
('ISBN-020', 'Project Management Essentials', 8, 2019, 380, 4, 3, 'Tech Books', 'Complete guide to managing projects efficiently');
GO
PRINT 'Books inserted: 20 records';

-- ============================================================================
-- INSERT INTO BOOK_AUTHORS (Many-to-Many relationships)
-- ============================================================================
INSERT INTO Book_Authors (BookID, AuthorID, AuthorSequence) VALUES
(1, 1, 1),  -- Murder on the Orient Express - Agatha Christie
(2, 2, 1),  -- The Shining - Stephen King
(3, 3, 1),  -- Harry Potter - J.K. Rowling
(4, 4, 1),  -- A Game of Thrones - George Martin
(5, 5, 1),  -- Foundation - Isaac Asimov
(6, 6, 1),  -- Cosmos - Carl Sagan
(7, 7, 1),  -- Sapiens - Yuval Harari
(8, 8, 1),  -- Clean Code - Robert Martin
(9, 9, 1),  -- How to Win Friends - Dale Carnegie
(10, 10, 1), -- The Tipping Point - Malcolm Gladwell
(11, 6, 1), -- The Great Gatsby - (Using Carl Sagan for demo)
(12, 9, 1), -- To Kill a Mockingbird - (Using Dale Carnegie for demo)
(13, 10, 1), -- The Catcher in the Rye - (Using Malcolm Gladwell for demo)
(14, 7, 1), -- Jane Eyre - (Using Yuval Harari for demo)
(15, 8, 1), -- Wuthering Heights - (Using Robert Martin for demo)
(16, 2, 1), -- The Da Vinci Code - Stephen King
(17, 5, 1), -- I, Claudius - Isaac Asimov
(18, 1, 1), -- The Selfish Gene - Agatha Christie
(19, 3, 1), -- Educated - J.K. Rowling
(20, 4, 1); -- Project Management - George Martin
GO
PRINT 'Book_Authors inserted: 20 records';

-- ============================================================================
-- INSERT INTO MEMBERS
-- ============================================================================
INSERT INTO Members (MembershipNumber, FirstName, LastName, Email, Phone, Address, City, Country, PostalCode, DateOfBirth, MembershipDate, MembershipExpiryDate, Status) VALUES
('MEM001', 'Ali', 'Ahmed', 'ali.ahmed@email.com', '0300-1234567', '123 Main St', 'Islamabad', 'Pakistan', '44000', '1990-05-15', '2024-01-10', '2026-01-10', 'Active'),
('MEM002', 'Fatima', 'Khan', 'fatima.khan@email.com', '0300-2234567', '456 Oak Ave', 'Lahore', 'Pakistan', '54000', '1995-03-22', '2024-02-20', '2026-02-20', 'Active'),
('MEM003', 'Hassan', 'Ali', 'hassan.ali@email.com', '0300-3234567', '789 Pine Rd', 'Karachi', 'Pakistan', '75000', '1988-07-10', '2024-03-15', '2026-03-15', 'Active'),
('MEM004', 'Aisha', 'Malik', 'aisha.malik@email.com', '0300-4234567', '321 Elm St', 'Rawalpindi', 'Pakistan', '46000', '1992-11-05', '2024-04-01', '2026-04-01', 'Active'),
('MEM005', 'Omar', 'Hassan', 'omar.hassan@email.com', '0300-5234567', '654 Cedar Ln', 'Multan', 'Pakistan', '60000', '1987-09-20', '2024-05-10', '2026-05-10', 'Active'),
('MEM006', 'Noor', 'Saeed', 'noor.saeed@email.com', '0300-6234567', '987 Maple Dr', 'Peshawar', 'Pakistan', '25000', '1998-01-30', '2024-06-05', '2026-06-05', 'Inactive'),
('MEM007', 'Zain', 'Raza', 'zain.raza@email.com', '0300-7234567', '234 Birch St', 'Faisalabad', 'Pakistan', '38000', '1991-04-12', '2024-07-08', '2026-07-08', 'Active'),
('MEM008', 'Hana', 'Amira', 'hana.amira@email.com', '0300-8234567', '567 Spruce Ave', 'Quetta', 'Pakistan', '87000', '1993-08-25', '2024-08-14', '2026-08-14', 'Active'),
('MEM009', 'Karim', 'Nasir', 'karim.nasir@email.com', '0300-9234567', '890 Ash Ln', 'Hyderabad', 'Pakistan', '71000', '1989-02-18', '2024-09-20', '2026-09-20', 'Suspended'),
('MEM010', 'Sara', 'Hussain', 'sara.hussain@email.com', '0300-0234567', '123 Willow Rd', 'Gujranwala', 'Pakistan', '52000', '1994-06-08', '2024-10-12', '2026-10-12', 'Active'),
('MEM011', 'Bilal', 'Aziz', 'bilal.aziz@email.com', '0301-1234567', '456 Juniper St', 'Sialkot', 'Pakistan', '51000', '1986-10-14', '2024-11-01', '2026-11-01', 'Active'),
('MEM012', 'Leila', 'Rashid', 'leila.rashid@email.com', '0301-2234567', '789 Poplar Ave', 'Sargodha', 'Pakistan', '40100', '1997-12-03', '2024-12-10', '2026-12-10', 'Active'),
('MEM013', 'Rahim', 'Fariq', 'rahim.fariq@email.com', '0301-3234567', '234 Chestnut Ln', 'Gujrat', 'Pakistan', '50700', '1985-03-22', '2025-01-05', '2027-01-05', 'Active'),
('MEM014', 'Maryam', 'Wasim', 'maryam.wasim@email.com', '0301-4234567', '567 Dogwood Dr', 'Jhang', 'Pakistan', '35200', '1996-05-14', '2025-02-08', '2027-02-08', 'Active'),
('MEM015', 'Mustafa', 'Iqbal', 'mustafa.iqbal@email.com', '0301-5234567', '890 Tamarisk St', 'Bahawalpur', 'Pakistan', '63100', '1988-09-07', '2025-03-12', '2027-03-12', 'Active'),
('MEM016', 'Yasmin', 'Adnan', 'yasmin.adnan@email.com', '0301-6234567', '123 Juniper Ln', 'Okara', 'Pakistan', '56300', '1999-07-21', '2025-04-18', '2027-04-18', 'Active'),
('MEM017', 'Tariq', 'Hamid', 'tariq.hamid@email.com', '0301-7234567', '456 Rowan Ave', 'Sahiwal', 'Pakistan', '57000', '1991-11-30', '2025-05-22', '2027-05-22', 'Active'),
('MEM018', 'Dina', 'Karim', 'dina.karim@email.com', '0301-8234567', '789 Blackwood Rd', 'Wazirabad', 'Pakistan', '52600', '1993-04-17', '2025-06-01', '2027-06-01', 'Active'),
('MEM019', 'Rashid', 'Samir', 'rashid.samir@email.com', '0301-9234567', '234 Redwood St', 'Jhang Sadar', 'Pakistan', '35200', '1987-08-09', '2025-06-15', '2027-06-15', 'Inactive'),
('MEM020', 'Sana', 'Khalid', 'sana.khalid@email.com', '0301-0234567', '567 Maple St', 'Chichawatni', 'Pakistan', '59400', '1998-02-26', '2025-07-20', '2027-07-20', 'Active');
GO
PRINT 'Members inserted: 20 records';

-- ============================================================================
-- INSERT INTO BORROWING
-- ============================================================================
INSERT INTO Borrowing (MemberID, BookID, BorrowDate, DueDate, ReturnDate, Status) VALUES
(1, 1, '2025-06-01', '2025-06-15', '2025-06-14', 'Returned'),
(2, 2, '2025-06-02', '2025-06-16', NULL, 'Borrowed'),
(3, 3, '2025-05-28', '2025-06-11', NULL, 'Overdue'),
(4, 4, '2025-06-03', '2025-06-17', '2025-06-17', 'Returned'),
(5, 5, '2025-06-04', '2025-06-18', NULL, 'Borrowed'),
(6, 6, '2025-05-25', '2025-06-08', NULL, 'Overdue'),
(7, 7, '2025-06-05', '2025-06-19', NULL, 'Borrowed'),
(8, 8, '2025-06-01', '2025-06-15', '2025-06-15', 'Returned'),
(10, 9, '2025-06-02', '2025-06-16', NULL, 'Borrowed'),
(11, 10, '2025-05-30', '2025-06-13', NULL, 'Overdue'),
(12, 11, '2025-06-03', '2025-06-17', NULL, 'Borrowed'),
(13, 12, '2025-06-04', '2025-06-18', '2025-06-18', 'Returned'),
(14, 13, '2025-06-01', '2025-06-15', NULL, 'Borrowed'),
(15, 14, '2025-05-29', '2025-06-12', NULL, 'Overdue'),
(16, 15, '2025-06-05', '2025-06-19', NULL, 'Borrowed'),
(17, 16, '2025-06-02', '2025-06-16', NULL, 'Borrowed'),
(18, 17, '2025-05-31', '2025-06-14', '2025-06-13', 'Returned'),
(19, 18, '2025-06-03', '2025-06-17', NULL, 'Borrowed'),
(20, 19, '2025-05-27', '2025-06-10', NULL, 'Overdue'),
(1, 20, '2025-06-04', '2025-06-18', NULL, 'Borrowed');
GO
PRINT 'Borrowing records inserted: 20 records';

-- ============================================================================
-- INSERT INTO FINES
-- ============================================================================
INSERT INTO Fines (BorrowingID, MemberID, FineAmount, DaysOverdue, PaymentStatus, FineDate) VALUES
(3, 3, 2.50, 5, 'Unpaid', GETDATE()),
(6, 6, 4.00, 8, 'Unpaid', GETDATE()),
(11, 11, 3.50, 7, 'Unpaid', GETDATE()),
(15, 15, 5.00, 10, 'Unpaid', GETDATE()),
(20, 20, 1.50, 3, 'Unpaid', GETDATE()),
(1, 1, 0.00, 0, 'Paid', '2025-06-14'),
(4, 4, 0.00, 0, 'Paid', '2025-06-17'),
(8, 8, 0.00, 0, 'Paid', '2025-06-15'),
(13, 13, 0.00, 0, 'Partial', '2025-06-10'),
(18, 18, 0.00, 0, 'Partial', '2025-06-12'),
(2, 2, 0.00, 0, 'Unpaid', GETDATE()),
(5, 5, 0.00, 0, 'Unpaid', GETDATE()),
(7, 7, 0.00, 0, 'Unpaid', GETDATE()),
(9, 10, 0.00, 0, 'Unpaid', GETDATE()),
(10, 11, 0.00, 0, 'Unpaid', GETDATE()),
(12, 13, 0.00, 0, 'Unpaid', GETDATE()),
(14, 14, 0.00, 0, 'Unpaid', GETDATE()),
(16, 17, 0.00, 0, 'Unpaid', GETDATE()),
(17, 19, 0.00, 0, 'Unpaid', GETDATE()),
(19, 1, 0.00, 0, 'Unpaid', GETDATE());
GO
PRINT 'Fines inserted: 20 records';

-- Re-enable triggers
ENABLE TRIGGER tr_UpdateBookAvailabilityOnBorrow ON Borrowing;
ENABLE TRIGGER tr_UpdateBookAvailabilityOnReturn ON Borrowing;
ENABLE TRIGGER tr_GenerateOverdueFine ON Borrowing;
ENABLE TRIGGER tr_PreventOverbooking ON Borrowing;
GO

PRINT '========================================';
PRINT 'Sample data inserted successfully!';
PRINT 'Total Records Inserted:';
PRINT '- Categories: 10';
PRINT '- Authors: 10';
PRINT '- Books: 20';
PRINT '- Book_Authors: 20';
PRINT '- Members: 20';
PRINT '- Borrowing: 20';
PRINT '- Fines: 20';
PRINT '========================================';
