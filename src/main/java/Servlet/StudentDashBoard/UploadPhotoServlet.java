package Servlet.StudentDashBoard;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.User;
import dao.StudentDAO;
import java.io.*;
import java.nio.file.*;
import java.util.Arrays;
import java.util.logging.*;

@WebServlet("/upload_photo")
@MultipartConfig(fileSizeThreshold=1024*1024, maxFileSize=1024*1024*5, maxRequestSize=1024*1024*5*5)
public class UploadPhotoServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(UploadPhotoServlet.class.getName());
    private static final String PERSISTENT_UPLOAD_DIR = "C:" + File.separator + "webapp" + File.separator + "Uploads" + File.separator + "students" + File.separator;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        if (user == null || !"student".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/view/student_dashboard_functionality_works/upload_photo.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        if (user == null || !"student".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
            return;
        }

        Part filePart = request.getPart("photo");
        if (filePart == null || filePart.getSize() == 0) {
            LOGGER.warning("No file selected for upload by user ID: " + user.getId());
            request.setAttribute("error", "No file selected.");
            request.getRequestDispatcher("/WEB-INF/view/student_dashboard_functionality_works/upload_photo.jsp").forward(request, response);
            return;
        }

        String submittedFileName = filePart.getSubmittedFileName();
        if (submittedFileName == null || submittedFileName.trim().isEmpty()) {
            LOGGER.warning("Invalid file name for upload by user ID: " + user.getId());
            request.setAttribute("error", "Invalid file name.");
            request.getRequestDispatcher("/WEB-INF/view/student_dashboard_functionality_works/upload_photo.jsp").forward(request, response);
            return;
        }

        String fileExtension = submittedFileName.substring(submittedFileName.lastIndexOf(".")).toLowerCase();
        if (!Arrays.asList(".jpg", ".jpeg", ".png", ".gif").contains(fileExtension)) {
            LOGGER.warning("Invalid file extension uploaded by user ID: " + user.getId() + ", extension: " + fileExtension);
            request.setAttribute("error", "Only JPG, PNG, or GIF files are allowed.");
            request.getRequestDispatcher("/WEB-INF/view/student_dashboard_functionality_works/upload_photo.jsp").forward(request, response);
            return;
        }

        String fileName = user.getId() + "_" + Paths.get(submittedFileName).getFileName().toString();
        String contentType = filePart.getContentType();
        if (!contentType.startsWith("image/")) {
            LOGGER.warning("Non-image file uploaded by user ID: " + user.getId() + ", contentType: " + contentType);
            request.setAttribute("error", "Only image files are allowed.");
            request.getRequestDispatcher("/WEB-INF/view/student_dashboard_functionality_works/upload_photo.jsp").forward(request, response);
            return;
        }

        String persistentUploadPath = PERSISTENT_UPLOAD_DIR;
        File persistentUploadDir = new File(persistentUploadPath);
        if (!persistentUploadDir.exists()) {
            if (!persistentUploadDir.mkdirs()) {
                LOGGER.severe("Failed to create persistent upload directory: " + persistentUploadPath + "; check parent directory permissions");
                request.setAttribute("error", "Server error: Unable to create upload directory.");
                request.getRequestDispatcher("/WEB-INF/view/student_dashboard_functionality_works/upload_photo.jsp").forward(request, response);
            }
        }

        if (!persistentUploadDir.canWrite()) {
            LOGGER.severe("Persistent upload directory is not writable: " + persistentUploadPath);
            request.setAttribute("error", "Server error: Upload directory is not writable.");
            request.getRequestDispatcher("/WEB-INF/view/student_dashboard_functionality_works/upload_photo.jsp").forward(request, response);
            return;
        }

        String persistentFilePath = persistentUploadPath + fileName;
        LOGGER.info("Saving file to persistent path: " + persistentFilePath);
        try {
            filePart.write(persistentFilePath);
            LOGGER.info("File uploaded successfully to: " + persistentFilePath);
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Failed to save file to persistent path for user ID: " + user.getId() + " at path: " + persistentFilePath + "; cause: " + e.getMessage(), e);
            request.setAttribute("error", "Failed to upload file due to server error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/view/student_dashboard_functionality_works/upload_photo.jsp").forward(request, response);
            return;
        }

        String relativePath = "students/" + fileName;
        try {
            StudentDAO studentDAO = new StudentDAO();
            studentDAO.updatePhotoPath(user.getId(), relativePath);
            LOGGER.info("Photo path updated in database for user ID: " + user.getId() + ", path: " + relativePath);
            session.setAttribute("photoUploadSuccess", "Successfully added image");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to update photo path in database for user ID: " + user.getId(), e);
            request.setAttribute("error", "Failed to save photo path to database.");
            request.getRequestDispatcher("/WEB-INF/view/student_dashboard_functionality_works/upload_photo.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/student-dash");
    }
}