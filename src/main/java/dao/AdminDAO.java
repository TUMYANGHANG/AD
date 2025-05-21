package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Attendance;
import model.Class;
import util.DBConnection;

public class AdminDAO {
    private Connection conn;

    public AdminDAO() {
        try {
            conn = DBConnection.getConnection();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Class> getAllClasses() throws SQLException {
        List<Class> classes = new ArrayList<>();
        String query = "SELECT * FROM classes";

        try (Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                Class cls = new Class();
                cls.setId(rs.getInt("id"));
                cls.setName(rs.getString("name"));
                cls.setDescription(rs.getString("description"));
                classes.add(cls);
            }
        }

        return classes;
    }

    public List<Attendance> getAttendanceRecords(String startDate, String endDate, String type) throws SQLException {
        List<Attendance> records = new ArrayList<>();
        StringBuilder query = new StringBuilder("SELECT * FROM attendance WHERE type = ?");

        if (startDate != null && endDate != null) {
            query.append(" AND date BETWEEN ? AND ?");
        }

        try (PreparedStatement pstmt = conn.prepareStatement(query.toString())) {
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
                    record.setType(rs.getString("type"));
                    records.add(record);
                }
            }
        }

        return records;
    }

    public List<Attendance> getClassAttendance(int classId, String startDate, String endDate) throws SQLException {
        List<Attendance> records = new ArrayList<>();
        StringBuilder query = new StringBuilder(
                "SELECT a.* FROM attendance a " +
                        "JOIN students s ON a.user_id = s.id " +
                        "WHERE s.class_id = ? AND a.type = 'student'");

        if (startDate != null && endDate != null) {
            query.append(" AND a.date BETWEEN ? AND ?");
        }

        try (PreparedStatement pstmt = conn.prepareStatement(query.toString())) {
            pstmt.setInt(1, classId);

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
                    record.setType(rs.getString("type"));
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

        try (PreparedStatement pstmt = conn.prepareStatement(query.toString())) {
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
                    record.setType(rs.getString("type"));
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

        try (PreparedStatement pstmt = conn.prepareStatement(query.toString())) {
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
                    record.setType(rs.getString("type"));
                    records.add(record);
                }
            }
        }

        return records;
    }
}
