package Servlet.login_reg;

import static Servlet.teacherdashboard.EditProfileServlet.*;

import java.io.File;
import java.io.IOException;
import java.util.Date;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

import dao.StudentDAO;
import dao.TeacherDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import model.Admin;
import model.Student;
import model.Teacher;
import model.User;

@WebServlet("/Nav_register_process")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 3, // 3MB
        maxFileSize = 1024 * 1024 * 5, // 5MB
        maxRequestSize = 1024 * 1024 * 10 // 10MB
)
public class RegisterServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(RegisterServlet.class.getName());
    private static final String[] ALLOWED_EXTENSIONS = { ".jpg", ".jpeg", ".png", ".gif" };

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
            request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
            return;
        }

        // Create user
        User user = createUserByRole(role);
        if (user == null) {
            request.setAttribute("error", "Invalid role selected");
            request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
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
            request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
            return;
        }

        // Handle role-specific data
        if (!saveRoleSpecificData(user, role, request, response)) {
            return;
        }
        // Successful registration - redirect to login
        response.sendRedirect(request.getContextPath() + "/Nav_login?registered=true");
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
        if (!success) {
            request.setAttribute("error", "Failed to save student data");
            request.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(request, response);
        }
        return success;
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
            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
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