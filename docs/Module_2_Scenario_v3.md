# Kịch bản chi tiết Module 2 — Lend Documents 1 (ver 3.0)

Nhân viên thư viện đã đăng nhập. Tên trang theo sơ đồ thiết kế. Trong mã JSP hiện tại, ba tệp tương ứng là `gdChinhNV.jsp`, `gdChoMuon.jsp` và `doLuuMuon.jsp`.

## Luồng chính theo sequence 77 bước

1. Tại `LibraryStaffHomeView1.jsp`, nhân viên chọn **Cho mượn tài liệu**.
2. Trang `LibraryStaffHomeView1.jsp` thực hiện `openLoanForm()`.
3. Trang `LibraryStaffHomeView1.jsp` chuyển đến `LoanFormView1.jsp`.
4. Trang `LoanFormView1.jsp` hiển thị giao diện lập phiếu mượn.
5. Độc giả đưa thẻ thư viện và tài liệu cần mượn cho nhân viên.
6. Nhân viên quét mã thẻ và gửi yêu cầu **Tìm độc giả**.
7. Trang `LoanFormView1.jsp` thực hiện `identifyByCard(cardCode)`.
8. Trang `LoanFormView1.jsp` gọi `ReaderCardDAO` để xác định độc giả theo mã thẻ.
9. Lớp `ReaderCardDAO` thực hiện `findReaderByCardCode(cardCode)`.
10. Hàm `findReaderByCardCode()` truy vấn dữ liệu và yêu cầu tạo đối tượng `ReaderCard1`.
11. Constructor `ReaderCard1(...)` khởi tạo thông tin thẻ.
12. Đối tượng `ReaderCard1` được trả về cho `ReaderCardDAO`.
13. Hàm `findReaderByCardCode()` yêu cầu tạo đối tượng `Reader1` kèm thông tin thẻ.
14. Constructor `Reader1(...)` khởi tạo thông tin độc giả.
15. Đối tượng `Reader1` được trả về cho `ReaderCardDAO`.
16. Lớp `ReaderCardDAO` trả độc giả kèm thẻ về `LoanFormView1.jsp`.
17. Trang `LoanFormView1.jsp` thực hiện `checkReader()`.
18. Trang `LoanFormView1.jsp` gọi `LoanDetailDAO` để đếm số bản sao đang mượn chưa trả.
19. Lớp `LoanDetailDAO` thực hiện `countActiveByReader(readerCode)`.
20. Lớp `LoanDetailDAO` trả số bản sao đang mượn về `LoanFormView1.jsp`.
21. Trang `LoanFormView1.jsp` yêu cầu `ReaderCard1` kiểm tra thẻ.
22. Đối tượng `ReaderCard1` thực hiện `isValid(at)`.
23. Đối tượng `ReaderCard1` trả kết quả kiểm tra thẻ về `LoanFormView1.jsp`.
24. Trang `LoanFormView1.jsp` yêu cầu `Reader1` kiểm tra điều kiện mượn.
25. Đối tượng `Reader1` thực hiện `checkBorrowEligibility(active, 0)`.
26. Đối tượng `Reader1` trả kết quả kiểm tra về `LoanFormView1.jsp`.
27. Trang `LoanFormView1.jsp` hiển thị thông tin độc giả và số bản sao đang mượn.
28. Nhân viên quét hoặc nhập barcode bản sao rồi chọn **Thêm vào danh sách**.
29. Trang `LoanFormView1.jsp` thực hiện `scanCopy(barcode)`.
30. Trang `LoanFormView1.jsp` gọi `DocumentCopyDAO` tìm bản sao.
31. Lớp `DocumentCopyDAO` thực hiện `findByBarcode(barcode)`.
32. Hàm `findByBarcode()` truy vấn dữ liệu và yêu cầu tạo `DocumentCopy1`.
33. Constructor `DocumentCopy1(...)` khởi tạo thông tin bản sao.
34. Đối tượng `DocumentCopy1` được trả về cho `DocumentCopyDAO`.
35. Hàm `findByBarcode()` yêu cầu tạo `Document1` tương ứng.
36. Constructor `Document1(...)` khởi tạo thông tin đầu tài liệu, kèm loại tài liệu.
37. Đối tượng `Document1` được trả về cho `DocumentCopyDAO` và gắn vào bản sao.
38. Lớp `DocumentCopyDAO` trả `DocumentCopy1` về `LoanFormView1.jsp`.
39. Trang `LoanFormView1.jsp` thực hiện `addCopy(copy)`.
40. Trang `LoanFormView1.jsp` yêu cầu `DocumentCopy1` kiểm tra khả năng cho mượn.
41. Đối tượng `DocumentCopy1` thực hiện `checkBorrowable()`.
42. Đối tượng `DocumentCopy1` trả kết quả kiểm tra về `LoanFormView1.jsp`.
43. Trang `LoanFormView1.jsp` yêu cầu `LoanSlip1` kiểm tra barcode trùng trong nháp.
44. Đối tượng `LoanSlip1` thực hiện `containsBarcode(barcode)`.
45. Đối tượng `LoanSlip1` trả kết quả kiểm tra trùng.
46. Trang `LoanFormView1.jsp` yêu cầu `Reader1` kiểm tra giới hạn nếu thêm bản sao.
47. Đối tượng `Reader1` thực hiện `checkBorrowEligibility(active, selected + 1)`.
48. Đối tượng `Reader1` trả kết quả kiểm tra giới hạn mượn.
49. Trang `LoanFormView1.jsp` yêu cầu `LoanSlip1` thêm bản sao hợp lệ vào nháp.
50. Đối tượng `LoanSlip1` thực hiện `addLoanDetail(copy)`.
51. Đối tượng `LoanSlip1` yêu cầu tạo dòng `LoanDetail1` cho bản sao vừa chọn.
52. Constructor `LoanDetail1(copy, borrowedCondition)` ghi nhận bản sao và tình trạng khi mượn.
53. Dòng `LoanDetail1` được trả về cho `LoanSlip1` và đưa vào danh sách nháp.
54. Đối tượng `LoanSlip1` trả kết quả thêm bản sao về `LoanFormView1.jsp`.
55. Trang `LoanFormView1.jsp` hiển thị danh sách mượn đã cập nhật. Nhân viên có thể lặp lại bước 28–55 cho bản sao tiếp theo.
56. Nhân viên bấm **Xác nhận**.
57. Trang `LoanFormView1.jsp` thực hiện `confirm()`.
58. Trang `LoanFormView1.jsp` chuyển yêu cầu lưu đến `doSaveLoan.jsp`.
59. Trang `doSaveLoan.jsp` thực hiện `submit()` và chuẩn bị phiếu nháp.
60. Trang `doSaveLoan.jsp` yêu cầu `LoanSlip1` kiểm tra dữ liệu nháp.
61. Đối tượng `LoanSlip1` thực hiện `isReadyToSave()`.
62. Đối tượng `LoanSlip1` trả kết quả kiểm tra về `doSaveLoan.jsp`.
63. Trang `doSaveLoan.jsp` gọi `LoanSlipDAO` để ghi nhận phiếu mượn.
64. Lớp `LoanSlipDAO` thực hiện `createLoanSlip(draft)`, kiểm tra lại dữ liệu, lưu phiếu, lưu chi tiết qua `LoanDetailDAO` và cập nhật bản sao qua `DocumentCopyDAO` trong cùng giao dịch.
65. Sau khi commit thành công, `LoanSlipDAO` trả phiếu đã lưu về `doSaveLoan.jsp`.
66. Trang `doSaveLoan.jsp` thực hiện `showResult()`.
67. Trang `doSaveLoan.jsp` chuyển về `LoanFormView1.jsp`.
68. Trang `LoanFormView1.jsp` hiển thị thông báo **Lưu phiếu mượn thành công**.
69. Trang `LoanFormView1.jsp` gọi `LoanSlipDAO` lấy dữ liệu phiếu để in.
70. Lớp `LoanSlipDAO` thực hiện `getForPrint(loanCode)`.
71. Hàm `getForPrint()` truy vấn và yêu cầu tạo đối tượng `LoanSlip1` từ dữ liệu đã lưu.
72. Constructor `LoanSlip1(...)` khởi tạo thông tin phiếu phục vụ in.
73. Đối tượng `LoanSlip1` được trả về cho `LoanSlipDAO`.
74. Lớp `LoanSlipDAO` trả phiếu về `LoanFormView1.jsp`.
75. Trang `LoanFormView1.jsp` thực hiện `printLoan(slip)`.
76. Trang `LoanFormView1.jsp` hiển thị phiếu đã lưu và tự mở hộp thoại in của trình duyệt.
77. Sau khi xác nhận in và nhận bản in, nhân viên giao phiếu, thẻ và tài liệu cho độc giả.

