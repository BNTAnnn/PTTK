package model;

import java.io.Serializable;
import java.util.*;
import java.util.Date;
import java.math.BigDecimal;

public class ReturnDetail1 implements Serializable {
    private int id;
    private String returnedCondition;
    private ReturnSlip1 returnSlip;
    private LoanDetail1 loanDetail;

    public ReturnDetail1() {}
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getReturnedCondition() { return returnedCondition; }
    public void setReturnedCondition(String returnedCondition) { this.returnedCondition = returnedCondition; }
    public ReturnSlip1 getReturnSlip() { return returnSlip; }
    public void setReturnSlip(ReturnSlip1 returnSlip) { this.returnSlip = returnSlip; }
    public LoanDetail1 getLoanDetail() { return loanDetail; }
    public void setLoanDetail(LoanDetail1 loanDetail) { this.loanDetail = loanDetail; }

}
