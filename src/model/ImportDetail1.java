package model;

import java.io.Serializable;
import java.util.*;
import java.util.Date;
import java.math.BigDecimal;

public class ImportDetail1 implements Serializable {
    private int id;
    private int quantity;
    private BigDecimal unitPrice;
    private ImportSlip1 importSlip;
    private Document1 document;

    public ImportDetail1() {}
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
    public ImportSlip1 getImportSlip() { return importSlip; }
    public void setImportSlip(ImportSlip1 importSlip) { this.importSlip = importSlip; }
    public Document1 getDocument() { return document; }
    public void setDocument(Document1 document) { this.document = document; }

}
