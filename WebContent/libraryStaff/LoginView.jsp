<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="dao.LibraryStaffDAO,model.LibraryStaff1,web.Html,web.Controls.Text,web.Controls.Submit,web.Controls.Hidden" %>
<%
request.setCharacterEncoding("UTF-8");
response.setHeader("Cache-Control", "no-store");
if (session.getAttribute("staff") instanceof LibraryStaff1) {
    response.sendRedirect("LibraryStaffHomeView1.jsp");
    return;
}

class LoginView {
    private Text txtUsername = new Text("username");
    private Text txtPassword = new Text("password");
    private Submit btnLogin = new Submit("btnLogin", "Đăng nhập");
    private Hidden hdnCsrfToken = new Hidden("csrfToken");
    private String username = "";
    private String outMessage = "";
}

LoginView pageModel = new LoginView();
if ("1".equals(request.getParameter("loggedOut"))) {
    pageModel.outMessage = "Bạn đã đăng xuất.";
}
if ("POST".equals(request.getMethod())) {
    pageModel.username = Html.text(request, pageModel.txtUsername.name);
    String password = request.getParameter(pageModel.txtPassword.name);
    try {
        Html.checkCsrf(request);
        if (pageModel.username.isBlank() || pageModel.username.length() > 50 || password == null || password.isEmpty() || password.length() > 255) {
            throw new IllegalArgumentException("Vui lòng nhập tên đăng nhập và mật khẩu hợp lệ.");
        }
        LibraryStaff1 staff;
        try (LibraryStaffDAO dao = new LibraryStaffDAO()) {
            staff = dao.authenticate(pageModel.username, password);
        }
        if (staff == null) {
            pageModel.outMessage = "Tên đăng nhập hoặc mật khẩu không đúng.";
        } else {
            session.invalidate();
            request.getSession(true).setAttribute("staff", staff);
            response.sendRedirect("LibraryStaffHomeView1.jsp");
            return;
        }
    } catch (RuntimeException e) {
        if (!(e instanceof IllegalArgumentException)) application.log("Staff login failed", e);
        pageModel.outMessage = Html.userError(e);
    }
}
Html.begin(out, "Đăng nhập nhân viên thư viện", request.getContextPath());
Html.message(out, pageModel.outMessage);
%>
<form class="staff-login-form" method="post" action="LoginView.jsp">
    <%= pageModel.hdnCsrfToken.render(Html.csrf(session)) %>

    <label for="staff-username">Tên đăng nhập</label>
    <input id="staff-username" type="text" name="<%= pageModel.txtUsername.name %>" autocomplete="username"
           maxlength="50" required value="<%= Html.escape(pageModel.username) %>">

    <label for="staff-password">Mật khẩu</label>
    <input id="staff-password" type="password" name="<%= pageModel.txtPassword.name %>" autocomplete="current-password"
           maxlength="255" required>

    <button type="submit" name="<%= pageModel.btnLogin.name %>"><%= pageModel.btnLogin.label %></button>
</form>
<% Html.end(out); %>
