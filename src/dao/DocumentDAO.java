package dao;
import model.*;
import java.sql.*;
import java.util.*;

public class DocumentDAO extends DAO {
    public DocumentDAO() { super(); }
    public DocumentDAO(Connection con) { super(con); }
    private static final String SELECT = "SELECT d.*, t.typeCode, t.typeName, t.description AS typeDescription, t.id AS typeId FROM tblDocument1 d JOIN tblDocumentType1 t ON t.id=d.documentTypeId ";
    
    public List<Document1> searchByTitle(String keyword) {
        List<Document1> result = new ArrayList<>();
        if(keyword == null || keyword.trim().isEmpty()) return result;
        String sql = SELECT + "WHERE CHARINDEX(?, d.title COLLATE Latin1_General_100_CI_AI) > 0 ORDER BY d.title,d.documentCode";
        try(PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setNString(1, keyword.trim());
            try(ResultSet rs = ps.executeQuery()) {
                while(rs.next()) {
                    // Sequence M1 7-10: package type inside each Document1; no separate getDocumentType query.
                    DocumentType1 type = new DocumentType1(rs.getString("typeCode"),rs.getString("typeName"),rs.getString("typeDescription"));
                    type.setId(rs.getInt("typeId"));
                    Document1 document = new Document1(rs.getString("documentCode"),rs.getString("title"),rs.getString("author"),rs.getString("publisher"),rs.getInt("publicationYear"),rs.getString("description"),rs.getString("shelfLocation"),rs.getString("coverImage"),type);
                    document.setId(rs.getInt("id")); result.add(document);
                }
            } return result;
        } catch(SQLException e) { throw failure(e); }
    }
    
    public Document1 getDocumentDetail(String documentCode) {
        try(PreparedStatement ps = con.prepareStatement(SELECT + "WHERE d.documentCode=?")) {
            ps.setString(1,documentCode);
            try(ResultSet rs = ps.executeQuery()) {
                if(!rs.next()) return null;
                // Sequence M1 16-19: explicit object packaging, as in Chapter 5.
                DocumentType1 type = new DocumentType1(rs.getString("typeCode"),rs.getString("typeName"),rs.getString("typeDescription"));
                type.setId(rs.getInt("typeId"));
                Document1 document = new Document1(rs.getString("documentCode"),rs.getString("title"),rs.getString("author"),rs.getString("publisher"),rs.getInt("publicationYear"),rs.getString("description"),rs.getString("shelfLocation"),rs.getString("coverImage"),type);
                document.setId(rs.getInt("id")); return document;
            }
        } catch(SQLException e) { throw failure(e); }
    }
}
