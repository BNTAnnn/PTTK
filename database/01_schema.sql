-- Run using SQL Server tooling (SSMS or sqlcmd). No tables are dropped.
IF DB_ID(N'LibMan') IS NULL EXEC('CREATE DATABASE LibMan');
GO
USE LibMan;
GO
IF OBJECT_ID(N'tblMember1',N'U') IS NULL
CREATE TABLE tblMember1 (
  id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  fullName NVARCHAR(150) NOT NULL,
  dateOfBirth DATE NULL,
  address NVARCHAR(255) NOT NULL,
  email VARCHAR(150) NOT NULL,
  phone VARCHAR(20) NOT NULL
);
GO
IF OBJECT_ID(N'tblManagementStaff1',N'U') IS NULL
CREATE TABLE tblManagementStaff1 (
  id INT NOT NULL PRIMARY KEY REFERENCES tblMember1(id),
  managementStaffCode VARCHAR(30) NOT NULL UNIQUE,
  position NVARCHAR(100) NOT NULL
);
GO
IF OBJECT_ID(N'tblLibraryStaff1',N'U') IS NULL
CREATE TABLE tblLibraryStaff1 (
  id INT NOT NULL PRIMARY KEY REFERENCES tblMember1(id),
  libraryStaffCode VARCHAR(30) NOT NULL UNIQUE,
  position NVARCHAR(100) NOT NULL
);
GO
IF OBJECT_ID(N'tblReader1',N'U') IS NULL
CREATE TABLE tblReader1 (
  id INT NOT NULL PRIMARY KEY REFERENCES tblMember1(id),
  readerCode VARCHAR(30) NOT NULL UNIQUE,
  classUnit NVARCHAR(100) NOT NULL
);
GO
IF OBJECT_ID(N'tblSupplier1',N'U') IS NULL
CREATE TABLE tblSupplier1 (
  id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  supplierCode VARCHAR(30) NOT NULL UNIQUE,
  supplierName NVARCHAR(150) NOT NULL,
  address NVARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  description NVARCHAR(500) NOT NULL
);
GO
IF OBJECT_ID(N'tblReaderCard1',N'U') IS NULL
CREATE TABLE tblReaderCard1 (
  id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  cardCode VARCHAR(30) NOT NULL UNIQUE,
  issueDate DATE NOT NULL,
  expiryDate DATE NOT NULL,
  status VARCHAR(20) NOT NULL,
  readerId INT NOT NULL UNIQUE REFERENCES tblReader1(id)
);
GO
IF OBJECT_ID(N'tblDocumentType1',N'U') IS NULL
CREATE TABLE tblDocumentType1 (
  id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  typeCode VARCHAR(30) NOT NULL UNIQUE,
  typeName NVARCHAR(100) NOT NULL,
  description NVARCHAR(500) NOT NULL
);
GO
IF OBJECT_ID(N'tblDocument1',N'U') IS NULL
CREATE TABLE tblDocument1 (
  id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  documentCode VARCHAR(30) NOT NULL UNIQUE,
  title NVARCHAR(250) NOT NULL,
  author NVARCHAR(200) NOT NULL,
  publisher NVARCHAR(150) NOT NULL,
  publicationYear SMALLINT NOT NULL,
  description NVARCHAR(1000) NOT NULL,
  shelfLocation NVARCHAR(100) NOT NULL,
  documentTypeId INT NOT NULL REFERENCES tblDocumentType1(id),
  coverImage VARCHAR(500) NOT NULL
);
GO
IF OBJECT_ID(N'tblDocumentCopy1',N'U') IS NULL
CREATE TABLE tblDocumentCopy1 (
  id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  barcode VARCHAR(40) NOT NULL UNIQUE,
  loanStatus VARCHAR(30) NOT NULL,
  physicalCondition VARCHAR(30) NOT NULL,
  documentId INT NOT NULL REFERENCES tblDocument1(id)
);
GO
IF OBJECT_ID(N'tblLoanSlip1',N'U') IS NULL
CREATE TABLE tblLoanSlip1 (
  id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  loanCode VARCHAR(30) NOT NULL UNIQUE,
  loanDate DATE NOT NULL,
  dueDate DATE NOT NULL,
  readerId INT NOT NULL REFERENCES tblReader1(id),
  libraryStaffId INT NOT NULL REFERENCES tblLibraryStaff1(id),
  CHECK (dueDate >= loanDate)
);
GO
IF OBJECT_ID(N'tblLoanDetail1',N'U') IS NULL
CREATE TABLE tblLoanDetail1 (
  id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  loanSlipId INT NOT NULL REFERENCES tblLoanSlip1(id),
  documentCopyId INT NOT NULL REFERENCES tblDocumentCopy1(id),
  borrowedCondition NVARCHAR(100) NOT NULL,
  UNIQUE (loanSlipId, documentCopyId)
);
GO
IF OBJECT_ID(N'tblImportSlip1',N'U') IS NULL
CREATE TABLE tblImportSlip1 (
  id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  importCode VARCHAR(30) NOT NULL UNIQUE,
  importDate DATE NOT NULL,
  totalAmount DECIMAL(18,2) NOT NULL,
  supplierId INT NOT NULL REFERENCES tblSupplier1(id),
  libraryStaffId INT NOT NULL REFERENCES tblLibraryStaff1(id)
);
GO
IF OBJECT_ID(N'tblImportDetail1',N'U') IS NULL
CREATE TABLE tblImportDetail1 (
  id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  importSlipId INT NOT NULL REFERENCES tblImportSlip1(id),
  documentId INT NOT NULL REFERENCES tblDocument1(id),
  quantity INT NOT NULL,
  unitPrice DECIMAL(18,2) NOT NULL,
  UNIQUE (importSlipId, documentId),
  CHECK (quantity > 0),
  CHECK (unitPrice >= 0)
);
GO
IF OBJECT_ID(N'tblReturnSlip1',N'U') IS NULL
CREATE TABLE tblReturnSlip1 (
  id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  returnCode VARCHAR(30) NOT NULL UNIQUE,
  returnDate DATE NOT NULL,
  note NVARCHAR(500) NOT NULL,
  loanSlipId INT NOT NULL REFERENCES tblLoanSlip1(id),
  readerId INT NOT NULL REFERENCES tblReader1(id),
  libraryStaffId INT NOT NULL REFERENCES tblLibraryStaff1(id)
);
GO
IF OBJECT_ID(N'tblReturnDetail1',N'U') IS NULL
CREATE TABLE tblReturnDetail1 (
  id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  returnSlipId INT NOT NULL REFERENCES tblReturnSlip1(id),
  loanDetailId INT NOT NULL UNIQUE REFERENCES tblLoanDetail1(id),
  returnedCondition NVARCHAR(100) NOT NULL
);
GO

