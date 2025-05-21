package Servlet.Dashboards;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import dao.AdminDAO;
import dao.StudentDAO;
import dao.TeacherDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Attendance;
import model.Student;
import model.Teacher;
import model.User;

@WebServlet("/admin")
public class AdminDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(AdminDashboardServlet.class.getName());
    private UserDAO userDAO;
    private StudentDAO studentDAO;
    private TeacherDAO teacherDAO;
    private AdminDAO adminDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        studentDAO = new StudentDAO();
        teacherDAO = new TeacherDAO();
        adminDAO = new AdminDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            LOGGER.warning("Unauthorized access to AdminDashboardServlet - no session or user.");
            response.sendRedirect(request.getContextPath() + "/login?unauthorized=true");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!"admin".equalsIgnoreCase(user.getRole())) {
            LOGGER.warning("Unauthorized access to AdminDashboardServlet - user is not admin.");
            response.sendRedirect(request.getContextPath() + "/login?unauthorized=true");
            return;
        }

        try {
            LOGGER.info("AdminDashboardServlet doGet method reached.");
            // Load all required data
            List<Student> students = studentDAO.getAllStudents();
            List<Teacher> teachers = teacherDAO.getAllTeachers();
            List<User> recentRegistrations = userDAO.getRecentRegistrations(5); // Get 5 most recent registrations
            int totalClasses = adminDAO.getTotalClasses();

            // Calculate attendance statistics
            double studentAttendanceRate = calculateAttendanceRate("student");
            double teacherAttendanceRate = calculateAttendanceRate("teacher");
            double overallAttendanceRate = calculateOverallAttendanceRate(); // New method for overall average

            // Prepare data for attendance report card
            Map<String, Object> attendanceSummary = new HashMap<>();
            attendanceSummary.put("totalStudents", students.size());
            attendanceSummary.put("totalTeachers", teachers.size());
            attendanceSummary.put("totalClasses", totalClasses);
            attendanceSummary.put("studentAttendanceRate", studentAttendanceRate);
            attendanceSummary.put("teacherAttendanceRate", teacherAttendanceRate);
            attendanceSummary.put("overallAttendanceRate", overallAttendanceRate);

            // Set all attributes
            request.setAttribute("totalStudents", students.size());
            request.setAttribute("totalTeachers", teachers.size());
            request.setAttribute("totalClasses", totalClasses);
            request.setAttribute("averageAttendance", overallAttendanceRate); // Using overall average for the main
                                                                              // circle
            request.setAttribute("recentRegistrations", recentRegistrations);
            request.setAttribute("notifications", loadNotifications());
            request.setAttribute("attendanceSummary", attendanceSummary); // Pass the attendance summary map

            // Forward to dashboard JSP
            request.getRequestDispatcher("/WEB-INF/view/users_dashboards/admin_dashboard/admin_dash.jsp")
                    .forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading dashboard data", e);
            request.setAttribute("error", "Error loading dashboard data: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/view/users_dashboards/admin_dashboard/admin_dash.jsp")
                    .forward(request, response);
        }
    }

    private double calculateAttendanceRate(String userType) throws SQLException {
        List<Attendance> records = adminDAO.getAttendanceRecords(null, null, userType);
        if (records.isEmpty()) {
            return 0.0;
        }
        long presentCount = records.stream()
                .filter(record -> "present".equalsIgnoreCase(record.getStatus()))
                .count();
        return (double) presentCount / records.size() * 100;
    }

    private double calculateOverallAttendanceRate() throws SQLException {
        List<Attendance> studentRecords = adminDAO.getAttendanceRecords(null, null, "student");
        List<Attendance> teacherRecords = adminDAO.getAttendanceRecords(null, null, "teacher");

        List<Attendance> allRecords = new ArrayList<>();
        allRecords.addAll(studentRecords);
        allRecords.addAll(teacherRecords);

        return calculateAttendanceRate(allRecords); // Use the helper for a combined list
    }

    private double calculateAttendanceRate(List<Attendance> records) {
        if (records.isEmpty()) {
            return 0.0;
        }
        long presentCount = records.stream()
                .filter(record -> "present".equalsIgnoreCase(record.getStatus()))
                .count();
        return (double) presentCount / records.size() * 100;
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