package Servlet.Dashboards;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import dao.AdminDAO;
import dao.StudentDAO;
import dao.TeacherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Attendance;
import model.Student;
import model.Teacher;
import model.User;
import util.DatabaseConnection;

@WebServlet("/admin/reports/*")
public class AdminReportsServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;
  private static final Logger LOGGER = Logger.getLogger(AdminReportsServlet.class.getName());
  private AdminDAO adminDAO;
  private TeacherDAO teacherDAO;
  private StudentDAO studentDAO;

  @Override
  public void init() throws ServletException {
    adminDAO = new AdminDAO();
    teacherDAO = new TeacherDAO();
    studentDAO = new StudentDAO();
  }

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    LOGGER.info("AdminReportsServlet doGet method reached.");
    HttpSession session = request.getSession(false);
    if (session == null || session.getAttribute("user") == null) {
      LOGGER.warning("Unauthorized access to AdminReportsServlet - no session or user.");
      response.sendRedirect(request.getContextPath() + "/login?unauthorized=true");
      return;
    }

    User user = (User) session.getAttribute("user");
    if (!"admin".equalsIgnoreCase(user.getRole())) {
      LOGGER.warning("Unauthorized access to AdminReportsServlet - user is not admin.");
      response.sendRedirect(request.getContextPath() + "/login?unauthorized=true");
      return;
    }

    String action = request.getPathInfo();
    LOGGER.info("AdminReportsServlet action: " + action);

    if (action == null || action.equals("/")) {
      showReportsPage(request, response);
    } else if (action.equals("/generate")) {
      generateReport(request, response);
    } else {
      LOGGER.warning("AdminReportsServlet - Resource not found for action: " + action);
      response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }
  }

  private void showReportsPage(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    LOGGER.info("AdminReportsServlet - showReportsPage method reached.");
    try {
      // Get total counts
      int totalStudents = studentDAO.getAllStudents().size();
      int totalTeachers = teacherDAO.getAllTeachers().size();
      int totalClasses = adminDAO.getTotalClasses();

      // Calculate attendance statistics
      double studentAttendance = calculateStudentAttendance();
      double teacherAttendance = calculateTeacherAttendance();

      // Get attendance records for both students and teachers
      List<Attendance> studentRecordsList = adminDAO.getAttendanceRecords(null, null, "student");
      List<Attendance> teacherRecords = adminDAO.getAttendanceRecords(null, null, "teacher");

      // Create a map of student attendance records by student ID for easier access in
      // JSP
      Map<Integer, List<Attendance>> studentAttendanceMap = new HashMap<>();
      for (Attendance record : studentRecordsList) {
        studentAttendanceMap.computeIfAbsent(record.getUserId(), k -> new ArrayList<>()).add(record);
      }

      // Debugging logs
      LOGGER.info("AdminReportsServlet - showReportsPage: Number of students fetched: "
          + (studentRecordsList != null ? studentRecordsList.size() : "null"));
      LOGGER.info(
          "AdminReportsServlet - showReportsPage: studentAttendanceMap is null: " + (studentAttendanceMap == null));
      if (studentAttendanceMap != null) {
        LOGGER.info("AdminReportsServlet - showReportsPage: studentAttendanceMap size: " + studentAttendanceMap.size());
      }

      // Prepare report data
      Map<String, Object> reportData = new HashMap<>();
      reportData.put("totalStudents", totalStudents);
      reportData.put("totalTeachers", totalTeachers);
      reportData.put("totalClasses", totalClasses);
      reportData.put("studentAttendance", studentAttendance); // Overall student attendance rate
      reportData.put("teacherAttendance", teacherAttendance);
      reportData.put("studentRecords", studentRecordsList); // Keep the list for other potential uses
      reportData.put("teacherRecords", teacherRecords);
      reportData.put("studentAttendanceMap", studentAttendanceMap); // New map for JSP table

      request.setAttribute("reportData", reportData);
      LOGGER.info("Forwarding to admin reports JSP.");
      request.getRequestDispatcher("/WEB-INF/view/users_dashboards/admin_dashboard/reports.jsp")
          .forward(request, response);
    } catch (Exception e) {
      LOGGER.log(Level.SEVERE, "Error in showReportsPage", e);
      response.sendRedirect(request.getContextPath() + "/admin?error=report_error");
    }
  }

  private void generateReport(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    LOGGER.info("AdminReportsServlet - generateReport method reached.");
    try {
      String reportType = request.getParameter("type");
      String startDate = request.getParameter("startDate");
      String endDate = request.getParameter("endDate");

      Map<String, Object> reportData = new HashMap<>();

      switch (reportType) {
        case "attendance":
          generateAttendanceReport(reportData, startDate, endDate);
          break;
        case "class":
          generateClassReport(reportData, startDate, endDate);
          break;
        case "student":
          generateStudentReport(reportData, startDate, endDate);
          break;
        case "teacher":
          generateTeacherReport(reportData, startDate, endDate);
          break;
        default:
          LOGGER.warning("Invalid report type: " + reportType);
          response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid report type");
          return;
      }

      request.setAttribute("reportData", reportData);
      LOGGER.info("Forwarding generated report to admin reports JSP.");
      request.getRequestDispatcher("/WEB-INF/view/users_dashboards/admin_dashboard/reports.jsp")
          .forward(request, response);
    } catch (SQLException e) {
      LOGGER.log(Level.SEVERE, "SQL Error in generateReport", e);
      response.sendRedirect(request.getContextPath() + "/admin?error=report_error");
    } catch (Exception e) {
      LOGGER.log(Level.SEVERE, "Error in generateReport", e);
      response.sendRedirect(request.getContextPath() + "/admin?error=report_error");
    }
  }

  private double calculateStudentAttendance() throws SQLException {
    LOGGER.info("AdminReportsServlet - calculateStudentAttendance method reached.");
    List<Attendance> records = adminDAO.getAttendanceRecords(null, null, "student");
    return calculateAttendanceRate(records);
  }

  private double calculateTeacherAttendance() throws SQLException {
    LOGGER.info("AdminReportsServlet - calculateTeacherAttendance method reached.");
    List<Attendance> records = adminDAO.getAttendanceRecords(null, null, "teacher");
    return calculateAttendanceRate(records);
  }

  private double calculateAttendanceRate(List<Attendance> records) {
    LOGGER.info("AdminReportsServlet - calculateAttendanceRate method reached.");
    if (records.isEmpty()) {
      return 0.0;
    }
    long presentCount = records.stream()
        .filter(record -> "present".equalsIgnoreCase(record.getStatus()))
        .count();
    return (double) presentCount / records.size() * 100;
  }

  private void generateAttendanceReport(Map<String, Object> reportData, String startDate, String endDate)
      throws SQLException {
    LOGGER.info("AdminReportsServlet - generateAttendanceReport method reached.");
    List<Attendance> studentAttendanceList = adminDAO.getAttendanceRecords(startDate, endDate, "student");
    List<Attendance> teacherAttendance = adminDAO.getAttendanceRecords(startDate, endDate, "teacher");

    // Create a map of student attendance records by student ID for easier access in
    // JSP
    Map<Integer, List<Attendance>> studentAttendanceMap = new HashMap<>();
    for (Attendance record : studentAttendanceList) {
      studentAttendanceMap.computeIfAbsent(record.getUserId(), k -> new ArrayList<>()).add(record);
    }

    double studentAttendanceRate = calculateAttendanceRate(studentAttendanceList);
    double teacherAttendanceRate = calculateAttendanceRate(teacherAttendance);

    reportData.put("studentAttendance", studentAttendanceRate);
    reportData.put("teacherAttendance", teacherAttendanceRate);
    reportData.put("studentRecords", studentAttendanceList); // Keep the list for other potential uses
    reportData.put("teacherRecords", teacherAttendance);
    reportData.put("studentAttendanceMap", studentAttendanceMap); // New map for JSP table
  }

  private void generateClassReport(Map<String, Object> reportData, String startDate, String endDate)
      throws SQLException {
    LOGGER.info("AdminReportsServlet - generateClassReport method reached.");
    String query = "SELECT DISTINCT classname FROM student";
    Map<String, List<Attendance>> classAttendance = new HashMap<>();

    try (Connection conn = DatabaseConnection.getConnection();
        PreparedStatement pstmt = conn.prepareStatement(query);
        ResultSet rs = pstmt.executeQuery()) {
      while (rs.next()) {
        String className = rs.getString("classname");
        List<Attendance> attendance = adminDAO.getClassAttendance(className, startDate, endDate);
        classAttendance.put(className, attendance);
      }
    }

    reportData.put("classAttendance", classAttendance);
  }

  private void generateStudentReport(Map<String, Object> reportData, String startDate, String endDate)
      throws SQLException {
    LOGGER.info("AdminReportsServlet - generateStudentReport method reached.");
    List<Student> students = studentDAO.getAllStudents();
    Map<Integer, List<Attendance>> studentAttendance = new HashMap<>();

    for (Student student : students) {
      List<Attendance> attendance = adminDAO.getStudentAttendance(student.getId(), startDate, endDate);
      studentAttendance.put(student.getId(), attendance);
    }

    reportData.put("studentAttendance", studentAttendance);
  }

  private void generateTeacherReport(Map<String, Object> reportData, String startDate, String endDate)
      throws SQLException {
    LOGGER.info("AdminReportsServlet - generateTeacherReport method reached.");
    List<Teacher> teachers = teacherDAO.getAllTeachers();
    Map<Integer, List<Attendance>> teacherAttendance = new HashMap<>();

    for (Teacher teacher : teachers) {
      List<Attendance> attendance = adminDAO.getTeacherAttendance(teacher.getId(), startDate, endDate);
      teacherAttendance.put(teacher.getId(), attendance);
    }

    reportData.put("teacherAttendance", teacherAttendance);
  }
}