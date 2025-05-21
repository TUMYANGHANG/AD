<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat, model.User, model.Student, model.Teacher, dao.UserDAO, java.sql.SQLException" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
  // Session check to ensure only authenticated admins access the dashboard
  User user = (User) session.getAttribute("user");
  if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
    response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
    return;
  }

  // Initialize UserDAO
  UserDAO userDAO = new UserDAO();
  User admin = null;
  try {
    // Fetch admin data from database
//    admin = userDAO.getUserData(user.getId());
  } catch (Exception e) {
    // Log error and set admin to null
    java.util.logging.Logger.getLogger("AdminDashboard").log(java.util.logging.Level.SEVERE, "Error fetching admin data", e);
  }

  // Handle success message for user management actions
  String successMessage = (String) session.getAttribute("userManagementSuccess");
  if (successMessage != null) {
    request.setAttribute("successMessage", successMessage);
    session.removeAttribute("userManagementSuccess"); // Clear message after displaying
  }

  // Mock user list (replace with actual DAO queries as needed)
  List<Map<String, String>> userList = new ArrayList<>();
  Map<String, String> user1 = new HashMap<>();
  user1.put("username", "student1");
  user1.put("role", "student");
  user1.put("email", "student1@example.com");
  user1.put("status", "Active");
  Map<String, String> user2 = new HashMap<>();
  user2.put("username", "teacher1");
  user2.put("role", "teacher");
  user2.put("email", "teacher1@example.com");
  user2.put("status", "Active");
  userList.add(user1);
  userList.add(user2);
  request.setAttribute("userList", userList);

  // Mock attendance report (replace with actual DAO queries as needed)
  Map<String, String> attendanceReport = new HashMap<>();
  attendanceReport.put("totalStudents", "150");
  attendanceReport.put("averageAttendance", "89");
  attendanceReport.put("classesToday", "10");
  request.setAttribute("attendanceReport", attendanceReport);

  // Mock notifications (replace with actual DAO queries as needed)
  List<String> notifications = Arrays.asList(
          "New user registration pending approval.",
          "System maintenance scheduled for May 10, 2025."
  );
  request.setAttribute("notifications", notifications);

  // Get dashboard data
  Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
  List<Student> students = (List<Student>) request.getAttribute("students");
  List<Teacher> teachers = (List<Teacher>) request.getAttribute("teachers");
  List<User> recentRegistrations = stats != null ? (List<User>) stats.get("recentRegistrations") : new ArrayList<>();

  // Current date
  SimpleDateFormat sdf = new SimpleDateFormat("MMMM dd, yyyy");
  String currentDate = sdf.format(new Date());

  // Initialize default values if stats is null
  int totalStudents = stats != null ? (int) stats.get("totalStudents") : 0;
  int totalTeachers = stats != null ? (int) stats.get("totalTeachers") : 0;
  double averageAttendance = stats != null ? (double) stats.get("averageAttendance") : 0.0;
  int totalClasses = stats != null ? (int) stats.get("classesToday") : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Admin Dashboard - Itahari International College Attendance Management System">
  <meta name="keywords" content="Itahari International College, admin dashboard, user management, attendance reports">
  <meta name="author" content="Itahari International College">
  <title>Admin Dashboard - Itahari International College</title>
  <!-- Favicon -->
  <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/favicon.png">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
  <!-- AOS Animation Library -->
  <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
  <!-- Google Fonts for Arial (as used in homepage) -->
  <link href="https://fonts.googleapis.com/css2?family=Arial:wght@400;700&display=swap" rel="stylesheet">
  <style>
    /* Navbar Styles */
    .navbar {
        background-color: white;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        padding: 1rem 0;
        position: sticky;
        top: 0;
        z-index: 1000;
        height: 70px;
        display: flex;
        align-items: center;
    }

    .navbar-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 1rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
        width: 100%;
    }

    .navbar-brand {
        color: #4a90e2;
        font-size: 1.5rem;
        font-weight: bold;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 0.5rem;
        height: 100%;
        padding: 0.5rem 0;
    }

    .navbar-brand i {
        font-size: 1.8rem;
    }

    .navbar-nav {
        display: flex;
        list-style: none;
        margin: 0;
        padding: 0;
        gap: 1.5rem;
        height: 100%;
        align-items: center;
    }

    .nav-item {
        position: relative;
        height: 100%;
        display: flex;
        align-items: center;
    }

    .nav-link {
        color: #2c3e50;
        text-decoration: none;
        padding: 0.75rem 1rem;
        display: flex;
        align-items: center;
        gap: 0.5rem;
        transition: color 0.3s ease;
        height: 100%;
        line-height: 1;
    }

    .nav-link:hover {
        color: #4a90e2;
    }

    .nav-link.active {
        color: #4a90e2;
        font-weight: 500;
    }

    .nav-link i {
        font-size: 1.1rem;
    }

    .navbar-toggler {
        display: none;
        background: none;
        border: none;
        cursor: pointer;
        padding: 0.5rem;
    }

    .navbar-toggler-icon {
        display: block;
        width: 25px;
        height: 2px;
        background-color: #2c3e50;
        position: relative;
        transition: background-color 0.3s ease;
    }

    .navbar-toggler-icon::before,
    .navbar-toggler-icon::after {
        content: '';
        position: absolute;
        width: 100%;
        height: 100%;
        background-color: #2c3e50;
        transition: transform 0.3s ease;
    }

    .navbar-toggler-icon::before {
        transform: translateY(-8px);
    }

    .navbar-toggler-icon::after {
        transform: translateY(8px);
    }

    /* Mobile Responsive */
    @media (max-width: 768px) {
        .navbar-toggler {
            display: block;
        }

        .navbar-collapse {
            display: none;
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            background-color: white;
            padding: 1rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .navbar-collapse.show {
            display: block;
        }

        .navbar-nav {
            flex-direction: column;
            gap: 0.5rem;
        }

        .nav-link {
            padding: 0.75rem 1rem;
            border-radius: 4px;
        }

        .nav-link:hover {
            background-color: #f8f9fa;
        }
    }

    body {
      font-family: Arial, sans-serif;
      margin: 0 !important;
      padding: 0;
      line-height: 1.6;
      background-color: #f5f5f5;
    }

    .card {
      transition: transform 0.3s ease, box-shadow 0.3s ease;
      background-color: #f0f8ff;
      border: 1px solid #b3d9ff;
      display: flex;
      flex-direction: column;
      align-items: center;
      text-align: center;
    }

    .card:hover {
      transform: translateY(-10px);
      box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
    }

    .cta-button {
      transition: all 0.3s ease;
    }

    .cta-button:hover {
      transform: scale(1.05);
      box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
    }

    .note {
      background-color: #f0f8ff;
      border-left: 4px solid #1e90ff;
      padding: 16px;
      margin: 16px 0;
      font-size: 16px;
      color: #4B5563;
      border-radius: 4px;
    }

    .hero-bg {
      background: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url('${pageContext.request.contextPath}/Images/College Image.jpg');
      background-size: cover;
      background-position: center;
      height: 60vh;
      display: flex;
      align-items: center;
      justify-content: center;
      text-align: center;
    }

    .main-content {
      padding: 80px 16px;
      background-color: #fff;
    }

    .profile-card {
      background-color: #f0f8ff;
      border-radius: 8px;
      padding: 24px;
      max-width: 700px;
      margin: 0 auto 32px;
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 24px;
      flex-wrap: wrap;
      box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
    }

    .profile-photo {
      width: 120px;
      height: 120px;
      border-radius: 8px;
      background-color: #e5e7eb;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
    }

    .profile-photo img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .profile-photo-placeholder {
      font-size: 14px;
      color: #6b7280;
      text-align: center;
    }

    .profile-info {
      flex: 1;
      min-width: 200px;
    }

    .profile-info h3 {
      font-size: 24px;
      font-weight: 600;
      color: #1e90ff;
      margin-bottom: 12px;
    }

    .profile-info div {
      font-size: 16px;
      color: #4B5563;
      margin-bottom: 8px;
    }

    .profile-actions {
      display: flex;
      gap: 12px;
      margin-top: 12px;
      flex-wrap: wrap;
    }

    .dashboard-container {
      max-width: 1200px;
      margin: 0 auto;
    }

    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 32px;
    }

    .progress-circle {
      position: relative;
      width: 100px;
      height: 100px;
      margin: 0 auto;
    }

    .progress-circle svg {
      transform: rotate(-90deg);
    }

    .progress-circle .circle-bg {
      fill: none;
      stroke: #e5e7eb;
      stroke-width: 8;
    }

    .progress-circle .circle-fg {
      fill: none;
      stroke: #1e90ff;
      stroke-width: 8;
      stroke-linecap: round;
      transition: stroke-dashoffset 0.5s ease;
    }

    .progress-circle span {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      font-size: 20px;
      font-weight: bold;
      color: #4B5563;
    }

    .notification-panel {
      max-height: 0;
      overflow: hidden;
      transition: max-height 0.3s ease;
    }

    .notification-panel.active {
      max-height: 250px;
    }

    .notification-list {
      list-style: none;
      padding: 0;
      margin: 10px 0 0;
    }

    .notification-list li {
      background-color: #f3f4f6;
      padding: 8px;
      border-radius: 4px;
      margin-bottom: 5px;
      font-size: 15px;
      color: #4B5563;
      display: flex;
      align-items: center;
      gap: 5px;
    }

    .user-list {
      list-style: none;
      padding: 0;
      margin: 10px 0 0;
    }

    .user-list li {
      background-color: #f3f4f6;
      padding: 10px;
      border-radius: 4px;
      margin-bottom: 5px;
      font-size: 15px;
      color: #4B5563;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    footer {
      background-color: #2f4f4f;
      padding: 40px 16px;
    }

    .footer-container {
      max-width: 1200px;
      margin: 0 auto;
      display: flex;
      flex-wrap: wrap;
      justify-content: space-between;
      gap: 32px;
    }

    .footer-column {
      flex: 1;
      min-width: 200px;
    }

    .footer-column h3 {
      color: #fff;
      font-size: 18px;
      margin-bottom: 16px;
    }

    .footer-column p,
    .footer-column a {
      color: #ccc;
      font-size: 14px;
      line-height: 1.8;
      text-decoration: none;
    }

    .footer-column a:hover {
      color: #ffd700;
    }

    .social-icons {
      display: flex;
      gap: 16px;
    }

    .social-icons a {
      color: #fff;
      font-size: 20px;
      transition: color 0.3s ease;
    }

    .social-icons a:hover {
      color: #ffd700;
    }

    @media (max-width: 768px) {
      .hero-bg {
        height: 50vh;
      }

      .hero-bg h1 {
        font-size: 32px;
      }

      .hero-bg p {
        font-size: 16px;
      }

      .profile-card {
        flex-direction: column;
        text-align: center;
      }

      .grid {
        grid-template-columns: 1fr;
      }

      .footer-container {
        flex-direction: column;
        text-align: center;
      }

      .social-icons {
        justify-content: center;
      }
    }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 20px;
      margin-bottom: 30px;
    }
    
    .stat-card {
      background: #fff;
      padding: 20px;
      border-radius: 10px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
      text-align: center;
    }
    
    .stat-card i {
      font-size: 2em;
      color: #1e90ff;
      margin-bottom: 10px;
    }
    
    .stat-card h3 {
      font-size: 1.5em;
      margin: 10px 0;
      color: #2f4f4f;
    }
    
    .stat-card p {
      color: #666;
      margin: 0;
    }
    
    .recent-registrations {
      background: #fff;
      padding: 20px;
      border-radius: 10px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
      margin-bottom: 30px;
    }
    
    .recent-registrations h2 {
      color: #1e90ff;
      margin-bottom: 20px;
    }
    
    .registration-list {
      list-style: none;
      padding: 0;
    }
    
    .registration-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 10px;
      border-bottom: 1px solid #eee;
    }
    
    .registration-item:last-child {
      border-bottom: none;
    }
    
    .quick-actions {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 20px;
      margin-bottom: 30px;
    }
    
    .action-card {
      background: #fff;
      padding: 20px;
      border-radius: 10px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
      text-align: center;
      cursor: pointer;
      transition: transform 0.3s ease;
    }
    
    .action-card:hover {
      transform: translateY(-5px);
    }
    
    .action-card i {
      font-size: 2em;
      color: #1e90ff;
      margin-bottom: 10px;
    }
  </style>
