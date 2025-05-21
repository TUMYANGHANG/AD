<%--
  Created by IntelliJ IDEA.
  User: Dell
  Date: 5/16/2025
  Time: 12:14 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.Teacher, model.Student, dao.TeacherDAO, dao.StudentDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="model.User" %>

<%
    // Session check
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
        return;
    }

    // Get data from request attributes
    List<Student> students = (List<Student>) request.getAttribute("students");
    List<Teacher> teachers = (List<Teacher>) request.getAttribute("teachers");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - Admin Dashboard</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
    <style>
        /* --- NAVBAR STYLES (DO NOT CHANGE) --- */
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
        /* --- END NAVBAR STYLES --- */

        /* --- NEW CUSTOM CSS FOR USERS PAGE --- */
        body {
            background: #f5f6fa;
            color: #222;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .container {
            max-width: 1100px;
            margin: 40px auto;
            padding: 0 16px;
        }
        .card {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.07);
            margin-bottom: 32px;
            padding: 32px 24px;
        }
        .card-title {
            font-size: 2rem;
            font-weight: 600;
            color: #222;
            margin-bottom: 24px;
        }
        .table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            background: #fff;
            border-radius: 10px;
            overflow: hidden;
            margin-bottom: 24px;
        }
        .table th {
            background: #4a90e2;
            color: #fff;
            font-weight: 500;
            padding: 14px 10px;
            border: none;
            font-size: 1rem;
        }
        .table td {
            padding: 12px 10px;
            border-bottom: 1px solid #f0f0f0;
            vertical-align: middle;
        }
        .table tr:last-child td {
            border-bottom: none;
        }
        .actions {
            white-space: nowrap;
        }
        .btn {
            display: inline-block;
            padding: 8px 18px;
            border-radius: 5px;
            border: none;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            transition: background 0.2s, color 0.2s, box-shadow 0.2s;
        }
        .btn-danger {
            background: #e74c3c;
            color: #fff;
        }
        .btn-danger:hover {
            background: #c0392b;
        }
        .btn-warning {
            background: #f1c40f;
            color: #fff;
        }
        .btn-warning:hover {
            background: #d4ac0d;
        }
        .search-box {
            position: relative;
            margin-bottom: 20px;
        }
        .search-box input {
            width: 100%;
            padding: 10px 16px 10px 38px;
            border-radius: 20px;
            border: 1px solid #ddd;
            font-size: 1rem;
        }
        .search-box i {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #666;
        }
        .filter-section {
            margin-bottom: 20px;
        }
        .filter-section select {
            border-radius: 20px;
            padding: 8px 15px;
            border: 1px solid #ddd;
            font-size: 1rem;
        }
        .alert {
            border-radius: 10px;
            border: none;
            padding: 12px 18px;
            margin-bottom: 18px;
        }
        .alert-success {
            background: #d4edda;
            color: #155724;
        }
        .alert-danger {
            background: #f8d7da;
            color: #721c24;
        }
        h3 {
            font-size: 1.3rem;
            font-weight: 600;
            margin-top: 32px;
            margin-bottom: 16px;
        }
        /* --- END NEW CUSTOM CSS --- */
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
                        <a class="nav-link active" href="${pageContext.request.contextPath}/admin/users">
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
                    
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/logout">
                            <i class="fas fa-sign-out-alt"></i> Logout
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="container mt-4">
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h2 class="card-title">
                                <i class="fas fa-users"></i> User Management
                            </h2>
                        </div>

                        <!-- Search and Filter -->
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <div class="search-box">
                                    <i class="fas fa-search"></i>
                                    <input type="text" class="form-control" id="searchInput" placeholder="Search users...">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="filter-section">
                                    <select class="form-select" id="roleFilter">
                                        <option value="all">All Roles</option>
                                        <option value="student">Students</option>
                                        <option value="teacher">Teachers</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <!-- Alerts -->
                        <c:if test="${not empty success}">
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                ${success}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                ${error}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <!-- Students Table -->
                        <h3 class="mb-3">Students</h3>
                        <div class="table-responsive" id="studentsTableWrapper">
                            <table class="table" data-role="student">
                                <thead>
                                    <tr>
                                        <th>Username</th>
                                        <th>Email</th>
                                        <th>Roll No</th>
                                        <th>Class</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${students}" var="student">
                                        <tr>
                                            <td>${student.username}</td>
                                            <td>${student.email}</td>
                                            <td>${student.rollNo}</td>
                                            <td>${student.className}</td>
                                            <td class="actions">
                                                <form action="/student_attendance_management_system_war_exploded/admin/users/delete" method="post">
                                                    <input type="hidden" name="id" value="${student.id}">
                                                    <input type="hidden" name="role" value="student">
                                                    <button type="submit">Delete</button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <!-- Teachers Table -->
                        <h3 class="mb-3 mt-4">Teachers</h3>
                        <div class="table-responsive" id="teachersTableWrapper">
                            <table class="table" data-role="teacher">
                                <thead>
                                    <tr>
                                        <th>Username</th>
                                        <th>Email</th>
                                        <th>Department</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${teachers}" var="teacher">
                                        <tr>
                                            <td>${teacher.username}</td>
                                            <td>${teacher.email}</td>
                                            <td>${teacher.department}</td>
                                            <td class="actions">
                                                <form action="${pageContext.request.contextPath}/admin/users/delete" method="post" class="d-inline">
                                                    <input type="hidden" name="id" value="${teacher.id}">
                                                    <input type="hidden" name="role" value="teacher">
                                                    <button type="submit" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete this teacher?')">
                                                        <i class="fas fa-trash"></i> Delete
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
    <script>
        // Initialize AOS
        AOS.init();

        // Search functionality
        document.getElementById('searchInput').addEventListener('keyup', function(e) {
            // Prevent event from bubbling up
            e.stopPropagation();
            
            const searchText = this.value.toLowerCase();
            const tables = document.querySelectorAll('table');
            
            tables.forEach(table => {
                const rows = table.getElementsByTagName('tr');
                for (let i = 1; i < rows.length; i++) {
                    const row = rows[i];
                    const cells = row.getElementsByTagName('td');
                    let found = false;
                    
                    for (let j = 0; j < cells.length; j++) {
                        const cell = cells[j];
                        if (cell.textContent.toLowerCase().indexOf(searchText) > -1) {
                            found = true;
                            break;
                        }
                    }
                    
                    row.style.display = found ? '' : 'none';
                }
            });
        });

        // Role filter functionality (robust, no :contains)
        document.getElementById('roleFilter').addEventListener('change', function(e) {
            const selectedRole = this.value;
            const studentsTable = document.querySelector('table[data-role="student"]').parentElement;
            const teachersTable = document.querySelector('table[data-role="teacher"]').parentElement;
            if (selectedRole === 'all') {
                studentsTable.style.display = '';
                teachersTable.style.display = '';
            } else if (selectedRole === 'student') {
                studentsTable.style.display = '';
                teachersTable.style.display = 'none';
            } else if (selectedRole === 'teacher') {
                studentsTable.style.display = 'none';
                teachersTable.style.display = '';
            }
        });

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

        // Add form submission handler
        document.querySelectorAll('form[action*="delete"]').forEach(form => {
            form.addEventListener('submit', function(e) {
                // Don't prevent default - let the form submit
                console.log('Form submitted:', this.action);
            });
        });
    </script>
</body>
</html>
