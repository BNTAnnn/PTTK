package model;

import java.io.Serializable;
import java.util.*;
import java.util.Date;
import java.math.BigDecimal;

public class ReaderCard1 implements Serializable {
    private int id;
    private String cardCode;
    private Date issueDate;
    private Date expiryDate;
    private String status;
    private Reader1 reader;

    public ReaderCard1() {}

    public ReaderCard1(String cardCode, Date issueDate, Date expiryDate, String status) {
        setCardCode(cardCode);
        setIssueDate(issueDate);
        setExpiryDate(expiryDate);
        setStatus(status);
    }
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getCardCode() { return cardCode; }
    public void setCardCode(String cardCode) { this.cardCode = cardCode; }
    public Date getIssueDate() { return issueDate; }
    public void setIssueDate(Date issueDate) { this.issueDate = issueDate; }
    public Date getExpiryDate() { return expiryDate; }
    public void setExpiryDate(Date expiryDate) { this.expiryDate = expiryDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Reader1 getReader() { return reader; }
    public void setReader(Reader1 reader) { this.reader = reader; }
    public boolean isValid(Date at) {
        if (at == null || issueDate == null || expiryDate == null) return false;
        java.time.LocalDate today = new java.sql.Date(at.getTime()).toLocalDate();
        java.time.LocalDate issued = new java.sql.Date(issueDate.getTime()).toLocalDate();
        java.time.LocalDate expires = new java.sql.Date(expiryDate.getTime()).toLocalDate();
        return "ACTIVE".equals(status) && !today.isBefore(issued) && !today.isAfter(expires);
    }
}
