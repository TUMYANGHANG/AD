package model;

import java.sql.Timestamp;

public class Notification {
    private int id;
    private String type;
    private String title;
    private String message;
    private Timestamp created_at;

    public Notification() {}

    public Notification(int id, String type, String title, String message, Timestamp created_at) {
        this.id = id;
        this.type = type;
        this.title = title;
        this.message = message;
        this.created_at = created_at;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public Timestamp getCreated_at() { return created_at; }
    public void setCreated_at(Timestamp created_at) { this.created_at = created_at; }
} 