<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.*" %>
<%
    // Mock data for students
    List<Map<String, Object>> studentRecords = new ArrayList<>();
    studentRecords.add(new HashMap<String, Object>() {{ put("name", "Alice Smith"); put("email", "alice@student.com"); put("class", "10A"); put("total", 180); put("present", 170); put("absent", 10); }});
    studentRecords.add(new HashMap<String, Object>() {{ put("name", "Bob Lee"); put("email", "bob@student.com"); put("class", "10B"); put("total", 180); put("present", 160); put("absent", 20); }});
    // Mock data for teachers
    List<Map<String, Object>> teacherRecords = new ArrayList<>();
    teacherRecords.add(new HashMap<String, Object>() {{ put("name", "Mr. John Doe"); put("email", "john@teacher.com"); put("department", "Math"); put("total", 180); put("present", 175); put("absent", 5); }});
    teacherRecords.add(new HashMap<String, Object>() {{ put("name", "Ms. Jane Roe"); put("email", "jane@teacher.com"); put("department", "Science"); put("total", 180); put("present", 178); put("absent", 2); }});
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Attendance Records - Admin Dashboard</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        /* Navbar Styles (copy from settings.jsp) */
        .navbar { background-color: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); padding: 1rem 0; position: sticky; top: 0; z-index: 1000; height: 70px; display: flex; align-items: center; }
        .navbar-container { max-width: 1200px; margin: 0 auto; padding: 0 1rem; display: flex; justify-content: space-between; align-items: center; width: 100%; }
        .navbar-brand { color: #4a90e2; font-size: 1.5rem; font-weight: bold; text-decoration: none; display: flex; align-items: center; gap: 0.5rem; height: 100%; padding: 0.5rem 0; }
        .navbar-brand i { font-size: 1.8rem; }
        .navbar-nav { display: flex; list-style: none; margin: 0; padding: 0; gap: 1.5rem; height: 100%; align-items: center; }
        .nav-item { position: relative; height: 100%; display: flex; align-items: center; }
        .nav-link { color: #2c3e50; text-decoration: none; padding: 0.75rem 1rem; display: flex; align-items: center; gap: 0.5rem; transition: color 0.3s ease; height: 100%; line-height: 1; }
        .nav-link:hover { color: #4a90e2; }
        .nav-link.active { color: #4a90e2; font-weight: 500; }
        .nav-link i { font-size: 1.1rem; }
        .navbar-toggler { display: none; background: none; border: none; cursor: pointer; padding: 0.5rem; }
        .navbar-toggler-icon { display: block; width: 25px; height: 2px; background-color: #2c3e50; position: relative; transition: background-color 0.3s ease; }
        .navbar-toggler-icon::before, .navbar-toggler-icon::after { content: ''; position: absolute; width: 100%; height: 100%; background-color: #2c3e50; transition: transform 0.3s ease; }
        .navbar-toggler-icon::before { transform: translateY(-8px); }
        .navbar-toggler-icon::after { transform: translateY(8px); }
        @media (max-width: 768px) { .navbar-toggler { display: block; } .navbar-collapse { display: none; position: absolute; top: 100%; left: 0; right: 0; background-color: white; padding: 1rem; box-shadow: 0 2px 4px rgba(0,0,0,0.1); } .navbar-collapse.show { display: block; } .navbar-nav { flex-direction: column; gap: 0.5rem; } .nav-link { padding: 0.75rem 1rem; border-radius: 4px; } .nav-link:hover { background-color: #f8f9fa; } }
        body { font-family: Arial, sans-serif; margin: 0 !important; padding: 0; line-height: 1.6; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 32px auto; padding: 24px; display: flex; gap: 32px; }
        .card { background-color: #fff; border-radius: 8px; padding: 24px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); flex: 1; }
        h2 { color: #1e90ff; margin-bottom: 24px; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 16px; }
        th, td { padding: 10px 12px; text-align: left; }
        th { background-color: #4a90e2; color: #fff; }
        tr:nth-child(even) { background-color: #f8f9fa; }
        tr:hover { background-color: #e6f0fa; }
    </style>
</head>
<body>
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
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin"><i class="fas fa-home"></i> Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/users"><i class="fas fa-users"></i> Users</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/notifications"><i class="fas fa-bell"></i> Notifications</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/settings"><i class="fas fa-cog"></i> Settings</a></li>
                <li class="nav-item"><a class="nav-link active" href="${pageContext.request.contextPath}/admin/records"><i class="fas fa-table"></i> Records</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </div>
    </div>
</nav>
<div class="container">
    <div class="card">
        <h2><i class="fas fa-user-graduate"></i> Student Attendance Records</h2>
        <table>
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Class</th>
                    <th>Total Days</th>
                    <th>Present</th>
                    <th>Absent</th>
                    <th>Percentage</th>
                </tr>
            </thead>
            <tbody>
            <% for (Map<String, Object> s : studentRecords) { %>
                <tr>
                    <td><%= s.get("name") %></td>
                    <td><%= s.get("email") %></td>
                    <td><%= s.get("class") %></td>
                    <td><%= s.get("total") %></td>
                    <td><%= s.get("present") %></td>
                    <td><%= s.get("absent") %></td>
                    <td><%= Math.round((Integer)s.get("present") * 100.0 / (Integer)s.get("total")) %> %</td>
                </tr>
            <% } %>
            </tbody>
        </table>
    </div>
    <div class="card">
        <h2><i class="fas fa-chalkboard-teacher"></i> Teacher Attendance Records</h2>
        <table>
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Department</th>
                    <th>Total Days</th>
                    <th>Present</th>
                    <th>Absent</th>
                    <th>Percentage</th>
                </tr>
            </thead>
            <tbody>
            <% for (Map<String, Object> t : teacherRecords) { %>
                <tr>
                    <td><%= t.get("name") %></td>
                    <td><%= t.get("email") %></td>
                    <td><%= t.get("department") %></td>
                    <td><%= t.get("total") %></td>
                    <td><%= t.get("present") %></td>
                    <td><%= t.get("absent") %></td>
                    <td><%= Math.round((Integer)t.get("present") * 100.0 / (Integer)t.get("total")) %> %</td>
                </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<script>
    function toggleNavbar() {
        const navbarCollapse = document.querySelector('.navbar-collapse');
        navbarCollapse.classList.toggle('show');
    }
    document.addEventListener('click', function(event) {
        const navbarCollapse = document.querySelector('.navbar-collapse');
        const navbarToggler = document.querySelector('.navbar-toggler');
        if (!navbarCollapse.contains(event.target) && !navbarToggler.contains(event.target)) {
            navbarCollapse.classList.remove('show');
        }
    });
</script>
</body>
</html> 