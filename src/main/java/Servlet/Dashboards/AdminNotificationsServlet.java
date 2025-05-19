package Servlet.Dashboards;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.Notification;
import dao.NotificationDAO;

@WebServlet("/admin/notifications/*")
public class AdminNotificationsServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    HttpSession session = request.getSession();
    User user = (User) session.getAttribute("user");

    // Check if user is logged in and is an admin
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
      response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
      return;
    }

    String pathInfo = request.getPathInfo();
    if (pathInfo == null || pathInfo.equals("/")) {
      // Show notifications page
      showNotificationsPage(request, response);
    } else if (pathInfo.equals("/mark-read")) {
      // Mark notification as read
      markNotificationAsRead(request, response);
    } else if (pathInfo.equals("/action")) {
      // Handle notification action
      handleNotificationAction(request, response);
    } else {
      response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    String action = request.getParameter("action");
    if ("create".equals(action)) {
      createNotification(request, response);
    } else if ("delete".equals(action)) {
      deleteNotification(request, response);
    } else {
      response.sendError(HttpServletResponse.SC_BAD_REQUEST);
    }
  }

  private void showNotificationsPage(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    try {
      NotificationDAO dao = new NotificationDAO();
      List<Notification> notifications = dao.loadNotifications();
      request.setAttribute("notifications", notifications);
      request.getRequestDispatcher("/WEB-INF/view/users_dashboards/admin_dashboard/notifications.jsp")
          .forward(request, response);
    } catch (Exception e) {
      e.printStackTrace();
      response.sendRedirect(request.getContextPath() + "/admin?error=notification_error");
    }
  }

  private void markNotificationAsRead(HttpServletRequest request, HttpServletResponse response) throws IOException {
    String notificationId = request.getParameter("id");
    if (notificationId != null && !notificationId.isEmpty()) {
      // TODO: Implement marking notification as read in database
      response.setContentType("application/json");
      response.getWriter().write("{\"success\": true}");
    } else {
      response.setContentType("application/json");
      response.getWriter().write("{\"success\": false, \"error\": \"Invalid notification ID\"}");
    }
  }

  private void handleNotificationAction(HttpServletRequest request, HttpServletResponse response) throws IOException {
    String notificationId = request.getParameter("id");
    String action = request.getParameter("action");

    if (notificationId != null && !notificationId.isEmpty() && action != null && !action.isEmpty()) {
      // TODO: Implement notification action handling
      response.setContentType("application/json");
      response.getWriter().write("{\"success\": true}");
    } else {
      response.setContentType("application/json");
      response.getWriter().write("{\"success\": false, \"error\": \"Invalid parameters\"}");
    }
  }

  private void createNotification(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    try {
      String type = request.getParameter("type");
      String title = request.getParameter("title");
      String message = request.getParameter("message");
      Notification notif = new Notification();
      notif.setType(type);
      notif.setTitle(title);
      notif.setMessage(message);
      NotificationDAO dao = new NotificationDAO();
      dao.addNotification(notif);
      response.sendRedirect(request.getContextPath() + "/admin/notifications");
    } catch (SQLException e) {
      e.printStackTrace();
      response.sendError(HttpServletResponse.SC_BAD_REQUEST);
    }
  }

  private void deleteNotification(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    try {
      int notificationId = Integer.parseInt(request.getParameter("id"));
      NotificationDAO dao = new NotificationDAO();
      dao.deleteNotification(notificationId);
      response.sendRedirect(request.getContextPath() + "/admin/notifications");
    } catch (Exception e) {
      e.printStackTrace();
      response.sendError(HttpServletResponse.SC_BAD_REQUEST);
    }
  }
}