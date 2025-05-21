package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import model.Student;
import model.User;
import util.DatabaseConnection;

public class StudentDAO {

    private static final Logger logger = Logger.getLogger(StudentDAO.class.getName());

    public boolean saveStudentData(User user, String rollNo, String className) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            if (user == null || user.getId() <= 0 || rollNo == null || rollNo.isEmpty() ||
                    className == null || className.isEmpty()) {
                logger.log(Level.WARNING, "Invalid input parameters in saveStudentData");
                return false;
            }

            String sql = "INSERT INTO student (user_id, rollno, classname) VALUES (?, ?, ?) " +
                    "ON DUPLICATE KEY UPDATE rollno = ?, classname = ?";

            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, user.getId());
            pstmt.setString(2, rollNo);
            pstmt.setString(3, className);
            pstmt.setString(4, rollNo);
            pstmt.setString(5, className);

            int rowsAffected = pstmt.executeUpdate();
            conn.commit();
            return rowsAffected > 0;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    logger.log(Level.SEVERE, "Failed to rollback transaction", ex);
                }
            }
            logger.log(Level.SEVERE, "Error saving student data for user ID: " +
                    (user != null ? user.getId() : "null"), e);
            return false;
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Unexpected error in saveStudentData", e);
            return false;
        } finally {
            try {
                if (pstmt != null)
                    pstmt.close();
            } catch (SQLException e) {
                logger.log(Level.WARNING, "Failed to close PreparedStatement", e);
            }
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException e) {
                logger.log(Level.WARNING, "Failed to close Connection", e);
            }
        }
    }

    public void updatePhotoPath(int userId, String photoPath) throws SQLException {
        String sql = "UPDATE student SET photo_path = ? WHERE user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, photoPath);
            stmt.setInt(2, userId);
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected == 0) {
                logger.warning("No student record found for user ID: " + userId + " to update photo path");
            } else {
                logger.info("Photo path updated for user ID: " + userId + ", path: " + photoPath);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating photo path for user ID: " + userId, e);
            throw e;
        }
    }

    public Student getStudentData(int userId) throws SQLException {
        String sql = "SELECT s.rollno, s.classname, s.photo_path, u.username, u.email, u.role " +
                "FROM student s JOIN users u ON s.user_id = u.id WHERE s.user_id = ?";
        Student student = null;

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                student = new Student();
                student.setId(userId);
                student.setRollNumber(rs.getString("rollno"));
                student.setClassName(rs.getString("classname"));
                student.setPhotoPath(rs.getString("photo_path"));
                student.setUsername(rs.getString("username"));
                student.setEmail(rs.getString("email"));
                student.setRole(rs.getString("role"));
            } else {
                logger.warning("No student data found for user ID: " + userId);
            }

        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error retrieving student data for user ID: " + userId, e);
            throw e;
        }

        return student;
    }

    public List<Student> getAllStudents() throws SQLException {
        List<Student> students = new ArrayList<>();
        String sql = "SELECT s.user_id, s.rollno, s.classname, s.photo_path, u.username, u.email, u.role " +
                "FROM student s JOIN users u ON s.user_id = u.id";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Student student = new Student();
                student.setId(rs.getInt("user_id"));
                student.setRollNumber(rs.getString("rollno"));
                student.setClassName(rs.getString("classname"));
                student.setPhotoPath(rs.getString("photo_path"));
                student.setUsername(rs.getString("username"));
                student.setEmail(rs.getString("email"));
                student.setRole(rs.getString("role"));
                students.add(student);
            }

        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error retrieving all students", e);
            throw e;
        }

        return students;
    }

    public boolean deleteStudent(int studentId) throws SQLException {
        System.out.println("[DEBUG] StudentDAO.deleteStudent called for ID: " + studentId);
        Connection conn = null;
        PreparedStatement stmt1 = null, stmt2 = null;
        boolean success = false;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            System.out.println("[DEBUG] Attempting to delete student with ID: " + studentId);

            // Delete from student
            stmt1 = conn.prepareStatement("DELETE FROM student WHERE user_id = ?");
            stmt1.setInt(1, studentId);
            int rowsAffected = stmt1.executeUpdate();
            System.out.println("[DEBUG] Rows affected in student table: " + rowsAffected);

            // Delete from users
            stmt2 = conn.prepareStatement("DELETE FROM users WHERE id = ?");
            stmt2.setInt(1, studentId);
            stmt2.executeUpdate();

            if (rowsAffected > 0) {
                conn.commit();
                success = true;
                System.out.println("[DEBUG] Successfully deleted student with ID: " + studentId);
            } else {
                conn.rollback();
                System.out.println("[DEBUG] No student found with ID: " + studentId + ", rolled back.");
            }
        } catch (SQLException e) {
            if (conn != null)
                conn.rollback();
            System.out.println("[DEBUG] SQL Exception in deleteStudent: " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            if (stmt2 != null) {
                try {
                    stmt2.close();
                } catch (SQLException e) {
                    System.out.println("[DEBUG] Error closing stmt2: " + e.getMessage());
                }
            }
            if (stmt1 != null) {
                try {
                    stmt1.close();
                } catch (SQLException e) {
                    System.out.println("[DEBUG] Error closing stmt1: " + e.getMessage());
                }
            }
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    System.out.println("[DEBUG] Error closing connection: " + e.getMessage());
                }
            }
        }
        return success;
    }

    // New method to get student data by user ID
    public Student getStudentById(int userId) throws SQLException {
        return getStudentData(userId);
    }

    // New method to update student data
    public boolean updateStudent(Student student) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmtUser = null;
        PreparedStatement pstmtStudent = null;
        boolean success = false;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            // Update users table (username, email, and photo)
            String sqlUser = "UPDATE users SET username = ?, email = ?, photo = ? WHERE id = ?";
            pstmtUser = conn.prepareStatement(sqlUser);
            pstmtUser.setString(1, student.getUsername());
            pstmtUser.setString(2, student.getEmail());
            pstmtUser.setString(3, student.getPhotoPath()); // Update photo column in users table
            pstmtUser.setInt(4, student.getId());
            pstmtUser.executeUpdate();

            // Update student table (classname only)
            String sqlStudent = "UPDATE student SET classname = ? WHERE user_id = ?";
            pstmtStudent = conn.prepareStatement(sqlStudent);
            pstmtStudent.setString(1, student.getClassName());
            pstmtStudent.setInt(2, student.getId());
            pstmtStudent.executeUpdate();

            conn.commit();
            success = true;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    logger.log(Level.SEVERE, "Failed to rollback transaction during student update", ex);
                }
            }
            logger.log(Level.SEVERE, "Error updating student data for user ID: " + student.getId(), e);
            throw e;
        } finally {
            if (pstmtUser != null) {
                try {
                    pstmtUser.close();
                } catch (SQLException e) {
                    logger.log(Level.WARNING, "Failed to close pstmtUser", e);
                }
            }
            if (pstmtStudent != null) {
                try {
                    pstmtStudent.close();
                } catch (SQLException e) {
                    logger.log(Level.WARNING, "Failed to close pstmtStudent", e);
                }
            }
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    logger.log(Level.WARNING, "Failed to close Connection", e);
                }
            }
        }
        return success;
    }
}