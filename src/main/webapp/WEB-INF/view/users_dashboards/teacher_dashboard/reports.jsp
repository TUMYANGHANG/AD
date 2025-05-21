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

    // Get report data from request attributes
    Map<String, Object> reportData = (Map<String, Object>) request.getAttribute("reportData");
    if (reportData == null) {
        reportData = new HashMap<>();
    }

    // Get students from request attributes
    List<Student> students = (List<Student>) request.getAttribute("students");
    if (students == null) {
        students = new ArrayList<>();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Attendance Reports - Teacher Dashboard</title>
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

        .report-filters {
            display: flex;
            gap: 16px;
            margin-bottom: 24px;
            flex-wrap: wrap;
        }

        .filter-group {
            flex: 1;
            min-width: 200px;
        }

        .filter-group label {
            display: block;
            margin-bottom: 8px;
            color: #4B5563;
            font-weight: 500;
        }

        .filter-group select,
        .filter-group input {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #E5E7EB;
            border-radius: 6px;
            font-size: 14px;
        }

        .btn {
            background-color: #48bb78;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s ease;
        }

        .btn:hover {
            background-color: #38a169;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 24px;
            margin-bottom: 24px;
        }

        .stat-card {
            background: linear-gradient(135deg, #48bb78, #38a169);
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
            color: #4B5563;
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
            stroke: #48bb78;
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
            color: #48bb78;
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
                <li><a class="nav-link active" href="${pageContext.request.contextPath}/teacher/reports">
                    <i class="fas fa-chart-bar"></i> Reports
                </a></li>
                <li><a class="nav-link" href="${pageContext.request.contextPath}/teacher/notifications">
                    <i class="fas fa-bell"></i> Notifications
                </a></li>
                <li><a class="nav-link" href="${pageContext.request.contextPath}/logout">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a></li>
            </ul>
        </div>
    </nav>

    <div class="container">
        <div class="card">
            <h2 style="margin-bottom: 20px; color: #2D3748;">Student Attendance Report</h2>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Student Name</th>
                            <th>Total Present</th>
                            <th>Total Absent</th>
                            <th>Absent Percentage</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        Map<Integer, List<Attendance>> studentAttendanceMap = (Map<Integer, List<Attendance>>) reportData.get("studentAttendanceMap");
                        if (students != null && studentAttendanceMap != null) {
                            for (Student student : students) {
                                int totalPresent = 0;
                                int totalAbsent = 0;
                                double absentPercentage = 0.0;
                                
                                // Get attendance records for this student from the map
                                List<Attendance> attendanceRecords = studentAttendanceMap.get(student.getId());
                                
                                // Debugging output
                                System.out.println("Processing student: " + student.getUsername() + " (ID: " + student.getId() + ")");
                                if (attendanceRecords != null) {
                                    System.out.println("Found " + attendanceRecords.size() + " attendance records.");
                                    for (Attendance record : attendanceRecords) {
                                        System.out.println("  Record ID: " + record.getId() + ", Status: " + record.getStatus() + ", Date: " + record.getDate());
                                        if ("present".equalsIgnoreCase(record.getStatus())) {
                                            totalPresent++;
                                        } else if ("absent".equalsIgnoreCase(record.getStatus())) {
                                            totalAbsent++;
                                        }
                                    }
                                } else {
                                    System.out.println("No attendance records found for this student in the map.");
                                }
                                
                                // Calculate absent percentage
                                int total = totalPresent + totalAbsent;
                                if (total > 0) {
                                    absentPercentage = (double) totalAbsent / total * 100;
                                }
                                
                                // Determine status based on absent percentage
                                String status = "Good";
                                String statusColor = "#48bb78";
                                if (absentPercentage > 30) {
                                    status = "Poor";
                                    statusColor = "#E53E3E";
                                } else if (absentPercentage > 15) {
                                    status = "Fair";
                                    statusColor = "#ECC94B";
                                }
                        %>
                            <tr>
                                <td><%= student.getUsername() %></td>
                                <td><%= totalPresent %></td>
                                <td><%= totalAbsent %></td>
                                <td><%= String.format("%.1f%%", absentPercentage) %></td>
                                <td style="color: <%= statusColor %>"><%= status %></td>
                            </tr>
                        <% }}
                         %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
    <script>
        // Initialize AOS animations
        AOS.init();

        // Set default dates
        const today = new Date();
        const lastMonth = new Date(today.getFullYear(), today.getMonth() - 1, today.getDate());
        
        document.getElementById('startDate').value = lastMonth.toISOString().split('T')[0];
        document.getElementById('endDate').value = today.toISOString().split('T')[0];

        // Update progress circle
        function updateProgressCircle() {
            const circles = document.querySelectorAll('.progress-circle');
            circles.forEach(circle => {
                const progress = circle.dataset.progress;
                const circleFg = circle.querySelector('.circle-fg');
                const offset = (100 - progress) * 3.14;
                circleFg.style.strokeDashoffset = offset;
            });
        }

        // Call on page load
        updateProgressCircle();
    </script>
</body>
</html> 