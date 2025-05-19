package Servlet.teacherdashboard;

import dao.TeacherDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Teacher;
import model.User;

import java.io.File;
import java.io.IOException;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/EditProfileServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 3, // 3MB
        maxFileSize = 1024 * 1024 * 5,      // 5MB
        maxRequestSize = 1024 * 1024 * 10   // 10MB
)
public class EditProfileServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(EditProfileServlet.class.getName());
    public static final String UPLOAD_DIR = "Images";
    private static final String[] ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif"};

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || !"teacher".equalsIgnoreCase(user.getRole())) {
            LOGGER.info("Unauthorized access attempt, redirecting to login.");
            response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
            return;
        }
        LOGGER.info("Forwarding to editProfile.jsp for user ID: " + user.getId());
        request.getRequestDispatcher("/WEB-INF/view/teacher_dashboard_functionality/editProfile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || !"teacher".equalsIgnoreCase(user.getRole())) {
            LOGGER.info("Unauthorized access attempt, redirecting to login.");
            response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
            return;
        }

        LOGGER.info("Processing profile update for user ID: " + user.getId());

        // Retrieve form fields
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String department = request.getParameter("department");
        String employeeID = request.getParameter("employeeID");
        Part photoPart = null;
        try {
            photoPart = request.getPart("photo");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error retrieving photo part for user ID: " + user.getId(), e);
            request.setAttribute("error", "Error processing photo upload.");
            request.getRequestDispatcher("/WEB-INF/view/teacher_dashboard_functionality/editProfile.jsp").forward(request, response);
            return;
        }

        // Validate inputs
        if (username == null || username.trim().isEmpty() ||
                email == null || email.trim().isEmpty() || !email.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$") ||
                department == null || department.trim().isEmpty() ||
                employeeID == null || employeeID.trim().isEmpty()) {
            LOGGER.warning("Validation failed for user ID: " + user.getId());
            request.setAttribute("error", "All fields are required and email must be valid.");
            request.getRequestDispatcher("/WEB-INF/view/teacher_dashboard_functionality/editProfile.jsp").forward(request, response);
            return;
        }

        // Validate photo file type
        String photoPath = null;
        if (photoPart != null && photoPart.getSize() > 0) {
            String fileName = photoPart.getSubmittedFileName();
            String extension = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
            if (!java.util.Arrays.asList(ALLOWED_EXTENSIONS).contains(extension)) {
                LOGGER.warning("Invalid file extension for user ID: " + user.getId() + ": " + extension);
                request.setAttribute("error", "Only image files (.jpg, .jpeg, .png, .gif) are allowed.");
                request.getRequestDispatcher("/WEB-INF/view/teacher_dashboard_functionality/editProfile.jsp").forward(request, response);
                return;
            }
            fileName = UUID.randomUUID() + "_" + fileName;
            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                try {
                    uploadDir.mkdirs();
                } catch (SecurityException e) {
                    LOGGER.log(Level.SEVERE, "Failed to create upload directory: " + uploadPath, e);
                    request.setAttribute("error", "Server error: Unable to create upload directory.");
                    request.getRequestDispatcher("/WEB-INF/view/teacher_dashboard_functionality/editProfile.jsp").forward(request, response);
                    return;
                }
            }
            String filepath = uploadPath + File.separator + fileName;
            try {
                photoPart.write(filepath);
                LOGGER.info("Photo uploaded successfully to: " + filepath + " for user ID: " + user.getId());
                photoPath = fileName;
            } catch (IOException e) {
                LOGGER.log(Level.SEVERE, "Failed to write photo to: " + filepath + " for user ID: " + user.getId(), e);
                request.setAttribute("error", "Error saving uploaded photo.");
                request.getRequestDispatcher("/WEB-INF/view/teacher_dashboard_functionality/editProfile.jsp").forward(request, response);
                return;
            }
        }

        // Update user data
        Teacher updatedTeacher = new Teacher();
        updatedTeacher.setId(user.getId());
        updatedTeacher.setUsername(username);
        updatedTeacher.setEmail(email);
        updatedTeacher.setRole("teacher");
        updatedTeacher.setCreatedAt(user.getCreatedAt());
        updatedTeacher.setPassword(user.getPassword());
        updatedTeacher.setDepartment(department);
        updatedTeacher.setEmployeeId(employeeID);
        if (photoPath != null) {
            updatedTeacher.setPhotoPath(photoPath);
        } else {
            updatedTeacher.setPhotoPath(((Teacher) user).getPhotoPath());
        }

        // Update database
        UserDAO userDAO = new UserDAO();
        boolean userUpdated;
        try {
            userUpdated = userDAO.updateUser(updatedTeacher);
            LOGGER.info("User update " + (userUpdated ? "successful" : "failed") + " for user ID: " + user.getId());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating user data for ID: " + user.getId(), e);
            request.setAttribute("error", "Database error: Unable to update user data.");
            request.getRequestDispatcher("/WEB-INF/view/teacher_dashboard_functionality/editProfile.jsp").forward(request, response);
            return;
        }

        TeacherDAO teacherDAO = new TeacherDAO();
        boolean teacherUpdated;
        try {
            teacherUpdated = teacherDAO.saveTeacherData(updatedTeacher, employeeID, department, photoPath);
            LOGGER.info("Teacher update " + (teacherUpdated ? "successful" : "failed") + " for user ID: " + user.getId());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating teacher data for ID: " + user.getId(), e);
            request.setAttribute("error", "Database error: Unable to update teacher data.");
            request.getRequestDispatcher("/WEB-INF/view/teacher_dashboard_functionality/editProfile.jsp").forward(request, response);
            return;
        }

        if (userUpdated && teacherUpdated) {
            // Update session user
            request.getSession().setAttribute("user", updatedTeacher);
            request.getSession().setAttribute("successMessage", "Successfully saved details.");
            LOGGER.info("Redirecting to Nav_teacher_dashServlet for user ID: " + user.getId());
            response.sendRedirect(request.getContextPath() + "/Nav_teacher_dashServlet");
        } else {
            LOGGER.warning("Profile update failed for user ID: " + user.getId());
            request.setAttribute("error", "Failed to update profile. Please try again.");
            request.getRequestDispatcher("/WEB-INF/view/teacher_dashboard_functionality/editProfile.jsp").forward(request, response);
        }
    }
}