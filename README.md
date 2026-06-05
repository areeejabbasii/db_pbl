# Library Management System - Database Project

**Course:** CS160 Database Systems  
**Semester:** 2  
**Batch:** CS25-C / SE25  
**Instructor:** Ms. Saima Yasmeen  
**Student Name:** [Your Name]  
**Roll #:** [Your Roll Number]  
**Total Marks:** 8 (+2 Bonus)  
**Deadline:** 15-06-2026

---

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

---

## Evaluation Areas

- EERD & Conceptual Modeling (30%)
- SQL Layout Implementation (30%)
- Query & Scripting Complexity (30%)
- Git Hygiene & Report Format (10%)
- Application Layer Bonus (+2 Marks)

