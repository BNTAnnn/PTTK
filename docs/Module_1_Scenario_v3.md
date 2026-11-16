### Kịch bản chi tiết Module 1 — Search Public Document 1 (ver 3.0)

1. Tại giao diện chính `gdChinhDG.jsp`, Reader1 click chọn chức năng **Tra cứu tài liệu**. Chức năng không yêu cầu đăng nhập.
2. Trang `gdChinhDG.jsp` gọi trang `gdTimTaiLieu.jsp`.
3. Trang `gdTimTaiLieu.jsp` hiển thị giao diện tìm kiếm cho Reader1.
4. Reader1 nhập tên tài liệu và click **Tìm kiếm**.
5. Trang `gdTimTaiLieu.jsp` gọi lớp `DocumentDAO` yêu cầu tìm danh sách tài liệu có tên chứa từ khóa.
6. Lớp `DocumentDAO` gọi hàm `searchByTitle(keyword)`.
7. Hàm `searchByTitle()` thực hiện truy vấn và gọi lớp `Document1` để đóng gói thông tin tài liệu kèm loại tài liệu tương ứng.
8. Lớp `Document1` đóng gói thông tin thực thể, gồm thuộc tính `documentType` có kiểu `DocumentType1`.
9. Lớp `Document1` trả kết quả về cho hàm `searchByTitle()`.
10. Hàm `searchByTitle()` trả danh sách `List<Document1>` về trang `gdTimTaiLieu.jsp`.
11. Trang `gdTimTaiLieu.jsp` hiển thị danh sách tài liệu cho Reader1.
12. Reader1 chọn một tài liệu và click **Xem chi tiết**.
13. Trang `gdTimTaiLieu.jsp` gọi trang `gdChiTietTaiLieu.jsp`, truyền mã tài liệu được chọn.
14. Trang `gdChiTietTaiLieu.jsp` gọi lớp `DocumentDAO` yêu cầu lấy thông tin chi tiết tài liệu.
15. Lớp `DocumentDAO` gọi hàm `getDocumentDetail(documentCode)`.
16. Hàm `getDocumentDetail()` thực hiện truy vấn và gọi lớp `Document1` để đóng gói thông tin tài liệu kèm loại tài liệu tương ứng.
17. Lớp `Document1` đóng gói thông tin thực thể, gồm thuộc tính `documentType` có kiểu `DocumentType1`.
18. Lớp `Document1` trả kết quả về cho hàm `getDocumentDetail()`.
19. Hàm `getDocumentDetail()` trả kết quả về trang `gdChiTietTaiLieu.jsp`.
20. Trang `gdChiTietTaiLieu.jsp` gọi lớp `DocumentCopyDAO` yêu cầu đếm số bản sao khả dụng của tài liệu.
21. Lớp `DocumentCopyDAO` gọi hàm `countAvailableByDocument(documentCode)`.
22. Hàm `countAvailableByDocument()` truy vấn CSDL và đếm số bản sao đáp ứng điều kiện cho mượn.
23. Hàm `countAvailableByDocument()` trả số lượng bản sao khả dụng về trang `gdChiTietTaiLieu.jsp`.
24. Trang `gdChiTietTaiLieu.jsp` hiển thị popup chi tiết tài liệu và số lượng bản sao khả dụng cho Reader1; tên loại được đọc từ `document.documentType`.
25. Reader1 xem thông tin và click **Quay lại**.
26. Trang `gdChiTietTaiLieu.jsp` thực hiện `close()` để đóng popup và trở về trang `gdTimTaiLieu.jsp`.
27. Trang `gdTimTaiLieu.jsp` hiển thị lại danh sách kết quả tìm kiếm.
28. Reader1 có thể lặp lại các bước 12–27 để xem tài liệu khác hoặc kết thúc lượt tra cứu.
