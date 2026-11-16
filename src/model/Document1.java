package model;

import java.io.Serializable;
import java.util.*;
import java.util.Date;
import java.math.BigDecimal;

public class Document1 implements Serializable {
    private int id;
    private String documentCode;
    private String title;
    private String author;
    private String publisher;
    private int publicationYear;
    private String description;
    private String shelfLocation;
    private String coverImage;
    private DocumentType1 documentType;
    private List<DocumentCopy1> copies = new ArrayList<>();

    public Document1() {}

    public Document1(String documentCode, String title, String author, String publisher, int publicationYear, String description, String shelfLocation, String coverImage, DocumentType1 documentType) {
        setDocumentCode(documentCode);
        setTitle(title);
        setAuthor(author);
        setPublisher(publisher);
        setPublicationYear(publicationYear);
        setDescription(description);
        setShelfLocation(shelfLocation);
        setCoverImage(coverImage);
        setDocumentType(documentType);
    }

    public Document1(String documentCode, String title, String author, String publisher, int publicationYear, String description, String shelfLocation, String coverImage) {
        setDocumentCode(documentCode);
        setTitle(title);
        setAuthor(author);
        setPublisher(publisher);
        setPublicationYear(publicationYear);
        setDescription(description);
        setShelfLocation(shelfLocation);
        setCoverImage(coverImage);
    }
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getDocumentCode() { return documentCode; }
    public void setDocumentCode(String documentCode) { this.documentCode = documentCode; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }
    public String getPublisher() { return publisher; }
    public void setPublisher(String publisher) { this.publisher = publisher; }
    public int getPublicationYear() { return publicationYear; }
    public void setPublicationYear(int publicationYear) { this.publicationYear = publicationYear; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getShelfLocation() { return shelfLocation; }
    public void setShelfLocation(String shelfLocation) { this.shelfLocation = shelfLocation; }
    public String getCoverImage() { return coverImage; }
    public void setCoverImage(String coverImage) { this.coverImage = coverImage; }
    public DocumentType1 getDocumentType() { return documentType; }
    public void setDocumentType(DocumentType1 documentType) { this.documentType = documentType; }
    public List<DocumentCopy1> getCopies() { return copies; }
    public void setCopies(List<DocumentCopy1> copies) { this.copies = (copies == null ? new ArrayList<>() : copies); }

}
