<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,java.io.*,model.*,dao.*,web.Html,web.Controls.*" %>
<%
request.setCharacterEncoding("UTF-8");
final javax.servlet.http.HttpServletRequest input = request;
final javax.servlet.http.HttpServletResponse reply = response;
final javax.servlet.http.HttpSession state = session;
final javax.servlet.jsp.JspWriter html = out;
// A local Page object is created per request. No mutable JSP servlet instance fields.
if (!Html.requireStaff(input, reply)) return;
class LoanFormView1 {
    private Submit btnLogout = new Submit("btnLogout", "Đăng xuất");
    private Text txtReaderIdentifier = new Text("txtReaderIdentifier");
    private Submit btnSearchReader = new Submit("btnSearchReader", "Tìm độc giả");
    private Text txtBarcode = new Text("txtBarcode");
    private Submit btnAddCopy = new Submit("btnAddCopy", "Thêm vào danh sách");
    private Panel pnlReaderInfo = new Panel("pnlReaderInfo");
    private Table tblLoanReceipt = new Table("tblLoanReceipt");
    private Table tblLoanDocuments = new Table("tblLoanDocuments");
    private Submit btnRemoveCopy = new Submit("btnRemoveCopy", "Xóa");
    private Submit btnConfirm = new Submit("btnConfirm", "Xác nhận");
    
    private Hidden hdnAction = new Hidden("action");
    private Hidden hdnBarcode = new Hidden("barcode");
    private Hidden hdnDraftToken = new Hidden("draftToken");
    private Hidden hdnCsrfToken = new Hidden("csrfToken");
    private String inCardCode = "", inReaderCode = "", inBarcode = "";
    private Reader1 reader;
    private LoanSlip1 draft;
    private int activeLoanCount;
    private String outMessage = "";
    private String scanMessage = "";
    private boolean ready;
    private LoanSlip1 savedSlip;

    LoanFormView1() {
        draft = (LoanSlip1) state.getAttribute("draft");
        if (draft == null) {
            draft = new LoanSlip1();
            draft.setStaff((LibraryStaff1) state.getAttribute("staff"));
            state.setAttribute("draft", draft);
            state.setAttribute("draftToken", UUID.randomUUID().toString());
        }
        reader = draft.getReader();
        Object count = state.getAttribute("activeLoanCount");
        activeLoanCount = count instanceof Integer ? (Integer) count : 0;
        ready = reader != null && reader.checkBorrowEligibility(activeLoanCount, draft.getDetails().size());
        savedSlip = (LoanSlip1) state.getAttribute("savedSlip");
        if (savedSlip == null && reader != null && !ready) outMessage = borrowerIssue();
    }

    public void identifyByCard(String cardCode) {
        inCardCode = cardCode;

        try (ReaderCardDAO dao = new ReaderCardDAO()) {
            reader = dao.findReaderByCardCode(cardCode);
        }
        if (reader == null) {
            outMessage = "Không tìm thấy thẻ. Có thể nhập mã độc giả để tìm.";
            ready = false;
            return;
        }
        checkReader();
    }
    
    public void searchReader(String readerCode) {
        inReaderCode = readerCode;
        try (ReaderDAO dao = new ReaderDAO()) {
            reader = dao.searchByCode(readerCode);
        }
        if (reader == null) {
            outMessage = "Không tìm thấy độc giả";
            ready = false;
            return;
        }
        outMessage = "";
        try (ReaderCardDAO dao = new ReaderCardDAO()) {
            reader.setCard(dao.findByReaderCode(readerCode));
        }
        checkReader();
    }
    
    private void checkReader() {
        // Sequence M2 15-24: count, card validity, reader eligibility, then display.
        try (LoanDetailDAO dao = new LoanDetailDAO()) {
            activeLoanCount = dao.countActiveByReader(reader.getReaderCode());
        }
        boolean valid = reader.getCard() != null && reader.getCard().isValid(new Date());
        ready = valid && reader.checkBorrowEligibility(activeLoanCount, 0);
        replaceDraft();
        if (!ready) outMessage = borrowerIssue();
    }
    
