package Servlet.login_reg;

import static Servlet.teacherdashboard.EditProfileServlet.*;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

import dao.StudentDAO;
import dao.TeacherDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import model.Admin;
import model.Student;
import model.Teacher;
import model.User;
import util.DatabaseConnection;

@WebServlet("/Nav_register_process")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(RegisterServlet.class.getName());
    private static final String[] ALLOWED_EXTENSIONS = { ".jpg", ".jpeg", ".png", ".gif" };

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get form data
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String role = request.getParameter("role");

        // Validate input
        if (username == null || username.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                confirmPassword == null || confirmPassword.trim().isEmpty() ||
                role == null || role.trim().isEmpty()) {
            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
            return;
        }

        // Validate password match
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
            return;
        }

        try {
            UserDAO userDAO = new UserDAO();

            // Check if email already exists
            String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
            try (Connection conn = DatabaseConnection.getConnection();
                    PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, email);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    request.setAttribute("error", "Email already registered. Please use a different email.");
                    request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
                    return;
                }
            }

            // Create user object using the factory method
            User user = userDAO.createUserFromRole(role);
            if (user == null) {
                request.setAttribute("error", "Invalid role selected.");
                request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
                return;
            }

            // Set user properties
            user.setUsername(username);
            user.setEmail(email);
            user.setPassword(password);
            user.setRole(role);
            user.setCreatedAt(new Date());

            // Register user
            boolean success = userDAO.registerUser(user);

            if (success) {
                // Set success message and redirect to login
                request.setAttribute("success", "Registration successful! Please login to continue.");
                response.sendRedirect(request.getContextPath() + "/Nav_login?registered=true");
            } else {
                request.setAttribute("error", "Registration failed. Please try again.");
                request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("error", "An error occurred during registration. Please try again later.");
            request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
        }
    }

    private User createUserByRole(String role) {
        switch (role.toLowerCase()) {
            case "admin":
                return new Admin();
            case "student":
                return new Student();
            case "teacher":
                return new Teacher();
            default:
                return null;
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
            request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
            return false;
        }

        boolean success = new StudentDAO().saveStudentData(user, rollNo, className);
        if (success) {
            // Student registration successful, now save a notification
            try {
                String notificationTitle = "New Student Registered";
                String notificationMessage = "A new student, " + user.getUsername() + ", has been registered.";
                new TeacherDAO().saveNotification("student_registration", notificationTitle, notificationMessage);
                LOGGER.info("Notification saved for new student: " + user.getUsername());
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error saving notification for new student registration", e);
                // Log the error, but don't necessarily fail the registration process
            }
            return true;
        } else {
            request.setAttribute("error", "Failed to save student data");
            request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
            return false;
        }
    }

    private boolean handleTeacherRegistration(User user, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {
        String employeeId = request.getParameter("employeeID");
        String department = request.getParameter("department");
        Part photoPart = request.getPart("photo");

        if (employeeId == null || department == null || employeeId.isEmpty() || department.isEmpty()) {
            request.setAttribute("error", "Missing teacher fields");
            request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
            return false;
        }

        // Handle photo upload
        String photoPath = null;
        if (photoPart != null && photoPart.getSize() > 0) {
            String fileName = photoPart.getSubmittedFileName();
            String extension = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
            if (!java.util.Arrays.asList(ALLOWED_EXTENSIONS).contains(extension)) {
                LOGGER.warning("Invalid file extension for user ID: " + user.getId() + ": " + extension);
                request.setAttribute("error", "Only image files (.jpg, .jpeg, .png, .gif) are allowed.");
                request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
                return false;
            }
            fileName = UUID.randomUUID() + "_" + fileName;
            // Save directly under the web context root's Images directory
            String uploadPath = getServletContext().getRealPath("/") + UPLOAD_DIR;
            LOGGER.info("Upload path: " + uploadPath);
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                try {
                    uploadDir.mkdirs();
                } catch (SecurityException e) {
                    LOGGER.log(Level.SEVERE, "Failed to create upload directory: " + uploadPath, e);
                    request.setAttribute("error", "Server error: Unable to create upload directory.");
                    request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
                    return false;
                }
            }
            String filePath = uploadPath + File.separator + fileName;
            try {
                photoPart.write(filePath);
                LOGGER.info("Photo uploaded successfully to: " + filePath);
                photoPath = fileName;
            } catch (IOException e) {
                LOGGER.log(Level.SEVERE, "Failed to write uploaded file: " + filePath, e);
                request.setAttribute("error", "Failed to upload photo.");
                request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
                return false;
            }
        } else {
            LOGGER.info("No photo uploaded or photo is empty for user ID: " + user.getId());
        }

        boolean success = new TeacherDAO().saveTeacherData((Teacher) user, employeeId, department, photoPath);
        if (!success) {
            request.setAttribute("error", "Failed to save teacher data");
            request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
        }
        return success;
    }
}