-- Create database
CREATE DATABASE IF NOT EXISTS student_attendance_management_system;
USE student_attendance_management_system;

-- Users table (main user information)
CREATE TABLE IF NOT EXISTS users (
                                     id INT AUTO_INCREMENT PRIMARY KEY,
                                     username VARCHAR(50) NOT NULL UNIQUE,
                                     password VARCHAR(255) NOT NULL,
                                     email VARCHAR(100) NOT NULL UNIQUE,
                                     role ENUM('admin', 'student', 'teacher') NOT NULL,
                                     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Student-specific information
CREATE TABLE IF NOT EXISTS student (
                                       id INT AUTO_INCREMENT PRIMARY KEY,
                                       user_id INT NOT NULL,
                                       rollno VARCHAR(20) NOT NULL UNIQUE,
                                       classname VARCHAR(50) NOT NULL,
                                       photo_path VARCHAR(255) DEFAULT NULL,
                                       FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Teacher-specific information
CREATE TABLE IF NOT EXISTS teacher (
                                       id INT AUTO_INCREMENT PRIMARY KEY,
                                       user_id INT NOT NULL,
                                       employee_id VARCHAR(20) NOT NULL UNIQUE,
                                       department VARCHAR(50) NOT NULL,
                                       FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(100) NOT NULL,
    message VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS attendence (
                                          AttendenceID INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
                                          User_ID INT(11) NOT NULL,
                                          Date DATE NOT NULL,
                                          Faculty VARCHAR(100) NOT NULL,
                                          Status VARCHAR(20) NOT NULL,
                                          Day VARCHAR(20) NOT NULL
);
