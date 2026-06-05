"""
Library Management System - GUI Application
Python Tkinter GUI for CRUD operations with SQL Server backend
"""

import tkinter as tk
from tkinter import ttk, messagebox, filedialog
from db_connection import DatabaseConnection
from datetime import datetime, timedelta
import sys

class LibraryManagementApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Library Management System - CRUD Interface")
        self.root.geometry("1000x700")
        self.root.resizable(True, True)
        
        # Database connection
        self.db = DatabaseConnection(
            server='DESKTOP-CE0E4P0\\SQLEXPRESS',  # Your SQL Server name
            database='LibraryManagementDB'
        )
        
        if not self.db.connect():
            messagebox.showerror("Connection Error", "Failed to connect to database. Check server name.")
            sys.exit()
        
        # Setup GUI
        self.setup_gui()
        self.load_members()
        
    def setup_gui(self):
        """Setup main GUI components"""
        # Create notebook (tabbed interface)
        self.notebook = ttk.Notebook(self.root)
        self.notebook.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Tabs
        self.members_tab = ttk.Frame(self.notebook)
        self.books_tab = ttk.Frame(self.notebook)
        self.borrowing_tab = ttk.Frame(self.notebook)
        self.reports_tab = ttk.Frame(self.notebook)
        
        self.notebook.add(self.members_tab, text="Members")
        self.notebook.add(self.books_tab, text="Books")
        self.notebook.add(self.borrowing_tab, text="Borrowing")
        self.notebook.add(self.reports_tab, text="Reports")
        
        # Setup each tab
        self.setup_members_tab()
        self.setup_books_tab()
        self.setup_borrowing_tab()
        self.setup_reports_tab()
    
    def setup_members_tab(self):
        """Setup Members management tab"""
        # Frame for input
        input_frame = ttk.LabelFrame(self.members_tab, text="Add/Edit Member", padding=10)
        input_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Label(input_frame, text="Membership #:").grid(row=0, column=0, sticky=tk.W, pady=5)
        self.member_num_var = tk.StringVar()
        ttk.Entry(input_frame, textvariable=self.member_num_var, width=20).grid(row=0, column=1, sticky=tk.W, pady=5)
        
        ttk.Label(input_frame, text="First Name:").grid(row=0, column=2, sticky=tk.W, pady=5)
        self.first_name_var = tk.StringVar()
        ttk.Entry(input_frame, textvariable=self.first_name_var, width=20).grid(row=0, column=3, sticky=tk.W, pady=5)
        
        ttk.Label(input_frame, text="Last Name:").grid(row=1, column=0, sticky=tk.W, pady=5)
        self.last_name_var = tk.StringVar()
        ttk.Entry(input_frame, textvariable=self.last_name_var, width=20).grid(row=1, column=1, sticky=tk.W, pady=5)
        
        ttk.Label(input_frame, text="Email:").grid(row=1, column=2, sticky=tk.W, pady=5)
        self.email_var = tk.StringVar()
        ttk.Entry(input_frame, textvariable=self.email_var, width=20).grid(row=1, column=3, sticky=tk.W, pady=5)
        
        ttk.Label(input_frame, text="Phone:").grid(row=2, column=0, sticky=tk.W, pady=5)
        self.phone_var = tk.StringVar()
        ttk.Entry(input_frame, textvariable=self.phone_var, width=20).grid(row=2, column=1, sticky=tk.W, pady=5)
        
        ttk.Label(input_frame, text="City:").grid(row=2, column=2, sticky=tk.W, pady=5)
        self.city_var = tk.StringVar()
        ttk.Entry(input_frame, textvariable=self.city_var, width=20).grid(row=2, column=3, sticky=tk.W, pady=5)
        
        ttk.Label(input_frame, text="Country:").grid(row=3, column=0, sticky=tk.W, pady=5)
        self.country_var = tk.StringVar(value="Pakistan")
        ttk.Entry(input_frame, textvariable=self.country_var, width=20).grid(row=3, column=1, sticky=tk.W, pady=5)
        
        ttk.Label(input_frame, text="Expiry Date (YYYY-MM-DD):").grid(row=3, column=2, sticky=tk.W, pady=5)
        self.expiry_var = tk.StringVar(value=str((datetime.now() + timedelta(days=365)).date()))
        ttk.Entry(input_frame, textvariable=self.expiry_var, width=20).grid(row=3, column=3, sticky=tk.W, pady=5)
        
        # Buttons
        button_frame = ttk.Frame(input_frame)
        button_frame.grid(row=4, column=0, columnspan=4, pady=10, sticky=tk.W)
        
        ttk.Button(button_frame, text="Add Member", command=self.add_member).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Refresh", command=self.load_members).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Delete Selected", command=self.delete_member).pack(side=tk.LEFT, padx=5)
        
        # Frame for table
        table_frame = ttk.LabelFrame(self.members_tab, text="Members List", padding=10)
        table_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        # Treeview for members
        self.members_tree = ttk.Treeview(table_frame, columns=('ID', 'Membership', 'Name', 'Email', 'Phone', 'Status'), 
                                        height=15, show='headings')
        
        self.members_tree.heading('ID', text='ID')
        self.members_tree.heading('Membership', text='Membership #')
        self.members_tree.heading('Name', text='Name')
        self.members_tree.heading('Email', text='Email')
        self.members_tree.heading('Phone', text='Phone')
        self.members_tree.heading('Status', text='Status')
        
        self.members_tree.column('ID', width=30)
        self.members_tree.column('Membership', width=100)
        self.members_tree.column('Name', width=150)
        self.members_tree.column('Email', width=150)
        self.members_tree.column('Phone', width=120)
        self.members_tree.column('Status', width=80)
        
        self.members_tree.pack(fill=tk.BOTH, expand=True)
        
        # Scrollbar
        scrollbar = ttk.Scrollbar(table_frame, orient=tk.VERTICAL, command=self.members_tree.yview)
        self.members_tree.configure(yscroll=scrollbar.set)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def setup_books_tab(self):
        """Setup Books management tab"""
        # Frame for input
        input_frame = ttk.LabelFrame(self.books_tab, text="Add Book", padding=10)
        input_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Label(input_frame, text="ISBN:").grid(row=0, column=0, sticky=tk.W, pady=5)
        self.isbn_var = tk.StringVar()
        ttk.Entry(input_frame, textvariable=self.isbn_var, width=20).grid(row=0, column=1, sticky=tk.W, pady=5)
        
        ttk.Label(input_frame, text="Title:").grid(row=0, column=2, sticky=tk.W, pady=5)
        self.title_var = tk.StringVar()
        ttk.Entry(input_frame, textvariable=self.title_var, width=30).grid(row=0, column=3, sticky=tk.W, pady=5)
        
        ttk.Label(input_frame, text="Category:").grid(row=1, column=0, sticky=tk.W, pady=5)
        self.category_var = tk.StringVar()
        self.category_combo = ttk.Combobox(input_frame, textvariable=self.category_var, width=18, state='readonly')
        self.category_combo.grid(row=1, column=1, sticky=tk.W, pady=5)
        self.load_categories()
        
        ttk.Label(input_frame, text="Publish Year:").grid(row=1, column=2, sticky=tk.W, pady=5)
        self.year_var = tk.StringVar()
        ttk.Entry(input_frame, textvariable=self.year_var, width=20).grid(row=1, column=3, sticky=tk.W, pady=5)
        
        ttk.Label(input_frame, text="Pages:").grid(row=2, column=0, sticky=tk.W, pady=5)
        self.pages_var = tk.StringVar()
        ttk.Entry(input_frame, textvariable=self.pages_var, width=20).grid(row=2, column=1, sticky=tk.W, pady=5)
        
        ttk.Label(input_frame, text="Total Copies:").grid(row=2, column=2, sticky=tk.W, pady=5)
        self.copies_var = tk.StringVar()
        ttk.Entry(input_frame, textvariable=self.copies_var, width=20).grid(row=2, column=3, sticky=tk.W, pady=5)
        
        ttk.Label(input_frame, text="Publisher:").grid(row=3, column=0, sticky=tk.W, pady=5)
        self.publisher_var = tk.StringVar()
        ttk.Entry(input_frame, textvariable=self.publisher_var, width=50).grid(row=3, column=1, columnspan=3, sticky=tk.W, pady=5)
        
        button_frame = ttk.Frame(input_frame)
        button_frame.grid(row=4, column=0, columnspan=4, pady=10, sticky=tk.W)
        
        ttk.Button(button_frame, text="Add Book", command=self.add_book).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Refresh", command=self.load_books).pack(side=tk.LEFT, padx=5)
        
        # Frame for table
        table_frame = ttk.LabelFrame(self.books_tab, text="Books List", padding=10)
        table_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        # Treeview for books
        self.books_tree = ttk.Treeview(table_frame, columns=('ID', 'ISBN', 'Title', 'Year', 'Total', 'Available'), 
                                      height=15, show='headings')
        
        self.books_tree.heading('ID', text='ID')
        self.books_tree.heading('ISBN', text='ISBN')
        self.books_tree.heading('Title', text='Title')
        self.books_tree.heading('Year', text='Year')
        self.books_tree.heading('Total', text='Total Copies')
        self.books_tree.heading('Available', text='Available')
        
        self.books_tree.column('ID', width=30)
        self.books_tree.column('ISBN', width=80)
        self.books_tree.column('Title', width=300)
        self.books_tree.column('Year', width=60)
        self.books_tree.column('Total', width=80)
        self.books_tree.column('Available', width=80)
        
        self.books_tree.pack(fill=tk.BOTH, expand=True)
        
        scrollbar = ttk.Scrollbar(table_frame, orient=tk.VERTICAL, command=self.books_tree.yview)
        self.books_tree.configure(yscroll=scrollbar.set)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def setup_borrowing_tab(self):
        """Setup Borrowing management tab"""
        input_frame = ttk.LabelFrame(self.borrowing_tab, text="Borrow/Return Book", padding=10)
        input_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Label(input_frame, text="Member ID:").grid(row=0, column=0, sticky=tk.W, pady=5)
        self.borrow_member_var = tk.StringVar()
        ttk.Entry(input_frame, textvariable=self.borrow_member_var, width=20).grid(row=0, column=1, sticky=tk.W, pady=5)
        
        ttk.Label(input_frame, text="Book ID:").grid(row=0, column=2, sticky=tk.W, pady=5)
        self.borrow_book_var = tk.StringVar()
        ttk.Entry(input_frame, textvariable=self.borrow_book_var, width=20).grid(row=0, column=3, sticky=tk.W, pady=5)
        
        ttk.Label(input_frame, text="Days (default 14):").grid(row=1, column=0, sticky=tk.W, pady=5)
        self.days_var = tk.StringVar(value="14")
        ttk.Entry(input_frame, textvariable=self.days_var, width=20).grid(row=1, column=1, sticky=tk.W, pady=5)
        
        button_frame = ttk.Frame(input_frame)
        button_frame.grid(row=2, column=0, columnspan=4, pady=10, sticky=tk.W)
        
        ttk.Button(button_frame, text="Borrow Book", command=self.borrow_book).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Return Book", command=self.return_book).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Refresh", command=self.load_borrowings).pack(side=tk.LEFT, padx=5)
        
        # Frame for table
        table_frame = ttk.LabelFrame(self.borrowing_tab, text="Borrowing Records", padding=10)
        table_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        self.borrowing_tree = ttk.Treeview(table_frame, columns=('ID', 'Member', 'Book', 'Borrow', 'Due', 'Return', 'Status'), 
                                          height=15, show='headings')
        
        self.borrowing_tree.heading('ID', text='ID')
        self.borrowing_tree.heading('Member', text='Member')
        self.borrowing_tree.heading('Book', text='Book Title')
        self.borrowing_tree.heading('Borrow', text='Borrow Date')
        self.borrowing_tree.heading('Due', text='Due Date')
        self.borrowing_tree.heading('Return', text='Return Date')
        self.borrowing_tree.heading('Status', text='Status')
        
        self.borrowing_tree.column('ID', width=40)
        self.borrowing_tree.column('Member', width=80)
        self.borrowing_tree.column('Book', width=250)
        self.borrowing_tree.column('Borrow', width=80)
        self.borrowing_tree.column('Due', width=80)
        self.borrowing_tree.column('Return', width=80)
        self.borrowing_tree.column('Status', width=80)
        
        self.borrowing_tree.pack(fill=tk.BOTH, expand=True)
        
        scrollbar = ttk.Scrollbar(table_frame, orient=tk.VERTICAL, command=self.borrowing_tree.yview)
        self.borrowing_tree.configure(yscroll=scrollbar.set)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def setup_reports_tab(self):
        """Setup Reports tab"""
        report_frame = ttk.LabelFrame(self.reports_tab, text="Database Reports", padding=10)
        report_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        ttk.Button(report_frame, text="View Overdue Books", command=self.show_overdue_books, width=30).pack(pady=5)
        ttk.Button(report_frame, text="View Member Fines Summary", command=self.show_fine_summary, width=30).pack(pady=5)
        ttk.Button(report_frame, text="View Book Availability Report", command=self.show_availability, width=30).pack(pady=5)
        ttk.Button(report_frame, text="View Member Borrowing Activity", command=self.show_member_activity, width=30).pack(pady=5)
        
        # Text widget for report display
        self.report_text = tk.Text(report_frame, height=20, width=120)
        self.report_text.pack(fill=tk.BOTH, expand=True, pady=10)
        
        scrollbar = ttk.Scrollbar(self.report_text, command=self.report_text.yview)
        self.report_text.configure(yscroll=scrollbar.set)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    # Member operations
    def load_members(self):
        """Load members from database"""
        for item in self.members_tree.get_children():
            self.members_tree.delete(item)
        
        members = self.db.get_all_members()
        for member in members:
            self.members_tree.insert('', tk.END, values=(
                member['MemberID'],
                member['MembershipNumber'],
                member['Name'],
                member['Email'],
                member['Phone'],
                member['Status']
            ))
    
    def add_member(self):
        """Add new member"""
        try:
            if not all([self.member_num_var.get(), self.first_name_var.get(), 
                       self.last_name_var.get(), self.email_var.get(), self.phone_var.get()]):
                messagebox.showerror("Error", "Please fill all required fields")
                return
            
            if self.db.add_member(
                self.member_num_var.get(),
                self.first_name_var.get(),
                self.last_name_var.get(),
                self.email_var.get(),
                self.phone_var.get(),
                self.city_var.get(),
                self.country_var.get(),
                self.expiry_var.get()
            ):
                messagebox.showinfo("Success", "Member added successfully!")
                self.clear_member_inputs()
                self.load_members()
            else:
                messagebox.showerror("Error", "Failed to add member")
        except Exception as e:
            messagebox.showerror("Error", str(e))
    
    def delete_member(self):
        """Delete selected member"""
        selection = self.members_tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "Please select a member to delete")
            return
        
        if messagebox.askyesno("Confirm", "Mark member as inactive?"):
            member_id = self.members_tree.item(selection[0])['values'][0]
            if self.db.delete_member(member_id):
                messagebox.showinfo("Success", "Member marked as inactive")
                self.load_members()
            else:
                messagebox.showerror("Error", "Failed to delete member")
    
    def clear_member_inputs(self):
        """Clear member input fields"""
        self.member_num_var.set('')
        self.first_name_var.set('')
        self.last_name_var.set('')
        self.email_var.set('')
        self.phone_var.set('')
        self.city_var.set('')
    
    # Book operations
    def load_categories(self):
        """Load categories into combobox"""
        categories = self.db.get_categories()
        values = [f"{cat['CategoryID']}: {cat['CategoryName']}" for cat in categories]
        self.category_combo['values'] = values
    
    def load_books(self):
        """Load books from database"""
        for item in self.books_tree.get_children():
            self.books_tree.delete(item)
        
        books = self.db.get_all_books()
        for book in books:
            self.books_tree.insert('', tk.END, values=(
                book['BookID'],
                book['ISBN'],
                book['Title'],
                book['PublishYear'],
                book['TotalCopies'],
                book['AvailableCopies']
            ))
    
    def add_book(self):
        """Add new book"""
        try:
            if not all([self.isbn_var.get(), self.title_var.get(), self.category_var.get()]):
                messagebox.showerror("Error", "Please fill required fields (ISBN, Title, Category)")
                return
            
            category_id = int(self.category_var.get().split(':')[0])
            
            if self.db.add_book(
                self.isbn_var.get(),
                self.title_var.get(),
                category_id,
                int(self.year_var.get() or 2024),
                int(self.pages_var.get() or 0),
                int(self.copies_var.get() or 1),
                self.publisher_var.get()
            ):
                messagebox.showinfo("Success", "Book added successfully!")
                self.isbn_var.set('')
                self.title_var.set('')
                self.year_var.set('')
                self.pages_var.set('')
                self.copies_var.set('')
                self.publisher_var.set('')
                self.load_books()
            else:
                messagebox.showerror("Error", "Failed to add book")
        except Exception as e:
            messagebox.showerror("Error", str(e))
    
    # Borrowing operations
    def load_borrowings(self):
        """Load borrowing records"""
        for item in self.borrowing_tree.get_children():
            self.borrowing_tree.delete(item)
        
        borrowings = self.db.get_all_borrowings()
        for borrowing in borrowings:
            return_date = borrowing['ReturnDate'] or 'N/A'
            self.borrowing_tree.insert('', tk.END, values=(
                borrowing['BorrowingID'],
                borrowing['MembershipNumber'],
                borrowing['Title'],
                borrowing['BorrowDate'],
                borrowing['DueDate'],
                return_date,
                borrowing['Status']
            ))
    
    def borrow_book(self):
        """Record book borrowing"""
        try:
            member_id = int(self.borrow_member_var.get())
            book_id = int(self.borrow_book_var.get())
            days = int(self.days_var.get())
            
            if self.db.borrow_book(member_id, book_id, days):
                messagebox.showinfo("Success", "Book borrowed successfully!")
                self.borrow_member_var.set('')
                self.borrow_book_var.set('')
                self.load_borrowings()
                self.load_books()
            else:
                messagebox.showerror("Error", "Failed to borrow book")
        except Exception as e:
            messagebox.showerror("Error", str(e))
    
    def return_book(self):
        """Record book return"""
        selection = self.borrowing_tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "Please select a borrowing record")
            return
        
        try:
            borrowing_id = self.borrowing_tree.item(selection[0])['values'][0]
            if self.db.return_book(borrowing_id):
                messagebox.showinfo("Success", "Book returned successfully!")
                self.load_borrowings()
                self.load_books()
            else:
                messagebox.showerror("Error", "Failed to return book")
        except Exception as e:
            messagebox.showerror("Error", str(e))
    
    # Report operations
    def show_overdue_books(self):
        """Show overdue books from view"""
        self.report_text.delete(1.0, tk.END)
        query = "SELECT * FROM vw_OverdueBooks"
        results = self.db.execute_query(query)
        
        self.report_text.insert(tk.END, "OVERDUE BOOKS REPORT\n")
        self.report_text.insert(tk.END, "=" * 120 + "\n\n")
        
        if results:
            for row in results:
                self.report_text.insert(tk.END, f"Member: {row['MemberName']} ({row['MembershipNumber']})\n")
                self.report_text.insert(tk.END, f"Email: {row['Email']}\n")
                self.report_text.insert(tk.END, f"Book: {row['Title']} (ISBN: {row['ISBN']})\n")
                self.report_text.insert(tk.END, f"Days Overdue: {row['DaysOverdue']}\n")
                self.report_text.insert(tk.END, f"Fine: Rs. {row['CalculatedFine']}\n")
                self.report_text.insert(tk.END, "-" * 120 + "\n\n")
        else:
            self.report_text.insert(tk.END, "No overdue books found.\n")
    
    def show_fine_summary(self):
        """Show fine collection summary"""
        self.report_text.delete(1.0, tk.END)
        query = "SELECT * FROM vw_FineCollectionSummary WHERE TotalFines > 0"
        results = self.db.execute_query(query)
        
        self.report_text.insert(tk.END, "FINE COLLECTION SUMMARY\n")
        self.report_text.insert(tk.END, "=" * 120 + "\n\n")
        
        if results:
            for row in results:
                self.report_text.insert(tk.END, f"Member: {row['MemberName']} ({row['MembershipNumber']})\n")
                self.report_text.insert(tk.END, f"Email: {row['Email']}\n")
                self.report_text.insert(tk.END, f"Total Fines: {row['TotalFines']}\n")
                self.report_text.insert(tk.END, f"Paid: Rs. {row['PaidAmount']}\n")
                self.report_text.insert(tk.END, f"Unpaid: Rs. {row['UnpaidAmount']}\n")
                self.report_text.insert(tk.END, f"Last Fine Date: {row['LastFineDate']}\n")
                self.report_text.insert(tk.END, "-" * 120 + "\n\n")
        else:
            self.report_text.insert(tk.END, "No outstanding fines.\n")
    
    def show_availability(self):
        """Show book availability report"""
        self.report_text.delete(1.0, tk.END)
        query = "SELECT * FROM vw_BookAvailabilityReport"
        results = self.db.execute_query(query)
        
        self.report_text.insert(tk.END, "BOOK AVAILABILITY REPORT\n")
        self.report_text.insert(tk.END, "=" * 120 + "\n\n")
        
        if results:
            for row in results:
                self.report_text.insert(tk.END, f"Title: {row['Title']} (ISBN: {row['ISBN']})\n")
                self.report_text.insert(tk.END, f"Authors: {row['Authors']}\n")
                self.report_text.insert(tk.END, f"Category: {row['CategoryName']}\n")
                self.report_text.insert(tk.END, f"Available: {row['AvailableCopies']} / {row['TotalCopies']} ({row['BorrowingPercentage']}% borrowed)\n")
                self.report_text.insert(tk.END, f"Total Times Booked: {row['TotalTimesBooked']}\n")
                self.report_text.insert(tk.END, "-" * 120 + "\n\n")
    
    def show_member_activity(self):
        """Show member borrowing activity"""
        self.report_text.delete(1.0, tk.END)
        query = "SELECT * FROM vw_MemberBorrowingActivity WHERE CurrentBorrowedBooks > 0"
        results = self.db.execute_query(query)
        
        self.report_text.insert(tk.END, "MEMBER BORROWING ACTIVITY\n")
        self.report_text.insert(tk.END, "=" * 120 + "\n\n")
        
        if results:
            for row in results:
                self.report_text.insert(tk.END, f"Member: {row['MemberName']} ({row['MembershipNumber']})\n")
                self.report_text.insert(tk.END, f"Email: {row['Email']}\n")
                self.report_text.insert(tk.END, f"Status: {row['MemberStatus']}\n")
                self.report_text.insert(tk.END, f"Currently Borrowed: {row['CurrentBorrowedBooks']}\n")
                self.report_text.insert(tk.END, f"Overdue Books: {row['OverdueBooks']}\n")
                self.report_text.insert(tk.END, f"Unpaid Fines: Rs. {row['UnpaidFinesAmount']}\n")
                self.report_text.insert(tk.END, "-" * 120 + "\n\n")
        else:
            self.report_text.insert(tk.END, "No active borrowing records.\n")

if __name__ == "__main__":
    root = tk.Tk()
    app = LibraryManagementApp(root)
    root.mainloop()
    app.db.disconnect()
