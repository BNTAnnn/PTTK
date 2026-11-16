package dao;
import model.*;
import java.sql.*;
public class LoanDetailDAO extends DAO {
    public LoanDetailDAO(){super();}
    public LoanDetailDAO(Connection con){super(con);}
    
    public int countActiveByReader(String readerCode){
        String sql="SELECT COUNT(*) FROM tblLoanDetail1 ld JOIN tblLoanSlip1 ls ON ls.id=ld.loanSlipId JOIN tblReader1 r ON r.id=ls.readerId WHERE r.readerCode=? AND NOT EXISTS(SELECT 1 FROM tblReturnDetail1 rd WHERE rd.loanDetailId=ld.id)";
        try(PreparedStatement ps=con.prepareStatement(sql)){ps.setString(1,readerCode);try(ResultSet rs=ps.executeQuery()){rs.next();return rs.getInt(1);}}catch(SQLException e){throw failure(e);}
    }
    
    public int saveLoanDetails(LoanSlip1 slip){
        String sql="INSERT INTO tblLoanDetail1(loanSlipId,documentCopyId,borrowedCondition) VALUES(?,?,?)";
        int count=0;
        for(LoanDetail1 detail:slip.getDetails()){
            try(PreparedStatement ps=con.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS)){
                ps.setInt(1,slip.getId());ps.setInt(2,detail.getCopy().getId());ps.setString(3,detail.getBorrowedCondition());
                count+=ps.executeUpdate();try(ResultSet rs=ps.getGeneratedKeys()){if(rs.next())detail.setId(rs.getInt(1));}
            }catch(SQLException e){throw failure(e);}
        }return count;
    }
}
