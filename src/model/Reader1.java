package model;

import java.io.Serializable;
import java.util.*;
import java.util.Date;
import java.math.BigDecimal;

public class Reader1 extends Member1 implements Serializable {
    private String readerCode;
    private String classUnit;
    private ReaderCard1 card;

    public Reader1() {}

    public Reader1(String username, String password, String fullName, Date dateOfBirth, String address, String email, String phone, String readerCode, String classUnit, ReaderCard1 card) {
        setUsername(username);
        setPassword(password);
        setFullName(fullName);
        setDateOfBirth(dateOfBirth);
        setAddress(address);
        setEmail(email);
        setPhone(phone);
        setReaderCode(readerCode);
        setClassUnit(classUnit);
        setCard(card);
    }
    public String getReaderCode() { return readerCode; }
    public void setReaderCode(String readerCode) { this.readerCode = readerCode; }
    public String getClassUnit() { return classUnit; }
    public void setClassUnit(String classUnit) { this.classUnit = classUnit; }
    public ReaderCard1 getCard() { return card; }
    public void setCard(ReaderCard1 card) { this.card = card; }
    public static final int MAX_ACTIVE_LOANS = 5;
    public boolean checkBorrowEligibility(int active, int selected) {
        return card != null && card.isValid(new Date()) && active >= 0 && selected >= 0
            && active < MAX_ACTIVE_LOANS && active + selected <= MAX_ACTIVE_LOANS;
    }
}
