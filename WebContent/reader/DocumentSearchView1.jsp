<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.io.IOException,java.util.ArrayList,java.util.List,model.Document1,dao.DocumentDAO,web.Html,web.Controls.*" %>
<%
request.setCharacterEncoding("UTF-8");
final javax.servlet.http.HttpServletRequest input = request;
final javax.servlet.http.HttpServletResponse reply = response;
final javax.servlet.http.HttpSession state = session;
final javax.servlet.jsp.JspWriter html = out;
// Each request has its own Page object.
class DocumentSearchView1 {
    private Text txtDocumentName = new Text("txtDocumentName");
    private Submit btnSearch = new Submit("btnSearch", "Tìm kiếm");
    private Submit btnBack = new Submit("btnBack", "Quay lại");
    private Table tblDocumentResults = new Table("tblDocumentResults");
    private Submit btnViewDetail = new Submit("btnViewDetail", "Xem chi tiết");
    
    private Hidden hdnAction = new Hidden("action");
    private Hidden hdnDocumentCode = new Hidden("documentCode");
    private String inDocumentName = "";
    private List<Document1> outDocumentList = new ArrayList<>();
    private String outMessage = "";
    
    public void search(String documentName) {
        inDocumentName = documentName == null ? "" : documentName.trim();
        if (inDocumentName.isEmpty()) {
            outMessage = "Vui lòng nhập từ khóa để tìm kiếm";
            return;
        }
        // The DAO returns Document1 objects with their document types.
        try (DocumentDAO dao = new DocumentDAO()) {
            outDocumentList = dao.searchByTitle(inDocumentName);
        }
        state.setAttribute("searchKeyword", inDocumentName);
        state.setAttribute("searchResults", outDocumentList);
        if (outDocumentList.isEmpty()) {
            outMessage = "Không tìm thấy tài liệu phù hợp";
        }
    }

    public void viewDetail(String documentCode) throws IOException {
        reply.sendRedirect("DocumentDetailView1.jsp?documentCode=" + Html.url(documentCode));
    }

    public void render() throws IOException {
        Html.beginWithBrand(html, "Tra cứu tài liệu", input.getContextPath());
        html.write(
            "<div class='page-heading'>"
            + "<form method='get' action='ReaderHomeView1.jsp'>"
            + "<button name='" + btnBack.name + "' type='submit'>" + btnBack.label + "</button>"
            + "</form>"
            + "<h2>Tra cứu tài liệu</h2>"
            + "</div>"
        );
        html.write(
            "<form method='get' class='search-form'>"
            + hdnAction.render("search")
            + "<label>Từ khóa trong tên tài liệu :"
            + "<input type='text' name='" + txtDocumentName.name
            + "' value='" + Html.escape(inDocumentName) + "'></label>"
            + "<button name='" + btnSearch.name + "' type='submit'>" + btnSearch.label + "</button>"
            + "</form>"
        );
        Html.message(html, outMessage);
        html.write(
            "<div class='table-scroll'><table id='" + tblDocumentResults.name + "'>"
            + "<thead><tr>"
            + "<th class='number'>TT</th><th>Mã tài liệu</th><th>Tên tài liệu</th>"
            + "<th>Tác giả</th><th>Thể loại</th><th>Thao tác</th>"
            + "</tr></thead><tbody>"
        );
        int rowNumber = 0;
        for (Document1 document : outDocumentList) {
            html.write(
                "<tr><td class='number'>" + (++rowNumber) + "</td>"
                + "<td>" + Html.escape(document.getDocumentCode()) + "</td>"
                + "<td>" + Html.escape(document.getTitle()) + "</td>"
                + "<td>" + Html.escape(document.getAuthor()) + "</td>"
                + "<td>" + Html.escape(document.getDocumentType().getTypeName()) + "</td>"
                + "<td><form class='inline' method='get'>"
                + hdnAction.render("detail")
                + hdnDocumentCode.render(document.getDocumentCode())
                + "<button type='submit' name='" + btnViewDetail.name + "'>"
                + btnViewDetail.label + "</button></form></td></tr>"
            );
        }
        html.write("</tbody></table></div>");
        Html.end(html);
    }
}

DocumentSearchView1 pageModel = new DocumentSearchView1();
try {
    String action = Html.text(input, "action");
    if ("detail".equals(action)) {
        pageModel.viewDetail(Html.text(input, "documentCode"));
        return;
    }
    if ("search".equals(action)) {
        pageModel.search(Html.text(input, "txtDocumentName"));
    } else {
        Object cached = state.getAttribute("searchResults");
        if (cached instanceof List< ? >) {
            pageModel.outDocumentList = (List<Document1>) cached;
        }
        Object keyword = state.getAttribute("searchKeyword");
        if (keyword != null) {
            pageModel.inDocumentName = keyword.toString();
        }
    }
} catch (RuntimeException e) {
    application.log("Document search failed", e);
    pageModel.outMessage = Html.userError(e);
}
pageModel.render();
%>
