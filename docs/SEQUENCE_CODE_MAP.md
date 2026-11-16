# Đối chiếu sequence và mã nguồn

Mốc Module 2 dưới đây theo bản sequence 68 bước cuối cùng người dùng cung cấp. Mốc Module 1 theo bản đã bỏ truy vấn loại riêng (28 bước, trước khi gộp hai câu đếm và trả số lượng). Mỗi hàm có chú thích Sequence tại đoạn tương ứng.

| Bước | File | Thứ tự xử lí |
|---|---|---|
| M1 1–3 | WebContent/reader/gdChinhDG.jsp | openSearch() chuyển trang; gdTimTaiLieu.jsp.render() |
| M1 4–11 | WebContent/reader/gdTimTaiLieu.jsp, src/dao/DocumentDAO.java | search(documentName) → searchByTitle(keyword) → new DocumentType1 → new Document1 → List<Document1> → render() |
| M1 12–19 | gdTimTaiLieu.jsp, gdChiTietTaiLieu.jsp, DocumentDAO.java | viewDetail(documentCode) → loadDocument(documentCode) → getDocumentDetail(documentCode) → đóng gói loại và tài liệu |
| M1 20–24 | gdChiTietTaiLieu.jsp, DocumentCopyDAO.java | countAvailableByDocument(documentCode) → int → render() |
| M1 25–28 | gdChiTietTaiLieu.jsp, gdTimTaiLieu.jsp | close() → danh sách được giữ trong session |
| M2 1–5 | WebContent/libraryStaff/gdChinhNV.jsp, gdChoMuon.jsp | openLoanForm(), hiển thị, quét thẻ |
| M2 6–14 | gdChoMuon.jsp, src/dao/ReaderCardDAO.java | identifyByCard(cardCode) → findReaderByCardCode(cardCode) → new ReaderCard1 → new Reader1 chứa card |
| M2 15–24 | gdChoMuon.jsp, LoanDetailDAO.java | countActiveByReader(readerCode) → card.isValid(at) → reader.checkBorrowEligibility(active, 0) → hiển thị độc giả |
| M2 25–34 | gdChoMuon.jsp, DocumentCopyDAO.java | scanCopy(barcode) → findByBarcode(barcode) → new DocumentCopy1 → new DocumentType1/Document1 → copy.setDocument(document) |
| M2 35–43 | gdChoMuon.jsp | copy.checkBorrowable() → draft.containsBarcode(barcode) → reader.checkBorrowEligibility(active, selected + 1) |
| M2 44–50 | gdChoMuon.jsp, src/model/LoanSlip1.java | addCopy(copy) → draft.addLoanDetail(copy) → new LoanDetail1 → details.add(detail) → hiển thị danh sách |
| M2 51–55 | gdChoMuon.jsp, doLuuMuon.jsp | confirm() → submit() → draft.isReadyToSave() |
| M2 56–60 | doLuuMuon.jsp, LoanSlipDAO.java | createLoanSlip(draft) → kiểm tra/lưu trong transaction → savedSlip → showResult() trả về form và thông báo |
| M2 61–68 | gdChoMuon.jsp, LoanSlipDAO.java | getForPrint(loanCode) → đóng gói LoanSlip1 cùng chi tiết → printLoan(slip) gửi yêu cầu in |

Không giả lập trao giấy giữa hai tác nhân bằng lời gọi Java. Trình duyệt không báo chắc chắn in giấy thành công, nên chỉ thông báo yêu cầu in đã được gửi. Phần gán/trả đối tượng trên sequence được hiện thực bằng constructor, setter, return; không tạo hàm giả tên “gọi”, “đóng gói”.

Các DAO helper trong createLoanSlip() là cài đặt nội bộ của bước 57: khóa Reader → Card → đếm lại active → khóa Copy theo barcode → insertLoanSlip → saveLoanDetails → markBorrowedIfAvailable → commit. Tất cả dùng cùng connection.

Nhánh nhập mã độc giả: ReaderDAO.searchByCode → ReaderCardDAO.findByReaderCode → cùng phần kiểm tra. Ô nhập được dùng chung; sau khi không tìm thấy mã thẻ thì thử mã độc giả. Cần bảo đảm mã thẻ và mã độc giả không gây nhập nhằng trong dữ liệu vận hành.

Nhánh Xóa: removeCopy(barcode) → LoanSlip1.removeLoanDetail(barcode), chỉ sửa nháp. Không gọi DAO xóa bản sao vật lý.

Một số bước thiết kế tổng hợp được tách thành helper riêng trong code và hiện trên sơ đồ lớp: checkReader, findCard, findCopy, findReader, init, hidden. Không đổi tên hoặc tham số của các phương thức nghiệp vụ đã có.
