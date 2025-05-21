package model;

import java.util.Date;

public class Attendance {
  private int id;
  private int userId;
  private Date date;
  private String faculty;
  private String status;
  private String day;

  public Attendance() {
  }

  public Attendance(int id, int userId, Date date, String faculty, String status, String day) {
    this.id = id;
    this.userId = userId;
    this.date = date;
    this.faculty = faculty;
    this.status = status;
    this.day = day;
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

  public String getFaculty() {
    return faculty;
  }

  public void setFaculty(String faculty) {
    this.faculty = faculty;
  }

  public String getStatus() {
    return status;
  }

  public void setStatus(String status) {
    this.status = status;
  }

  public String getDay() {
    return day;
  }

  public void setDay(String day) {
    this.day = day;
  }
}