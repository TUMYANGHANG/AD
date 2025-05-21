package Servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Enumeration;

import dao.TeacherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet("/SaveAttendanceServlet")
public class SaveAttendanceServlet extends HttpServlet {
  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    HttpSession session = request.getSession();
    User user = (User) session.getAttribute("user");

    // Check if user is logged in and is a teacher
    if (user == null || !"teacher".equalsIgnoreCase(user.getRole())) {
      response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
      return;
    }

    String attendanceDateStr = request.getParameter("attendanceDate");
    String className = request.getParameter("className");

    if (attendanceDateStr == null || className == null || attendanceDateStr.isEmpty() || className.isEmpty()) {
      session.setAttribute("errorMessage", "Please select both date and class");
      response.sendRedirect(request.getContextPath() + "/manage-attendance");
      return;
    }

    java.sql.Date attendanceDate = null;
    String dayOfWeek = null;
    try {
      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
      java.util.Date parsedDate = sdf.parse(attendanceDateStr);
      attendanceDate = new java.sql.Date(parsedDate.getTime());

      // Get Day of Week
      Calendar calendar = Calendar.getInstance();
      calendar.setTime(parsedDate);
      dayOfWeek = new SimpleDateFormat("EEEE").format(calendar.getTime()); // e.g., "Monday"

    } catch (ParseException e) {
      e.printStackTrace();
      session.setAttribute("errorMessage", "Invalid date format");
      response.sendRedirect(request.getContextPath() + "/manage-attendance");
      return;
    }

    try {
      TeacherDAO teacherDAO = new TeacherDAO();
      boolean success = true;
      Enumeration<String> paramNames = request.getParameterNames();

      while (paramNames.hasMoreElements()) {
        String paramName = paramNames.nextElement();
        if (paramName.startsWith("attendance_")) {
          String studentId = paramName.substring("attendance_".length());
          String status = request.getParameter(paramName);

          // Pass java.sql.Date object and dayOfWeek
          if (!teacherDAO.saveAttendance(Integer.parseInt(studentId), attendanceDate, status, className, dayOfWeek)) {
            success = false;
            // Optionally, log which student failed
          }
        }
      }

      if (success) {
        session.setAttribute("successMessage", "Attendance saved successfully");
      } else {
        session.setAttribute("errorMessage", "Failed to save attendance for some students");
      }
    } catch (SQLException e) {
      e.printStackTrace();
      session.setAttribute("errorMessage", "Database error occurred while saving attendance");
    }

    response.sendRedirect(request.getContextPath() + "/manage-attendance");
  }
}