-- ============================================================================
-- Library Management System - Create Tables
-- ============================================================================
USE LibraryManagementDB;
GO

-- Drop existing tables if they exist (clean slate)
IF OBJECT_ID('dbo.Fines', 'U') IS NOT NULL DROP TABLE dbo.Fines;
IF OBJECT_ID('dbo.Borrowing', 'U') IS NOT NULL DROP TABLE dbo.Borrowing;
IF OBJECT_ID('dbo.Book_Authors', 'U') IS NOT NULL DROP TABLE dbo.Book_Authors;
IF OBJECT_ID('dbo.Books', 'U') IS NOT NULL DROP TABLE dbo.Books;
IF OBJECT_ID('dbo.Authors', 'U') IS NOT NULL DROP TABLE dbo.Authors;
IF OBJECT_ID('dbo.Members', 'U') IS NOT NULL DROP TABLE dbo.Members;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.MemberStatusAudit', 'U') IS NOT NULL DROP TABLE dbo.MemberStatusAudit;
GO

-- ============================================================================
-- 1. CATEGORIES TABLE
-- ============================================================================
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO
PRINT 'Categories table created.';

-- ============================================================================
-- 2. AUTHORS TABLE
-- ============================================================================
CREATE TABLE Authors (
    AuthorID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    DateOfBirth DATE,
    Nationality NVARCHAR(50),
    CreatedDate DATETIME DEFAULT GETDATE(),
    CHECK (LEN(FirstName) > 0 AND LEN(LastName) > 0)
);
GO
PRINT 'Authors table created.';

-- ============================================================================
-- 3. BOOKS TABLE
-- ============================================================================
CREATE TABLE Books (
    BookID INT PRIMARY KEY IDENTITY(1,1),
    ISBN NVARCHAR(20) NOT NULL UNIQUE,
    Title NVARCHAR(200) NOT NULL,
    CategoryID INT NOT NULL,
    PublishYear INT,
    NumberOfPages INT,
    TotalCopies INT NOT NULL DEFAULT 1,
    AvailableCopies INT NOT NULL DEFAULT 1,
    PublisherName NVARCHAR(100),
    Description NVARCHAR(1000),
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID) ON DELETE CASCADE,
    CHECK (TotalCopies > 0),
    CHECK (AvailableCopies >= 0),
    CHECK (AvailableCopies <= TotalCopies),
    CHECK (PublishYear >= 1000 AND PublishYear <= YEAR(GETDATE()))
);
GO
PRINT 'Books table created.';

-- ============================================================================
-- 4. BOOK_AUTHORS TABLE (Many-to-Many relationship)
-- ============================================================================
CREATE TABLE Book_Authors (
    BookAuthorID INT PRIMARY KEY IDENTITY(1,1),
    BookID INT NOT NULL,
    AuthorID INT NOT NULL,
    AuthorSequence INT NOT NULL DEFAULT 1,
    FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE CASCADE,
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID) ON DELETE CASCADE,
    UNIQUE (BookID, AuthorID),
    CHECK (AuthorSequence > 0)
);
GO
PRINT 'Book_Authors table created.';

-- ============================================================================
-- 5. MEMBERS TABLE
-- ============================================================================
CREATE TABLE Members (
    MemberID INT PRIMARY KEY IDENTITY(1,1),
    MembershipNumber NVARCHAR(20) NOT NULL UNIQUE,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Phone NVARCHAR(20) NOT NULL,
    Address NVARCHAR(200),
    City NVARCHAR(50),
    Country NVARCHAR(50),
    PostalCode NVARCHAR(10),
    DateOfBirth DATE,
    MembershipDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    MembershipExpiryDate DATE NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (Status IN ('Active', 'Inactive', 'Suspended')),
    CreatedDate DATETIME DEFAULT GETDATE(),
    CHECK (LEN(FirstName) > 0 AND LEN(LastName) > 0),
    CHECK (MembershipExpiryDate > MembershipDate)
);
GO
PRINT 'Members table created.';

-- ============================================================================
-- 6. BORROWING TABLE
-- ============================================================================
CREATE TABLE Borrowing (
    BorrowingID INT PRIMARY KEY IDENTITY(1,1),
    MemberID INT NOT NULL,
    BookID INT NOT NULL,
    BorrowDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    DueDate DATE NOT NULL,
    ReturnDate DATE NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Borrowed' CHECK (Status IN ('Borrowed', 'Returned', 'Overdue')),
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID) ON DELETE CASCADE,
    FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE CASCADE,
    CHECK (DueDate > BorrowDate),
    CHECK (ReturnDate IS NULL OR ReturnDate >= BorrowDate)
);
GO
PRINT 'Borrowing table created.';

-- ============================================================================
-- 7. FINES TABLE
-- ============================================================================
CREATE TABLE Fines (
    FineID INT PRIMARY KEY IDENTITY(1,1),
    BorrowingID INT NOT NULL,
    MemberID INT NOT NULL,
    FineAmount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    FineDate DATETIME NOT NULL DEFAULT GETDATE(),
    DaysOverdue INT,
    PaymentStatus NVARCHAR(20) NOT NULL DEFAULT 'Unpaid' CHECK (PaymentStatus IN ('Paid', 'Unpaid', 'Partial')),
    PaymentDate DATETIME NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BorrowingID) REFERENCES Borrowing(BorrowingID) ON DELETE NO ACTION,
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID) ON DELETE NO ACTION,
    CHECK (FineAmount >= 0),
    CHECK (DaysOverdue IS NULL OR DaysOverdue >= 0)
);
GO
PRINT 'Fines table created.';

-- ============================================================================
-- CREATE INDEXES FOR PERFORMANCE OPTIMIZATION
-- ============================================================================
CREATE INDEX IDX_Books_CategoryID ON Books(CategoryID);
CREATE INDEX IDX_Book_Authors_BookID ON Book_Authors(BookID);
CREATE INDEX IDX_Book_Authors_AuthorID ON Book_Authors(AuthorID);
CREATE INDEX IDX_Borrowing_MemberID ON Borrowing(MemberID);
CREATE INDEX IDX_Borrowing_BookID ON Borrowing(BookID);
CREATE INDEX IDX_Borrowing_Status ON Borrowing(Status);
CREATE INDEX IDX_Fines_MemberID ON Fines(MemberID);
CREATE INDEX IDX_Fines_PaymentStatus ON Fines(PaymentStatus);
CREATE INDEX IDX_Members_Status ON Members(Status);

PRINT 'All indexes created.';
GO

PRINT '========================================';
PRINT 'All tables created successfully!';
PRINT '========================================';
