package dao;

import model.User;
import util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class StudentDAO {

    private static final Logger logger = Logger.getLogger(StudentDAO.class.getName());

    // Saves student-related data to the student table
    public boolean saveStudentData(User user, String rollNo, String className) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            // Validate input parameters
            if (user == null || user.getId() <= 0 || rollNo == null || rollNo.isEmpty() ||
                    className == null || className.isEmpty()) {
                logger.log(Level.WARNING, "Invalid input parameters in saveStudentData");
                return false;
            }

            // SQL query to insert user_id, roll number, and class name
            String sql = "INSERT INTO student (user_id, rollno, classname) VALUES (?, ?, ?)";

            // Get database connection
            conn = DatabaseConnection.getConnection();

            // Set auto-commit to false to manage transactions manually
            conn.setAutoCommit(false);

            // Prepare statement
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, user.getId());
            pstmt.setString(2, rollNo);
            pstmt.setString(3, className);

            // Execute the insert statement
            int rowsAffected = pstmt.executeUpdate();

            // Commit transaction if successful
            conn.commit();

            // Return true if insert was successful
            return rowsAffected > 0;

        } catch (SQLException e) {
            // Rollback transaction in case of error
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
            // Close resources in finally block
            try {
                if (pstmt != null) pstmt.close();
            } catch (SQLException e) {
                logger.log(Level.WARNING, "Failed to close PreparedStatement", e);
            }
            try {
                if (conn != null) conn.close();
            } catch (SQLException e) {
                logger.log(Level.WARNING, "Failed to close Connection", e);
            }
        }
    }
}