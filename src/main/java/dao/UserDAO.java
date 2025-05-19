package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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

    public User authenticate(String email, String password) {
        User user = null;
        String sql = "SELECT * FROM users WHERE email = ?";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("password");
                if (BCrypt.checkpw(password, storedHash)) {
                    String role = rs.getString("role");
                    user = createUserFromRole(role);
                    if (user != null) {
                        user.setId(rs.getInt("id"));
                        user.setUsername(rs.getString("username"));
                        user.setPassword(storedHash);
                        user.setRole(role);
                        user.setEmail(rs.getString("email"));
                        user.setCreatedAt(rs.getDate("created_at"));
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Authentication error for email: " + email, e);
            throw new RuntimeException("Authentication error", e);
        }
        return user;
    }

    public User getUserById(int userId) {
        String sql = "SELECT * FROM users WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                String role = rs.getString("role");
                User user = createUserFromRole(role);
                if (user != null) {
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(role);
                    user.setCreatedAt(rs.getDate("created_at"));
                    return user;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching user by ID: " + userId, e);
            throw new RuntimeException("Error fetching user", e);
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
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error registering user: " + user.getUsername(), e);
            throw new RuntimeException("Error registering user", e);
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
                String role = rs.getString("role");
                User user = createUserFromRole(role);
                if (user != null) {
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(role);
                    user.setCreatedAt(rs.getDate("created_at"));
                    recentUsers.add(user);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching recent registrations", e);
            throw new RuntimeException("Error fetching recent registrations", e);
        }

        return recentUsers;
    }
}