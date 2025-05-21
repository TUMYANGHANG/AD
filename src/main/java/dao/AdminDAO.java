package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

import model.Attendance;
import util.DatabaseConnection;

public class AdminDAO {
    private static final Logger LOGGER = Logger.getLogger(AdminDAO.class.getName());

    public int getTotalClasses() throws SQLException {
        String query = "SELECT COUNT(DISTINCT classname) as total FROM student";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query);
                ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("total");
            }
        }
        return 0;
    }

    public List<Attendance> getAttendanceRecords(String startDate, String endDate, String type) throws SQLException {
        List<Attendance> records = new ArrayList<>();
        StringBuilder query = new StringBuilder("SELECT * FROM attendance WHERE type = ?");

        if (startDate != null && endDate != null) {
            query.append(" AND date BETWEEN ? AND ?");
        }

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query.toString())) {
            pstmt.setString(1, type);

            if (startDate != null && endDate != null) {
                pstmt.setString(2, startDate);
                pstmt.setString(3, endDate);
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Attendance record = new Attendance();
                    record.setId(rs.getInt("id"));
                    record.setUserId(rs.getInt("user_id"));
                    record.setDate(rs.getDate("date"));
                    record.setStatus(rs.getString("status"));
                    record.setDay(rs.getString("type"));
                    records.add(record);
                }
            }
        }

        return records;
    }

    public List<Attendance> getClassAttendance(String className, String startDate, String endDate) throws SQLException {
        List<Attendance> records = new ArrayList<>();
        StringBuilder query = new StringBuilder(
                "SELECT a.* FROM attendance a " +
                        "JOIN student s ON a.user_id = s.user_id " +
                        "WHERE s.classname = ? AND a.type = 'student'");

        if (startDate != null && endDate != null) {
            query.append(" AND a.date BETWEEN ? AND ?");
        }

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query.toString())) {
            pstmt.setString(1, className);

            if (startDate != null && endDate != null) {
                pstmt.setString(2, startDate);
                pstmt.setString(3, endDate);
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Attendance record = new Attendance();
                    record.setId(rs.getInt("id"));
                    record.setUserId(rs.getInt("user_id"));
                    record.setDate(rs.getDate("date"));
                    record.setStatus(rs.getString("status"));
                    record.setDay(rs.getString("type"));
                    records.add(record);
                }
            }
        }

        return records;
    }

    public List<Attendance> getStudentAttendance(int studentId, String startDate, String endDate) throws SQLException {
        List<Attendance> records = new ArrayList<>();
        StringBuilder query = new StringBuilder(
                "SELECT * FROM attendance WHERE user_id = ? AND type = 'student'");

        if (startDate != null && endDate != null) {
            query.append(" AND date BETWEEN ? AND ?");
        }

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query.toString())) {
            pstmt.setInt(1, studentId);

            if (startDate != null && endDate != null) {
                pstmt.setString(2, startDate);
                pstmt.setString(3, endDate);
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Attendance record = new Attendance();
                    record.setId(rs.getInt("id"));
                    record.setUserId(rs.getInt("user_id"));
                    record.setDate(rs.getDate("date"));
                    record.setStatus(rs.getString("status"));
                    record.setDay(rs.getString("type"));
                    records.add(record);
                }
            }
        }

        return records;
    }

    public List<Attendance> getTeacherAttendance(int teacherId, String startDate, String endDate) throws SQLException {
        List<Attendance> records = new ArrayList<>();
        StringBuilder query = new StringBuilder(
                "SELECT * FROM attendance WHERE user_id = ? AND type = 'teacher'");

        if (startDate != null && endDate != null) {
            query.append(" AND date BETWEEN ? AND ?");
        }

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query.toString())) {
            pstmt.setInt(1, teacherId);

            if (startDate != null && endDate != null) {
                pstmt.setString(2, startDate);
                pstmt.setString(3, endDate);
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Attendance record = new Attendance();
                    record.setId(rs.getInt("id"));
                    record.setUserId(rs.getInt("user_id"));
                    record.setDate(rs.getDate("date"));
                    record.setStatus(rs.getString("status"));
                    record.setDay(rs.getString("type"));
                    records.add(record);
                }
            }
        }

        return records;
    }
}
