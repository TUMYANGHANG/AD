package dao;

import model.Notification;
import util.DatabaseConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    public int addNotification(Notification notif) throws SQLException {
        String sql = "INSERT INTO notifications (type, title, message) VALUES (?, ?, ?)";
        int generatedId = -1;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setString(1, notif.getType());
            pstmt.setString(2, notif.getTitle());
            pstmt.setString(3, notif.getMessage());
            int affected = pstmt.executeUpdate();
            if (affected > 0) {
                ResultSet rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    generatedId = rs.getInt(1);
                }
            }
        }
        return generatedId;
    }

    public boolean deleteNotification(int id) throws SQLException {
        String sql = "DELETE FROM notifications WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            int affected = pstmt.executeUpdate();
            return (affected > 0);
        }
    }

    public List<Notification> loadNotifications() throws SQLException {
        List<Notification> notifications = new ArrayList<>();
        String sql = "SELECT id, type, title, message, created_at FROM notifications ORDER BY created_at DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Notification notif = new Notification();
                notif.setId(rs.getInt("id"));
                notif.setType(rs.getString("type"));
                notif.setTitle(rs.getString("title"));
                notif.setMessage(rs.getString("message"));
                notif.setCreated_at(rs.getTimestamp("created_at"));
                notifications.add(notif);
            }
        }
        return notifications;
    }
} 