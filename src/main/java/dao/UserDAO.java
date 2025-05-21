package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.mindrot.jbcrypt.BCrypt;

import model.Admin;
import model.Student;
import model.Teacher;
import model.User;
import util.DatabaseConnection;

public class UserDAO {
    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    public boolean updateUser(User user) {
        String sql = "UPDATE users SET username = ?, email = ?, role = ? WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, user.getEmail());
            pstmt.setString(3, user.getRole());
            pstmt.setInt(4, user.getId());
            int rows = pstmt.executeUpdate();

            // If password is provided, update it separately
            if (user.getPassword() != null && !user.getPassword().isEmpty()) {
                String passwordSql = "UPDATE users SET password = ? WHERE id = ?";
                try (PreparedStatement pwdStmt = conn.prepareStatement(passwordSql)) {
                    pwdStmt.setString(1, BCrypt.hashpw(user.getPassword(), BCrypt.gensalt()));
                    pwdStmt.setInt(2, user.getId());
                    pwdStmt.executeUpdate();
                }
            }

            LOGGER.info("Updated user ID: " + user.getId() + ", rows affected: " + rows);
            return rows > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating user data for ID: " + user.getId(), e);
            throw new RuntimeException("Error updating user", e);
        }
    }

    public User authenticate(String username, String password) throws SQLException {
        String query = "SELECT * FROM users WHERE username = ?";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setString(1, username);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String hashedPassword = rs.getString("password");
                    // Verify the password using BCrypt
                    if (BCrypt.checkpw(password, hashedPassword)) {
                        User user = new User();
                        user.setId(rs.getInt("id"));
                        user.setUsername(rs.getString("username"));
                        user.setEmail(rs.getString("email"));
                        user.setRole(rs.getString("role"));
                        user.setCreatedAt(rs.getTimestamp("created_at"));
                        return user;
                    }
                }
            }
        }
        return null;
    }

    public User getUserData(int userId) throws SQLException {
        String query = "SELECT * FROM users WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, userId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                    return user;
                }
            }
        }
        return null;
    }

    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM users WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting user: " + userId, e);
            throw new RuntimeException("Error deleting user", e);
        }
    }

    public User createUserFromRole(String role) {
        switch (role.toLowerCase()) {
            case "admin":
                return new Admin();
            case "student":
                return new Student();
            case "teacher":
                return new Teacher();
            default:
                return null;
        }
    }

    public boolean registerUser(User user) {
        String sql = "INSERT INTO users (username, password, email, role, created_at) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, hashedPassword);
            pstmt.setString(3, user.getEmail());
            pstmt.setString(4, user.getRole());
            pstmt.setDate(5, new java.sql.Date(user.getCreatedAt().getTime()));

            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        user.setId(generatedKeys.getInt(1));
                    }
                }
                LOGGER.info("Registered user: " + user.getUsername() + ", ID: " + user.getId());
                return true;
            }
            return false;
        } catch (SQLIntegrityConstraintViolationException e) {
            // Log specific duplicate entry error
            LOGGER.log(Level.WARNING, "Registration failed due to duplicate entry for username or email: "
                    + user.getUsername() + " / " + user.getEmail(), e);
            return false; // Indicate failure due to duplicate constraint
        } catch (SQLException e) {
            // Log other SQL errors
            LOGGER.log(Level.SEVERE, "Error registering user: " + user.getUsername(), e);
            // Optionally, re-throw a more specific custom exception or the original
            // SQLException
            throw new RuntimeException("Error registering user", e); // Re-throwing for now, will catch in servlet
        }
    }

    public List<User> getRecentRegistrations(int limit) {
        List<User> recentUsers = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY created_at DESC LIMIT ?";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, limit);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                recentUsers.add(user);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching recent registrations", e);
            throw new RuntimeException("Error fetching recent registrations", e);
        }

        return recentUsers;
    }

    public boolean isUsernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking username existence: " + username, e);
        }
        return false;
    }

    public boolean isEmailExists(String email) {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking email existence: " + email, e);
        }
        return false;
    }
}