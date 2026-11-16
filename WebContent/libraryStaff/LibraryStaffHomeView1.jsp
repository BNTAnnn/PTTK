<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.io.IOException,model.LibraryStaff1,web.Html,web.Controls.Submit" %>
<%
request.setCharacterEncoding("UTF-8");
final javax.servlet.http.HttpServletRequest input = request;
final javax.servlet.http.HttpServletResponse reply = response;
final javax.servlet.http.HttpSession state = session;
final javax.servlet.jsp.JspWriter html = out;
if (!Html.requireStaff(input, reply)) {
    return;
}
class LibraryStaffHomeView1 {
    private Submit btnLogout = new Submit("btnLogout", "Đăng xuất");
    private Submit btnLendDocuments = new Submit("btnLendDocuments", "Cho mượn tài liệu");
    private LibraryStaff1 staff = (LibraryStaff1) state.getAttribute("staff");
    private String loanUrl = "LoanFormView1.jsp";
    
    public void openLoanForm() throws IOException {
        synchronized (state) {
            if (state.getAttribute("savedSlip") != null
            && !Boolean.TRUE.equals(state.getAttribute("printPending"))) {
                state.removeAttribute("draft");
                state.removeAttribute("draftToken");
                state.removeAttribute("activeLoanCount");
                state.removeAttribute("savedSlip");
                state.removeAttribute("savedDraftToken");
            }
        }
        reply.sendRedirect(loanUrl);
    }
    
    public void render() throws IOException {
        Html.begin(html, "Trang chủ nhân viên thư viện", input.getContextPath());
        html.write("<p>" + Html.escape(staff.getFullName()) + "</p>");
        html.write(
            "<div class='staff-home-actions'>"
            + "<form method='get' action='LibraryStaffHomeView1.jsp'>"
            + "<button id='" + btnLendDocuments.name + "' type='submit' name='action' value='loan'>"
            + btnLendDocuments.label + "</button>"
            + "</form>"
        );
        Html.staffLogout(html, state, btnLogout);
        html.write("</div>");
        Html.end(html);
    }
}
LibraryStaffHomeView1 pageModel = new LibraryStaffHomeView1();
if ("loan".equals(Html.text(input, "action"))) {
    pageModel.openLoanForm();
} else {
    pageModel.render();
}
%>
