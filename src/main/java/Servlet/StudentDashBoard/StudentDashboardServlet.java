package Servlet.StudentDashBoard;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.User;

import java.io.IOException;

@WebServlet("/student-dash")
public class StudentDashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        if (user == null || !"student".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/view/users_dashboards/student_dash.jsp").forward(request, response);
    }
}