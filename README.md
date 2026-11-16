# LibMan theo Chương 5

Ứng dụng triển khai hai module đã thiết kế: tra cứu tài liệu công khai và thủ thư cho mượn tài liệu. Giao diện dùng HTML/JSP đơn giản, chữ căn trái và dữ liệu số căn phải. Mã định danh/barcode là chuỗi nên căn trái.

## Tổ chức thư mục

```text
LibMan/
  src/model/                 Các lớp thực thể có hậu tố 1
  src/dao/                   DAO chung và các DAO chuyên biệt
  src/web/                   Hàm HTML và kiểu điều khiển giao diện
  WebContent/
    reader/                  ReaderHomeView1.jsp, DocumentSearchView1.jsp, DocumentDetailView1.jsp
    libraryStaff/            LoginView.jsp, LibraryStaffHomeView1.jsp, LoanFormView1.jsp, doSaveLoan.jsp, doDangXuatNV.jsp
    css/site.css
    WEB-INF/web.xml
  database/                  Cấu trúc SQL Server và dữ liệu mẫu tùy chọn
  docs/                      Đối chiếu sequence, UML và code
  pom.xml
```

Trong Eclipse, `src` xuất hiện dưới Java Resources; `WebContent` chứa các trang JSP, tương ứng mục 5.1 của giáo trình. Maven đóng gói JDBC driver vào `WEB-INF/lib` trong WAR. Không dùng framework giao diện.

## Môi trường và cách chạy

1. Cài JDK 17 trở lên, Maven và Tomcat 9 (Servlet 4.0 / JSP 2.3, namespace `javax`). Không đổi trực tiếp sang Tomcat 10+ vì namespace khác.
2. Trong SSMS hoặc sqlcmd chạy `database/01_schema.sql`. Script tạo database LibMan nếu chưa có, không xóa bảng. Nếu đã có database cũ, cần đối chiếu cấu trúc trước; script không tự di trú bảng cũ.
3. Có thể chạy `database/02_demo_data.sql` để tạo dữ liệu mẫu.
4. Đặt biến môi trường cho tiến trình Tomcat:

```powershell
$env:LIBMAN_DB_URL='jdbc:sqlserver://localhost:1433;databaseName=LibMan;encrypt=true;trustServerCertificate=true'
$env:LIBMAN_DB_USER='tai_khoan_sql_cua_ban'
$env:LIBMAN_DB_PASSWORD='mat_khau_sql_cua_ban'
$env:LIBMAN_LOAN_DAYS='SO_NGAY_THEO_CHINH_SACH_THU_VIEN'
```

`LIBMAN_LOAN_DAYS` phải là số nguyên dương. Không đặt mặc định số ngày mượn vì đề chưa quy định. `trustServerCertificate=true` trong ví dụ chỉ dành cho máy phát triển dùng chứng chỉ tự ký.

5. Tại thư mục LibMan chạy `mvn package -DskipTests`, chép `target/LibMan.war` vào `webapps` của Tomcat rồi khởi động Tomcat từ môi trường đã cấu hình. Mở `http://localhost:8080/LibMan/`.
6. Module tra cứu không yêu cầu đăng nhập. Nhân viên đăng nhập trước khi vào trang chủ. Module cho mượn nhận đối tượng `LibraryStaff1` đã xác thực từ `session.getAttribute("staff")`, đúng tiền điều kiện của bài. Không nhận mã nhân viên từ hidden input.

## Dữ liệu và tài khoản demo

Chạy lại `database/02_demo_data.sql` trên CSDL demo để bổ sung các đầu tài liệu và bản sao còn thiếu. Script giữ trạng thái của những barcode đã có và kích hoạt tài khoản `demo.staff` nếu mật khẩu mẫu cũ còn là `DISABLED`.

- Đăng nhập bằng tài khoản mẫu `demo.staff` và mật khẩu `LibManDemo#2026`. Dùng bộ dữ liệu này cho môi trường demo.
- Tra cứu bằng một phần tên, ví dụ `phần mềm`, `phan mem` hoặc `Java`.
- Cho mượn với mã thẻ `THE001` hoặc mã độc giả `DG001`. Thử barcode `PTTK01-001`, `CNPM01-002` hoặc `CSDL01-001`. Barcode `CSDL01-003` dùng để kiểm tra thông báo bản sao hư hỏng.
- Tên đăng nhập tra từ `tblMember1` và phải có bản ghi tương ứng trong `tblLibraryStaff1`. Cột mật khẩu lưu chuỗi `pbkdf2-sha256:<salt-base64>:<hash-base64>` với 600.000 vòng và hash 32 byte.

## Các lựa chọn cài đặt cần đối chiếu

- Tên DAO, Entity, phương thức và tham số giữ theo sơ đồ đã chốt. Các constructor, getter/setter bổ sung và thuộc tính ẩn được ghi trong hai sơ đồ lớp đã đồng bộ ở thư mục output của dự án cha.
- Các phương thức thiết kế của JSP được cài trong một lớp cục bộ `Page` bên trong chính trang JSP. Mỗi request có một đối tượng Page riêng, không lưu dữ liệu người dùng vào trường dùng chung của servlet JSP. Đây vẫn là xử lí trực tiếp trong JSP, không thêm tầng Service/Controller.
- Text/Submit/Link/Table/Hidden là các kiểu mô tả điều khiển HTML của sơ đồ sách; lớp nhỏ `web.Controls` biểu diễn chúng trong code. Tên HTML `action`, `documentCode`, `barcode`, `draftToken`, `csrfToken` được khai báo tường minh bằng Hidden.
- Model dùng trường private, đầy đủ getter/setter. Lớp gốc pha thiết kế có id; lớp con kế thừa id từ Member1. BigDecimal dùng cho tiền ở model; SQL dùng DECIMAL.
- DAO đóng gói đối tượng lồng nhau rõ ràng như ví dụ Kihoc/Namhoc trong sách. `Document1` đã chứa `DocumentType1`; không có truy vấn `DocumentDAO.getDocumentType()` riêng.
- Một connection cho cả transaction mượn. Reader được khóa trước khi đếm lại số đang mượn; các bản sao được khóa theo barcode. Thành công mới commit, lỗi thì rollback.
- Session giữ nháp, phiếu đã lưu và token chống gửi lặp. Hidden input chỉ truyền định danh/thao tác/token, không truyền số lượng đang mượn hay giá trị trạng thái tin cậy.
- In phiếu tự động bằng `window.print()` sau commit, không có nút In/In lại. Trình duyệt có thể yêu cầu xác nhận hộp thoại in; code không khẳng định máy in đã in giấy thành công. Phiếu đã lưu được giữ khi có lỗi, không tạo lại giao dịch. Mở chức năng Cho mượn tài liệu từ trang chủ để bắt đầu lượt tiếp theo sau khi đã gửi yêu cầu in.
- Bộ nguồn có đủ 15 model của thiết kế toàn hệ thống; DAO/JSP triển khai hai module được yêu cầu. Không triển khai thêm nghiệp vụ nhập/trả/đăng ký thẻ.

Nguồn tương thích: [Tomcat 9 và Java EE](https://tomcat.apache.org/whichversion), [Microsoft JDBC driver](https://learn.microsoft.com/en-us/sql/connect/jdbc/system-requirements-for-the-jdbc-driver).
