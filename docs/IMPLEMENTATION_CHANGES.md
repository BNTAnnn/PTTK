# Đồng bộ từ thiết kế sang cài đặt

- Bổ sung id cho các model gốc của pha thiết kế và getter/setter tương ứng; các lớp Reader1, LibraryStaff1, ManagementStaff1 kế thừa id. Không thay đổi sơ đồ pha phân tích.
- Dùng cùng một định nghĩa Document1 cho hai module, bao gồm documentType; bổ sung DocumentType1 vào sơ đồ chi tiết Module 2 để phản ánh kiểu thực tế dùng khi đóng gói đối tượng.
- Giữ constructor có tham số đã thiết kế; bổ sung constructor rỗng/getter/setter để đóng gói dữ liệu JDBC theo cách trong Chương 5.
- Hai sơ đồ chi tiết liệt kê đầy đủ phương thức hiện thực của lớp dùng chung, kể cả phương thức được module kia sử dụng. Vì vậy DocumentCopyDAO trong sơ đồ Module 1 có cả các thao tác cho mượn; đó là cùng một lớp Java, không phải thêm nghiệp vụ cho luồng tra cứu.
- Thêm trường Hidden cho action, documentCode, barcode, draftToken, csrfToken theo từng JSP. Các giá trị quan trọng của giao dịch lấy từ server/session và kiểm tra lại trong transaction.
- Bổ sung liên kết gdChoMuon.jsp–LoanSlipDAO để khớp getForPrint(loanCode).
- BigDecimal thay decimal cho tiền trong model Java; SQL vẫn DECIMAL(18,2).
- Phương thức thiết kế trong mỗi JSP được cài trong đối tượng Page cục bộ theo request. Không dùng biến mutable chung của servlet để chứa dữ liệu độc giả/phiếu.
- Không thêm nút In hoặc In lại. printLoan() được gọi sau getForPrint(), sau khi giao dịch lưu đã commit. window.print() chỉ gửi yêu cầu in tới trình duyệt; hệ thống không đoán kết quả in giấy.
- Giao diện là HTML đơn giản theo form đã có; chi tiết tài liệu mở thành trang có nút Quay lại, phù hợp wireframe. Từ “popup” trong mô tả cũ cần hiểu là phần chi tiết; nếu cần đúng popup JS thì phải thống nhất lại giao diện/kịch bản, không thay đổi nghiệp vụ.