    private void replaceDraft() {
        draft = new LoanSlip1();
        draft.setReader(reader);
        draft.setStaff((LibraryStaff1) state.getAttribute("staff"));
        state.setAttribute("draft", draft);
        state.setAttribute("activeLoanCount", activeLoanCount);
        state.setAttribute("draftToken", UUID.randomUUID().toString());
    }
    
    private String borrowerIssue() {
        if (reader == null) return "Cần xác định độc giả trước khi quét bản sao.";
        if (reader.getCard() == null) return "Độc giả chưa có thẻ thư viện.";
        if (!reader.getCard().isValid(new Date())) return "Thẻ độc giả hết hạn hoặc không hoạt động.";
        return "Đã đạt giới hạn 5 cuốn đang mượn và chọn mới.";
    }
    
    public void scanCopy(String barcode) {
        inBarcode = barcode;
        if (!ready) throw new IllegalArgumentException(borrowerIssue());
        if (barcode.isBlank()) throw new IllegalArgumentException("Vui lòng nhập hoặc quét barcode của bản sao.");
        // Sequence M2 26-34: DAO packages copy, document and type.
        DocumentCopy1 copy;
        try (DocumentCopyDAO dao = new DocumentCopyDAO()) {
            copy = dao.findByBarcode(barcode);
        }
        if (copy == null) throw new IllegalArgumentException("Không tìm thấy barcode " + barcode + ". Hãy dùng mã trên bản sao vật lý.");
        if (!addCopy(copy)) throw new IllegalArgumentException("Không thêm được bản sao " + barcode + " vào danh sách mượn.");
        inBarcode = "";
    }
    
    public boolean addCopy(DocumentCopy1 copy) {
        // Sequence M2 35-49: preserve this order for comparison with the diagram.
        if (!copy.checkBorrowable()) {
            if ("BORROWED".equals(copy.getLoanStatus())) throw new IllegalArgumentException("Bản sao " + copy.getBarcode()
            + " đang được mượn.");
            if (!"AVAILABLE".equals(copy.getLoanStatus())) throw new IllegalArgumentException("Bản sao " + copy.getBarcode()
            + " chưa sẵn sàng cho mượn. Trạng thái: " + copy.getLoanStatus() + ".");
            throw new IllegalArgumentException("Bản sao " + copy.getBarcode() + " không đủ điều kiện về tình trạng vật lý: "
            + copy.getPhysicalCondition() + ".");
        }
        if (draft.containsBarcode(copy.getBarcode())) throw new IllegalArgumentException("Bản sao " + copy.getBarcode()
        + " đã có trong danh sách.");
        if (!reader.checkBorrowEligibility(activeLoanCount, draft.getDetails().size() + 1)) throw new IllegalArgumentException(borrowerIssue());
        return draft.addLoanDetail(copy);
    }
    
    public void removeCopy(String barcode) {
        draft.removeLoanDetail(barcode);
    }
    
    public void confirm() throws IOException {
        if (!ready) throw new IllegalArgumentException("Độc giả không đủ điều kiện.");
        // Sequence M2 51-52: retain server-side draft; forward POST to processing JSP.
        try {
            input.getRequestDispatcher("doSaveLoan.jsp").forward(input, reply);
        } catch (javax.servlet.ServletException e) {
            throw new IOException(e);
        }
    }
    
