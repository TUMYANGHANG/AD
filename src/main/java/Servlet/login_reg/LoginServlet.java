package Servlet.login_reg;

import java.io.IOException;
import java.sql.SQLException;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet(name = "LoginServlet", value = "/login_process")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Username and password are required");
            request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
            return;
        }

        try {
            User user = userDAO.authenticate(username, password);

            if (user != null) {
                // Create session and store user information
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                session.setAttribute("userId", user.getId());
                session.setAttribute("username", user.getUsername());
                session.setAttribute("role", user.getRole());

                // Redirect based on role
                String role = user.getRole().toLowerCase();
                switch (role) {
                    case "admin":
                        response.sendRedirect(request.getContextPath() + "/admin");
                        break;
                    case "teacher":
                        response.sendRedirect(request.getContextPath() + "/teacher");
                        break;
                    case "student":
                        response.sendRedirect(request.getContextPath() + "/student");
                        break;
                    default:
                        request.setAttribute("error", "Invalid user role");
                        request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
                        break;
                }
            } else {
                // Invalid credentials
                request.setAttribute("error", "Invalid username or password");
                request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error occurred. Please try again later.");
            request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is already logged in
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            String role = user.getRole().toLowerCase();

            // Redirect to appropriate dashboard
            switch (role) {
                case "admin":
                    response.sendRedirect(request.getContextPath() + "/admin");
                    break;
                case "teacher":
                    response.sendRedirect(request.getContextPath() + "/teacher");
                    break;
                case "student":
                    response.sendRedirect(request.getContextPath() + "/student");
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/Nav_login");
                    break;
            }
        } else {
            // Not logged in, show login page
            request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
        }
    }
}