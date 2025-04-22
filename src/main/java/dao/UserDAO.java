package dao;

import model.User;
import model.Admin;
import model.Student;
import model.Teacher;
import org.mindrot.jbcrypt.BCrypt;
import util.DatabaseConnection;
import java.sql.*;

public class UserDAO {

    public User authenticate(String username, String password) {
        User user = null;
        // Fixed query - removed password check from SQL (we'll verify with BCrypt)
        String sql = "SELECT * FROM users WHERE username = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, username);
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
            throw new RuntimeException("Authentication error", e);
        }
        return user;
    }

    //fetch user by their unique id
    public User getUserById(int id) {
        User user = null;
        String sql = "SELECT * FROM users WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {    //prepare sql query

            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {    //id user exists
                String role = rs.getString("role");     //get the role
                // Instantiate the appropriate subclass based on role
                user = createUserFromRole(role);
                if (user != null) {     //Assign values
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setPassword(rs.getString("password"));
                    user.setRole(role);
                    user.setEmail(rs.getString("email"));          // Assuming column exists
                    user.setCreatedAt(rs.getDate("created_at"));   // Assuming column exists
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error retrieving user by ID: " + e.getMessage());
        }
        return user;
    }

    // Helper method to create the appropriate User subclass based on role
    private User createUserFromRole(String role) {
        switch (role.toLowerCase()) {
            case "admin":
                return new Admin();
            case "student":
                return new Student();
            case "teacher":
                return new Teacher();
            default:
                return null; // Or throw an exception if role is invalid
        }
    }

    public boolean registerUser(User user) {
        String sql = "INSERT INTO users (username, password, email, role, created_at) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS))
        {

            // Hash password before storing
            String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());

            //correct parameter order
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, hashedPassword);
            pstmt.setString(3, user.getEmail());
            pstmt.setString(4, user.getRole().toLowerCase());
            pstmt.setDate(5, new java.sql.Date(user.getCreatedAt().getTime()));


            int rows = pstmt.executeUpdate();       //insert row

            if (rows > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {  // Retrieve the generated ID.
                    if (generatedKeys.next()) {
                        user.setId(generatedKeys.getInt(1));  // Set the ID in the user object.
                    }
                }
                return true;
            }
            return false;
        } catch (SQLException e) {
            throw new RuntimeException("Error registering user", e);
        }
    }}

