<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,java.io.*,model.*,dao.*,web.Html,web.Controls.*" %>
<%
request.setCharacterEncoding("UTF-8");
final javax.servlet.http.HttpServletRequest input = request;
final javax.servlet.http.HttpServletResponse reply = response;
final javax.servlet.http.HttpSession state = session;
final javax.servlet.jsp.JspWriter html = out;

class ReaderHomeView1 {
    private Link lnkSearchDocument = new Link("lnkSearchDocument", "Tra cứu tài liệu");
    private String searchUrl = "DocumentSearchView1.jsp";
    
    public void openSearch() throws IOException {
        reply.sendRedirect(searchUrl);
    }
    
    public void render() throws IOException {
        Html.begin(html, "LibMan", input.getContextPath());
        html.write("<a id='" + lnkSearchDocument.name + "' href='?action=search'>" + lnkSearchDocument.label + "</a>");
        Html.end(html);
    }
}

ReaderHomeView1 pageModel = new ReaderHomeView1();
if ("search".equals(input.getParameter("action"))) pageModel.openSearch();
else pageModel.render();
%>
