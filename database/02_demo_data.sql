USE LibMan;
GO
-- Optional records and account for a local demo database.
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF NOT EXISTS(SELECT 1 FROM tblMember1 WHERE username='demo.staff')
BEGIN
 INSERT tblMember1(username,password,fullName,dateOfBirth,address,email,phone) VALUES('demo.staff','pbkdf2-sha256:4VznEclOA4orooZAplcRfw==:TK1vgjqH0VC/3u0KJntrgSq36TrEzVqD8sEMt4/Amuc=',N'Nhân viên thư viện',NULL,N'Thư viện','staff@example.invalid','000');
 INSERT tblLibraryStaff1(id,libraryStaffCode,position) VALUES(SCOPE_IDENTITY(),'NV001',N'Thủ thư');
END;
-- Enable the old demo account without overwriting a configured password.
UPDATE m SET password='pbkdf2-sha256:4VznEclOA4orooZAplcRfw==:TK1vgjqH0VC/3u0KJntrgSq36TrEzVqD8sEMt4/Amuc='
FROM tblMember1 m JOIN tblLibraryStaff1 s ON s.id=m.id
WHERE m.username='demo.staff' AND s.libraryStaffCode='NV001' AND m.password='DISABLED';

IF NOT EXISTS(SELECT 1 FROM tblMember1 WHERE username='demo.reader')
BEGIN
 INSERT tblMember1(username,password,fullName,dateOfBirth,address,email,phone) VALUES('demo.reader','DISABLED',N'Nguyễn Văn A','2005-01-01',N'Hà Nội','reader@example.invalid','000');
 DECLARE @readerId INT=SCOPE_IDENTITY();
 INSERT tblReader1(id,readerCode,classUnit) VALUES(@readerId,'DG001','D23');
 INSERT tblReaderCard1(cardCode,issueDate,expiryDate,status,readerId) VALUES('THE001','2025-01-01','2099-12-31','ACTIVE',@readerId);
END;
IF NOT EXISTS(SELECT 1 FROM tblMember1 WHERE username='demo.reader2')
BEGIN
 INSERT tblMember1(username,password,fullName,dateOfBirth,address,email,phone) VALUES('demo.reader2','DISABLED',N'Trần Thị Mai','2005-08-15',N'Hà Nội','reader2@example.invalid','000');
 DECLARE @reader2Id INT=SCOPE_IDENTITY();
 INSERT tblReader1(id,readerCode,classUnit) VALUES(@reader2Id,'DG002','D23');
 INSERT tblReaderCard1(cardCode,issueDate,expiryDate,status,readerId) VALUES('THE002','2025-01-01','2099-12-31','ACTIVE',@reader2Id);
END;
IF NOT EXISTS(SELECT 1 FROM tblDocumentType1 WHERE typeCode='GT') INSERT tblDocumentType1(typeCode,typeName,description) VALUES('GT',N'Giáo trình',N'Giáo trình học tập');
IF NOT EXISTS(SELECT 1 FROM tblDocument1 WHERE documentCode='DOC102')
 INSERT tblDocument1(documentCode,title,author,publisher,publicationYear,description,shelfLocation,documentTypeId,coverImage)
 SELECT 'DOC102',N'Phân tích Thiết kế Hệ thống',N'Nguyễn Văn A',N'NXB Giáo dục',2020,N'Tài liệu môn học',N'A1 - Tầng 3',id,'' FROM tblDocumentType1 WHERE typeCode='GT';
IF NOT EXISTS(SELECT 1 FROM tblDocument1 WHERE documentCode='DOC103')
 INSERT tblDocument1(documentCode,title,author,publisher,publicationYear,description,shelfLocation,documentTypeId,coverImage)
 SELECT 'DOC103',N'Công nghệ phần mềm',N'Nguyễn Văn B',N'NXB Giáo dục',2021,N'Tài liệu môn học',N'A2 - Tầng 3',id,'' FROM tblDocumentType1 WHERE typeCode='GT';
