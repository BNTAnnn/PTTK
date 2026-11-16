package dao;
import model.*;
import java.sql.*;
import java.util.*;
import java.util.Date;
public class LoanSlipDAO extends DAO {
    private ReaderDAO readerDAO;
    private ReaderCardDAO cardDAO;
    private LoanDetailDAO detailDAO;
    private DocumentCopyDAO copyDAO;
    public LoanSlipDAO(){super();init();}
    public LoanSlipDAO(Connection con){super(con);init();}
    private void init(){readerDAO=new ReaderDAO(con);cardDAO=new ReaderCardDAO(con);detailDAO=new LoanDetailDAO(con);copyDAO=new DocumentCopyDAO(con);}
    /** Sequence M2 57-58: all writes are encapsulated in this single operation. */
    public LoanSlip1 createLoanSlip(LoanSlip1 draft){
        if(draft==null || !draft.isReadyToSave())throw new IllegalArgumentException("Danh sách mượn không hợp lệ.");
        int isolation;
        try{isolation=con.getTransactionIsolation();}catch(SQLException e){throw failure(e);}
        boolean begun=false;
        try{
            beginTransaction();begun=true;
            Reader1 reader=readerDAO.findByCodeForUpdate(draft.getReader().getReaderCode());
            if(reader==null)throw new IllegalArgumentException("Độc giả không còn tồn tại.");
            ReaderCard1 card=cardDAO.findByReaderCodeForUpdate(reader.getReaderCode());reader.setCard(card);
            int active=detailDAO.countActiveByReader(reader.getReaderCode());
            if(!reader.checkBorrowEligibility(active,draft.getDetails().size()))throw new IllegalArgumentException("Thẻ không hợp lệ hoặc vượt giới hạn 5 cuốn.");
            List<LoanDetail1> source=new ArrayList<>(draft.getDetails());
            source.sort(Comparator.comparing(d -> d.getCopy().getBarcode()));
            List<LoanDetail1> checked=new ArrayList<>();Set<String> seen=new HashSet<>();
            for(LoanDetail1 item:source){
                String barcode=item.getCopy().getBarcode();
                if(!seen.add(barcode))throw new IllegalArgumentException("Trùng bản sao trong phiếu.");
                DocumentCopy1 copy=copyDAO.findByBarcodeForUpdate(barcode);
                if(copy==null || !copy.checkBorrowable())throw new IllegalArgumentException("Bản sao không còn khả dụng: "+barcode);
                checked.add(new LoanDetail1(copy,copy.getPhysicalCondition()));
            }
            // Staff identity comes from the authenticated session, checked against DB.
            try(PreparedStatement ps=con.prepareStatement("SELECT id FROM tblLibraryStaff1 WHERE id=? AND libraryStaffCode=?")){
                ps.setInt(1,draft.getStaff().getId());ps.setString(2,draft.getStaff().getLibraryStaffCode());
                try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("Nhân viên không hợp lệ.");}
            }
            String days=System.getenv("LIBMAN_LOAN_DAYS");
            if(days==null)throw new IllegalStateException("Chưa cấu hình LIBMAN_LOAN_DAYS theo chính sách thư viện.");
            int loanDays=Integer.parseInt(days);if(loanDays<=0)throw new IllegalStateException("LIBMAN_LOAN_DAYS phải lớn hơn 0.");
            Date now=new Date();Calendar due=Calendar.getInstance();due.setTime(now);due.add(Calendar.DATE,loanDays);
            // Update the existing draft, not a second loan transaction.
            draft.setReader(reader);draft.setDetails(checked);draft.setLoanDate(now);draft.setDueDate(due.getTime());
            draft.setLoanCode("PM-"+UUID.randomUUID().toString().replace("-", "").substring(0,24));
            insertLoanSlip(draft);
            for(LoanDetail1 d:checked)d.setLoanSlip(draft);
            if(detailDAO.saveLoanDetails(draft)!=checked.size())throw new IllegalStateException("Lưu thiếu chi tiết.");
            for(LoanDetail1 d:checked)if(copyDAO.markBorrowedIfAvailable(d.getCopy().getBarcode())!=1)throw new IllegalStateException("Không cập nhật được bản sao.");
            commit();return draft;
        }catch(SQLException e){if(begun)rollback();throw failure(e);
        }catch(RuntimeException e){if(begun)rollback();throw e;
        }finally{
            if(begun)try{con.setAutoCommit(true);con.setTransactionIsolation(isolation);}catch(SQLException e){try{con.close();}catch(SQLException ignored){}}
        }
    }
    protected String insertLoanSlip(LoanSlip1 slip){
        String sql="INSERT INTO tblLoanSlip1(loanCode,loanDate,dueDate,readerId,libraryStaffId) VALUES(?,?,?,?,?)";
        try(PreparedStatement ps=con.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS)){
            ps.setString(1,slip.getLoanCode());ps.setDate(2,new java.sql.Date(slip.getLoanDate().getTime()));ps.setDate(3,new java.sql.Date(slip.getDueDate().getTime()));ps.setInt(4,slip.getReader().getId());ps.setInt(5,slip.getStaff().getId());
            if(ps.executeUpdate()!=1)throw new IllegalStateException("Không lưu được phiếu.");
            try(ResultSet rs=ps.getGeneratedKeys()){if(!rs.next())throw new IllegalStateException("Không nhận được khóa phiếu.");slip.setId(rs.getInt(1));}
            return slip.getLoanCode();
        }catch(SQLException e){throw failure(e);}
    }
    public LoanSlip1 getForPrint(String loanCode){
        String sql="SELECT ls.*,r.readerCode,s.libraryStaffCode,s.position,m.username,m.fullName,m.dateOfBirth,m.address,m.email,m.phone,sm.fullName AS staffName FROM tblLoanSlip1 ls JOIN tblReader1 r ON r.id=ls.readerId JOIN tblMember1 m ON m.id=r.id JOIN tblLibraryStaff1 s ON s.id=ls.libraryStaffId JOIN tblMember1 sm ON sm.id=s.id WHERE ls.loanCode=?";
        try(PreparedStatement ps=con.prepareStatement(sql)){
            ps.setString(1,loanCode);LoanSlip1 slip;
            try(ResultSet rs=ps.executeQuery()){
                if(!rs.next())return null;
                Reader1 reader=new Reader1();reader.setId(rs.getInt("readerId"));reader.setReaderCode(rs.getString("readerCode"));reader.setFullName(rs.getString("fullName"));
                LibraryStaff1 staff=new LibraryStaff1();staff.setId(rs.getInt("libraryStaffId"));staff.setLibraryStaffCode(rs.getString("libraryStaffCode"));staff.setFullName(rs.getString("staffName"));
                // Sequence M2 63-65: package an object for printing; this is not INSERT.
                slip=new LoanSlip1(rs.getString("loanCode"),rs.getDate("loanDate"),rs.getDate("dueDate"),reader,staff,new ArrayList<>());slip.setId(rs.getInt("id"));
            }
            try(PreparedStatement pd=con.prepareStatement("SELECT ld.*,c.barcode FROM tblLoanDetail1 ld JOIN tblDocumentCopy1 c ON c.id=ld.documentCopyId WHERE ld.loanSlipId=? ORDER BY ld.id")){
                pd.setInt(1,slip.getId());try(ResultSet rs=pd.executeQuery()){
                    while(rs.next()){
                        DocumentCopy1 copy=copyDAO.findByBarcode(rs.getString("barcode"));
                        LoanDetail1 detail=new LoanDetail1(copy,rs.getString("borrowedCondition"));detail.setId(rs.getInt("id"));detail.setLoanSlip(slip);slip.getDetails().add(detail);
                    }
                }
            }return slip;
        }catch(SQLException e){throw failure(e);}
    }
}
