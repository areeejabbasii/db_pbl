-- ============================================================================
-- Library Management System - SQL Server 2019
-- Database Creation Script
-- ============================================================================

-- Drop existing database if it exists (optional)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'LibraryManagementDB')
BEGIN
    ALTER DATABASE LibraryManagementDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LibraryManagementDB;
END
GO

-- Create the database
CREATE DATABASE LibraryManagementDB;
GO

-- Use the new database
USE LibraryManagementDB;
GO

PRINT 'Database LibraryManagementDB created successfully!';
GO
