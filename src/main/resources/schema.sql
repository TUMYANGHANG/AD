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