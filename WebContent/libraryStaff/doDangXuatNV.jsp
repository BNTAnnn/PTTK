<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="false" import="web.Html" %>
<%
response.setHeader("Cache-Control", "no-store");
if (!"POST".equals(request.getMethod())) {
    response.setHeader("Allow", "POST");
    response.sendError(405);
    return;
}
try {
    Html.checkCsrf(request);
    request.getSession(false).invalidate();
    response.sendRedirect("LoginView.jsp?loggedOut=1");
} catch (IllegalArgumentException e) {
    response.sendError(403, e.getMessage());
}
%>
