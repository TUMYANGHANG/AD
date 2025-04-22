package Servlet;

import dao.StudentDAO;
import dao.TeacherDAO;
import dao.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.*;
import java.io.IOException;
import java.util.Date;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get parameters
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String email = request.getParameter("email");
        String role = request.getParameter("role").trim().toLowerCase();

        // Validate password match
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match");
            request.getRequestDispatcher("/register").forward(request, response);
            return;
        }

        // Create user
        User user = createUserByRole(role);
        if (user == null) {
            request.setAttribute("error", "Invalid role selected");
            request.getRequestDispatcher("/register").forward(request, response);
            return;
        }

        user.setUsername(username);
        user.setPassword(password);
        user.setEmail(email);
        user.setRole(role);
        user.setCreatedAt(new Date());

        // Register user
        UserDAO userDAO = new UserDAO();
        if (!userDAO.registerUser(user)) {
            request.setAttribute("error", "Registration failed. Username may already exist.");
            request.getRequestDispatcher("/register").forward(request, response);
            return;
        }

        // Handle role-specific data
        if (!saveRoleSpecificData(user, role, request, response)) {
            return;
        }
        // Successful registration - redirect to login
        response.sendRedirect(request.getContextPath() + "/login?registered=true");
    }



    private User createUserByRole(String role) {
        switch (role.toLowerCase()) {
            case "admin": return new Admin();
            case "student": return new Student();
            case "teacher": return new Teacher();
            default: return null;
        }
    }

    private boolean saveRoleSpecificData(User user, String role,
                                         HttpServletRequest request,
                                         HttpServletResponse response) throws IOException, ServletException {
        switch (role.toLowerCase()) {
            case "student":
                return handleStudentRegistration(user, request, response);
            case "teacher":
                return handleTeacherRegistration(user, request, response);
            case "admin":
                return true;
            default:
                request.setAttribute("error", "Invalid role for saving additional data");
                request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
                return false;
        }
    }

    private boolean handleStudentRegistration(User user, HttpServletRequest request,
                                              HttpServletResponse response) throws ServletException, IOException {
        String rollNo = request.getParameter("rollno");
        String className = request.getParameter("classname");

        if (rollNo == null || className == null || rollNo.isEmpty() || className.isEmpty()) {
            request.setAttribute("error", "Missing student fields");
            request.getRequestDispatcher("/register").forward(request, response);
            return false;
        }

        boolean success = new StudentDAO().saveStudentData(user, rollNo, className);
        if (!success) {
            request.setAttribute("error", "Failed to save student data");
            request.getRequestDispatcher("/register").forward(request, response);
        }
        return success;
    }

    private boolean handleTeacherRegistration(User user, HttpServletRequest request,
                                              HttpServletResponse response) throws ServletException, IOException {
        String employeeId = request.getParameter("employeeID");
        String department = request.getParameter("department");

        if (employeeId == null || department == null || employeeId.isEmpty() || department.isEmpty()) {
            request.setAttribute("error", "Missing teacher fields");
            request.getRequestDispatcher("/register").forward(request, response);
            return false;
        }

        boolean success = new TeacherDAO().saveTeacherData(user, employeeId, department);
        if (!success) {
            request.setAttribute("error", "Failed to save teacher data");
            request.getRequestDispatcher("/register").forward(request, response);
        }
        return success;
    }
}