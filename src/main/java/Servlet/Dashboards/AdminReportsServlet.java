package Servlet.Dashboards;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import dao.StudentDAO;
import dao.TeacherDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Student;
import model.Teacher;
import model.User;

@WebServlet("/admin/reports/*")
public class AdminReportsServlet extends HttpServlet {
  private StudentDAO studentDAO;
  private TeacherDAO teacherDAO;
  private UserDAO userDAO;

  @Override
  public void init() throws ServletException {
    studentDAO = new StudentDAO();
    teacherDAO = new TeacherDAO();
    userDAO = new UserDAO();
  }

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    HttpSession session = request.getSession();
    User user = (User) session.getAttribute("user");

    // Check if user is logged in and is an admin
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
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

      // Get total students
      List<Student> students = studentDAO.getAllStudents();
      reportData.put("totalStudents", students.size());

      // Get total teachers
      List<Teacher> teachers = teacherDAO.getAllTeachers();
      reportData.put("totalTeachers", teachers.size());

      // Calculate average attendance
      double averageAttendance = calculateAverageAttendance(students);
      reportData.put("averageAttendance", String.format("%.1f", averageAttendance));

      // Get total classes (placeholder for now)
      reportData.put("totalClasses", 10);

      request.setAttribute("reportData", reportData);
      request.getRequestDispatcher("/WEB-INF/view/users_dashboards/admin_dashboard/reports.jsp")
          .forward(request, response);
    } catch (Exception e) {
      e.printStackTrace();
      response.sendRedirect(request.getContextPath() + "/admin?error=report_error");
    }
  }

  private void generateReport(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    String reportType = request.getParameter("type");
    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");

    try {
      Map<String, Object> reportData = new HashMap<>();

      // Load base statistics
      List<Student> students = studentDAO.getAllStudents();
      reportData.put("totalStudents", students.size());

      List<Teacher> teachers = teacherDAO.getAllTeachers();
      reportData.put("totalTeachers", teachers.size());

      double averageAttendance = calculateAverageAttendance(students);
      reportData.put("averageAttendance", String.format("%.1f", averageAttendance));

      // Generate specific report based on type
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
        default:
          throw new IllegalArgumentException("Invalid report type");
      }

      request.setAttribute("reportData", reportData);
      request.getRequestDispatcher("/WEB-INF/view/users_dashboards/admin_dashboard/reports.jsp")
          .forward(request, response);
    } catch (Exception e) {
      e.printStackTrace();
      response.sendRedirect(request.getContextPath() + "/admin/reports?error=generation_failed");
    }
  }

  private void generateAttendanceReport(Map<String, Object> reportData, String startDate, String endDate) {
    // TODO: Implement attendance report generation
    // This would typically involve:
    // 1. Querying attendance records for the date range
    // 2. Calculating attendance statistics
    // 3. Preparing data for visualization
    reportData.put("reportType", "attendance");
    reportData.put("startDate", startDate);
    reportData.put("endDate", endDate);
  }

  private void generateClassReport(Map<String, Object> reportData, String startDate, String endDate) {
    // TODO: Implement class-wise report generation
    reportData.put("reportType", "class");
    reportData.put("startDate", startDate);
    reportData.put("endDate", endDate);
  }

  private void generateStudentReport(Map<String, Object> reportData, String startDate, String endDate) {
    // TODO: Implement student-wise report generation
    reportData.put("reportType", "student");
    reportData.put("startDate", startDate);
    reportData.put("endDate", endDate);
  }

  private double calculateAverageAttendance(List<Student> students) {
    // TODO: Implement actual attendance calculation
    // For now, return a placeholder value
    return 85.5;
  }
}