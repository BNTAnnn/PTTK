package model;

import java.io.Serializable;
import java.util.*;
import java.util.Date;
import java.math.BigDecimal;

public class LibraryStaff1 extends Member1 implements Serializable {
    private String libraryStaffCode;
    private String position;

    public LibraryStaff1() {}

    public LibraryStaff1(String username, String password, String fullName, Date dateOfBirth, String address, String email, String phone, String libraryStaffCode, String position) {
        setUsername(username);
        setPassword(password);
        setFullName(fullName);
        setDateOfBirth(dateOfBirth);
        setAddress(address);
        setEmail(email);
        setPhone(phone);
        setLibraryStaffCode(libraryStaffCode);
        setPosition(position);
    }
    public String getLibraryStaffCode() { return libraryStaffCode; }
    public void setLibraryStaffCode(String libraryStaffCode) { this.libraryStaffCode = libraryStaffCode; }
    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }

}
