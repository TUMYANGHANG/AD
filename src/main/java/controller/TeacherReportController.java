package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Attendance;
import model.Student;
import model.User;
import util.DatabaseConnection;

@WebServlet("/teacher/reports")
public class TeacherReportController extends HttpServlet {
  private static final long serialVersionUID = 1L;
  private static final Logger LOGGER = Logger.getLogger(TeacherReportController.class.getName());

  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    HttpSession session = request.getSession();
    User user = (User) session.getAttribute("user");

    // Check if user is logged in and is a teacher
    if (user == null || !"teacher".equalsIgnoreCase(user.getRole())) {
      response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
      return;
    }

    try (Connection conn = DatabaseConnection.getConnection()) {
      LOGGER.info("Database connection successful");

      // Get all students
      List<Student> students = getAllStudents(conn);
      LOGGER.info("Retrieved " + students.size() + " students");
      request.setAttribute("students", students);

      // Get attendance data for all students
      Map<Integer, List<Attendance>> studentAttendanceMap = getStudentAttendance(conn);
      LOGGER.info("Retrieved attendance data for " + studentAttendanceMap.size() + " students");

      Map<String, Object> reportData = new HashMap<>();
      reportData.put("studentAttendanceMap", studentAttendanceMap);
      request.setAttribute("reportData", reportData);

      // Forward to reports.jsp
      request.getRequestDispatcher("/WEB-INF/view/users_dashboards/teacher_dashboard/reports.jsp")
          .forward(request, response);

    } catch (SQLException e) {
      LOGGER.severe("Database error: " + e.getMessage());
      e.printStackTrace();
      request.setAttribute("errorMessage", "Database error: " + e.getMessage());
      request.getRequestDispatcher("/WEB-INF/view/error.jsp").forward(request, response);
    }
  }

  private List<Student> getAllStudents(Connection conn) throws SQLException {
    List<Student> students = new ArrayList<>();
    String query = "SELECT * FROM users WHERE role = 'student'";

    try (PreparedStatement pstmt = conn.prepareStatement(query);
        ResultSet rs = pstmt.executeQuery()) {

      while (rs.next()) {
        Student student = new Student();
        student.setId(rs.getInt("id"));
        student.setUsername(rs.getString("username"));
        student.setEmail(rs.getString("email"));
        students.add(student);
      }
    }
    return students;
  }

  private Map<Integer, List<Attendance>> getStudentAttendance(Connection conn) throws SQLException {
    Map<Integer, List<Attendance>> studentAttendanceMap = new HashMap<>();
    String query = "SELECT a.*, u.username FROM attendence a " +
        "JOIN users u ON a.User_ID = u.id " +
        "WHERE u.role = 'student' " +
        "ORDER BY a.Date DESC";

    try (PreparedStatement pstmt = conn.prepareStatement(query);
        ResultSet rs = pstmt.executeQuery()) {

      while (rs.next()) {
        int studentId = rs.getInt("User_ID");
        Attendance attendance = new Attendance();
        attendance.setId(rs.getInt("AttendenceID"));
        attendance.setUserId(studentId);
        attendance.setDate(rs.getDate("Date"));
        attendance.setFaculty(rs.getString("Faculty"));
        attendance.setStatus(rs.getString("Status"));
        attendance.setDay(rs.getString("Day"));

        studentAttendanceMap.computeIfAbsent(studentId, k -> new ArrayList<>())
            .add(attendance);
      }
    }
    return studentAttendanceMap;
  }
}