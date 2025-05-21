package Servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import dao.TeacherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Notification;
import model.Student;
import model.Teacher;
import model.User;

@WebServlet({ "/teacher", "/teacher-dashboard" })
public class TeacherDashboardServlet extends HttpServlet {
  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    HttpSession session = request.getSession();
    User user = (User) session.getAttribute("user");

    // Check if user is logged in and is a teacher
    if (user == null || !"teacher".equalsIgnoreCase(user.getRole())) {
      response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
      return;
    }

    try {
      TeacherDAO teacherDAO = new TeacherDAO();
      Teacher teacher = teacherDAO.getTeacherData(user.getId());
      List<Student> students = teacherDAO.getAllStudents();
      List<Notification> notifications = teacherDAO.getAllNotifications();

      if (teacher == null) {
        response.sendRedirect(request.getContextPath() + "/login?error=profileNotFound");
        return;
      }

      request.setAttribute("teacher", teacher);
      request.setAttribute("students", students);
      request.setAttribute("notifications", notifications);
      request.getRequestDispatcher("/WEB-INF/view/users_dashboards/teacher_dash.jsp").forward(request, response);
    } catch (SQLException e) {
      e.printStackTrace();
      response.sendRedirect(request.getContextPath() + "/login?error=databaseError");
    }
  }
}