</head>
<body>
    <!-- Navigation Bar -->
    <nav class="navbar">
        <div class="navbar-container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/admin">
                <i class="fas fa-graduation-cap"></i> Admin Dashboard
            </a>
            <div style="flex:1;"></div>
            <div class="navbar-collapse" id="navbarNav">
                <ul class="navbar-nav" style="margin-left:auto;">
                    <li class="nav-item">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/admin">
                            <i class="fas fa-home"></i> Dashboard
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/admin/users">
                            <i class="fas fa-users"></i> Users
                        </a>
                    </li>
                    
                    <li class="nav-item">
                      <a class="nav-link" href="${pageContext.request.contextPath}/admin/notifications">
                          <i class="fas fa-bell"></i> Notifications
                      </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/admin/settings">
                            <i class="fas fa-cog"></i> Settings
                        </a>
                    </li>
                    
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/logout">
                            <i class="fas fa-sign-out-alt"></i> Logout
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

<!-- Hero Section -->
<section id="home" class="hero-bg" data-aos="fade-up" data-aos-duration="1200">
  <div style="max-width: 1200px; margin: 0 auto; text-align: center;">
    <h1 style="font-size: 48px; font-weight: bold; margin-bottom: 16px; color: #fff;">Admin Dashboard</h1>
    <p style="font-size: 20px; margin-bottom: 16px; color: #fff;">Welcome, <%= user.getUsername() %>! Manage users, view attendance reports, and configure the system with our intuitive admin portal.</p>
    <div class="note" style="color: #fff; background-color: rgba(0, 0, 0, 0.5); max-width: 600px; margin: 16px auto;" data-aos="fade-up" data-aos-delay="300">
      Today is <%= currentDate %>. Stay updated with the latest system activities!
    </div>
  </div>
