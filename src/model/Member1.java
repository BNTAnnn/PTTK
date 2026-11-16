package model;

import java.io.Serializable;
import java.util.*;
import java.util.Date;
import java.math.BigDecimal;

public abstract class Member1 implements Serializable {
    private int id;
    private String username;
    private String password;
    private String fullName;
    private Date dateOfBirth;
    private String address;
    private String email;
    private String phone;

    public Member1() {}

    public Member1(String username, String password, String fullName, Date dateOfBirth, String address, String email, String phone) {
        setUsername(username);
        setPassword(password);
        setFullName(fullName);
        setDateOfBirth(dateOfBirth);
        setAddress(address);
        setEmail(email);
        setPhone(phone);
    }
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public Date getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(Date dateOfBirth) { this.dateOfBirth = dateOfBirth; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

}
