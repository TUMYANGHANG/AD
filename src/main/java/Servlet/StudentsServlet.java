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
import model.Student;
import model.User;

@WebServlet("/students")
public class StudentsServlet extends HttpServlet {
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
      List<Student> students = teacherDAO.getAllStudents();
      request.setAttribute("students", students);
      request.getRequestDispatcher("/WEB-INF/view/users_dashboards/student_view.jsp").forward(request, response);
    } catch (SQLException e) {
      e.printStackTrace();
      response.sendRedirect(request.getContextPath() + "/teacher-dash?error=databaseError");
    }
  }
}