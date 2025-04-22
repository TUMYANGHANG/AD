package Servlet;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.User;
import java.io.IOException;

@WebServlet("/teacher/dashboard")
public class TeacherDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("../login?unauthorized=true");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!"teacher".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("../login?unauthorized=true");
            return;
        }

        request.getRequestDispatcher("/WEB-INF/views/teacher/dashboard.jsp").forward(request, response);
    }
}