IF NOT EXISTS(SELECT 1 FROM tblDocumentCopy1 WHERE barcode='PTTK01-001')
 INSERT tblDocumentCopy1(barcode,loanStatus,physicalCondition,documentId) SELECT 'PTTK01-001','AVAILABLE','OLD',id FROM tblDocument1 WHERE documentCode='DOC102';
IF NOT EXISTS(SELECT 1 FROM tblDocumentCopy1 WHERE barcode='CNPM01-002')
 INSERT tblDocumentCopy1(barcode,loanStatus,physicalCondition,documentId) SELECT 'CNPM01-002','AVAILABLE','GOOD',id FROM tblDocument1 WHERE documentCode='DOC103';

INSERT tblDocumentType1(typeCode,typeName,description)
SELECT v.typeCode,v.typeName,v.description
FROM (VALUES
    ('TK',N'Sách tham khảo',N'Tài liệu tham khảo theo chuyên ngành'),
    ('HD',N'Sổ tay thực hành',N'Tài liệu hướng dẫn thực hành')
) v(typeCode,typeName,description)
WHERE NOT EXISTS (SELECT 1 FROM tblDocumentType1 t WHERE t.typeCode=v.typeCode);

INSERT tblDocument1(documentCode,title,author,publisher,publicationYear,description,shelfLocation,documentTypeId,coverImage)
SELECT v.documentCode,v.title,v.author,N'NXB Giáo dục',v.publicationYear,v.description,v.shelfLocation,t.id,''
FROM (VALUES
    ('DOC104',N'Cơ sở dữ liệu',N'Trần Minh Anh',2021,N'Mô hình quan hệ, SQL và giao dịch.',N'B1 - Tầng 2','GT'),
    ('DOC105',N'Thiết kế cơ sở dữ liệu',N'Phạm Hoàng Nam',2023,N'Mô hình hóa và chuẩn hóa dữ liệu.',N'B1 - Tầng 2','TK'),
    ('DOC106',N'Cấu trúc dữ liệu và giải thuật',N'Lê Hà Linh',2022,N'Danh sách, cây, đồ thị và thuật toán.',N'B1 - Tầng 2','GT'),
    ('DOC107',N'Lập trình Java cơ bản',N'Nguyễn Minh Châu',2024,N'Lập trình hướng đối tượng và xử lý ngoại lệ.',N'B1 - Tầng 2','GT'),
    ('DOC108',N'Lập trình Java Web',N'Đỗ Hồng Sơn',2023,N'Thực hành Servlet, JSP và JDBC.',N'B2 - Tầng 2','HD'),
    ('DOC109',N'Phân tích yêu cầu phần mềm',N'Vũ Thanh Bình',2021,N'Khảo sát, đặc tả và xác nhận yêu cầu.',N'B2 - Tầng 2','TK'),
    ('DOC110',N'Thiết kế hướng đối tượng với UML',N'Bùi Mai Hương',2022,N'Biểu đồ lớp, tuần tự và hoạt động.',N'B2 - Tầng 2','HD'),
    ('DOC111',N'Kiểm thử phần mềm',N'Phạm Hải Yến',2020,N'Các mức và kỹ thuật thiết kế ca kiểm thử.',N'B2 - Tầng 2','GT'),
    ('DOC112',N'Kiến trúc phần mềm',N'Trần Quốc Huy',2024,N'Các mẫu kiến trúc và tiêu chí chất lượng.',N'B3 - Tầng 2','TK'),
    ('DOC113',N'Nhập môn trí tuệ nhân tạo',N'Nguyễn Hà Phương',2023,N'Tìm kiếm, biểu diễn tri thức và suy luận.',N'B3 - Tầng 2','GT'),
    ('DOC114',N'Học máy ứng dụng',N'Lê Minh Khôi',2024,N'Xây dựng và đánh giá mô hình học máy.',N'B3 - Tầng 2','TK'),
    ('DOC115',N'Mạng máy tính',N'Hoàng Thị Thu',2022,N'Giao thức mạng và mô hình TCP/IP.',N'B3 - Tầng 2','GT'),
    ('DOC116',N'An toàn thông tin',N'Võ Tuấn Anh',2021,N'Kiểm soát truy cập và bảo mật dữ liệu.',N'B4 - Tầng 2','TK'),
    ('DOC117',N'Phát triển ứng dụng Web',N'Đặng Thùy Dương',2024,N'Thực hành HTML, CSS và ứng dụng phía máy chủ.',N'B4 - Tầng 2','HD'),
    ('DOC118',N'Hệ điều hành',N'Phan Hoàng Hà',2019,N'Tiến trình, luồng và bộ nhớ.',N'B4 - Tầng 2','GT'),
    ('DOC119',N'Quản lý dự án phần mềm',N'Đinh Đức Mạnh',2022,N'Lập kế hoạch, ước lượng và theo dõi tiến độ.',N'B4 - Tầng 2','TK')
) v(documentCode,title,author,publicationYear,description,shelfLocation,typeCode)
JOIN tblDocumentType1 t ON t.typeCode=v.typeCode
WHERE NOT EXISTS (SELECT 1 FROM tblDocument1 d WHERE d.documentCode=v.documentCode);

