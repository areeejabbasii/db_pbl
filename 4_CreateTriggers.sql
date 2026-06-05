-- ============================================================================
-- Library Management System - Create Triggers
-- ============================================================================
USE LibraryManagementDB;
GO

-- ============================================================================
-- TRIGGER 1: Update Book Availability When Book Is Borrowed
-- Purpose: Automatically decrease available copies when a book is borrowed
-- ============================================================================
GO

CREATE TRIGGER tr_UpdateBookAvailabilityOnBorrow
ON Borrowing
AFTER INSERT
AS
BEGIN
    UPDATE Books
    SET AvailableCopies = AvailableCopies - 1
    FROM Books b
    INNER JOIN inserted i ON b.BookID = i.BookID
    WHERE b.AvailableCopies > 0;
    
    PRINT 'Book availability updated: Borrowed book(s) removed from available inventory.';
END;
GO
PRINT 'Trigger: tr_UpdateBookAvailabilityOnBorrow created.';

-- ============================================================================
-- TRIGGER 2: Update Book Availability When Book Is Returned
-- Purpose: Automatically increase available copies when a book is returned
-- ============================================================================
GO

CREATE TRIGGER tr_UpdateBookAvailabilityOnReturn
ON Borrowing
AFTER UPDATE
AS
BEGIN
    -- Update when book is returned
    UPDATE Books
    SET AvailableCopies = AvailableCopies + 1
    FROM Books b
    INNER JOIN inserted i ON b.BookID = i.BookID
    WHERE i.ReturnDate IS NOT NULL 
    AND i.Status = 'Returned'
    AND b.AvailableCopies < b.TotalCopies;
    
    PRINT 'Book availability updated: Returned book(s) added back to inventory.';
END;
GO
PRINT 'Trigger: tr_UpdateBookAvailabilityOnReturn created.';

-- ============================================================================
-- TRIGGER 3: Automatic Fine Generation for Overdue Books
-- Purpose: Automatically creates fine record when book is overdue (daily)
-- Note: This trigger runs when borrowing record status is updated to 'Overdue'
-- ============================================================================
GO

CREATE TRIGGER tr_GenerateOverdueFine
ON Borrowing
AFTER UPDATE
AS
BEGIN
    DECLARE @DaysOverdue INT;
    DECLARE @FineAmount DECIMAL(10,2);
    DECLARE @DailyFineRate DECIMAL(10,2) = 0.50; -- 0.50 per day
    
    INSERT INTO Fines (BorrowingID, MemberID, FineAmount, DaysOverdue, PaymentStatus, FineDate)
    SELECT 
        i.BorrowingID,
        i.MemberID,
        CAST(DATEDIFF(DAY, i.DueDate, CAST(GETDATE() AS DATE)) * @DailyFineRate AS DECIMAL(10,2)),
        DATEDIFF(DAY, i.DueDate, CAST(GETDATE() AS DATE)),
        'Unpaid',
        GETDATE()
    FROM inserted i
    WHERE i.Status = 'Overdue'
    AND i.ReturnDate IS NULL
    AND NOT EXISTS (
        SELECT 1 FROM Fines f 
        WHERE f.BorrowingID = i.BorrowingID 
        AND f.PaymentStatus = 'Unpaid'
    );
    
    PRINT 'Fine generated for overdue book(s).';
END;
GO
PRINT 'Trigger: tr_GenerateOverdueFine created.';

-- ============================================================================
-- TRIGGER 4: Prevent Overbooking of Books
-- Purpose: Prevents borrowing if no copies are available
-- ============================================================================
GO

CREATE TRIGGER tr_PreventOverbooking
ON Borrowing
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @BookID INT;
    DECLARE @AvailableCopies INT;
    
    SELECT @BookID = BookID FROM inserted;
    SELECT @AvailableCopies = AvailableCopies FROM Books WHERE BookID = @BookID;
    
    IF @AvailableCopies > 0
    BEGIN
        INSERT INTO Borrowing (MemberID, BookID, BorrowDate, DueDate, Status)
        SELECT MemberID, BookID, BorrowDate, DueDate, Status FROM inserted;
        PRINT 'Borrowing record created successfully.';
    END
    ELSE
    BEGIN
        RAISERROR('Cannot borrow: No available copies of this book.', 16, 1);
    END;
END;
GO
PRINT 'Trigger: tr_PreventOverbooking created.';

-- ============================================================================
-- TRIGGER 5: Audit Member Membership Status Changes
-- Purpose: Creates audit log when member status changes
-- ============================================================================
GO

CREATE TABLE MemberStatusAudit (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    MemberID INT NOT NULL,
    OldStatus NVARCHAR(20),
    NewStatus NVARCHAR(20),
    ChangedDate DATETIME DEFAULT GETDATE(),
    ChangeReason NVARCHAR(200)
GO

CREATE TRIGGER tr_AuditMemberStatusChange
ON Members
AFTER UPDATE
AS
BEGIN
    INSERT INTO MemberStatusAudit (MemberID, OldStatus, NewStatus, ChangeReason)
    SELECT 
        i.MemberID,
        d.Status,
        i.Status,
        CASE 
            WHEN i.MembershipExpiryDate < CAST(GETDATE() AS DATE) THEN 'Membership Expired'
            WHEN i.Status = 'Suspended' THEN 'Suspended by Admin'
            ELSE 'Status Updated'
        END
    FROM inserted i
    INNER JOIN deleted d ON i.MemberID = d.MemberID
    WHERE i.Status <> d.Status;
    
    PRINT 'Member status change audited.';
END;
GO
PRINT 'Trigger: tr_AuditMemberStatusChange created.';

-- ============================================================================
-- TRIGGER 6: Prevent Deletion of Recently Borrowed Books
-- Purpose: Prevents deletion of books that were borrowed in last 30 days
-- ============================================================================
GO

CREATE TRIGGER tr_PreventRecentBookDeletion
ON Books
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @BookID INT;
    
    SELECT @BookID = BookID FROM deleted;
    
    IF EXISTS (
        SELECT 1 FROM Borrowing 
        WHERE BookID = @BookID 
        AND DATEDIFF(DAY, BorrowDate, GETDATE()) <= 30
    )
    BEGIN
        RAISERROR('Cannot delete: Book has been borrowed within the last 30 days.', 16, 1);
    END
    ELSE
    BEGIN
        DELETE FROM Books WHERE BookID = @BookID;
        PRINT 'Book deleted successfully.';
    END;
END;
GO
PRINT 'Trigger: tr_PreventRecentBookDeletion created.';

PRINT '========================================';
PRINT 'All triggers created successfully!';
PRINT '========================================';
