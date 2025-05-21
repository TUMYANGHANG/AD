package model;

import java.util.Date;

public class Attendance {
  private int id;
  private int userId;
  private Date date;
  private String status;
  private String type;

  public Attendance() {
  }

  public Attendance(int id, int userId, Date date, String status, String type) {
    this.id = id;
    this.userId = userId;
    this.date = date;
    this.status = status;
    this.type = type;
  }

  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

  public int getUserId() {
    return userId;
  }

  public void setUserId(int userId) {
    this.userId = userId;
  }

  public Date getDate() {
    return date;
  }

  public void setDate(Date date) {
    this.date = date;
  }

  public String getStatus() {
    return status;
  }

  public void setStatus(String status) {
    this.status = status;
  }

  public String getType() {
    return type;
  }

  public void setType(String type) {
    this.type = type;
  }
}