CREATE OR ALTER TRIGGER trReturnSlipConsistency ON tblReturnSlip1 AFTER INSERT,UPDATE AS
BEGIN
  SET NOCOUNT ON;
  IF EXISTS(SELECT 1 FROM inserted r JOIN tblLoanSlip1 l ON l.id=r.loanSlipId WHERE r.readerId<>l.readerId)
    THROW 50001, 'Return reader does not match loan reader.',1;
  IF EXISTS(SELECT 1 FROM inserted r JOIN tblReturnDetail1 rd ON rd.returnSlipId=r.id JOIN tblLoanDetail1 ld ON ld.id=rd.loanDetailId WHERE ld.loanSlipId<>r.loanSlipId)
    THROW 50002, 'Returned detail does not belong to loan.',1;
END;
GO
CREATE OR ALTER TRIGGER trReturnDetailConsistency ON tblReturnDetail1 AFTER INSERT,UPDATE AS
BEGIN
  SET NOCOUNT ON;
  IF EXISTS(SELECT 1 FROM inserted rd JOIN tblReturnSlip1 r ON r.id=rd.returnSlipId JOIN tblLoanDetail1 ld ON ld.id=rd.loanDetailId WHERE ld.loanSlipId<>r.loanSlipId)
    THROW 50003, 'Returned detail does not belong to loan.',1;
END;
GO
