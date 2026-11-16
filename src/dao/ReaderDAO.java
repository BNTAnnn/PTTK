package dao;
import model.*;
import java.sql.*;
public class ReaderDAO extends DAO {
    public ReaderDAO(){super();}
    public ReaderDAO(Connection con){super(con);}
    
    public Reader1 searchByCode(String readerCode){return findReader(readerCode,false);}
    
    public Reader1 findByCodeForUpdate(String readerCode){return findReader(readerCode,true);}
    
    private Reader1 findReader(String readerCode,boolean lock){
        String sql="SELECT m.*,r.readerCode,r.classUnit FROM tblReader1 r"+(lock?" WITH (UPDLOCK,HOLDLOCK)":"")+" JOIN tblMember1 m ON m.id=r.id WHERE r.readerCode=?";
        try(PreparedStatement ps=con.prepareStatement(sql)){
            ps.setString(1,readerCode);try(ResultSet rs=ps.executeQuery()){
                if(!rs.next())return null;
                Reader1 reader=new Reader1(rs.getString("username"),null,rs.getString("fullName"),rs.getDate("dateOfBirth"),rs.getString("address"),rs.getString("email"),rs.getString("phone"),rs.getString("readerCode"),rs.getString("classUnit"),null);
                reader.setId(rs.getInt("id"));return reader;
            }
        }catch(SQLException e){throw failure(e);}
    }
}
