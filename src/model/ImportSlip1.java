package model;

import java.io.Serializable;
import java.util.*;
import java.util.Date;
import java.math.BigDecimal;

public class ImportSlip1 implements Serializable {
    private int id;
    private String importCode;
    private Date importDate;
    private BigDecimal totalAmount;
    private Supplier1 supplier;
    private LibraryStaff1 staff;
    private List<ImportDetail1> details = new ArrayList<>();

    public ImportSlip1() {}
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getImportCode() { return importCode; }
    public void setImportCode(String importCode) { this.importCode = importCode; }
    public Date getImportDate() { return importDate; }
    public void setImportDate(Date importDate) { this.importDate = importDate; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public Supplier1 getSupplier() { return supplier; }
    public void setSupplier(Supplier1 supplier) { this.supplier = supplier; }
    public LibraryStaff1 getStaff() { return staff; }
    public void setStaff(LibraryStaff1 staff) { this.staff = staff; }
    public List<ImportDetail1> getDetails() { return details; }
    public void setDetails(List<ImportDetail1> details) { this.details = (details == null ? new ArrayList<>() : details); }

}
