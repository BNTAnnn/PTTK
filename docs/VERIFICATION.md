# Kiểm tra bản mã nguồn

Ngày kiểm tra: 06/11/2026, Asia/Bangkok.

- Maven biên dịch Java và đóng gói `LibMan.war`: thành công.
- Tomcat Jasper 9.0.123 biên dịch toàn bộ JSP: `Generation completed with [0] errors`. JSP dùng cú pháp tương thích Java 11; các lớp Java của ứng dụng biên dịch với release 17.
- Hai sơ đồ lớp được đồng bộ tên thuộc tính, mức truy cập, phương thức và tên/kiểu tham số từ mã Java/JSP, render lại PNG/SVG và mở kiểm tra.
- Đã giữ các tham số nghiệp vụ: keyword/documentCode/cardCode/readerCode/barcode/draft/slip/loanCode; giữ các đối tượng đóng gói lồng nhau, không trả các map thô thay cho Entity.
- Các trường HTML Hidden được hiện thực và thể hiện trong hai sơ đồ lớp.
- CSS mặc định căn trái, các ô số thứ tự/năm xuất bản/số lượng dùng class number căn phải. Barcode/mã định danh vẫn căn trái.

Chưa thực thi script SQL và giao dịch trên SQL Server thật vì chưa có cấu hình kết nối/tài khoản CSDL cho dự án. Chưa xác nhận in giấy trên máy in vật lý. Đây là giới hạn kiểm tra, không phải xác nhận rằng toàn bộ ứng dụng đã được kiểm thử đầu cuối.

Để kiểm tra sau cấu hình: chạy schema và seed, thử tra cứu có/không có kết quả, xem chi tiết hết bản sao, tìm độc giả bằng thẻ/mã, thêm/xóa, trùng barcode, vượt 5 cuốn, xác nhận và kiểm tra phiếu/chi tiết/trạng thái; thử gửi lại cùng POST để bảo đảm không tạo thêm phiếu.
