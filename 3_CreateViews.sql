-- ============================================================================
-- Library Management System - Create Views
-- ============================================================================
USE LibraryManagementDB;
GO

-- ============================================================================
-- VIEW 1: Member Borrowing Activity Dashboard
-- Purpose: Shows member info with their current borrowing status
-- ============================================================================
CREATE VIEW vw_MemberBorrowingActivity AS
SELECT 
    m.MemberID,
    m.MembershipNumber,
    CONCAT(m.FirstName, ' ', m.LastName) AS MemberName,
    m.Email,
    m.Phone,
    m.Status AS MemberStatus,
    COUNT(CASE WHEN b.Status = 'Borrowed' THEN 1 END) AS CurrentBorrowedBooks,
    COUNT(CASE WHEN b.Status = 'Overdue' THEN 1 END) AS OverdueBooks,
    COUNT(CASE WHEN b.Status = 'Returned' THEN 1 END) AS ReturnedBooks,
    COALESCE(SUM(CASE WHEN f.PaymentStatus = 'Unpaid' THEN f.FineAmount ELSE 0 END), 0) AS UnpaidFinesAmount,
    m.MembershipDate,
    m.MembershipExpiryDate
FROM Members m
LEFT JOIN Borrowing b ON m.MemberID = b.MemberID
LEFT JOIN Fines f ON m.MemberID = f.MemberID
GROUP BY 
    m.MemberID, m.MembershipNumber, m.FirstName, m.LastName, 
    m.Email, m.Phone, m.Status, m.MembershipDate, m.MembershipExpiryDate;
GO
PRINT 'View: vw_MemberBorrowingActivity created.';

-- ============================================================================
-- VIEW 2: Book Availability and Popularity Report
-- Purpose: Shows books with availability and borrowing frequency
-- ============================================================================
GO

CREATE VIEW vw_BookAvailabilityReport AS
SELECT 
    b.BookID,
    b.ISBN,
    b.Title,
    c.CategoryName,
    STRING_AGG(CONCAT(a.FirstName, ' ', a.LastName), ', ') AS Authors,
    b.PublishYear,
    b.TotalCopies,
    b.AvailableCopies,
    (b.TotalCopies - b.AvailableCopies) AS BorrowedCopies,
    CAST(CAST((b.TotalCopies - b.AvailableCopies) AS DECIMAL) / CAST(b.TotalCopies AS DECIMAL) * 100 AS DECIMAL(5,2)) AS BorrowingPercentage,
    COUNT(DISTINCT br.BorrowingID) AS TotalTimesBooked,
    COUNT(DISTINCT CASE WHEN br.Status IN ('Borrowed', 'Overdue') THEN br.BorrowingID END) AS CurrentlyBorrowedCount
FROM Books b
LEFT JOIN Categories c ON b.CategoryID = c.CategoryID
LEFT JOIN Book_Authors ba ON b.BookID = ba.BookID
LEFT JOIN Authors a ON ba.AuthorID = a.AuthorID
LEFT JOIN Borrowing br ON b.BookID = br.BookID
GROUP BY 
    b.BookID, b.ISBN, b.Title, c.CategoryName, b.PublishYear, 
    b.TotalCopies, b.AvailableCopies;
GO
PRINT 'View: vw_BookAvailabilityReport created.';

-- ============================================================================
-- VIEW 3: Overdue Books Report
-- Purpose: Lists all overdue books with member and borrowing details
-- ============================================================================
GO

CREATE VIEW vw_OverdueBooks AS
SELECT 
    br.BorrowingID,
    m.MemberID,
    m.MembershipNumber,
    CONCAT(m.FirstName, ' ', m.LastName) AS MemberName,
    m.Email,
    m.Phone,
    b.BookID,
    b.ISBN,
    b.Title,
    c.CategoryName,
    br.BorrowDate,
    br.DueDate,
    DATEDIFF(DAY, br.DueDate, CAST(GETDATE() AS DATE)) AS DaysOverdue,
    CAST(DATEDIFF(DAY, br.DueDate, CAST(GETDATE() AS DATE)) * 0.50 AS DECIMAL(10,2)) AS CalculatedFine
FROM Borrowing br
INNER JOIN Members m ON br.MemberID = m.MemberID
INNER JOIN Books b ON br.BookID = b.BookID
INNER JOIN Categories c ON b.CategoryID = c.CategoryID
WHERE br.ReturnDate IS NULL AND br.DueDate < CAST(GETDATE() AS DATE)
    AND br.Status IN ('Borrowed', 'Overdue');
GO
PRINT 'View: vw_OverdueBooks created.';

-- ============================================================================
-- VIEW 4: Fine Collection Summary
-- Purpose: Shows fine amounts and payment status by member
-- ============================================================================
GO

CREATE VIEW vw_FineCollectionSummary AS
SELECT 
    f.MemberID,
    m.MembershipNumber,
    CONCAT(m.FirstName, ' ', m.LastName) AS MemberName,
    m.Email,
    COUNT(f.FineID) AS TotalFines,
    COALESCE(SUM(CASE WHEN f.PaymentStatus = 'Paid' THEN f.FineAmount ELSE 0 END), 0) AS PaidAmount,
    COALESCE(SUM(CASE WHEN f.PaymentStatus = 'Unpaid' THEN f.FineAmount ELSE 0 END), 0) AS UnpaidAmount,
    COALESCE(SUM(CASE WHEN f.PaymentStatus = 'Partial' THEN f.FineAmount ELSE 0 END), 0) AS PartialAmount,
    COALESCE(SUM(f.FineAmount), 0) AS TotalFineAmount,
    MAX(f.FineDate) AS LastFineDate
FROM Fines f
INNER JOIN Members m ON f.MemberID = m.MemberID
GROUP BY f.MemberID, m.MembershipNumber, m.FirstName, m.LastName, m.Email;
GO
PRINT 'View: vw_FineCollectionSummary created.';

PRINT '========================================';
PRINT 'All views created successfully!';
PRINT '========================================';
