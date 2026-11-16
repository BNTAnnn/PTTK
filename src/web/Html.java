package web;
import java.io.*;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;
import javax.servlet.http.*;
public final class Html {
    private Html(){}
    public static String escape(Object value){return value==null?"":value.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");}
    public static String url(String value){return URLEncoder.encode(value==null?"":value,StandardCharsets.UTF_8);}
    public static String hidden(String name,String value){return "<input type='hidden' name='"+escape(name)+"' value='"+escape(value)+"'>";}
    public static String csrf(HttpSession session){synchronized(session){String value=(String)session.getAttribute("csrfToken");if(value==null){value=UUID.randomUUID().toString();session.setAttribute("csrfToken",value);}return value;}}
    public static void checkCsrf(HttpServletRequest request){if(!"POST".equals(request.getMethod()) || !csrf(request.getSession()).equals(request.getParameter("csrfToken")))throw new IllegalArgumentException("Yêu cầu không hợp lệ. Vui lòng tải lại trang.");}
    public static String date(java.util.Date value){return value==null?"":new java.text.SimpleDateFormat("dd/MM/yyyy").format(value);}
    public static String text(HttpServletRequest request,String name){String value=request.getParameter(name);return value==null?"":value.trim();}
    public static void begin(Writer out,String title,String context) throws IOException {
        begin(out, title, context, false);
    }
    public static void beginWithBrand(Writer out,String title,String context) throws IOException {
        begin(out, title, context, true);
    }
    private static void begin(Writer out,String title,String context,boolean showBrandHeading) throws IOException {
        String base = escape(context);
        String brandLink = "<a href='"+base+"/'>LibMan</a>";
        out.write("<!doctype html><html lang='vi'><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1'><title>"+escape(title)+"</title><link rel='stylesheet' href='"+base+"/css/site.css?v=10'></head><body><main>");
        out.write(showBrandHeading ? "<h1 class='site-brand'>"+brandLink+"</h1>" : "<h1>"+escape(title)+"</h1>");
        out.write("<nav aria-label='Điều hướng chính'>");
        if (!showBrandHeading) out.write(brandLink);
        out.write("<a href='"+base+"/reader/ReaderHomeView1.jsp'>Trang chủ độc giả</a>"
                  + "<a href='"+base+"/libraryStaff/LibraryStaffHomeView1.jsp'>Trang chủ nhân viên thư viện</a></nav>");
    }
    public static boolean requireStaff(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setHeader("Cache-Control", "no-store");
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("staff") instanceof model.LibraryStaff1) return true;
        response.sendRedirect(request.getContextPath()+"/libraryStaff/LoginView.jsp");
        return false;
    }
    public static void staffLogout(Writer out, HttpSession session, Controls.Submit button) throws IOException {
        out.write("<form method='post' action='doDangXuatNV.jsp' class='inline'>"
                  + hidden("csrfToken", csrf(session)) + " <button type='submit' name='" + escape(button.name) + "'>" + escape(button.label) + "</button></form>");
    }
    public static void end(Writer out) throws IOException{out.write("</main></body></html>");}
    public static void message(Writer out,String message) throws IOException{if(message!=null && !message.isBlank())out.write("<p role='status'>"+escape(message)+"</p>");}
    public static String userError(RuntimeException e){return e instanceof IllegalArgumentException?e.getMessage():"Không xử lí được yêu cầu. Kiểm tra cấu hình hoặc liên hệ quản trị.";}
}
