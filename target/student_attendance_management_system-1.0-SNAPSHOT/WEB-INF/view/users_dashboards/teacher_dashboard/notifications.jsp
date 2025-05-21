<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.*, model.*" %>

<%
    // Session check
    User user = (User) session.getAttribute("user");
    if (user == null || !"teacher".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
        return;
    }

    // Get notifications from request attributes
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    if (notifications == null) {
        notifications = new ArrayList<>();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Notifications - Teacher Dashboard</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
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
            color: #48bb78;
            font-size: 1.5rem;
            font-weight: bold;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            height: 100%;
            padding: 0.5rem 0;
        }

        .navbar-nav {
            display: flex;
            gap: 1rem;
            list-style: none;
            margin: 0;
            padding: 0;
        }

        .nav-link {
            color: #4B5563;
            text-decoration: none;
            padding: 0.5rem 1rem;
            border-radius: 4px;
            transition: all 0.3s ease;
        }

        .nav-link:hover {
            background-color: #f3f4f6;
        }

        .nav-link.active {
            background-color: #48bb78;
            color: white;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 24px;
        }

        .card {
            background-color: #fff;
            border-radius: 8px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
        }

        .notification {
            padding: 16px;
            border-bottom: 1px solid #eee;
            display: flex;
            align-items: flex-start;
            gap: 16px;
            transition: background-color 0.3s ease;
        }

        .notification:hover {
            background-color: #f8f9fa;
        }

        .notification:last-child {
            border-bottom: none;
        }

        .notification-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            flex-shrink: 0;
        }

        .notification-icon.attendance {
            background-color: #4CAF50;
        }

        .notification-icon.user {
            background-color: #2196F3;
        }

        .notification-icon.system {
            background-color: #FF9800;
        }

        .notification-icon.default {
            background-color: #9E9E9E;
        }

        .notification-content {
            flex-grow: 1;
        }

        .notification-title {
            font-weight: bold;
            margin-bottom: 4px;
            color: #48bb78;
        }

        .notification-message {
            color: #4B5563;
            margin-bottom: 8px;
        }

        .notification-time {
            font-size: 12px;
            color: #666;
        }

        .notification-actions {
            display: flex;
            gap: 8px;
        }

        .btn {
            padding: 8px 16px;
            border-radius: 4px;
            text-decoration: none;
            font-size: 14px;
            cursor: pointer;
            border: none;
            background-color: #48bb78;
            color: #fff;
            transition: all 0.3s ease;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }

        .btn-secondary {
            background-color: #e5e7eb;
            color: #4B5563;
        }

        .notification-filters {
            display: flex;
            gap: 16px;
            margin-bottom: 24px;
        }

        .filter-btn {
            padding: 8px 16px;
            border-radius: 4px;
            border: 1px solid #ddd;
            background-color: #fff;
            color: #4B5563;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .filter-btn:hover {
            background-color: #f8f9fa;
            transform: translateY(-2px);
        }

        .filter-btn.active {
            background-color: #48bb78;
            color: #fff;
            border-color: #48bb78;
        }

        .inline-form {
            display: inline;
        }

        /* Add Notification Modal */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(0,0,0,0.3);
            z-index: 2000;
            align-items: center;
            justify-content: center;
        }

        .modal-content {
            background: #fff;
            border-radius: 10px;
            padding: 32px 24px;
            max-width: 400px;
            margin: auto;
            position: relative;
        }

        .modal-close {
            position: absolute;
            top: 10px;
            right: 14px;
            background: none;
            border: none;
            font-size: 20px;
            color: #888;
            cursor: pointer;
        }

        .form-group {
            margin-bottom: 14px;
        }

        .form-group label {
            display: block;
            font-weight: 500;
            margin-bottom: 4px;
        }

        .form-control {
            width: 100%;
            padding: 8px;
            border-radius: 5px;
            border: 1px solid #ddd;
        }

        .form-control:focus {
            border-color: #48bb78;
            outline: none;
        }

        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 18px;
        }
    </style>
