package dao;
import model.*;
import java.sql.*;
public class DocumentCopyDAO extends DAO {
    public DocumentCopyDAO(){super();}
    public DocumentCopyDAO(Connection con){super(con);}
    
    public DocumentCopy1 findByBarcode(String barcode){return findCopy(barcode,false);}
    
    public DocumentCopy1 findByBarcodeForUpdate(String barcode){return findCopy(barcode,true);}
    
    private DocumentCopy1 findCopy(String barcode,boolean lock){
        String sql="SELECT c.id AS copyId,c.barcode,c.loanStatus,c.physicalCondition,d.*,t.id AS typeId,t.typeCode,t.typeName,t.description AS typeDescription FROM tblDocumentCopy1 c"+(lock?" WITH (UPDLOCK,HOLDLOCK)":"")+" JOIN tblDocument1 d ON d.id=c.documentId JOIN tblDocumentType1 t ON t.id=d.documentTypeId WHERE c.barcode=?";
        try(PreparedStatement ps=con.prepareStatement(sql)){
            ps.setString(1,barcode);try(ResultSet rs=ps.executeQuery()){
                if(!rs.next())return null;
                // Sequence M2 28-30: first package the physical copy.
                DocumentCopy1 copy=new DocumentCopy1(rs.getString("barcode"),rs.getString("loanStatus"),rs.getString("physicalCondition"),null);copy.setId(rs.getInt("copyId"));
                // Sequence M2 31-34: then document (with its type), attach it to copy.
                DocumentType1 type=new DocumentType1(rs.getString("typeCode"),rs.getString("typeName"),rs.getString("typeDescription"));type.setId(rs.getInt("typeId"));
                Document1 document=new Document1(rs.getString("documentCode"),rs.getString("title"),rs.getString("author"),rs.getString("publisher"),rs.getInt("publicationYear"),rs.getString("description"),rs.getString("shelfLocation"),rs.getString("coverImage"),type);document.setId(rs.getInt("id"));
                copy.setDocument(document);return copy;
            }
        }catch(SQLException e){throw failure(e);}
    }
    
    public int countAvailableByDocument(String documentCode){
        String sql="SELECT COUNT(*) FROM tblDocumentCopy1 c JOIN tblDocument1 d ON d.id=c.documentId WHERE d.documentCode=? AND c.loanStatus='AVAILABLE' AND c.physicalCondition IN ('NEW','GOOD','OLD')";
        try(PreparedStatement ps=con.prepareStatement(sql)){
            ps.setString(1,documentCode);try(ResultSet rs=ps.executeQuery()){rs.next();return rs.getInt(1);}
        }catch(SQLException e){throw failure(e);}
    }
    
    public int markBorrowedIfAvailable(String barcode){
        String sql="UPDATE tblDocumentCopy1 SET loanStatus='BORROWED' WHERE barcode=? AND loanStatus='AVAILABLE' AND physicalCondition IN ('NEW','GOOD','OLD')";
        try(PreparedStatement ps=con.prepareStatement(sql)){ps.setString(1,barcode);return ps.executeUpdate();}catch(SQLException e){throw failure(e);}
    }
}
