<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*,java.io.*,model.*,dao.*,web.Html,web.Controls.*" %>
<%
request.setCharacterEncoding("UTF-8");
final javax.servlet.http.HttpServletRequest input = request;
final javax.servlet.http.HttpServletResponse reply = response;
final javax.servlet.http.HttpSession state = session;
final javax.servlet.jsp.JspWriter html = out;
// A local Page object is created per request. No mutable JSP servlet instance fields.
class DocumentDetailView1 {
    private Submit btnClose = new Submit("btnClose", "Quay lại");
    private Table tblDocumentDetails = new Table("tblDocumentDetails");
    
    private Hidden hdnAction = new Hidden("action");
    private Hidden hdnDocumentCode = new Hidden("documentCode");
    private Document1 document;
    private int availableCount;
    private String outMessage = "";
    
    public void loadDocument(String documentCode) {
        
        try (DocumentDAO dao = new DocumentDAO()) {
            document = dao.getDocumentDetail(documentCode);
        }
        if (document == null) {
            outMessage = "Tài liệu không còn tồn tại";
            return;
        }
        
        try (DocumentCopyDAO dao = new DocumentCopyDAO()) {
            availableCount = dao.countAvailableByDocument(documentCode);
        }
    }
    
    public void close() throws IOException {
        reply.sendRedirect("DocumentSearchView1.jsp");
    }
    
    public void render() throws IOException {
        Html.beginWithBrand(html, "Chi tiết tài liệu", input.getContextPath());
        html.write("<div class='page-heading'><form method='get'>" + hdnAction.render("close") + hdnDocumentCode.render(document == null ? "" : document.getDocumentCode())
        + "<button type='submit' name='" + btnClose.name + "'>" + btnClose.label + "</button></form><h2>Chi tiết tài liệu</h2></div>");
        Html.message(html, outMessage);
        if (document != null) {
            html.write("<table id='" + tblDocumentDetails.name + "' class='document-detail'><tbody><tr><th scope='row'>Mã tài liệu</th><td>"
                + Html.escape(document.getDocumentCode()) + "</td></tr><tr><th scope='row'>Tên tài liệu</th><td>"
                + Html.escape(document.getTitle()) + "</td></tr><tr><th scope='row'>Tác giả</th><td>" + Html.escape(document.getAuthor())
                + "</td></tr><tr><th scope='row'>Thể loại</th><td>" + Html.escape(document.getDocumentType().getTypeName())
                + "</td></tr><tr><th scope='row'>Nhà xuất bản</th><td>" + Html.escape(document.getPublisher()) + "</td></tr><tr><th scope='row'>Năm xuất bản</th><td>"
                + document.getPublicationYear() + "</td></tr><tr><th scope='row'>Mô tả</th><td>" + Html.escape(document.getDescription())
                + "</td></tr><tr><th scope='row'>Vị trí kệ</th><td>" + Html.escape(document.getShelfLocation()) + "</td></tr><tr><th scope='row'>Số bản sao khả dụng</th><td>"
            + availableCount + "</td></tr></tbody></table>");
            if (availableCount == 0) html.write("<p>Hiện không có bản sao khả dụng.</p>");
        }
        Html.end(html);
    }
}

DocumentDetailView1 pageModel = new DocumentDetailView1();
if ("close".equals(Html.text(input, "action"))) {
    pageModel.close();
    return;
}
try {
    pageModel.loadDocument(Html.text(input, "documentCode"));
} catch (RuntimeException e) {
    application.log("Document detail failed", e);
    pageModel.outMessage = Html.userError(e);
}
pageModel.render();
%>
