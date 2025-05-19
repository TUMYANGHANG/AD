package model;

public class Student extends User {
    private String rollNumber;
    private String className;
    private String photoPath;

    // Getters and setters
    public String getRollNumber() {

        return rollNumber;
    }

    public void setRollNumber(String rollNumber) {

        this.rollNumber = rollNumber;
    }

    public String getClassName() {

        return className;
    }

    public void setClassName(String className) {

        this.className = className;
    }

    public String getPhotoPath() {
        return photoPath;
    }

    public void setPhotoPath(String photoPath) {
        this.photoPath = photoPath;
    }

    public String getRollNo() {
        return getRollNumber();
    }
}