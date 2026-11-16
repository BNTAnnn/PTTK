package model;

import java.io.Serializable;
import java.util.*;
import java.util.Date;
import java.math.BigDecimal;

public class LoanSlip1 implements Serializable {
    private int id;
    private String loanCode;
    private Date loanDate;
    private Date dueDate;
    private Reader1 reader;
    private LibraryStaff1 staff;
    private List<LoanDetail1> details = new ArrayList<>();

    public LoanSlip1() {}

    public LoanSlip1(String loanCode, Date loanDate, Date dueDate, Reader1 reader, LibraryStaff1 staff, List<LoanDetail1> details) {
        setLoanCode(loanCode);
        setLoanDate(loanDate);
        setDueDate(dueDate);
        setReader(reader);
        setStaff(staff);
        setDetails(details);
    }
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getLoanCode() { return loanCode; }
    public void setLoanCode(String loanCode) { this.loanCode = loanCode; }
    public Date getLoanDate() { return loanDate; }
    public void setLoanDate(Date loanDate) { this.loanDate = loanDate; }
    public Date getDueDate() { return dueDate; }
    public void setDueDate(Date dueDate) { this.dueDate = dueDate; }
    public Reader1 getReader() { return reader; }
    public void setReader(Reader1 reader) { this.reader = reader; }
    public LibraryStaff1 getStaff() { return staff; }
    public void setStaff(LibraryStaff1 staff) { this.staff = staff; }
    public List<LoanDetail1> getDetails() { return details; }
    public void setDetails(List<LoanDetail1> details) { this.details = (details == null ? new ArrayList<>() : details); }
    public boolean containsBarcode(String barcode) {
        return details.stream().anyMatch(d -> d.getCopy() != null && Objects.equals(d.getCopy().getBarcode(), barcode));
    }
    public boolean addLoanDetail(DocumentCopy1 copy) {
        if(copy == null || !copy.checkBorrowable() || containsBarcode(copy.getBarcode()) || details.size() >= 5) return false;
        // Sequence M2 46-49: construct LoanDetail1, then append to the draft.
        LoanDetail1 detail = new LoanDetail1(copy, copy.getPhysicalCondition());
        detail.setLoanSlip(this); details.add(detail); return true;
    }
    public boolean removeLoanDetail(String barcode) {
        return details.removeIf(d -> d.getCopy() != null && Objects.equals(barcode, d.getCopy().getBarcode()));
    }
    public boolean isReadyToSave() {
        if(reader == null || staff == null || details == null || details.isEmpty() || details.size() > 5) return false;
        Set<String> seen = new HashSet<>();
        for(LoanDetail1 d : details) if(d == null || d.getCopy() == null || !seen.add(d.getCopy().getBarcode())) return false;
        return true;
    }
}
