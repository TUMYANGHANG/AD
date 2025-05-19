package Servlet.teacherdashboard;

import dao.StudentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import model.User;

@WebServlet("/DeleteStudentServlet")
public class DeleteStudentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private StudentDAO studentDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        studentDAO = new StudentDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();

        // Proper authentication check using User object
        User user = (User) session.getAttribute("user");
        if (user == null || !"teacher".equalsIgnoreCase(user.getRole())) {
            session.setAttribute("errorMessage", "Unauthorized access");
            response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
            return;
        }

        String studentIdParam = request.getParameter("studentId");

        if (studentIdParam == null || studentIdParam.isEmpty()) {
            session.setAttribute("errorMessage", "Student ID is required");
            response.sendRedirect(request.getContextPath() + "/Nav_teacher_dashServlet");
            return;
        }

        try {
            int studentId = Integer.parseInt(studentIdParam);
            boolean isDeleted = studentDAO.deleteStudent(studentId);

            if (isDeleted) {
                session.setAttribute("successMessage", "Student deleted successfully");
                // Add debug log
                System.out.println("Successfully deleted student ID: " + studentId);
            } else {
                session.setAttribute("errorMessage", "Student not found or could not be deleted");
                System.out.println("Failed to delete student ID: " + studentId);
            }
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid Student ID format");
            System.out.println("Invalid student ID format: " + studentIdParam);
        } catch (SQLException e) {
            session.setAttribute("errorMessage", "Error deleting student. Please try again.");
            System.out.println("Database error deleting student: " + e.getMessage());
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/Nav_teacher_dashServlet");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/Nav_teacher_dashServlet");
    }
}