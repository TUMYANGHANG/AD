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
        <!-- Report Filters -->
        <div class="card" data-aos="fade-up">
            <h2 style="color: #48bb78; margin-bottom: 16px;"><i class="fas fa-filter"></i> Report Filters</h2>
            <form action="${pageContext.request.contextPath}/teacher/reports/generate" method="get" class="report-filters">
                <div class="filter-group">
                    <label for="reportType">Report Type</label>
                    <select id="reportType" name="type" required>
                        <option value="attendance">Attendance Report</option>
                        <option value="class">Class-wise Report</option>
                        <option value="student">Student-wise Report</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label for="startDate">Start Date</label>
                    <input type="date" id="startDate" name="startDate" required>
                </div>
                <div class="filter-group">
                    <label for="endDate">End Date</label>
                    <input type="date" id="endDate" name="endDate" required>
                </div>
                <div class="filter-group">
                    <label for="className">Class</label>
                    <select id="className" name="className">
                        <option value="">All Classes</option>
                        <%
                        Set<String> uniqueClasses = new HashSet<>();
                        for (Student student : students) {
                            if (student.getClassName() != null) {
                                uniqueClasses.add(student.getClassName());
                            }
                        }
                        for (String className : uniqueClasses) {
                        %>
                        <option value="<%= className %>"><%= className %></option>
                        <% } %>
                    </select>
                </div>
                <div class="filter-group" style="display: flex; align-items: flex-end;">
                    <button type="submit" class="btn">
                        <i class="fas fa-search"></i> Generate Report
                    </button>
                </div>
            </form>
        </div>

        <!-- Statistics Overview -->
        <div class="stats-grid" data-aos="fade-up" data-aos-delay="100">
            <div class="stat-card">
                <h3>${reportData.totalStudents}</h3>
                <p>Total Students</p>
            </div>
            <div class="stat-card">
                <h3>${reportData.averageAttendance}%</h3>
                <p>Average Attendance</p>
            </div>
            <div class="stat-card">
                <h3>${reportData.totalPresent}</h3>
                <p>Total Present</p>
            </div>
            <div class="stat-card">
                <h3>${reportData.totalAbsent}</h3>
                <p>Total Absent</p>
            </div>
        </div>

        <!-- Attendance Overview -->
        <div class="card" data-aos="fade-up" data-aos-delay="200">
            <h2 style="color: #48bb78; margin-bottom: 16px;"><i class="fas fa-chart-pie"></i> Attendance Overview</h2>
            <div class="progress-circle" data-progress="${reportData.averageAttendance}">
                <svg width="120" height="120">
                    <circle class="circle-bg" cx="60" cy="60" r="50"></circle>
                    <circle class="circle-fg" cx="60" cy="60" r="50" 
                            stroke-dasharray="314" 
                            stroke-dashoffset="${(100 - reportData.averageAttendance) * 3.14}"></circle>
                </svg>
                <span>${reportData.averageAttendance}%</span>
            </div>
            <p style="text-align: center; margin: 16px 0; color: #4B5563;">
                ${reportData.totalPresent} students present, ${reportData.totalAbsent} students absent
            </p>
        </div>

        <!-- Detailed Report -->
        <div class="card" data-aos="fade-up" data-aos-delay="300">
            <h2 style="color: #48bb78; margin-bottom: 16px;"><i class="fas fa-table"></i> Detailed Report</h2>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Class</th>
                            <th>Total Students</th>
                            <th>Present</th>
                            <th>Absent</th>
                            <th>Attendance %</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Add dynamic rows based on report data -->
                        <tr>
                            <td colspan="6" style="text-align: center;">Select filters and generate report to view data</td>
                        </tr>
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