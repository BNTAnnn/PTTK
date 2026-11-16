package model;

import java.io.Serializable;
import java.util.*;
import java.util.Date;
import java.math.BigDecimal;

public class DocumentType1 implements Serializable {
    private int id;
    private String typeCode;
    private String typeName;
    private String description;
    private List<Document1> documents = new ArrayList<>();

    public DocumentType1() {}

    public DocumentType1(String typeCode, String typeName, String description) {
        setTypeCode(typeCode);
        setTypeName(typeName);
        setDescription(description);
    }
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getTypeCode() { return typeCode; }
    public void setTypeCode(String typeCode) { this.typeCode = typeCode; }
    public String getTypeName() { return typeName; }
    public void setTypeName(String typeName) { this.typeName = typeName; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public List<Document1> getDocuments() { return documents; }
    public void setDocuments(List<Document1> documents) { this.documents = (documents == null ? new ArrayList<>() : documents); }

}