</section>

<!-- Main Content -->
<section class="main-content">
  <div class="dashboard-container">
    <!-- Display Success or Error Messages -->
    <% if (request.getAttribute("successMessage") != null) { %>
    <div class="note" style="background-color: #dcfce7; border-left: 4px solid #22c55e; color: #166534;" data-aos="fade-up">
      <%= request.getAttribute("successMessage") %>
    </div>
    <% } %>

    <!-- Profile Section -->
    <div class="profile-card" data-aos="fade-up" data-aos-duration="1000">
<%--      <div class="profile-photo">--%>
<%--        <% if (admin != null && admin.getPhotoPath() != null && !admin.getPhotoPath().isEmpty()) { %>--%>
<%--        <img src="${pageContext.request.contextPath}/<%= admin.getPhotoPath() %>" alt="Admin Photo" onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">--%>
<%--        <% } else { %>--%>
<%--        <img src="${pageContext.request.contextPath}/Images/default-photo.jpg" alt="Default Photo" style="display: none;">--%>
<%--        <% } %>--%>
<%--        <div class="profile-photo-placeholder" <%= (admin != null && admin.getPhotoPath() != null && !admin.getPhotoPath().isEmpty()) ? "style='display: none;'" : "" %>>No Photo</div>--%>
<%--      </div>--%>
      <div class="profile-info">
        <h3><i class="fas fa-user-circle"></i> Admin Profile</h3>
        <div><strong>Username:</strong> <%= user.getUsername() %></div>
        <div><strong>Role:</strong> Administrator</div>
        <div><strong>Email:</strong> <%= user.getEmail() %></div>
      </div>
      <div class="profile-actions">
        <a href="${pageContext.request.contextPath}/admin/settings" class="cta-button" style="background-color: #1e90ff; color: #fff; padding: 8px 16px; border-radius: 4px; text-decoration: none; font-size: 16px;"><i class="fas fa-edit"></i> Edit Profile</a>
      </div>
    </div>

    <!-- Dashboard Section -->
    <h2 style="font-size: 36px; font-weight: bold; text-align: center; margin-bottom: 24px; color: #2f4f4f;" data-aos="fade-up">Control Panel</h2>
    <div class="note" data-aos="fade-up" data-aos-delay="100">Tip: Navigate through the sections below to manage users, view reports, or check notifications.</div>
    <div class="grid">
      <!-- User Management -->
      <div class="card" style="background-color: #f0f8ff; padding: 24px; border-radius: 8px;" data-aos="flip-left" data-aos-duration="800" id="users">
        <h3 style="font-size: 24px; font-weight: 600; margin-bottom: 16px; color: #1e90ff;"><i class="fas fa-users"></i> User Management</h3>
        <ul class="user-list">
          <% 
            List<Map<String, String>> users = (List<Map<String, String>>) request.getAttribute("userList");
            // Filter out admin users
            List<Map<String, String>> filteredUsers = new ArrayList<>();
            for (Map<String, String> userItem : users) {
              if (!"admin".equalsIgnoreCase(userItem.get("role"))) {
                filteredUsers.add(userItem);
              }
            }
            // Show only the first two users
            int showCount = Math.min(filteredUsers.size(), 2);
            if (showCount > 0) {
              for (int i = 0; i < showCount; i++) {
                Map<String, String> userItem = filteredUsers.get(i);
          %>
          <li>
            <span><strong><%= userItem.get("username") %></strong></span>
            <span><%= userItem.get("status") %></span>
          </li>
          <% 
              }
            } 
          %>
        </ul>
        <a href="${pageContext.request.contextPath}/admin/users" class="cta-button" style="background-color: #1e90ff; color: #fff; padding: 8px 16px; border-radius: 4px; text-decoration: none; font-size: 16px; margin-top: 16px; display: inline-block;"><i class="fas fa-eye"></i> Manage Users</a>
      </div>

      <!-- Attendance Reports
      <div class="card" data-aos="fade-up" data-aos-delay="100">
                <h2 style="color: #4a90e2; margin-bottom: 16px;"><i class="fas fa-chart-pie"></i> Attendance Reports</h2>
                <div class="progress-circle" data-progress="<%= averageAttendance %>">
                    <svg width="120" height="120">
                        <circle class="circle-bg" cx="60" cy="60" r="50"></circle>
                        <circle class="circle-fg" cx="60" cy="60" r="50" 
                                stroke-dasharray="314" 
                                stroke-dashoffset="<%=(100 - averageAttendance) * 3.14%>"
                                style="stroke: #4a90e2;"></circle>
                    </svg>
                    <span><%= String.format("%.1f", averageAttendance) %> %</span>
                </div>
                <p style="color: #4B5563; margin-bottom: 16px; text-align: center;"><%= totalStudents %> students, <%= totalClasses %> classes today</p>
                <a href="${pageContext.request.contextPath}/admin/reports" class="btn">
                    <i class="fas fa-file-alt"></i> View Reports
                </a>
            </div> -->

      <!-- Notifications -->
      <div class="card" style="background-color: #f0f8ff; padding: 24px; border-radius: 8px;" data-aos="flip-left" data-aos-duration="800" data-aos-delay="400" id="notifications">
        <h3 style="font-size: 24px; font-weight: 600; margin-bottom: 16px; color: #1e90ff; cursor: pointer;" onclick="toggleNotifications()"><i class="fas fa-bell"></i> Notifications <i class="fas fa-chevron-down" id="notif-icon"></i></h3>
        <button class="btn btn-primary" style="margin-bottom: 16px; background: #4a90e2; color: #fff; border: none; border-radius: 5px; padding: 8px 18px; font-size: 1rem; font-weight: 500; cursor: pointer;" onclick="showNotificationModal()"><i class="fas fa-plus"></i> Add Notification</button>
        <div class="notification-panel" id="notification-panel">
          <ul class="notification-list" id="notification-list">
            <%
              List<String> notifs = (List<String>) request.getAttribute("notifications");
              for (String notification : notifs) {
            %>
            <li><i class="fas fa-info-circle"></i> <%= notification %></li>
            <%
              }
            %>
          </ul>
        </div>
        <a href="${pageContext.request.contextPath}/admin/notifications" class="cta-button" style="background-color: #1e90ff; color: #fff; padding: 8px 16px; border-radius: 4px; text-decoration: none; font-size: 16px; margin-top: 16px; display: inline-block;"><i class="fas fa-bell"></i> View All</a>
      </div>
    </div>
  </div>
