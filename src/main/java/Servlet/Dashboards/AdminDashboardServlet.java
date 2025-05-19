package Servlet.Dashboards;

import java.io.IOException;
import java.util.ArrayList;
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

@WebServlet("/admin")
public class AdminDashboardServlet extends HttpServlet {
    private UserDAO userDAO;
    private StudentDAO studentDAO;
    private TeacherDAO teacherDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        studentDAO = new StudentDAO();
        teacherDAO = new TeacherDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login?unauthorized=true");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login?unauthorized=true");
            return;
        }

        try {
            // Load all required data
            List<Student> students = studentDAO.getAllStudents();
            List<Teacher> teachers = teacherDAO.getAllTeachers();
            List<User> recentRegistrations = userDAO.getRecentRegistrations(5); // Get 5 most recent registrations

            // Create stats map
            Map<String, Object> stats = new HashMap<>();
            stats.put("totalStudents", students.size());
            stats.put("totalTeachers", teachers.size());
            stats.put("recentRegistrations", recentRegistrations);
            stats.put("averageAttendance", calculateAverageAttendance(students));

            // Set all attributes
            request.setAttribute("stats", stats);
            request.setAttribute("students", students);
            request.setAttribute("teachers", teachers);
            request.setAttribute("notifications", loadNotifications());

            // Forward to dashboard JSP
            request.getRequestDispatcher("/WEB-INF/view/users_dashboards/admin_dashboard/admin_dash.jsp")
                    .forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Error loading dashboard data: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/view/users_dashboards/admin_dashboard/admin_dash.jsp")
                    .forward(request, response);
        }
    }

    private double calculateAverageAttendance(List<Student> students) {
        // TODO: Implement actual attendance calculation
        return 85.5; // Placeholder value
    }

    private List<String> loadNotifications() {
        // TODO: Implement loading notifications from database
        List<String> notifications = new ArrayList<>();
        notifications.add("New student registration pending approval");
        notifications.add("System maintenance scheduled for next week");
        notifications.add("Attendance report generation completed");
        return notifications;
    }
}