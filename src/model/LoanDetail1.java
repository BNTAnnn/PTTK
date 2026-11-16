package model;

import java.io.Serializable;
import java.util.*;
import java.util.Date;
import java.math.BigDecimal;

public class LoanDetail1 implements Serializable {
    private int id;
    private String borrowedCondition;
    private LoanSlip1 loanSlip;
    private DocumentCopy1 copy;

    public LoanDetail1() {}

    public LoanDetail1(DocumentCopy1 copy, String borrowedCondition) {
        setCopy(copy);
        setBorrowedCondition(borrowedCondition);
    }
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getBorrowedCondition() { return borrowedCondition; }
    public void setBorrowedCondition(String borrowedCondition) { this.borrowedCondition = borrowedCondition; }
    public LoanSlip1 getLoanSlip() { return loanSlip; }
    public void setLoanSlip(LoanSlip1 loanSlip) { this.loanSlip = loanSlip; }
    public DocumentCopy1 getCopy() { return copy; }
    public void setCopy(DocumentCopy1 copy) { this.copy = copy; }

}
