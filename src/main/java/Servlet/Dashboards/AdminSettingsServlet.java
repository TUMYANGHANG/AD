package Servlet.Dashboards;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet("/admin/settings/*")
public class AdminSettingsServlet extends HttpServlet {
  private UserDAO userDAO;

  @Override
  public void init() throws ServletException {
    userDAO = new UserDAO();
  }

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    HttpSession session = request.getSession();
    User user = (User) session.getAttribute("user");

    // Check if user is logged in and is an admin
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
      response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
      return;
    }

    // Load settings
    Map<String, Object> settings = loadSettings();
    request.setAttribute("settings", settings);

    request.getRequestDispatcher("/WEB-INF/view/users_dashboards/admin_dashboard/settings.jsp")
        .forward(request, response);
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    HttpSession session = request.getSession();
    User user = (User) session.getAttribute("user");

    // Check if user is logged in and is an admin
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
      response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
      return;
    }

    String pathInfo = request.getPathInfo();
    if (pathInfo == null) {
      response.sendError(HttpServletResponse.SC_BAD_REQUEST);
      return;
    }

    try {
      switch (pathInfo) {
        case "/profile":
          updateProfile(request, response, user);
          break;
        case "/password":
          updatePassword(request, response, user);
          break;
        case "/system":
          updateSystemSettings(request, response);
          break;
        default:
          response.sendError(HttpServletResponse.SC_NOT_FOUND);
      }
    } catch (Exception e) {
      e.printStackTrace();
      response.sendRedirect(request.getContextPath() + "/admin/settings?error=update_failed");
    }
  }

  private void updateProfile(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
    String updateField = request.getParameter("updateField");
    boolean updated = false;
    if ("username".equals(updateField)) {
      String username = request.getParameter("username");
      if (username != null && !username.isEmpty()) {
        user.setUsername(username);
        user.setPassword(null); // Don't change password
        userDAO.updateUser(user);
        updated = true;
      }
    } else if ("email".equals(updateField)) {
      String email = request.getParameter("email");
      if (email != null && !email.isEmpty()) {
        user.setEmail(email);
        user.setPassword(null); // Don't change password
        userDAO.updateUser(user);
        updated = true;
      }
    }
    try {
      if (updated) {
        // Reload the latest user from DB and update session
        User updatedUser = userDAO.getUserData(user.getId());
        request.getSession().setAttribute("user", updatedUser);
        response.sendRedirect(request.getContextPath() + "/admin/settings?success=profile_updated");
      } else {
        response.sendRedirect(request.getContextPath() + "/admin/settings?error=update_failed");
      }
    } catch (SQLException e) {
      e.printStackTrace();
      response.sendRedirect(request.getContextPath() + "/admin/settings?error=database_error");
    }
  }

  private void updatePassword(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
    String currentPassword = request.getParameter("currentPassword");
    String newPassword = request.getParameter("newPassword");
    String confirmPassword = request.getParameter("confirmPassword");

    try {
      if (currentPassword != null && newPassword != null && confirmPassword != null
          && newPassword.equals(confirmPassword)) {
        // Always fetch the latest user from DB
        User dbUser = userDAO.getUserData(user.getId());
        if (dbUser != null) {
          // Authenticate with latest email (since login is by email)
          if (userDAO.authenticate(dbUser.getEmail(), currentPassword) != null) {
            dbUser.setPassword(newPassword);
            userDAO.updateUser(dbUser);
            // Reload user from DB and update session
            User updatedUser = userDAO.getUserData(user.getId());
            request.getSession().setAttribute("user", updatedUser);
            response.sendRedirect(request.getContextPath() + "/admin/settings?success=password_updated");
          } else {
            response.sendRedirect(request.getContextPath() + "/admin/settings?error=invalid_current_password");
          }
        } else {
          response.sendRedirect(request.getContextPath() + "/admin/settings?error=user_not_found");
        }
      } else {
        response.sendRedirect(request.getContextPath() + "/admin/settings?error=password_mismatch");
      }
    } catch (SQLException e) {
      e.printStackTrace();
      response.sendRedirect(request.getContextPath() + "/admin/settings?error=database_error");
    }
  }

  private void updateSystemSettings(HttpServletRequest request, HttpServletResponse response) throws IOException {
    boolean emailNotifications = "on".equals(request.getParameter("emailNotifications"));
    boolean attendanceAlerts = "on".equals(request.getParameter("attendanceAlerts"));
    String attendanceThreshold = request.getParameter("attendanceThreshold");

    Map<String, Object> settings = new HashMap<>();
    settings.put("emailNotifications", emailNotifications);
    settings.put("attendanceAlerts", attendanceAlerts);
    settings.put("attendanceThreshold", attendanceThreshold);

    // TODO: Save settings to database or configuration file
    // For now, just redirect with success
    response.sendRedirect(request.getContextPath() + "/admin/settings?success=settings_updated");
  }

  private Map<String, Object> loadSettings() {
    // TODO: Load settings from database or configuration file
    // For now, return default settings
    Map<String, Object> settings = new HashMap<>();
    settings.put("emailNotifications", true);
    settings.put("attendanceAlerts", true);
    settings.put("attendanceThreshold", 75);
    return settings;
  }
}