</head>
<body>
    <!-- Navigation Bar -->
    <nav class="navbar">
        <div class="navbar-container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/Nav_teacher_dashServlet">
                <i class="fas fa-graduation-cap"></i> Teacher Dashboard
            </a>
            <ul class="navbar-nav">
                <li><a class="nav-link" href="${pageContext.request.contextPath}/Nav_teacher_dashServlet">
                    <i class="fas fa-home"></i> Dashboard
                </a></li>
                <li><a class="nav-link" href="${pageContext.request.contextPath}/students">
                    <i class="fas fa-users"></i> Students
                </a></li>
                <li><a class="nav-link" href="${pageContext.request.contextPath}/manage-attendance">
                    <i class="fas fa-clipboard-check"></i> Attendance
                </a></li>
                <li><a class="nav-link active" href="${pageContext.request.contextPath}/teacher/notifications">
                    <i class="fas fa-bell"></i> Notifications
                </a></li>
                <li><a class="nav-link" href="${pageContext.request.contextPath}/logout">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a></li>
            </ul>
        </div>
    </nav>

    <div class="container">
        <!-- Add Notification Button -->
        <div style="display: flex; justify-content: flex-end; margin-bottom: 24px;">
            <button class="btn" onclick="showNotificationModal()">
                <i class="fas fa-plus"></i> Add Notification
            </button>
        </div>

        <!-- Notification Filters -->
        <div class="notification-filters" data-aos="fade-up">
            <button class="filter-btn active" data-filter="all">All</button>
            <button class="filter-btn" data-filter="attendance">Attendance</button>
            <button class="filter-btn" data-filter="user">User Management</button>
            <button class="filter-btn" data-filter="system">System</button>
        </div>

        <!-- Notifications List -->
        <div class="card" data-aos="fade-up" data-aos-delay="200">
            <h2 style="color: #48bb78; margin-bottom: 16px;"><i class="fas fa-bell"></i> Notifications</h2>
            <c:if test="${empty notifications}">
                <p style="text-align: center; color: #666;">No notifications to display</p>
            </c:if>
            <c:forEach items="${notifications}" var="notification">
                <div class="notification" data-type="${notification.type}">
                    <div class="notification-icon ${notification.type}">
                        <i class="fas 
                            <c:choose>
                                <c:when test='${notification.type == "attendance"}'>fa-calendar-check</c:when>
                                <c:when test='${notification.type == "user"}'>fa-user</c:when>
                                <c:when test='${notification.type == "system"}'>fa-cog</c:when>
                                <c:otherwise>fa-bell</c:otherwise>
                            </c:choose>"></i>
                    </div>
                    <div class="notification-content">
                        <div class="notification-title">${notification.title}</div>
                        <div class="notification-message">${notification.message}</div>
                        <div class="notification-time">
                            <fmt:formatDate value="${notification.created_at}" pattern="yyyy-MM-dd HH:mm"/>
                        </div>
                    </div>
                    <div class="notification-actions">
                        <form class="inline-form" action="${pageContext.request.contextPath}/teacher/notifications" method="post" onsubmit="return confirm('Delete this notification?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="${notification.id}">
                            <button type="submit" class="btn btn-secondary" style="background: #e74c3c; color: #fff;">Delete</button>
                        </form>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>

    <!-- Add Notification Modal -->
    <div id="notificationModal" class="modal">
        <div class="modal-content">
            <h3 style="margin-bottom:18px; color:#48bb78; font-weight:600;">Add Notification</h3>
            <form id="addNotificationForm" action="${pageContext.request.contextPath}/teacher/notifications" method="post">
                <input type="hidden" name="action" value="create">
                <div class="form-group">
                    <label for="notifType">Topic</label>
                    <select id="notifType" name="type" required class="form-control">
                        <option value="attendance">Attendance</option>
                        <option value="user">User Management</option>
                        <option value="system">System</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="notifTitle">Title</label>
                    <input type="text" id="notifTitle" name="title" required maxlength="100" class="form-control">
                </div>
                <div class="form-group">
                    <label for="notifDesc">Short Description</label>
                    <input type="text" id="notifDesc" name="message" required maxlength="100" class="form-control">
                </div>
                <div class="form-group">
                    <label>Posted Time</label>
                    <input type="text" id="notifTime" readonly class="form-control" style="background:#f5f5f5;">
                </div>
                <div class="modal-footer">
                    <button type="button" onclick="hideNotificationModal()" class="btn btn-secondary">Cancel</button>
                    <button type="submit" class="btn">Add</button>
                </div>
            </form>
            <button onclick="hideNotificationModal()" class="modal-close">&times;</button>
        </div>
    </div>

    <script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
    <script>
        AOS.init();

        function showNotificationModal() {
            document.getElementById('notificationModal').style.display = 'flex';
            document.getElementById('notifTime').value = new Date().toLocaleString();
        }

        function hideNotificationModal() {
            document.getElementById('notificationModal').style.display = 'none';
        }

        // Notification filter logic
        document.querySelectorAll('.filter-btn').forEach(button => {
            button.addEventListener('click', () => {
                // Update active state
                document.querySelectorAll('.filter-btn').forEach(btn => btn.classList.remove('active'));
                button.classList.add('active');
                // Filter notifications
                const filter = button.dataset.filter;
                document.querySelectorAll('.notification').forEach(notification => {
                    if (filter === 'all' || notification.dataset.type === filter) {
                        notification.style.display = 'flex';
                    } else {
                        notification.style.display = 'none';
                    }
                });
            });
        });
    </script>
</body>
</html> 