package model;

import java.io.Serializable;
import java.util.*;
import java.util.Date;
import java.math.BigDecimal;

public class DocumentCopy1 implements Serializable {
    private int id;
    private String barcode;
    private String loanStatus;
    private String physicalCondition;
    private Document1 document;

    public DocumentCopy1() {}

    public DocumentCopy1(String barcode, String loanStatus, String physicalCondition, Document1 document) {
        setBarcode(barcode);
        setLoanStatus(loanStatus);
        setPhysicalCondition(physicalCondition);
        setDocument(document);
    }
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getBarcode() { return barcode; }
    public void setBarcode(String barcode) { this.barcode = barcode; }
    public String getLoanStatus() { return loanStatus; }
    public void setLoanStatus(String loanStatus) { this.loanStatus = loanStatus; }
    public String getPhysicalCondition() { return physicalCondition; }
    public void setPhysicalCondition(String physicalCondition) { this.physicalCondition = physicalCondition; }
    public Document1 getDocument() { return document; }
    public void setDocument(Document1 document) { this.document = document; }
    public boolean checkBorrowable() {
        return "AVAILABLE".equals(loanStatus)
            && Arrays.asList("NEW", "GOOD", "OLD").contains(physicalCondition);
    }
    public boolean getAvailability() { return checkBorrowable(); }
}