</section>

<!-- Footer -->
<footer>
  <div class="footer-container">
    <div class="footer-column">
      <h3>About Us</h3>
      <p>Itahari International College is committed to academic excellence and fostering a vibrant student community. Learn more about our programs and values on our website.</p>
    </div>
    <div class="footer-column">
      <h3>Contact Info</h3>
      <p>Email: <a href="mailto:info@itahariinternationalcollege.edu">info@itahariinternationalcollege.edu</a></p>
      <p>Phone: +977-123-456-7890</p>
      <p>Address: Itahari, Sunsari, Nepal</p>
    </div>
    <div class="footer-column">
      <h3>Follow Us</h3>
      <div class="social-icons">
        <a href="https://facebook.com" aria-label="Facebook"><i class="fab fa-facebook-f"></i></a>
        <a href="https://twitter.com" aria-label="Twitter"><i class="fab fa-twitter"></i></a>
        <a href="https://instagram.com" aria-label="Instagram"><i class="fab fa-instagram"></i></a>
        <a href="https://linkedin.com" aria-label="LinkedIn"><i class="fab fa-linkedin-in"></i></a>
      </div>
    </div>
  </div>
  <p style="color: #fff; font-size: 16px; text-align: center; margin-top: 32px;">© <%= new java.util.Date().getYear() + 1900 %> Itahari International College. All rights reserved.</p>
