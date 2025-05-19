package Servlet.login_reg;

import java.io.IOException;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet("/Nav_login_process")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check for successful registration
        if ("true".equals(request.getParameter("registered"))) {
            request.setAttribute("success", "Registration successful! Please login.");
        }

        // Check if already logged in
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            redirectBasedOnRole(user, request, response);
            return;
        }
        request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        UserDAO userDAO = new UserDAO();
        User user = userDAO.authenticate(email, password);

        if (user == null) {
            request.setAttribute("error", "Invalid email or password");
            request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        session.setAttribute("user", user);
        session.setMaxInactiveInterval(30 * 60); // 30 minutes

        redirectBasedOnRole(user, request, response);
    }

    private void redirectBasedOnRole(User user, HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String contextPath = request.getContextPath();
        switch (user.getRole().toLowerCase()) {
            case "admin":
                response.sendRedirect(contextPath + "/Nav_admin_dash");
                break;
            case "student":
                response.sendRedirect(contextPath + "/Nav_student_dashServlet");
                break;
            case "teacher":
                response.sendRedirect(contextPath + "/Nav_teacher_dashServlet");
                break;
            default:
                response.sendRedirect(contextPath + "/Nav_login?error=invalid_role");
        }
    }
}