## Luồng thay thế và ngoại lệ

- **Nhập mã độc giả ở bước 6–16.** Nếu mã nhập không khớp thẻ, trang gọi `searchReader(readerCode)`, sử dụng `ReaderDAO.searchByCode(readerCode)` rồi lấy thẻ bằng `ReaderCardDAO.findByReaderCode(readerCode)`. Nếu tìm được độc giả, tiếp tục ở bước 17. Nếu không tìm được hoặc không đủ điều kiện, trang báo lý do để nhân viên nhập lại.
- **Bản sao không hợp lệ ở bước 28–54.** Trang thông báo lý do và giữ danh sách nháp. Nhân viên có thể thử barcode khác.
- **Xóa khỏi danh sách sau bước 55.** Trang gọi `removeCopy(barcode)` rồi `LoanSlip1.removeLoanDetail(barcode)` và hiển thị danh sách đã cập nhật.
- **Nháp không hợp lệ hoặc lưu lỗi ở bước 59–65.** Trang báo lỗi và quay về danh sách. DAO hoàn tác giao dịch nếu đã bắt đầu.
- **Lỗi đọc dữ liệu in hoặc nhân viên đóng hộp thoại in ở bước 69–76.** Phiếu đã lưu vẫn có hiệu lực. Nếu không đọc được dữ liệu in, trang hiển thị thông báo lỗi.
- Sau khi hoàn tất lượt mượn, nhân viên quay về trang chủ và chọn lại **Cho mượn tài liệu** để mở lượt mới.
