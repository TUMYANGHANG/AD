<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.*, model.*" %>

<%
    // Session check
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
        return;
    }

    // Get settings from request attributes
    Map<String, Object> settings = (Map<String, Object>) request.getAttribute("settings");
    if (settings == null) {
        settings = new HashMap<>();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Settings - Admin Dashboard</title>
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

        /* Rest of your existing styles */
        body {
            font-family: Arial, sans-serif;
            margin: 0 !important;
            padding: 0;
            line-height: 1.6;
            background-color: #f5f5f5;
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

        .settings-section {
            margin-bottom: 32px;
        }

        .settings-section h3 {
            color: #1e90ff;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .form-group {
            margin-bottom: 16px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #4B5563;
        }

        .form-group input[type="text"],
        .form-group input[type="password"],
        .form-group input[type="email"],
        .form-group select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }

        .form-group input[type="text"]:focus,
        .form-group input[type="password"]:focus,
        .form-group input[type="email"]:focus,
        .form-group select:focus {
            border-color: #1e90ff;
            box-shadow: 0 0 0 2px rgba(30, 144, 255, 0.2);
            outline: none;
        }

        .form-group input[type="checkbox"] {
            margin-right: 8px;
        }

        .btn {
            padding: 8px 16px;
            border-radius: 4px;
            text-decoration: none;
            font-size: 14px;
            cursor: pointer;
            border: none;
            background-color: #1e90ff;
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

        .settings-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 24px;
        }

        .toggle-switch {
            position: relative;
            display: inline-block;
            width: 60px;
            height: 34px;
        }

        .toggle-switch input {
            opacity: 0;
            width: 0;
            height: 0;
        }

        .slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #ccc;
            transition: .4s;
            border-radius: 34px;
        }

        .slider:before {
            position: absolute;
            content: "";
            height: 26px;
            width: 26px;
            left: 4px;
            bottom: 4px;
            background-color: white;
            transition: .4s;
            border-radius: 50%;
        }

        input:checked + .slider {
            background-color: #1e90ff;
        }

        input:checked + .slider:before {
            transform: translateX(26px);
        }

        /* Note styles for consistency */
        .note {
            background-color: #f0f8ff;
            border-left: 4px solid #1e90ff;
            padding: 16px;
            margin: 16px 0;
            font-size: 16px;
            color: #4B5563;
            border-radius: 4px;
        }

        /* Remove any conflicting styles */
        .row, .col-md-6, .col-12, .d-flex, .justify-content-between, .align-items-center, .mb-4, .mt-4 {
            all: unset;
        }

        .form-control, .form-select {
            all: unset;
        }

        .alert, .alert-success, .alert-danger, .alert-dismissible, .fade, .show {
            all: unset;
        }

        .btn-close {
            all: unset;
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
            <button class="navbar-toggler" type="button" onclick="toggleNavbar()">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="navbar-collapse" id="navbarNav">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/admin">
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
                        <a class="nav-link active" href="${pageContext.request.contextPath}/admin/settings">
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

    <div class="container">
        <div class="settings-grid">
            <!-- Username Update Form -->
            <div class="card" data-aos="fade-up">
                <div class="settings-section">
                    <h3><i class="fas fa-user"></i> Profile Settings</h3>
                    <form action="${pageContext.request.contextPath}/admin/settings/profile" method="post" style="margin-bottom: 16px;">
                        <input type="hidden" name="updateField" value="username">
                        <div class="form-group">
                            <label for="username">Username</label>
                            <input type="text" id="username" name="username" value="<%= user.getUsername() %>" required>
                        </div>
                        <button type="submit" class="btn">Save Username</button>
                    </form>
                    <!-- Email Update Form -->
                    <form action="${pageContext.request.contextPath}/admin/settings/profile" method="post">
                        <input type="hidden" name="updateField" value="email">
                        <div class="form-group">
                            <label for="email">Email</label>
                            <input type="email" id="email" name="email" value="<%= user.getEmail() %>" required>
                        </div>
                        <button type="submit" class="btn">Save Email</button>
                    </form>
                </div>
            </div>

            <!-- Security Settings -->
            <div class="card" data-aos="fade-up" data-aos-delay="200">
                <div class="settings-section">
                    <h3><i class="fas fa-lock"></i> Security Settings</h3>
                    <form action="${pageContext.request.contextPath}/admin/settings/password" method="post">
                        <div class="form-group">
                            <label for="currentPassword">Current Password</label>
                            <input type="password" id="currentPassword" name="currentPassword" required>
                        </div>
                        <div class="form-group">
                            <label for="newPassword">New Password</label>
                            <input type="password" id="newPassword" name="newPassword" required>
                        </div>
                        <div class="form-group">
                            <label for="confirmPassword">Confirm New Password</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" required>
                        </div>
                        <button type="submit" class="btn">Change Password</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
    <script>
        AOS.init();

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

        // Password confirmation validation
        document.querySelector('form[action*="password"]').addEventListener('submit', function(e) {
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (newPassword !== confirmPassword) {
                e.preventDefault();
                alert('New passwords do not match!');
            }
        });
    </script>
</body>
</html> 