</footer>

<!-- AOS Animation Script -->
<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
<script>
  AOS.init();
</script>

<!-- Toggle Notifications -->
<script>
  function toggleNotifications() {
    const panel = document.getElementById('notification-panel');
    const icon = document.getElementById('notif-icon');
    panel.classList.toggle('active');
    icon.classList.toggle('fa-chevron-down');
    icon.classList.toggle('fa-chevron-up');
  }
</script>

<!-- Toggle Navbar -->
<script>
    function toggleNavbar() {
        const navbarCollapse = document.querySelector('.navbar-collapse');
        navbarCollapse.classList.toggle('show');
    }

    // Close mobile menu when clicking outside
    document.addEventListener('click', function(event) {
        const navbarCollapse = document.querySelector('.navbar-collapse');
        const navbarToggler = document.querySelector('.navbar-toggler');
        
        if (!navbarCollapse.contains(event.target) && !navbarToggler.contains(event.target)) {
            navbarCollapse.classList.remove('show');
        }
    });
</script>

<!-- Add Notification Modal -->
<div id="notificationModal" style="display:none; position:fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.3); z-index:2000; align-items:center; justify-content:center;">
  <div style="background:#fff; border-radius:10px; padding:32px 24px; max-width:400px; margin:auto; position:relative;">
    <h3 style="margin-bottom:18px; color:#1e90ff; font-weight:600;">Add Notification</h3>
    <form id="addNotificationForm" action="${pageContext.request.contextPath}/admin/notifications" method="post">
      <input type="hidden" name="action" value="create">
      <div style="margin-bottom:14px;">
        <label for="notifType" style="font-weight:500;">Topic</label>
        <select id="notifType" name="type" required style="width:100%; padding:8px; border-radius:5px; border:1px solid #ddd;">
          <option value="attendance">Attendance</option>
          <option value="user">User Management</option>
          <option value="system">System</option>
        </select>
      </div>
      <div style="margin-bottom:14px;">
        <label for="notifTitle" style="font-weight:500;">Title</label>
        <input type="text" id="notifTitle" name="title" required maxlength="100" style="width:100%; padding:8px; border-radius:5px; border:1px solid #ddd;">
      </div>
      <div style="margin-bottom:14px;">
        <label for="notifDesc" style="font-weight:500;">Short Description</label>
        <input type="text" id="notifDesc" name="message" required maxlength="100" style="width:100%; padding:8px; border-radius:5px; border:1px solid #ddd;">
      </div>
      <div style="margin-bottom:18px;">
        <label style="font-weight:500;">Posted Time</label>
        <input type="text" id="notifTime" readonly style="width:100%; padding:8px; border-radius:5px; border:1px solid #ddd; background:#f5f5f5;">
      </div>
      <div style="display:flex; justify-content:flex-end; gap:10px;">
        <button type="button" onclick="hideNotificationModal()" style="background:#ccc; color:#222; border:none; border-radius:5px; padding:8px 16px;">Cancel</button>
        <button type="submit" style="background:#1e90ff; color:#fff; border:none; border-radius:5px; padding:8px 16px;">Add</button>
      </div>
    </form>
    <button onclick="hideNotificationModal()" style="position:absolute; top:10px; right:14px; background:none; border:none; font-size:20px; color:#888; cursor:pointer;">&times;</button>
  </div>
</div>

<script>
function showNotificationModal() {
  document.getElementById('notificationModal').style.display = 'flex';
  document.getElementById('notifTime').value = new Date().toLocaleString();
}
function hideNotificationModal() {
  document.getElementById('notificationModal').style.display = 'none';
}
</script>
</body>
</html>