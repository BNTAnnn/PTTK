package dao;
import java.sql.*;

/** Chapter 5 DAO structure; one connection per request/transaction, never static. */
public abstract class DAO implements AutoCloseable {
    protected Connection con;
    protected boolean ownsConnection;
    protected DAO() {
        try {
            String url = System.getenv("LIBMAN_DB_URL");
            if(url == null || url.isBlank()) throw new IllegalStateException("Chưa cấu hình LIBMAN_DB_URL.");
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            con = DriverManager.getConnection(url, System.getenv("LIBMAN_DB_USER"), System.getenv("LIBMAN_DB_PASSWORD"));
            ownsConnection = true;
        } catch (SQLException | ClassNotFoundException e) { throw new IllegalStateException("Không thể kết nối CSDL LibMan.", e); }
    }
    protected DAO(Connection con) { this.con = java.util.Objects.requireNonNull(con); this.ownsConnection = false; }
    protected void beginTransaction() { try { if(!con.getAutoCommit()) throw new IllegalStateException("Connection đã có transaction."); con.setAutoCommit(false); } catch(SQLException e) { throw failure(e); } }
    protected void commit() { try { con.commit(); } catch(SQLException e) { throw failure(e); } }
    protected void rollback() { try { con.rollback(); } catch(SQLException e) { throw failure(e); } }
    public void close() { if(ownsConnection) try { con.close(); } catch(SQLException e) { throw failure(e); } }
    protected IllegalStateException failure(SQLException e) { return new IllegalStateException("Lỗi truy cập dữ liệu.", e); }
}
