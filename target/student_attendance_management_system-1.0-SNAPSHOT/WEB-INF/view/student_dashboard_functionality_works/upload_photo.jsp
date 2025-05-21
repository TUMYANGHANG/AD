<%--
  Created by IntelliJ IDEA.
  User: Umar
  Date: 5/3/2025
  Time: 3:57 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%
    // Session check to ensure only authenticated students access the page
    User user = (User) session.getAttribute("user");
    if (user == null || !"student".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Upload Profile Photo - Itahari International College Student Attendance Management System">
    <meta name="keywords" content="Itahari International College, student dashboard, profile photo">
    <meta name="author" content="Itahari International College">
    <title>Upload Profile Photo - Itahari International College</title>
    <!-- Favicon -->
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/favicon.png">
    <!-- AOS Animation Library -->
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
    <!-- Font Awesome for Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts for Roboto -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Roboto', Arial, sans-serif;
            margin: 0;
            padding: 0;
            line-height: 1.6;
            background-color: #f5f5f5;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .sidebar {
            width: 250px;
            background: linear-gradient(180deg, #4682b4, #b0c4de);
            color: #fff;
            position: fixed;
            top: 0;
            left: 0;
            height: 100%;
            padding: 20px;
            z-index: 1000;
            transition: width 0.3s ease, transform 0.3s ease;
        }

        .sidebar.collapsed {
            width: 60px;
        }

        .sidebar.collapsed .logo,
        .sidebar.collapsed .nav-text {
            display: none;
        }

        .sidebar .logo {
            font-size: 22px;
            font-weight: 700;
            margin-bottom: 30px;
            text-align: center;
        }

        .sidebar .toggle-btn {
            display: flex;
            justify-content: center;
            margin-bottom: 20px;
        }

        .sidebar .toggle-btn i {
            font-size: 24px;
            cursor: pointer;
            color: #fff;
            transition: transform 0.3s ease;
        }

        .sidebar .toggle-btn i:hover {
            transform: scale(1.2);
        }

        .sidebar a {
            display: flex;
            align-items: center;
            gap: 12px;
            color: #fff;
            padding: 12px 16px;
            text-decoration: none;
            border-radius: 8px;
            margin-bottom: 8px;
            font-size: 16px;
            transition: background 0.3s ease;
        }

        .sidebar a:hover {
            background-color: #f4a261;
            color: #2f4f4f;
        }

        .sidebar.collapsed a {
            justify-content: center;
            padding: 12px;
        }

        .sidebar-toggle {
            display: none;
            position: fixed;
            top: 20px;
            left: 20px;
            font-size: 24px;
            color: #4682b4;
            cursor: pointer;
            z-index: 1100;
        }

        .main-content {
            margin-left: 250px;
            padding: 20px;
            flex: 1;
        }

        .card {
            background: linear-gradient(90deg, #ffffff, #e6f0fa);
            border: 2px solid #4682b4;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
            max-width: 500px;
            margin: 20px auto;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .card:hover {
            transform: translateY(-8px);
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.15);
        }

        .btn {
            background-color: #4682b4;
            color: #fff;
            padding: 10px 20px;
            border-radius: 25px;
            font-size: 16px;
            font-weight: 500;
            text-decoration: none;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border: none;
            cursor: pointer;
        }

        .btn:hover {
            background-color: #f4a261;
            color: #2f4f4f;
            transform: scale(1.1);
        }

        .error {
            color: #d32f2f;
            margin-bottom: 16px;
            font-size: 15px;
            background: #ffebee;
            padding: 8px 12px;
            border-radius: 8px;
            text-align: center;
        }

        h2 {
            font-size: 28px;
            font-weight: 600;
            color: #4682b4;
            margin-bottom: 20px;
            text-align: center;
        }

        .form-group {
            margin-bottom: 20px;
        }

        input[type="file"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #b0c4de;
            border-radius: 8px;
            font-size: 15px;
            background: #fff;
        }

        .photo-preview {
            width: 150px;
            height: 150px;
            border-radius: 8px;
            background-color: #e0e0e0;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            margin: 16px auto;
            position: relative;
        }

        .photo-preview img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .photo-preview-placeholder {
            font-size: 14px;
            color: #4B5563;
            text-align: center;
        }

        .note {
            background: linear-gradient(90deg, #e6f0fa, #f5f5f5);
            border-left: 5px solid #4682b4;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 15px;
            color: #2f4f4f;
            margin-bottom: 20px;
            text-align: center;
        }

        footer {
            background-color: #2f4f4f;
            padding: 32px 16px;
            color: #fff;
            text-align: center;
            width: 100%;
            position: relative;
        }

        @media (max-width: 768px) {
            .sidebar {
                width: 250px;
                transform: translateX(-250px);
            }

            .sidebar.active {
                transform: translateX(0);
            }

            .sidebar.collapsed {
                width: 250px;
                transform: translateX(-250px);
            }

            .sidebar-toggle {
                display: block;
            }

            .main-content {
                margin-left: 0;
            }

            .card {
                padding: 16px;
            }

            .photo-preview {
                width: 120px;
                height: 120px;
            }
        }
    </style>
</head>
<body>
<!-- Sidebar -->
<aside class="sidebar" id="sidebar">
    <div class="toggle-btn" onclick="toggleSidebar()">
        <i class="fas fa-bars"></i>
    </div>
    <div class="logo">Itahari International</div>
    <a href="${pageContext.request.contextPath}/student-dash" title="Go to Dashboard"><i class="fas fa-home"></i><span class="nav-text">Dashboard</span></a>
    <a href="${pageContext.request.contextPath}/student-dash#attendance" title="View Attendance"><i class="fas fa-clipboard-check"></i><span class="nav-text">Attendance</span></a>
    <a href="${pageContext.request.contextPath}/student-dash#notifications" title="View Notifications"><i class="fas fa-bell"></i><span class="nav-text">Notifications</span></a>
    <a href="${pageContext.request.contextPath}/student-dash#profile" title="View Profile"><i class="fas fa-user-circle"></i><span class="nav-text">Profile</span></a>
    <a href="${pageContext.request.contextPath}/logout" title="Log Out"><i class="fas fa-sign-out-alt"></i><span class="nav-text">Logout</span></a>
</aside>

<!-- Sidebar Toggle for Mobile -->
<div class="sidebar-toggle" id="sidebar-toggle">
    <i class="fas fa-bars"></i>
</div>

<!-- Main Content -->
<div class="main-content">
    <div class="card" data-aos="fade-up">
        <h2><i class="fas fa-upload fa-lg"></i> Upload Profile Photo</h2>
        <div class="note">Choose a clear photo (jpg, png) to update your student profile.</div>
        <% if (request.getAttribute("error") != null) { %>
        <div class="error"><%= request.getAttribute("error") %></div>
        <% } %>
        <form action="${pageContext.request.contextPath}/upload_photo" method="post" enctype="multipart/form-data">
            <div class="form-group">
                <input type="file" name="photo" id="photoInput" accept="image/*" required onchange="previewPhoto()">
                <div class="photo-preview" id="photoPreview">
                    <div class="photo-preview-placeholder">No Photo Selected</div>
                </div>
            </div>
            <div style="display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;">
                <button type="submit" class="btn"><i class="fas fa-upload"></i> Upload</button>
                <a href="${pageContext.request.contextPath}/student-dash" class="btn"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
            </div>
        </form>
    </div>
</div>

<!-- Footer -->
<footer>
    <div style="max-width: 1200px; margin: 0 auto;">
        <p style="font-size: 16px;">© <%= new java.util.Date().getYear() + 1900 %> Itahari International College. All rights reserved.</p>
    </div>
</footer>

<!-- AOS Animation Script -->
<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
<script>
    AOS.init({ duration: 1000 });
</script>

<!-- Sidebar Toggle -->
<script>
    const sidebar = document.getElementById('sidebar');
    const toggle = document.getElementById('sidebar-toggle');

    function toggleSidebar() {
        sidebar.classList.toggle('collapsed');
    }

    toggle.addEventListener('click', () => {
        sidebar.classList.toggle('active');
        sidebar.classList.toggle('collapsed');
    });
</script>

<!-- Photo Preview Script -->
<script>
    function previewPhoto() {
        const input = document.getElementById('photoInput');
        const preview = document.getElementById('photoPreview');
        const placeholder = preview.querySelector('.photo-preview-placeholder');

        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                const img = document.createElement('img');
                img.src = e.target.result;
                preview.innerHTML = '';
                preview.appendChild(img);
            };
            reader.readAsDataURL(input.files[0]);
        } else {
            preview.innerHTML = '<div class="photo-preview-placeholder">No Photo Selected</div>';
        }
    }
</script>
</body>
</html>