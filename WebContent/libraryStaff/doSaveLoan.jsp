<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,java.io.*,model.*,dao.*,web.Html,web.Controls.*" %>
<%
request.setCharacterEncoding("UTF-8");
final javax.servlet.http.HttpServletRequest input = request;
final javax.servlet.http.HttpServletResponse reply = response;
final javax.servlet.http.HttpSession state = session;
final javax.servlet.jsp.JspWriter html = out;
// A local Page object is created per request. No mutable JSP servlet instance fields.
if (!Html.requireStaff(input, reply)) return;
class SaveLoan {
    private LoanSlip1 draft;
    private LoanSlip1 savedSlip;
    private String outMessage = "";
    private Hidden hdnDraftToken = new Hidden("draftToken");
    private Hidden hdnCsrfToken = new Hidden("csrfToken");
    
    public void submit() {
        Html.checkCsrf(input);
        String token = input.getParameter(hdnDraftToken.name);
        // Duplicate POST with the same token returns the previous result, not another INSERT.
        if (token != null && token.equals(state.getAttribute("savedDraftToken"))) {
            savedSlip = (LoanSlip1) state.getAttribute("savedSlip");
            return;
        }
        if (!Objects.equals(token, state.getAttribute("draftToken"))) throw new IllegalArgumentException("Nháp không còn hợp lệ.");
        LoanSlip1 source = (LoanSlip1) state.getAttribute("draft");
        if (source == null) throw new IllegalArgumentException("Không có danh sách mượn.");
        // A server-side snapshot. Reader/staff/contents are never trusted from hidden input.
        List<LoanDetail1> details = new ArrayList<>();
        for (LoanDetail1 d : source.getDetails()) details.add(new LoanDetail1(d.getCopy(), d.getBorrowedCondition()));
        draft = new LoanSlip1(null, null, null, source.getReader(), (LibraryStaff1) state.getAttribute("staff"), details);
        // Sequence M2 53-55, then 56-58: validate first, one DAO save operation.
        if (!draft.isReadyToSave()) throw new IllegalArgumentException("Danh sách mượn không hợp lệ.");
        try (LoanSlipDAO dao = new LoanSlipDAO()) {
            savedSlip = dao.createLoanSlip(draft);
        }
        state.setAttribute("savedSlip", savedSlip);
        state.setAttribute("savedDraftToken", token);
        state.setAttribute("printPending", true);
        outMessage = "Lưu phiếu mượn thành công";
    }
    
    public void showResult() throws IOException {
        state.setAttribute("flash", outMessage);
        reply.sendRedirect("LoanFormView1.jsp");
    }
}
if (!"POST".equals(input.getMethod())) {
    reply.sendError(405);
    return;
}
synchronized (state) {
    SaveLoan pageModel = new SaveLoan();
    try {
        pageModel.submit();
    } catch (RuntimeException e) {
        application.log("Save loan failed", e);
        pageModel.outMessage = Html.userError(e);
    }
    pageModel.showResult();
}
%>
