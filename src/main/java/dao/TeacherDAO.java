package dao;

import model.User;
import util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class TeacherDAO {

    // Inserts teacher-specific information into 'teacher' table.
    public boolean saveTeacherData(User user, String employeeId, String department) {
        String sql = "INSERT INTO teacher (user_id, employee_id, department) VALUES (?, ?, ?)";  //

        try (Connection conn = DatabaseConnection.getConnection();  // Open DB connection.
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, user.getId());  // Set foreign key: user ID.
            pstmt.setString(2, employeeId);  // Set employee ID.
            pstmt.setString(3, department);  // Set department.

            int rows = pstmt.executeUpdate();  // Execute insert.
            return rows > 0;  // Return true on success.

        } catch (SQLException e) {
            e.printStackTrace();
            return false;  // Return false if error.
        }
    }
}

