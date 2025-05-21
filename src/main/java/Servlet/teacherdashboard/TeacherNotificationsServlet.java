package Servlet.teacherdashboard;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import dao.TeacherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Notification;
import model.User;

@WebServlet("/teacher/notifications/*")
public class TeacherNotificationsServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    HttpSession session = request.getSession();
    User user = (User) session.getAttribute("user");

    // Check if user is logged in and is a teacher
    if (user == null || !"teacher".equalsIgnoreCase(user.getRole())) {
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
      TeacherDAO dao = new TeacherDAO();
      List<Notification> notifications = dao.getAllNotifications();
      request.setAttribute("notifications", notifications);
      request.getRequestDispatcher("/WEB-INF/view/users_dashboards/teacher_dashboard/notifications.jsp")
          .forward(request, response);
    } catch (Exception e) {
      e.printStackTrace();
      response.sendRedirect(request.getContextPath() + "/teacher-dash?error=notification_error");
    }
  }

  private void markNotificationAsRead(HttpServletRequest request, HttpServletResponse response) throws IOException {
    String notificationId = request.getParameter("id");
    if (notificationId != null && !notificationId.isEmpty()) {
      response.setContentType("application/json");
      response.getWriter().write("{\"success\": true}");
    } else {
      response.setContentType("application/json");
      response.getWriter().write("{\"success\": false, \"error\": \"Invalid notification ID\"}");
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
      TeacherDAO dao = new TeacherDAO();
      dao.addNotification(notif);
      response.sendRedirect(request.getContextPath() + "/teacher/notifications");
    } catch (SQLException e) {
      e.printStackTrace();
      response.sendError(HttpServletResponse.SC_BAD_REQUEST);
    }
  }

  private void deleteNotification(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    try {
      int notificationId = Integer.parseInt(request.getParameter("id"));
      TeacherDAO dao = new TeacherDAO();
      dao.deleteNotification(notificationId);
      response.sendRedirect(request.getContextPath() + "/teacher/notifications");
    } catch (Exception e) {
      e.printStackTrace();
      response.sendError(HttpServletResponse.SC_BAD_REQUEST);
    }
  }
}