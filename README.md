# Library Management System - Database Project

## Project Overview

A comprehensive Library Management System built with SQL Server 2019, featuring:
- Complete EERD with entities for Members, Books, Authors, Categories, Borrowing, and Fines
- Full relational schema with integrity constraints
- Advanced SQL queries with joins, aggregations, subqueries, views, and triggers
- Python GUI application for CRUD operations (Bonus)

---

## Setup Instructions

### Database Setup

1. Open SQL Server Management Studio (SSMS)
2. Execute scripts in order:
   - 1_CreateDatabase.sql
   - 2_CreateTables.sql
   - 3_CreateViews.sql
   - 4_CreateTriggers.sql
   - 5_InsertSampleData.sql

3. Verify: `SELECT name FROM sys.databases WHERE name = 'LibraryManagementDB'`

### GUI Application (Bonus)

```bash
pip install -r requirements.txt
python app.py
```

---

## Database Entities

- **Members** - Library users
- **Books** - Physical inventory
- **Authors** - Book creators
- **Categories** - Classifications
- **Borrowing** - Loan transactions
- **Fines** - Overdue penalties



