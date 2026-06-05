-- ============================================================================
-- Library Management System - Advanced Queries
-- ============================================================================
USE LibraryManagementDB;
GO

PRINT '====== ADVANCED QUERY DEMONSTRATIONS ======';
PRINT '';

-- ============================================================================
-- QUERY 1: Multi-Table Join - Members with Overdue Books
-- Purpose: Shows members with overdue books and fine calculations
-- Tables: Members, Borrowing, Books, Categories
-- ============================================================================
PRINT 'QUERY 1: Members with Overdue Books (3+ Table Join)';
PRINT '-------------------------------------------';
SELECT 
    m.MembershipNumber,
    CONCAT(m.FirstName, ' ', m.LastName) AS MemberName,
    m.Email,
    m.Phone,
    b.ISBN,
    b.Title,
    c.CategoryName,
    br.BorrowDate,
    br.DueDate,
    DATEDIFF(DAY, br.DueDate, CAST(GETDATE() AS DATE)) AS DaysOverdue,
    CAST(DATEDIFF(DAY, br.DueDate, CAST(GETDATE() AS DATE)) * 0.50 AS DECIMAL(10,2)) AS CalculatedFine
FROM Members m
INNER JOIN Borrowing br ON m.MemberID = br.MemberID
INNER JOIN Books b ON br.BookID = b.BookID
INNER JOIN Categories c ON b.CategoryID = c.CategoryID
WHERE br.ReturnDate IS NULL 
    AND br.DueDate < CAST(GETDATE() AS DATE)
    AND br.Status IN ('Borrowed', 'Overdue')
ORDER BY m.MemberID, br.DueDate DESC;
GO

-- ============================================================================
-- QUERY 2: Multi-Table Join - Book Popularity with Author Information
-- Purpose: Shows book details with multiple authors and borrowing frequency
-- Tables: Books, Categories, Book_Authors, Authors, Borrowing
-- ============================================================================
PRINT '';
PRINT 'QUERY 2: Book Popularity Report with Authors (5 Table Join)';
PRINT '-------------------------------------------';
SELECT 
    b.ISBN,
    b.Title,
    c.CategoryName,
    STRING_AGG(CONCAT(a.FirstName, ' ', a.LastName), ', ') AS Authors,
    b.PublishYear,
    b.TotalCopies,
    b.AvailableCopies,
    (b.TotalCopies - b.AvailableCopies) AS CurrentlyBorrowedCount,
    COUNT(DISTINCT br.BorrowingID) AS TotalTimesBooked,
    CAST(CAST((b.TotalCopies - b.AvailableCopies) AS DECIMAL) / CAST(b.TotalCopies AS DECIMAL) * 100 AS DECIMAL(5,2)) AS BorrowingPercentage
FROM Books b
LEFT JOIN Categories c ON b.CategoryID = c.CategoryID
LEFT JOIN Book_Authors ba ON b.BookID = ba.BookID
LEFT JOIN Authors a ON ba.AuthorID = a.AuthorID
LEFT JOIN Borrowing br ON b.BookID = br.BookID
GROUP BY 
    b.BookID, b.ISBN, b.Title, c.CategoryName, b.PublishYear, 
    b.TotalCopies, b.AvailableCopies
ORDER BY TotalTimesBooked DESC, b.Title;
GO

-- ============================================================================
-- QUERY 3: Aggregation with GROUP BY and HAVING
-- Purpose: Members with high fine amounts and unpaid balances
-- Aggregation Functions: SUM, COUNT
-- Filtering: GROUP BY and HAVING
-- ============================================================================
PRINT '';
PRINT 'QUERY 3: Members with High Unpaid Fines (Aggregation with HAVING)';
PRINT '-------------------------------------------';
SELECT 
    m.MemberID,
    m.MembershipNumber,
    CONCAT(m.FirstName, ' ', m.LastName) AS MemberName,
    COUNT(f.FineID) AS TotalFines,
    COALESCE(SUM(CASE WHEN f.PaymentStatus = 'Unpaid' THEN f.FineAmount ELSE 0 END), 0) AS UnpaidAmount,
    COALESCE(SUM(CASE WHEN f.PaymentStatus = 'Paid' THEN f.FineAmount ELSE 0 END), 0) AS PaidAmount,
    COALESCE(SUM(f.FineAmount), 0) AS TotalFineAmount
FROM Members m
LEFT JOIN Fines f ON m.MemberID = f.MemberID
GROUP BY m.MemberID, m.MembershipNumber, m.FirstName, m.LastName
HAVING COALESCE(SUM(CASE WHEN f.PaymentStatus = 'Unpaid' THEN f.FineAmount ELSE 0 END), 0) > 0
ORDER BY UnpaidAmount DESC;
GO

-- ============================================================================
-- QUERY 4: Aggregation - Category Statistics
-- Purpose: Shows statistics for each book category
-- Aggregation Functions: COUNT, SUM, AVG, MIN, MAX
-- ============================================================================
PRINT '';
PRINT 'QUERY 4: Category Statistics (Multiple Aggregation Functions)';
PRINT '-------------------------------------------';
SELECT 
    c.CategoryID,
    c.CategoryName,
    COUNT(b.BookID) AS TotalBooks,
    COUNT(DISTINCT ba.AuthorID) AS TotalAuthors,
    SUM(b.TotalCopies) AS TotalCopiesInCategory,
    SUM(b.AvailableCopies) AS AvailableCopiesInCategory,
    CAST(AVG(CAST(b.PublishYear AS FLOAT)) AS INT) AS AvgPublishYear,
    MIN(b.PublishYear) AS EarliestPublished,
    MAX(b.PublishYear) AS LatestPublished,
    COUNT(DISTINCT br.BorrowingID) AS TotalBorrowingsInCategory
