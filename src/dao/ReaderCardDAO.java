package dao;
import model.*;
import java.sql.*;
public class ReaderCardDAO extends DAO {
    public ReaderCardDAO() {super();}
    public ReaderCardDAO(Connection con) {super(con);}
    
    public Reader1 findReaderByCardCode(String cardCode) {
        String sql="SELECT c.id AS cardId,c.cardCode,c.issueDate,c.expiryDate,c.status,r.readerCode,r.classUnit,m.* FROM tblReaderCard1 c JOIN tblReader1 r ON r.id=c.readerId JOIN tblMember1 m ON m.id=r.id WHERE c.cardCode=?";
        try(PreparedStatement ps=con.prepareStatement(sql)) {
            ps.setString(1,cardCode);
            try(ResultSet rs=ps.executeQuery()) {
                if(!rs.next()) return null;
                // Sequence M2 8-10: ReaderCard1 is packaged first.
                ReaderCard1 card=new ReaderCard1(rs.getString("cardCode"),rs.getDate("issueDate"),rs.getDate("expiryDate"),rs.getString("status")); card.setId(rs.getInt("cardId"));
                // Sequence M2 11-14: then Reader1 containing the card.
                Reader1 reader=new Reader1(rs.getString("username"),null,rs.getString("fullName"),rs.getDate("dateOfBirth"),rs.getString("address"),rs.getString("email"),rs.getString("phone"),rs.getString("readerCode"),rs.getString("classUnit"),card);
                reader.setId(rs.getInt("id")); card.setReader(reader); return reader;
            }
        } catch(SQLException e) {throw failure(e);}
    }
   
    public ReaderCard1 findByReaderCode(String readerCode) { return findCard(readerCode,false); }
    
    public ReaderCard1 findByReaderCodeForUpdate(String readerCode) { return findCard(readerCode,true); }
    
    private ReaderCard1 findCard(String readerCode, boolean lock) {
        String hint=lock?" WITH (UPDLOCK,HOLDLOCK)":"";
        String sql="SELECT c.* FROM tblReaderCard1 c"+hint+" JOIN tblReader1 r ON r.id=c.readerId WHERE r.readerCode=?";
        try(PreparedStatement ps=con.prepareStatement(sql)) {
            ps.setString(1,readerCode); try(ResultSet rs=ps.executeQuery()) {
                if(!rs.next()) return null;
                ReaderCard1 card=new ReaderCard1(rs.getString("cardCode"),rs.getDate("issueDate"),rs.getDate("expiryDate"),rs.getString("status")); card.setId(rs.getInt("id")); return card;
            }
        } catch(SQLException e) {throw failure(e);}
    }
}
