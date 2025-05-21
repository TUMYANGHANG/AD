package Servlet.teacherdashboard;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import dao.TeacherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Student;
import model.User;

@WebServlet("/teacher/reports/*")
public class TeacherReportsServlet extends HttpServlet {
  private TeacherDAO teacherDAO;

  @Override
  public void init() throws ServletException {
    teacherDAO = new TeacherDAO();
  }

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    HttpSession session = request.getSession();
    User user = (User) session.getAttribute("user");

    // Check if user is logged in and is a teacher
    if (user == null || !"teacher".equalsIgnoreCase(user.getRole())) {
      response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
      return;
    }

    String pathInfo = request.getPathInfo();
    if (pathInfo == null || pathInfo.equals("/")) {
      // Show reports page
      showReportsPage(request, response);
    } else if (pathInfo.equals("/generate")) {
      // Generate report based on filters
      generateReport(request, response);
    } else {
      response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }
  }

  private void showReportsPage(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    try {
      // Load initial report data
      Map<String, Object> reportData = new HashMap<>();

      // Get all students
      List<Student> students = teacherDAO.getAllStudents();
      reportData.put("totalStudents", students.size());
      request.setAttribute("students", students);

      // Calculate attendance statistics
      Map<String, Object> attendanceStats = calculateAttendanceStats(students);
      reportData.putAll(attendanceStats);

      // Get class-wise statistics
      Map<String, Object> classStats = calculateClassStats(students);
      reportData.putAll(classStats);

      request.setAttribute("reportData", reportData);
      request.getRequestDispatcher("/WEB-INF/view/users_dashboards/teacher_dashboard/reports.jsp")
          .forward(request, response);
    } catch (Exception e) {
      e.printStackTrace();
      response.sendRedirect(request.getContextPath() + "/Nav_teacher_dashServlet?error=report_error");
    }
  }

  private void generateReport(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    String reportType = request.getParameter("type");
    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");
    String className = request.getParameter("className");

    try {
      Map<String, Object> reportData = new HashMap<>();

      // Load base statistics
      List<Student> students = teacherDAO.getAllStudents();
      reportData.put("totalStudents", students.size());

      // Generate specific report based on type
      switch (reportType) {
        case "attendance":
          generateAttendanceReport(reportData, students, startDate, endDate, className);
          break;
        case "class":
          generateClassReport(reportData, students, startDate, endDate, className);
          break;
        case "student":
          generateStudentReport(reportData, students, startDate, endDate, className);
          break;
        default:
          throw new IllegalArgumentException("Invalid report type");
      }

      request.setAttribute("reportData", reportData);
      request.getRequestDispatcher("/WEB-INF/view/users_dashboards/teacher_dashboard/reports.jsp")
          .forward(request, response);
    } catch (Exception e) {
      e.printStackTrace();
      response.sendRedirect(request.getContextPath() + "/teacher/reports?error=generation_failed");
    }
  }

  private Map<String, Object> calculateAttendanceStats(List<Student> students) {
    Map<String, Object> stats = new HashMap<>();
    // TODO: Implement actual attendance calculation
    // For now, return placeholder values
    stats.put("averageAttendance", "85.5");
    stats.put("totalPresent", "127");
    stats.put("totalAbsent", "23");
    return stats;
  }

  private Map<String, Object> calculateClassStats(List<Student> students) {
    Map<String, Object> stats = new HashMap<>();
    // TODO: Implement actual class statistics calculation
    // For now, return placeholder values
    stats.put("totalClasses", "10");
    stats.put("classesToday", "3");
    return stats;
  }

  private void generateAttendanceReport(Map<String, Object> reportData, List<Student> students,
      String startDate, String endDate, String className) {
    // TODO: Implement attendance report generation
    reportData.put("reportType", "attendance");
    reportData.put("startDate", startDate);
    reportData.put("endDate", endDate);
    reportData.put("className", className);
  }

  private void generateClassReport(Map<String, Object> reportData, List<Student> students,
      String startDate, String endDate, String className) {
    // TODO: Implement class-wise report generation
    reportData.put("reportType", "class");
    reportData.put("startDate", startDate);
    reportData.put("endDate", endDate);
    reportData.put("className", className);
  }

  private void generateStudentReport(Map<String, Object> reportData, List<Student> students,
      String startDate, String endDate, String className) {
    // TODO: Implement student-wise report generation
    reportData.put("reportType", "student");
    reportData.put("startDate", startDate);
    reportData.put("endDate", endDate);
    reportData.put("className", className);
  }
}