FROM Categories c
LEFT JOIN Books b ON c.CategoryID = b.CategoryID
LEFT JOIN Book_Authors ba ON b.BookID = ba.BookID
LEFT JOIN Borrowing br ON b.BookID = br.BookID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY TotalBooks DESC;
GO

-- ============================================================================
-- QUERY 5: Nested Subquery with IN operator
-- Purpose: Find members who have borrowed books from their preferred category
-- Nested subqueries using IN
-- ============================================================================
PRINT '';
PRINT 'QUERY 5: Members Who Borrowed Science Fiction Books (Subquery with IN)';
PRINT '-------------------------------------------';
SELECT DISTINCT
    m.MemberID,
    m.MembershipNumber,
    CONCAT(m.FirstName, ' ', m.LastName) AS MemberName,
    m.Email
FROM Members m
WHERE m.MemberID IN (
    SELECT DISTINCT br.MemberID
    FROM Borrowing br
    INNER JOIN Books b ON br.BookID = b.BookID
    WHERE b.CategoryID IN (
        SELECT CategoryID FROM Categories WHERE CategoryName = 'Science Fiction'
    )
)
ORDER BY m.MembershipNumber;
GO

-- ============================================================================
-- QUERY 6: Nested Subquery with EXISTS operator
-- Purpose: Find members with at least one overdue book
-- Nested subqueries using EXISTS
-- ============================================================================
PRINT '';
PRINT 'QUERY 6: Members with Overdue Books (Subquery with EXISTS)';
PRINT '-------------------------------------------';
SELECT 
    m.MemberID,
    m.MembershipNumber,
    CONCAT(m.FirstName, ' ', m.LastName) AS MemberName,
    m.Email,
    m.Status
FROM Members m
WHERE EXISTS (
    SELECT 1
    FROM Borrowing br
    WHERE br.MemberID = m.MemberID
    AND br.ReturnDate IS NULL
    AND br.DueDate < CAST(GETDATE() AS DATE)
    AND br.Status IN ('Borrowed', 'Overdue')
)
ORDER BY m.MembershipNumber;
GO

-- ============================================================================
-- QUERY 7: Correlated Subquery with ANY operator
-- Purpose: Find books borrowed more times than the average
-- Correlated subqueries with ANY
-- ============================================================================
PRINT '';
PRINT 'QUERY 7: Popular Books (Correlated Subquery with ANY)';
PRINT '-------------------------------------------';
SELECT 
    b.BookID,
    b.ISBN,
    b.Title,
    c.CategoryName,
    (SELECT COUNT(*) FROM Borrowing WHERE BookID = b.BookID) AS TimesBorrowed,
    b.TotalCopies,
    b.AvailableCopies
FROM Books b
LEFT JOIN Categories c ON b.CategoryID = c.CategoryID
WHERE (SELECT COUNT(*) FROM Borrowing WHERE BookID = b.BookID) > (
    SELECT AVG(BorrowCount)
    FROM (
        SELECT COUNT(BorrowingID) AS BorrowCount
        FROM Borrowing
        GROUP BY BookID
    ) AS BorrowStats
)
ORDER BY TimesBorrowed DESC;
GO

-- ============================================================================
-- VIEW DEMONSTRATIONS
-- ============================================================================
PRINT '';
PRINT '========== VIEW DEMONSTRATIONS ==========';
PRINT '';

-- ============================================================================
-- VIEW 1: Member Borrowing Activity Dashboard
-- ============================================================================
PRINT 'VIEW 1: Member Borrowing Activity Dashboard';
PRINT '-------------------------------------------';
SELECT TOP 10 * FROM vw_MemberBorrowingActivity ORDER BY MemberID;
GO

-- ============================================================================
-- VIEW 2: Book Availability Report
-- ============================================================================
PRINT '';
PRINT 'VIEW 2: Book Availability Report';
PRINT '-------------------------------------------';
SELECT TOP 15 * FROM vw_BookAvailabilityReport ORDER BY BookID;
GO

-- ============================================================================
-- VIEW 3: Overdue Books
-- ============================================================================
PRINT '';
PRINT 'VIEW 3: Overdue Books Report';
PRINT '-------------------------------------------';
SELECT * FROM vw_OverdueBooks ORDER BY DaysOverdue DESC;
GO

-- ============================================================================
-- VIEW 4: Fine Collection Summary
-- ============================================================================
PRINT '';
PRINT 'VIEW 4: Fine Collection Summary';
PRINT '-------------------------------------------';
SELECT * FROM vw_FineCollectionSummary WHERE TotalFines > 0 ORDER BY UnpaidAmount DESC;
GO

-- ============================================================================
-- SUMMARY STATISTICS
-- ============================================================================
PRINT '';
PRINT '========== LIBRARY SYSTEM SUMMARY STATISTICS ==========';
PRINT '';

PRINT 'Total Members:';
SELECT COUNT(*) AS TotalMembers FROM Members;
GO

PRINT 'Total Books:';
SELECT COUNT(*) AS TotalBooks, SUM(TotalCopies) AS TotalCopies, SUM(AvailableCopies) AS AvailableCopies
FROM Books;
GO

PRINT 'Active Borrowings:';
SELECT COUNT(*) AS ActiveBorrowings FROM Borrowing WHERE ReturnDate IS NULL;
GO

PRINT 'Total Outstanding Fines:';
SELECT 
    COUNT(*) AS TotalUnpaidFines,
    COALESCE(SUM(FineAmount), 0) AS TotalUnpaidAmount
FROM Fines
WHERE PaymentStatus = 'Unpaid';
GO

PRINT '========================================';
PRINT 'All advanced queries executed successfully!';
PRINT '========================================';