    public void printLoan(LoanSlip1 slip) throws IOException {
        // Called after getForPrint() returned: preserve the sequence order.
        savedSlip = slip;
        html.write("<section id='loan-slip'><h2>Phiếu mượn tài liệu</h2><p>Mã phiếu: " + Html.escape(savedSlip.getLoanCode())
            + " | Độc giả: " + Html.escape(savedSlip.getReader().getFullName()) + " (" + Html.escape(savedSlip.getReader().getReaderCode())
            + ") | Nhân viên: " + Html.escape(savedSlip.getStaff().getLibraryStaffCode()) + "</p><p>Ngày mượn: "
            + Html.date(savedSlip.getLoanDate()) + " | Hạn trả: " + Html.date(savedSlip.getDueDate()) + "</p><table id='"
        + tblLoanReceipt.name + "'><tr><th class='number'>TT</th><th>Mã bản sao</th><th>Tên tài liệu</th><th>Tình trạng khi mượn</th></tr>");
        int i = 0;
        for (LoanDetail1 d : savedSlip.getDetails()) html.write("<tr><td class='number'>" + (++i) + "</td><td>"
            + Html.escape(d.getCopy().getBarcode()) + "</td><td>" + Html.escape(d.getCopy().getDocument().getTitle())
        + "</td><td>" + Html.escape(d.getBorrowedCondition()) + "</td></tr>");
        html.write("</table></section>");
        // Browser printing requests a print dialog; JavaScript cannot prove paper was printed.
        html.write("<script>document.body.classList.add('printing');window.addEventListener('load',function(){window.print();});</script>");
    }
    public void reset() {
        state.removeAttribute("draft");
        state.removeAttribute("draftToken");
        state.removeAttribute("activeLoanCount");
        state.removeAttribute("savedSlip");
        state.removeAttribute("savedDraftToken");
        state.removeAttribute("printPending");
    }
    private String hidden(String action) {
        return hdnAction.render(action) + hdnCsrfToken.render(Html.csrf(state)) + hdnDraftToken.render(String.valueOf(state.getAttribute("draftToken")));
    }
    public void render() throws IOException {
        Html.beginWithBrand(html, "Lập phiếu mượn tài liệu", input.getContextPath());
        html.write("<div class='page-heading loan-page-heading'><h2>Lập phiếu mượn tài liệu</h2>");
        Html.staffLogout(html, state, btnLogout);
        html.write("</div>");
        Html.message(html, outMessage);
        if (savedSlip != null) {
            html.write("<p>Lưu phiếu mượn thành công. Dữ liệu đã được cập nhật.</p>");
            boolean pending = Boolean.TRUE.equals(state.getAttribute("printPending"));
            if (pending) {
                try {
                    // Sequence M2 61-66: first retrieve/package, then print.
                    LoanSlip1 printSlip;
                    try (LoanSlipDAO dao = new LoanSlipDAO()) {
                        printSlip = dao.getForPrint(savedSlip.getLoanCode());
                    }
                    if (printSlip == null) throw new IllegalArgumentException("Không đọc được phiếu đã lưu.");
                    printLoan(printSlip);
                    state.setAttribute("printPending", false);
                } catch (RuntimeException e) {
                    Html.message(html, "Phiếu đã lưu, chưa lấy được dữ liệu in. Thông tin phiếu được giữ lại.");
                    Html.end(html);
                    return;
                }
            } else html.write("<p>Phiếu đã lưu: " + Html.escape(savedSlip.getLoanCode()) + ". Hệ thống đã gửi yêu cầu in tới trình duyệt.</p>");
            html.write("<p>Quay về trang chủ nhân viên để bắt đầu lượt mượn tiếp theo.</p>");
            Html.end(html);
            return;
        }
        html.write(
            "<h2>1. Xác định độc giả</h2>"
            + "<div class='loan-reader-lookup'><form method='post'>"
            + hidden("reader")
            + "<label>Quét thẻ / Mã độc giả <input type='text' name='" + txtReaderIdentifier.name
            + "' required></label>"
            + "<button type='submit' name='" + btnSearchReader.name + "'>" + btnSearchReader.label + "</button>"
            + "</form>"
            + "<div id='" + pnlReaderInfo.name + "' class='loan-reader-info'><strong>Thông tin độc giả</strong>"
        );
        if (reader != null) {
            html.write(
                "<p>" + Html.escape(reader.getFullName()) + " (" + Html.escape(reader.getReaderCode()) + ")"
                + " | Lớp/đơn vị: " + Html.escape(reader.getClassUnit())
                + " | Thẻ: " + Html.escape(reader.getCard() == null ? "Không có" : reader.getCard().getStatus())
                + " | Đang mượn: " + activeLoanCount + " cuốn</p>"
            );
        }
        html.write("</div></div>");
        html.write("<h2>2. Quét / nhập mã tài liệu</h2><form method='post'>" + hidden("add") + "<label>Mã bản sao <input type='text' name='"
            + txtBarcode.name + "' value='" + Html.escape(inBarcode) + "' aria-describedby='scan-message' required "
            + (!ready ? "disabled" : "autofocus onfocus='this.select()'") + "></label> <button type='submit' name='"
        + btnAddCopy.name + "' " + (!ready ? "disabled" : "") + ">" + btnAddCopy.label + "</button></form>");
        html.write("<div id='scan-message' class='scan-message'>");
        Html.message(html, scanMessage);
        html.write("</div><div class='table-scroll'><table id='" + tblLoanDocuments.name + "'><tr><th class='number'>TT</th><th>Mã bản sao</th><th>Tên tài liệu</th><th>Tác giả</th><th>Trạng thái</th><th>Tình trạng vật lý</th><th>Thao tác</th></tr>");
        int i = 0;
        for (LoanDetail1 d : draft.getDetails()) html.write("<tr><td class='number'>" + (++i) + "</td><td>" + Html.escape(d.getCopy().getBarcode())
            + "</td><td>" + Html.escape(d.getCopy().getDocument().getTitle()) + "</td><td>" + Html.escape(d.getCopy().getDocument().getAuthor())
            + "</td><td>" + Html.escape(d.getCopy().getLoanStatus()) + "</td><td>" + Html.escape(d.getCopy().getPhysicalCondition())
            + "</td><td><form class='inline' method='post'>" + hidden("remove") + hdnBarcode.render(d.getCopy().getBarcode())
        + "<button type='submit' name='" + btnRemoveCopy.name + "'>" + btnRemoveCopy.label + "</button></form></td></tr>");
        html.write("</table></div><p>Kiểm tra trùng barcode, tình trạng bản sao và tổng số đang mượn + chọn mới không vượt 5.</p><form method='post' class='actions'>"
            + hidden("confirm") + "<button type='submit' name='" + btnConfirm.name + "' " + (!ready || draft.getDetails().isEmpty() ? "disabled" : "")
        + ">" + btnConfirm.label + "</button></form>");
        Html.end(html);
    }
}
synchronized (state) {
    LoanFormView1 pageModel = new LoanFormView1();
    Object flash = state.getAttribute("flash");
    if (flash != null) {
        pageModel.outMessage = flash.toString();
        state.removeAttribute("flash");
    }
    try {
        if ("POST".equals(input.getMethod())) {
            Html.checkCsrf(input);
            String action = Html.text(input, "action");
            if ("new".equals(action)) {
                pageModel.reset();
                reply.sendRedirect("LoanFormView1.jsp");
                return;
            }
            if (!Objects.equals(state.getAttribute("draftToken"), input.getParameter("draftToken"))) throw new IllegalArgumentException("Danh sách đã thay đổi. Hãy tải lại trang.");
            if (pageModel.savedSlip != null) throw new IllegalArgumentException("Phiếu đã được lưu; không gửi giao dịch lần nữa.");
            if ("reader".equals(action)) {
                String identifier = Html.text(input, "txtReaderIdentifier");
                if (identifier.isBlank()) throw new IllegalArgumentException("Vui lòng nhập mã thẻ hoặc mã độc giả.");
                pageModel.identifyByCard(identifier);
                if (pageModel.reader == null) pageModel.searchReader(identifier);
                if (pageModel.reader == null && pageModel.draft.getReader() != null) {
                    pageModel.reader = pageModel.draft.getReader();
                    pageModel.ready = pageModel.reader.checkBorrowEligibility(pageModel.activeLoanCount, pageModel.draft.getDetails().size());
                    pageModel.outMessage += ". Danh sách hiện tại vẫn thuộc độc giả " + pageModel.reader.getReaderCode() + ".";
                }
            } else if ("add".equals(action)) pageModel.scanCopy(Html.text(input, "txtBarcode"));
            else if ("remove".equals(action)) pageModel.removeCopy(Html.text(input, "barcode"));
            else if ("confirm".equals(action)) {
                pageModel.confirm();
                return;
            }
            else throw new IllegalArgumentException("Thao tác không hợp lệ.");
        }
    } catch (RuntimeException e) {
        if (!(e instanceof IllegalArgumentException)) application.log("Loan form failed", e);
        if ("add".equals(Html.text(input, "action"))) pageModel.scanMessage = Html.userError(e);
        else pageModel.outMessage = Html.userError(e);
    }
    pageModel.render();
}
%>
