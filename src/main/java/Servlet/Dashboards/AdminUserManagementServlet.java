package Servlet.Dashboards;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

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

@WebServlet("/admin/users/*")
public class AdminUserManagementServlet extends HttpServlet {
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
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    HttpSession session = request.getSession();
    User user = (User) session.getAttribute("user");

    // Check if user is logged in and is an admin
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
      response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
      return;
    }

    String pathInfo = request.getPathInfo();
    if (pathInfo == null || pathInfo.equals("/")) {
      showUsersPage(request, response);
    } else if (pathInfo != null && (pathInfo.equals("/add") || pathInfo.equals("/add/"))) {
      showAddUserForm(request, response);
    } else if (pathInfo != null && (pathInfo.equals("/edit") || pathInfo.equals("/edit/"))) {
      showEditUserForm(request, response);
    } else if (pathInfo != null && (pathInfo.equals("/delete") || pathInfo.equals("/delete/"))) {
      handleDeleteUser(request, response);
    } else {
      response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    System.out.println("[DEBUG] AdminUserManagementServlet.doPost called");
    HttpSession session = request.getSession();
    User user = (User) session.getAttribute("user");

    // Check if user is logged in and is an admin
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
      response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
      return;
    }

    String pathInfo = request.getPathInfo();
    if (pathInfo == null || pathInfo.equals("/")) {
      handleUserSubmission(request, response);
    } else if (pathInfo != null && (pathInfo.equals("/edit") || pathInfo.equals("/edit/"))) {
      handleUserUpdate(request, response);
    } else if (pathInfo != null && (pathInfo.equals("/delete") || pathInfo.equals("/delete/"))) {
      handleDeleteUser(request, response);
    } else {
      response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }
  }

  private void showUsersPage(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    try {
      // Load all students and teachers
      List<Student> students = studentDAO.getAllStudents();
      List<Teacher> teachers = teacherDAO.getAllTeachers();

      request.setAttribute("students", students);
      request.setAttribute("teachers", teachers);

      request.getRequestDispatcher("/WEB-INF/view/users_dashboards/admin_dashboard/users.jsp")
          .forward(request, response);
    } catch (SQLException e) {
      request.setAttribute("error", "Error loading users: " + e.getMessage());
      request.getRequestDispatcher("/WEB-INF/view/users_dashboards/admin_dashboard/users.jsp")
          .forward(request, response);
    }
  }

  private void showAddUserForm(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    request.getRequestDispatcher("/WEB-INF/view/users_dashboards/admin_dashboard/add_user.jsp")
        .forward(request, response);
  }

  private void showEditUserForm(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    String userId = request.getParameter("id");
    String role = request.getParameter("role");

    try {
      if (userId != null && role != null) {
        if ("student".equals(role)) {
          Student student = studentDAO.getStudentData(Integer.parseInt(userId));
          request.setAttribute("user", student);
        } else if ("teacher".equals(role)) {
          Teacher teacher = teacherDAO.getTeacherData(Integer.parseInt(userId));
          request.setAttribute("user", teacher);
        }
      }

      request.getRequestDispatcher("/WEB-INF/view/users_dashboards/admin_dashboard/edit_user.jsp")
          .forward(request, response);
    } catch (SQLException e) {
      response.sendRedirect(request.getContextPath() + "/admin/users?error=load_failed");
    }
  }

  private void handleUserSubmission(HttpServletRequest request, HttpServletResponse response)
      throws IOException {
    String role = request.getParameter("role");
    String username = request.getParameter("username");
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    if (role != null && username != null && email != null && password != null) {
      User user = userDAO.createUserFromRole(role);
      if (user != null) {
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(password);

        boolean success = userDAO.registerUser(user);
        if (success) {
          if ("student".equals(role)) {
            String rollNo = request.getParameter("rollno");
            String className = request.getParameter("classname");
            if (rollNo != null && className != null) {
              success = studentDAO.saveStudentData(user, rollNo, className);
            }
          } else if ("teacher".equals(role)) {
            String employeeId = request.getParameter("employee_id");
            String department = request.getParameter("department");
            if (employeeId != null && department != null) {
              success = teacherDAO.saveTeacherData((Teacher) user, employeeId, department, null);
            }
          }
        }

        if (success) {
          response.sendRedirect(request.getContextPath() + "/admin/users?success=user_added");
        } else {
          response.sendRedirect(request.getContextPath() + "/admin/users?error=add_failed");
        }
      } else {
        response.sendRedirect(request.getContextPath() + "/admin/users?error=invalid_role");
      }
    } else {
      response.sendRedirect(request.getContextPath() + "/admin/users?error=missing_fields");
    }
  }

  private void handleUserUpdate(HttpServletRequest request, HttpServletResponse response)
      throws IOException {
    String userId = request.getParameter("id");
    String role = request.getParameter("role");
    String username = request.getParameter("username");
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    if (userId != null && role != null && username != null && email != null) {
      try {
        boolean success = false;
        if ("student".equals(role)) {
          Student student = studentDAO.getStudentData(Integer.parseInt(userId));
          if (student != null) {
            student.setUsername(username);
            student.setEmail(email);
            if (password != null && !password.isEmpty()) {
              student.setPassword(password);
            }
            success = userDAO.updateUser(student);
          }
        } else if ("teacher".equals(role)) {
          Teacher teacher = teacherDAO.getTeacherData(Integer.parseInt(userId));
          if (teacher != null) {
            teacher.setUsername(username);
            teacher.setEmail(email);
            if (password != null && !password.isEmpty()) {
              teacher.setPassword(password);
            }
            success = userDAO.updateUser(teacher);
          }
        }

        if (success) {
          response.sendRedirect(request.getContextPath() + "/admin/users?success=user_updated");
        } else {
          response.sendRedirect(request.getContextPath() + "/admin/users?error=update_failed");
        }
      } catch (SQLException e) {
        response.sendRedirect(request.getContextPath() + "/admin/users?error=update_failed");
      }
    } else {
      response.sendRedirect(request.getContextPath() + "/admin/users?error=missing_fields");
    }
  }

  private void handleDeleteUser(HttpServletRequest request, HttpServletResponse response)
      throws IOException {
    String userId = request.getParameter("id");
    String role = request.getParameter("role");
    System.out.println("[DEBUG] Delete request: id=" + userId + ", role=" + role);
    if (userId != null && role != null) {
      try {
        boolean success = false;
        if ("student".equals(role)) {
          success = studentDAO.deleteStudent(Integer.parseInt(userId));
        } else if ("teacher".equals(role)) {
          success = teacherDAO.deleteTeacher(Integer.parseInt(userId));
        }

        if (success) {
          response.sendRedirect(request.getContextPath() + "/admin/users?success=user_deleted");
        } else {
          response.sendRedirect(request.getContextPath() + "/admin/users?error=delete_failed");
        }
      } catch (SQLException e) {
        response.sendRedirect(request.getContextPath() + "/admin/users?error=delete_failed");
      }
    } else {
      response.sendRedirect(request.getContextPath() + "/admin/users?error=missing_fields");
    }
  }
}