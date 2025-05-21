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

    // Get report data from request attributes
    Map<String, Object> reportData = (Map<String, Object>) request.getAttribute("reportData");
    if (reportData == null) {
        reportData = new HashMap<>();
    }

    // Get attendance records
    List<Attendance> studentRecords = (List<Attendance>) reportData.get("studentRecords");
    List<Attendance> teacherRecords = (List<Attendance>) reportData.get("teacherRecords");
    if (studentRecords == null) studentRecords = new ArrayList<>();
    if (teacherRecords == null) teacherRecords = new ArrayList<>();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Attendance Reports - Admin Dashboard</title>
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
        }

        .navbar-nav {
            display: flex;
            gap: 1rem;
            list-style: none;
            margin: 0;
            padding: 0;
        }

        .nav-link {
            color: #2c3e50;
            text-decoration: none;
            padding: 0.5rem 1rem;
            border-radius: 4px;
            transition: all 0.3s ease;
        }

        .nav-link:hover {
            background-color: #f3f4f6;
        }

        .nav-link.active {
            background-color: #4a90e2;
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
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 24px;
            margin-bottom: 24px;
        }

        .stat-card {
            background: linear-gradient(135deg, #4a90e2, #357abd);
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
        }

        .stat-card h3 {
            font-size: 24px;
            margin: 0;
            margin-bottom: 8px;
        }

        .stat-card p {
            margin: 0;
            opacity: 0.9;
        }

        .tab-container {
            margin-bottom: 24px;
        }

        .tab-buttons {
            display: flex;
            gap: 16px;
            margin-bottom: 16px;
        }

        .tab-button {
            padding: 8px 16px;
            border: none;
            background: none;
            color: #2c3e50;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            border-bottom: 2px solid transparent;
            transition: all 0.3s ease;
        }

        .tab-button:hover {
            color: #4a90e2;
        }

        .tab-button.active {
            color: #4a90e2;
            border-bottom-color: #4a90e2;
        }

        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
        }

        .table-container {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 16px;
        }

        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #E5E7EB;
        }

        th {
            background-color: #F9FAFB;
            font-weight: 600;
            color: #2c3e50;
        }

        tr:hover {
            background-color: #F9FAFB;
        }

        .progress-circle {
            width: 120px;
            height: 120px;
            position: relative;
            margin: 0 auto;
        }

        .progress-circle svg {
            transform: rotate(-90deg);
        }

        .progress-circle circle {
            fill: none;
            stroke-width: 8;
        }

        .progress-circle .circle-bg {
            stroke: #E5E7EB;
        }

        .progress-circle .circle-fg {
            stroke: #4a90e2;
            stroke-linecap: round;
            transition: stroke-dashoffset 0.3s ease;
        }

        .progress-circle span {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 24px;
            font-weight: 600;
            color: #4a90e2;
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
            <ul class="navbar-nav">
                <li><a class="nav-link" href="${pageContext.request.contextPath}/admin">
                    <i class="fas fa-home"></i> Dashboard
                </a></li>
                <li><a class="nav-link" href="${pageContext.request.contextPath}/admin/users">
                    <i class="fas fa-users"></i> Users
                </a></li>
                <li><a class="nav-link active" href="${pageContext.request.contextPath}/admin/reports">
                    <i class="fas fa-chart-bar"></i> Reports
                </a></li>
                <li><a class="nav-link" href="${pageContext.request.contextPath}/admin/notifications">
                    <i class="fas fa-bell"></i> Notifications
                </a></li>
                <li><a class="nav-link" href="${pageContext.request.contextPath}/logout">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a></li>
            </ul>
        </div>
    </nav>

    <div class="container">
        <!-- Statistics Overview -->
        <div class="stats-grid">
            <div class="stat-card">
                <h3><%= reportData.get("totalStudents") %></h3>
                <p>Total Students</p>
            </div>
            <div class="stat-card">
                <h3><%= reportData.get("totalTeachers") %></h3>
                <p>Total Teachers</p>
            </div>
            <div class="stat-card">
                <h3><%= reportData.get("totalClasses") %></h3>
                <p>Total Classes</p>
            </div>
        </div>

        <!-- Attendance Reports -->
        <div class="card">
            <h2 style="color: #2c3e50; margin-bottom: 24px;">Attendance Reports</h2>
            
            <!-- Tab Buttons -->
            <div class="tab-buttons">
                <button class="tab-button active" onclick="showTab('student-tab')">Student Attendance</button>
                <button class="tab-button" onclick="showTab('teacher-tab')">Teacher Attendance</button>
            </div>

            <!-- Student Attendance Tab -->
            <div id="student-tab" class="tab-content active">
                <div class="progress-circle" data-progress="<%= reportData.get("studentAttendance") %>">
                    <svg width="120" height="120">
                        <circle class="circle-bg" cx="60" cy="60" r="50"></circle>
                        <circle class="circle-fg" cx="60" cy="60" r="50" 
                                stroke-dasharray="314" 
                                stroke-dashoffset="<%=(100 - (Double)reportData.get("studentAttendance")) * 3.14%>"></circle>
                    </svg>
                    <span><%= String.format("%.1f", reportData.get("studentAttendance")) %>%</span>
                </div>
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Student ID</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Attendance record : studentRecords) { %>
                            <tr>
                                <td><%= record.getDate() %></td>
                                <td><%= record.getUserId() %></td>
                                <td><%= record.getStatus() %></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Teacher Attendance Tab -->
            <div id="teacher-tab" class="tab-content">
                <div class="progress-circle" data-progress="<%= reportData.get("teacherAttendance") %>">
                    <svg width="120" height="120">
                        <circle class="circle-bg" cx="60" cy="60" r="50"></circle>
                        <circle class="circle-fg" cx="60" cy="60" r="50" 
                                stroke-dasharray="314" 
                                stroke-dashoffset="<%=(100 - (Double)reportData.get("teacherAttendance")) * 3.14%>"></circle>
                    </svg>
                    <span><%= String.format("%.1f", reportData.get("teacherAttendance")) %>%</span>
                </div>
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Teacher ID</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Attendance record : teacherRecords) { %>
                            <tr>
                                <td><%= record.getDate() %></td>
                                <td><%= record.getUserId() %></td>
                                <td><%= record.getStatus() %></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
    <script>
        AOS.init();

        function showTab(tabId) {
            // Hide all tab contents
            document.querySelectorAll('.tab-content').forEach(tab => {
                tab.classList.remove('active');
            });
            
            // Remove active class from all buttons
            document.querySelectorAll('.tab-button').forEach(button => {
                button.classList.remove('active');
            });
            
            // Show selected tab content
            document.getElementById(tabId).classList.add('active');
            
            // Add active class to clicked button
            event.target.classList.add('active');
        }
    </script>
</body>
</html> 