"""
Database Connection Module
Handles all database connections and operations
"""

import pyodbc
from typing import List, Dict, Tuple, Any
import sys

class DatabaseConnection:
    """Manages database connections and queries"""
    
    def __init__(self, server: str, database: str):
        """
        Initialize database connection
        
        Args:
            server: SQL Server name (e.g., 'DESKTOP-ABC\\SQLEXPRESS')
            database: Database name
        """
        self.server = server
        self.database = database
        self.connection = None
        self.cursor = None
        
    def connect(self) -> bool:
        """
        Establish database connection
        
        Returns:
            True if successful, False otherwise
        """
        try:
            connection_string = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={self.server};DATABASE={self.database};Trusted_Connection=yes;'
            self.connection = pyodbc.connect(connection_string)
            self.cursor = self.connection.cursor()
            print(f"Connected to database: {self.database}")
            return True
        except pyodbc.Error as e:
            print(f"Connection Error: {e}")
            return False
        except Exception as e:
            print(f"Unexpected Error: {e}")
            return False
    
    def disconnect(self):
        """Close database connection"""
        if self.cursor:
            self.cursor.close()
        if self.connection:
            self.connection.close()
        print("Disconnected from database")
    
    def execute_query(self, query: str, params: Tuple = ()) -> List[Dict]:
        """
        Execute SELECT query and return results
        
        Args:
            query: SQL query string
            params: Query parameters
            
        Returns:
            List of dictionaries representing rows
        """
        try:
            if params:
                self.cursor.execute(query, params)
            else:
                self.cursor.execute(query)
            
            columns = [description[0] for description in self.cursor.description]
            results = []
            for row in self.cursor.fetchall():
                results.append(dict(zip(columns, row)))
            return results
        except pyodbc.Error as e:
            print(f"Query Error: {e}")
            return []
    
    def execute_update(self, query: str, params: Tuple = ()) -> bool:
        """
        Execute INSERT/UPDATE/DELETE query
        
        Args:
            query: SQL query string
            params: Query parameters
            
        Returns:
            True if successful, False otherwise
        """
        try:
            if params:
                self.cursor.execute(query, params)
            else:
                self.cursor.execute(query)
            self.connection.commit()
            return True
        except pyodbc.Error as e:
            print(f"Update Error: {e}")
            self.connection.rollback()
            return False
    
    def get_all_members(self) -> List[Dict]:
        """Get all members from database"""
        query = """
        SELECT MemberID, MembershipNumber, CONCAT(FirstName, ' ', LastName) as Name, 
               Email, Phone, Status FROM Members ORDER BY MemberID
        """
        return self.execute_query(query)
    
    def get_all_books(self) -> List[Dict]:
        """Get all books from database"""
        query = """
        SELECT BookID, ISBN, Title, CategoryID, PublishYear, TotalCopies, 
               AvailableCopies, PublisherName FROM Books ORDER BY BookID
        """
        return self.execute_query(query)
    
    def get_all_borrowings(self) -> List[Dict]:
        """Get all borrowing records"""
        query = """
        SELECT b.BorrowingID, m.MembershipNumber, bo.Title, b.BorrowDate, 
               b.DueDate, b.ReturnDate, b.Status
        FROM Borrowing b
        INNER JOIN Members m ON b.MemberID = m.MemberID
        INNER JOIN Books bo ON b.BookID = bo.BookID
        ORDER BY b.BorrowingID DESC
        """
        return self.execute_query(query)
    
    def add_member(self, membership_num: str, first_name: str, last_name: str, 
                   email: str, phone: str, city: str, country: str, 
                   expiry_date: str) -> bool:
        """Add new member"""
        query = """
        INSERT INTO Members (MembershipNumber, FirstName, LastName, Email, Phone, 
                           City, Country, MembershipDate, MembershipExpiryDate, Status)
        VALUES (?, ?, ?, ?, ?, ?, ?, CAST(GETDATE() AS DATE), ?, 'Active')
        """
        return self.execute_update(query, 
            (membership_num, first_name, last_name, email, phone, city, country, expiry_date))
    
    def add_book(self, isbn: str, title: str, category_id: int, publish_year: int,
                pages: int, total_copies: int, publisher: str) -> bool:
        """Add new book"""
        query = """
        INSERT INTO Books (ISBN, Title, CategoryID, PublishYear, NumberOfPages, 
                          TotalCopies, AvailableCopies, PublisherName)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        return self.execute_update(query, 
            (isbn, title, category_id, publish_year, pages, total_copies, total_copies, publisher))
    
    def borrow_book(self, member_id: int, book_id: int, days: int = 14) -> bool:
        """Record book borrowing"""
        query = """
        INSERT INTO Borrowing (MemberID, BookID, BorrowDate, DueDate, Status)
        VALUES (?, ?, CAST(GETDATE() AS DATE), DATEADD(DAY, ?, CAST(GETDATE() AS DATE)), 'Borrowed')
        """
        return self.execute_update(query, (member_id, book_id, days))
    
    def return_book(self, borrowing_id: int) -> bool:
        """Record book return"""
        query = """
        UPDATE Borrowing
        SET ReturnDate = CAST(GETDATE() AS DATE), Status = 'Returned'
        WHERE BorrowingID = ?
        """
        return self.execute_update(query, (borrowing_id,))
    
    def update_member(self, member_id: int, email: str, phone: str, status: str) -> bool:
        """Update member information"""
        query = """
        UPDATE Members
        SET Email = ?, Phone = ?, Status = ?
        WHERE MemberID = ?
        """
        return self.execute_update(query, (email, phone, status, member_id))
    
    def delete_member(self, member_id: int) -> bool:
        """Delete member (soft delete - mark as inactive)"""
        query = """
        UPDATE Members
        SET Status = 'Inactive'
        WHERE MemberID = ?
        """
        return self.execute_update(query, (member_id,))
    
    def get_categories(self) -> List[Dict]:
        """Get all categories"""
        query = "SELECT CategoryID, CategoryName FROM Categories ORDER BY CategoryName"
        return self.execute_query(query)
    
    def get_member_fines(self, member_id: int) -> float:
        """Get unpaid fines for a member"""
        query = """
        SELECT COALESCE(SUM(FineAmount), 0) as TotalFines
        FROM Fines
        WHERE MemberID = ? AND PaymentStatus = 'Unpaid'
        """
        result = self.execute_query(query, (member_id,))
        return result[0]['TotalFines'] if result else 0
