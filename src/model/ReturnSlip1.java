package model;

import java.io.Serializable;
import java.util.*;
import java.util.Date;
import java.math.BigDecimal;

public class ReturnSlip1 implements Serializable {
    private int id;
    private String returnCode;
    private Date returnDate;
    private String note;
    private LoanSlip1 loanSlip;
    private Reader1 reader;
    private LibraryStaff1 staff;
    private List<ReturnDetail1> details = new ArrayList<>();

    public ReturnSlip1() {}
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getReturnCode() { return returnCode; }
    public void setReturnCode(String returnCode) { this.returnCode = returnCode; }
    public Date getReturnDate() { return returnDate; }
    public void setReturnDate(Date returnDate) { this.returnDate = returnDate; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public LoanSlip1 getLoanSlip() { return loanSlip; }
    public void setLoanSlip(LoanSlip1 loanSlip) { this.loanSlip = loanSlip; }
    public Reader1 getReader() { return reader; }
    public void setReader(Reader1 reader) { this.reader = reader; }
    public LibraryStaff1 getStaff() { return staff; }
    public void setStaff(LibraryStaff1 staff) { this.staff = staff; }
    public List<ReturnDetail1> getDetails() { return details; }
    public void setDetails(List<ReturnDetail1> details) { this.details = (details == null ? new ArrayList<>() : details); }

}