INSERT tblDocumentCopy1(barcode,loanStatus,physicalCondition,documentId)
SELECT v.barcode,v.loanStatus,v.physicalCondition,d.id
FROM (VALUES
    ('DOC102','PTTK01-002','AVAILABLE','GOOD'),
    ('DOC103','CNPM01-003','AVAILABLE','GOOD'),
    ('DOC104','CSDL01-003','AVAILABLE','DAMAGED'),
    ('DOC104','CSDL01-001','AVAILABLE','NEW'),
    ('DOC104','CSDL01-002','AVAILABLE','GOOD'),
    ('DOC105','TKCSDL01-001','AVAILABLE','NEW'),
    ('DOC105','TKCSDL01-002','AVAILABLE','GOOD'),
    ('DOC106','CTDL01-001','AVAILABLE','NEW'),
    ('DOC106','CTDL01-002','AVAILABLE','GOOD'),
    ('DOC107','JAVA01-001','AVAILABLE','NEW'),
    ('DOC107','JAVA01-002','AVAILABLE','GOOD'),
    ('DOC108','JWEB01-001','AVAILABLE','NEW'),
    ('DOC108','JWEB01-002','AVAILABLE','GOOD'),
    ('DOC109','PTYC01-001','AVAILABLE','NEW'),
    ('DOC109','PTYC01-002','AVAILABLE','GOOD'),
    ('DOC110','UML01-001','AVAILABLE','NEW'),
    ('DOC110','UML01-002','AVAILABLE','GOOD'),
    ('DOC111','KTPM01-001','AVAILABLE','NEW'),
    ('DOC111','KTPM01-002','AVAILABLE','GOOD'),
    ('DOC112','KTPHANMEM01-001','AVAILABLE','NEW'),
    ('DOC112','KTPHANMEM01-002','AVAILABLE','GOOD'),
    ('DOC113','AI01-001','AVAILABLE','NEW'),
    ('DOC113','AI01-002','AVAILABLE','GOOD'),
    ('DOC114','ML01-001','AVAILABLE','NEW'),
    ('DOC114','ML01-002','AVAILABLE','GOOD'),
    ('DOC115','MMT01-001','AVAILABLE','NEW'),
    ('DOC115','MMT01-002','AVAILABLE','GOOD'),
    ('DOC116','ATTT01-001','AVAILABLE','NEW'),
    ('DOC116','ATTT01-002','AVAILABLE','GOOD'),
    ('DOC117','WEB01-001','AVAILABLE','NEW'),
    ('DOC117','WEB01-002','AVAILABLE','GOOD'),
    ('DOC118','HDH01-001','AVAILABLE','NEW'),
    ('DOC118','HDH01-002','AVAILABLE','GOOD'),
    ('DOC119','QLDA01-001','AVAILABLE','NEW'),
    ('DOC119','QLDA01-002','AVAILABLE','GOOD')
) v(documentCode,barcode,loanStatus,physicalCondition)
JOIN tblDocument1 d ON d.documentCode=v.documentCode
WHERE NOT EXISTS (SELECT 1 FROM tblDocumentCopy1 c WHERE c.barcode=v.barcode);

COMMIT TRANSACTION;
GO
