<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat, java.util.Date, model.User, model.Teacher, model.Student, dao.TeacherDAO, java.sql.SQLException, java.util.List, java.util.ArrayList, java.time.Year, java.util.Set, java.util.HashSet" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"teacher".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
        return;
    }

    TeacherDAO teacherDAO = new TeacherDAO();
    Teacher teacher = null;
    List<Student> students = new ArrayList<>();
    try {
        teacher = teacherDAO.getTeacherData(user.getId());
        students = teacherDAO.getAllStudents();
        if (teacher == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=profileNotFound");
            return;
        }
    } catch (SQLException e) {
        java.util.logging.Logger.getLogger("TeacherDashboard").log(java.util.logging.Level.SEVERE, "Error fetching data", e);
        response.sendRedirect(request.getContextPath() + "/login?error=databaseError");
        return;
    }

    SimpleDateFormat sdf = new SimpleDateFormat("MMMM dd, yyyy");
    String currentDate = sdf.format(new Date());
    request.setAttribute("currentDate", currentDate);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Teacher Dashboard - Itahari International College Student Attendance Management System">
    <meta name="keywords" content="Itahari International College, teacher dashboard, student management, attendance">
    <meta name="author" content="Itahari International College">
    <title>Teacher Dashboard - Itahari International College</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/favicon.png">
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f5f8fb;
            color: #1a202c;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .navbar {
            background: linear-gradient(90deg, #1a202c, #2d3748);
            padding: 12px 20px;
            display: flex;
            justify-content: flex-start;
            align-items: center;
            position: fixed;
            top: 0;
            width: 100%;
            z-index: 1100;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .navbar-brand {
            font-size: 24px;
            font-weight: 600;
            color: #fff;
        }

        .sidebar {
            width: 240px;
            background: linear-gradient(180deg, #1a202c, #2d3748);
            color: #fff;
            position: fixed;
            top: 60px;
            left: 0;
            height: calc(100% - 60px);
            padding: 20px 0;
            z-index: 1000;
            display: block;
            box-shadow: 2px 0 4px rgba(0, 0, 0, 0.1);
        }

        .sidebar-menu {
            list-style: none;
            padding: 10px 0;
        }

        .sidebar-menu li {
            margin: 8px 0;
        }

        .sidebar-menu a {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #e2e8f0;
            text-decoration: none;
            font-size: 15px;
            font-weight: 500;
            padding: 10px 20px;
            border-radius: 0 20px 20px 0;
            transition: background 0.3s, transform 0.2s;
        }

        .sidebar-menu a:hover {
            background: #48bb78;
            color: #fff;
            transform: translateX(5px);
        }

        .sidebar-btn {
            display: none;
            background: #48bb78;
            color: #fff;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 500;
            text-align: center;
            cursor: pointer;
            position: fixed;
            top: 70px;
            left: 15px;
            z-index: 1200;
            transition: background 0.3s, transform 0.2s;
        }

        .sidebar-btn:hover {
            background: #38a169;
            transform: scale(1.05);
        }

        .main-content {
            margin-left: 240px;
            margin-top: 60px;
            padding: 25px;
            flex: 1;
        }

        .hero-bg {
            background: linear-gradient(135deg, rgba(72, 187, 120, 0.9), rgba(0, 0, 0, 0.6)), url('${pageContext.request.contextPath}/images/classes.jpg');
            background-size: cover;
            background-position: center;
            height: 220px;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            color: #fff;
            border-radius: 12px;
            margin-bottom: 25px;
        }

        .hero-bg h1 {
            font-size: 32px;
            font-weight: 600;
        }

        .hero-bg p {
            font-size: 16px;
            margin: 10px 0;
        }

        .dashboard-container {
            max-width: 1100px;
            margin: 0 auto;
        }

        .card {
            background: #fff;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s, box-shadow 0.3s;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
        }

        .profile-card {
            max-width: 550px;
            margin: 0 auto 30px;
            text-align: center;
        }

        .note {
            background: linear-gradient(90deg, #e6fffa, #f7fafc);
            border-left: 5px solid #48bb78;
            padding: 10px 15px;
            border-radius: 6px;
            font-size: 14px;
            color: #1a202c;
            margin: 15px 0;
        }

        .success-message {
            background: linear-gradient(90deg, #c6f6d5, #f7fafc);
            border-left: 5px solid #48bb78;
            padding: 10px 15px;
            border-radius: 6px;
            font-size: 14px;
            color: #2f855a;
            margin: 15px 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .error-message {
            background: linear-gradient(90deg, #fed7d7, #f7fafc);
            border-left: 5px solid #f56565;
            padding: 10px 15px;
            border-radius: 6px;
            font-size: 14px;
            color: #9b2c2c;
            margin: 15px 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .btn {
            background: #48bb78;
            color: #fff;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 500;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: background 0.3s, transform 0.2s;
            border: none;
            cursor: pointer;
        }

        .btn:hover {
            background: #38a169;
            transform: scale(1.05);
        }

        .btn.delete {
            background: #f56565;
        }

        .btn.delete:hover {
            background: #c53030;
        }

        .btn.close {
            background: transparent;
            color: inherit;
            padding: 0;
            border: none;
            font-size: 16px;
            cursor: pointer;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-top: 25px;
        }

        .teacher-profile {
            display: flex;
            gap: 20px;
            align-items: center;
            justify-content: center;
            flex-wrap: wrap;
        }

        .profile-photo {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background: #edf2f7;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 3px solid #48bb78;
            overflow: hidden;
        }

        .profile-photo img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .profile-photo-placeholder {
            font-size: 14px;
            color: #718096;
            text-align: center;
        }

        .student-photo {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: #edf2f7;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 2px solid #48bb78;
            overflow: hidden;
        }

        .student-photo img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .student-photo-placeholder {
            font-size: 10px;
            color: #718096;
            text-align: center;
        }

        .search-bar {
            margin: 25px 0;
            display: flex;
            justify-content: center;
        }

        .search-bar input {
            width: 100%;
            max-width: 550px;
            padding: 10px 15px;
            border: 1px solid #e2e8f0;
            border-radius: 20px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.3s, box-shadow 0.3s;
        }

        .search-bar input:focus {
            border-color: #48bb78;
            box-shadow: 0 0 6px rgba(72, 187, 120, 0.3);
        }

        .student-table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            background: #fff;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        .student-table th,
        .student-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
        }

        .student-table th {
            background: #48bb78;
            color: #fff;
            font-weight: 500;
            cursor: pointer;
            position: relative;
        }

        .student-table th:hover {
            background: #38a169;
        }

        .student-table th.sort-asc::after {
            content: '↑';
            position: absolute;
            right: 8px;
        }

        .student-table th.sort-desc::after {
            content: '↓';
            position: absolute;
            right: 8px;
        }

        .student-table tr:hover {
            background: #f7fafc;
        }

        .filter-section {
            display: flex;
            gap: 15px;
            margin: 20px 0;
            flex-wrap: wrap;
            justify-content: center;
        }

        .filter-section select {
            padding: 8px 15px;
            border: 1px solid #e2e8f0;
            border-radius: 20px;
            font-size: 14px;
            outline: none;
            background: #fff;
            cursor: pointer;
        }

        .filter-section select:focus {
            border-color: #48bb78;
            box-shadow: 0 0 6px rgba(72, 187, 120, 0.3);
        }

        .no-students {
            text-align: center;
            padding: 20px;
            color: #718096;
            font-style: italic;
        }

        .info-section {
            margin-top: 30px;
        }

        .info-section h3 {
            font-size: 24px;
            font-weight: 600;
            color: #1a202c;
            margin-bottom: 15px;
            text-align: center;
        }

        .info-card {
            background: #fff;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }

        .info-card h4 {
            font-size: 18px;
            font-weight: 500;
            color: #48bb78;
            margin-bottom: 10px;
        }

        .info-card p {
            font-size: 14px;
            color: #1a202c;
            margin: 6px 0;
        }

        footer {
            background: linear-gradient(90deg, #1a202c, #2d3748);
            padding: 20px;
            color: #e2e8f0;
            text-align: center;
            width: 100%;
            margin-top: auto;
        }

        /* Loading state for deletion */
        body.deleting::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(255,255,255,0.7);
            z-index: 9999;
        }

        body.deleting::after {
            content: 'Deleting student...';
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: #48bb78;
            color: white;
            padding: 15px 25px;
            border-radius: 5px;
            z-index: 10000;
            font-size: 16px;
        }

        @media (max-width: 768px) {
            .sidebar {
                display: none;
            }

            .sidebar-btn {
                display: block;
            }

            .main-content {
                margin-left: 0;
                margin-top: 60px;
                padding: 15px;
            }

            .hero-bg {
                height: 180px;
            }

            .hero-bg h1 {
                font-size: 28px;
            }

            .hero-bg p {
                font-size: 14px;
            }

            .grid {
                grid-template-columns: 1fr;
            }

            .teacher-profile {
                flex-direction: column;
            }

            .search-bar input {
                max-width: 100%;
            }

            .student-table {
                font-size: 12px;
            }

            .student-table th,
            .student-table td {
                padding: 8px;
            }

            .student-photo {
                width: 30px;
                height: 30px;
            }
        }
    </style>
</head>
<body>
<nav class="navbar">
    <div class="navbar-brand">Itahari International College</div>
</nav>

<nav class="sidebar" id="sidebar">
    <ul class="sidebar-menu">
        <li><a href="${pageContext.request.contextPath}/Nav_teacher_dashServlet"><i class="fas fa-home"></i> Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/students"><i class="fas fa-users"></i> Students</a></li>
        <li><a href="${pageContext.request.contextPath}/manage-attendance"><i class="fas fa-clipboard-check"></i> Attendance</a></li>
        <li><a href="${pageContext.request.contextPath}/teacher/reports"><i class="fas fa-chart-bar"></i> Reports</a></li>
        <li><a href="${pageContext.request.contextPath}/teacher/notifications"><i class="fas fa-bell"></i> Notifications</a></li>
        <li><a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
    </ul>
</nav>
<div class="sidebar-btn" id="sidebar-btn" onclick="toggleSidebar()">Hide Sidebar</div>

<div class="main-content">
    <section class="hero-bg" data-aos="zoom-in">
        <div style="max-width: 700px; padding: 15px;">
            <h1>Welcome, <%= teacher.getUsername() %>!</h1>
            <p>Manage your teaching tasks with ease and efficiency.</p>
            <div class="note" style="background: rgba(255, 255, 255, 0.3); color: #fff; max-width: 450px; margin: 0 auto;">
                Today is <%= currentDate %>. Inspire your students!
            </div>
        </div>
    </section>

    <!-- Message Display Area -->
    <% if (session.getAttribute("successMessage") != null) { %>
    <div class="success-message" data-aos="fade-up">
        <span><%= session.getAttribute("successMessage") %></span>
        <button class="btn close" onclick="this.parentElement.remove()">&times;</button>
        <% session.removeAttribute("successMessage"); %>
    </div>
    <% } %>
    <% if (session.getAttribute("errorMessage") != null) { %>
    <div class="error-message" data-aos="fade-up">
        <span><%= session.getAttribute("errorMessage") %></span>
        <button class="btn close" onclick="this.parentElement.remove()">&times;</button>
        <% session.removeAttribute("errorMessage"); %>
    </div>
    <% } %>

    <section class="dashboard-container">
        <h2 style="font-size: 28px; font-weight: 600; color: #1a202c; text-align: center; margin-bottom: 25px;" data-aos="fade-up">Teacher Dashboard</h2>

        <!-- Teacher Profile Card -->
        <div class="card profile-card" data-aos="fade-up" data-aos-delay="100">
            <h3 style="font-size: 22px; font-weight: 500; color: #48bb78; margin-bottom: 15px;"><i class="fas fa-user-circle"></i> Teacher Profile</h3>
            <div class="teacher-profile">
                <div class="profile-photo">
                    <% if (teacher.getPhotoPath() != null && !teacher.getPhotoPath().isEmpty()) { %>
                    <img src="${pageContext.request.contextPath}/Images/<%= teacher.getPhotoPath() %>" alt="Teacher Photo"
                         onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                    <div class="profile-photo-placeholder" style="display: none;">No Photo</div>
                    <% } else { %>
                    <div class="profile-photo-placeholder">No Photo</div>
                    <% } %>
                </div>
                <div>
                    <div><strong>Name:</strong> <%= teacher.getUsername() %></div>
                    <div><strong>Email:</strong> <%= teacher.getEmail() %></div>
                    <div><strong>Department:</strong> <%= teacher.getDepartment() != null ? teacher.getDepartment() : "Not Set" %></div>
                    <div><strong>Employee ID:</strong> <%= teacher.getEmployeeId() != null ? teacher.getEmployeeId() : "Not Set" %></div>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/EditProfileServlet" class="btn" style="margin-top: 15px;"><i class="fas fa-edit"></i> Edit Profile</a>
        </div>

        <div class="note" data-aos="fade-up" data-aos-delay="200">Tip: Navigate using the sidebar!</div>

        <!-- Search and Filter Section -->
        <div class="search-bar" data-aos="fade-up" data-aos-delay="300">
            <input type="text" id="student-search" placeholder="Search students by name, roll number, or email..." onkeyup="searchStudents()">
        </div>
        
        <div class="filter-section" data-aos="fade-up" data-aos-delay="350">
            <select id="class-filter" onchange="filterStudents()">
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

        <table class="student-table" id="student-table" data-aos="fade-up" data-aos-delay="400">
            <thead>
            <tr>
                <th onclick="sortTable(0)">Photo</th>
                <th onclick="sortTable(1)">Name</th>
                <th onclick="sortTable(2)">Roll No</th>
                <th onclick="sortTable(3)">Class</th>
                <th onclick="sortTable(4)">Email</th>
                <th>Action</th>
            </tr>
            </thead>
            <tbody>
            <% if (students.isEmpty()) { %>
            <tr>
                <td colspan="6" class="no-students">No students found</td>
            </tr>
            <% } else {
                for (Student student : students) { %>
            <tr>
                <td>
                    <div class="student-photo">
                        <% if (student.getPhotoPath() != null && !student.getPhotoPath().isEmpty()) { %>
                        <img src="${pageContext.request.contextPath}/Images/<%= student.getPhotoPath() %>" alt="Student Photo"
                             onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                        <div class="student-photo-placeholder" style="display: none;">No Photo</div>
                        <% } else { %>
                        <div class="student-photo-placeholder">No Photo</div>
                        <% } %>
                    </div>
                </td>
                <td><%= student.getUsername() %></td>
                <td><%= student.getRollNumber() != null ? student.getRollNumber() : "N/A" %></td>
                <td><%= student.getClassName() != null ? student.getClassName() : "N/A" %></td>
                <td><%= student.getEmail() != null ? student.getEmail() : "N/A" %></td>
                <td>
                    <form action="${pageContext.request.contextPath}/DeleteStudentServlet" method="post"
                          onsubmit="return confirmDeletion(this, '<%= student.getUsername() %>')">
                        <input type="hidden" name="studentId" value="<%= student.getId() %>">
                        <button type="submit" class="btn delete">
                            <i class="fas fa-trash"></i> Delete
                        </button>
                    </form>
                </td>
            </tr>
            <% }} %>
            </tbody>
        </table>

        <!-- Dashboard Cards -->
        <div class="grid">
            <div class="card" data-aos="fade-up" data-aos-delay="500">
                <h3 style="font-size: 18px; font-weight: 500; color: #48bb78; margin-bottom: 10px;"><i class="fas fa-users"></i> Student Management</h3>
                <p style="color: #718096;">View and manage student profiles.</p>
                <a href="${pageContext.request.contextPath}/students" class="btn"><i class="fas fa-eye"></i> View Students</a>
            </div>
            <div class="card" data-aos="fade-up" data-aos-delay="600">
                <h3 style="font-size: 18px; font-weight: 500; color: #48bb78; margin-bottom: 10px;"><i class="fas fa-clipboard-check"></i> Attendance Management</h3>
                <p style="color: #718096;">Mark and review student attendance.</p>
                <a href="${pageContext.request.contextPath}/manage-attendance" class="btn"><i class="fas fa-check"></i> Mark Attendance</a>
            </div>
            <div class="card" data-aos="fade-up" data-aos-delay="700">
                <h3 style="font-size: 18px; font-weight: 500; color: #48bb78; margin-bottom: 10px;"><i class="fas fa-calendar-alt"></i> Schedule</h3>
                <p style="color: #718096;">Your teaching schedule is displayed below.</p>
                <div style="margin-top: 15px; padding: 10px; background: #f8f9fa; border-radius: 8px;">
                    <p style="margin: 0; color: #4B5563;"><i class="fas fa-info-circle"></i> Schedule is view-only</p>
                </div>
            </div>
            <div class="card" data-aos="fade-up" data-aos-delay="800">
                <h3 style="font-size: 18px; font-weight: 500; color: #48bb78; margin-bottom: 10px;"><i class="fas fa-bell"></i> Notifications</h3>
                <p style="color: #718096;">Send and manage notifications.</p>
                <a href="${pageContext.request.contextPath}/teacher/notifications" class="btn"><i class="fas fa-bell"></i> View Notifications</a>
            </div>
            <div class="card" data-aos="fade-up" data-aos-delay="300">
                <h2 style="color: #48bb78; margin-bottom: 16px;"><i class="fas fa-chart-bar"></i> Reports</h2>
                <p style="color: #4B5563; margin-bottom: 16px;">View detailed attendance reports and analytics for your classes.</p>
                <a href="${pageContext.request.contextPath}/teacher/reports" class="btn">
                    <i class="fas fa-chart-line"></i> View Reports
                </a>
            </div>
        </div>

        <!-- Information Section -->
        <section class="info-section" data-aos="fade-up" data-aos-delay="900">
            <h3>Dashboard Information</h3>
            <div class="info-card">
                <h4>Student Statistics</h4>
                <p><strong>Total Students:</strong> <%= students.size() %></p>
                <p><strong>Classes Assigned:</strong> Not Set</p>
                <p><strong>Average Attendance Rate:</strong> Not Set</p>
                <p><strong>Students with Low Attendance:</strong> Not Set</p>
            </div>
            <div class="info-card">
                <h4>Recent Announcements</h4>
                <p><strong>May 3, 2025:</strong> Parent-Teacher Meeting scheduled for May 10, 2025.</p>
                <p><strong>May 2, 2025:</strong> Mid-term exams start on May 15, 2025.</p>
                <p><strong>April 30, 2025:</strong> Reminder: Submit attendance records by May 5, 2025.</p>
            </div>
        </section>
    </section>
</div>

<footer>
    <div style="max-width: 1100px; margin: 0 auto;">
        <p style="font-size: 14px;">© <%= Year.now().getValue() %> Itahari International College. All rights reserved.</p>
    </div>
</footer>

<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
<script>
    // Initialize AOS animations
    AOS.init({ duration: 800 });

    // Toggle sidebar visibility
    function toggleSidebar() {
        const sidebar = document.getElementById('sidebar');
        const btn = document.getElementById('sidebar-btn');
        if (sidebar && btn) {
            if (sidebar.style.display === 'none') {
                sidebar.style.display = 'block';
                btn.textContent = 'Hide Sidebar';
            } else {
                sidebar.style.display = 'none';
                btn.textContent = 'Show Sidebar';
            }
        }
    }

    // Search students function
    function searchStudents() {
        const input = document.getElementById('student-search').value.toLowerCase();
        const table = document.getElementById('student-table');
        const rows = table.querySelectorAll('tbody tr');
        const classFilter = document.getElementById('class-filter').value;
        
        rows.forEach(row => {
            const name = row.cells[1].textContent.toLowerCase();
            const rollNo = row.cells[2].textContent.toLowerCase();
            const email = row.cells[4].textContent.toLowerCase();
            const className = row.cells[3].textContent;
            
            const matchesSearch = name.includes(input) || rollNo.includes(input) || email.includes(input);
            const matchesClass = !classFilter || className === classFilter;
            
            row.style.display = matchesSearch && matchesClass ? '' : 'none';
        });
    }

    // Filter students by class
    function filterStudents() {
        searchStudents(); // Reuse search function to apply both filters
    }

    // Sort table function
    function sortTable(n) {
        const table = document.getElementById('student-table');
        const tbody = table.querySelector('tbody');
        const rows = Array.from(tbody.querySelectorAll('tr'));
        const header = table.querySelectorAll('th')[n];
        
        // Remove sort indicators from all headers
        table.querySelectorAll('th').forEach(th => {
            th.classList.remove('sort-asc', 'sort-desc');
        });
        
        // Determine sort direction
        const isAsc = !header.classList.contains('sort-asc');
        header.classList.toggle('sort-asc', isAsc);
        header.classList.toggle('sort-desc', !isAsc);
        
        // Sort rows
        rows.sort((a, b) => {
            let x = a.cells[n].textContent.trim();
            let y = b.cells[n].textContent.trim();
            
            // Handle special cases
            if (x === 'N/A') x = '';
            if (y === 'N/A') y = '';
            
            if (isAsc) {
                return x.localeCompare(y);
            } else {
                return y.localeCompare(x);
            }
        });
        
        // Reorder rows in the table
        rows.forEach(row => tbody.appendChild(row));
    }

    // Delete confirmation function
    function confirmDeletion(form, studentName) {
        if (confirm('Are you sure you want to delete ' + studentName + '? This action cannot be undone.')) {
            // Show loading state
            document.body.classList.add('deleting');
            return true;
        }
        return false;
    }
</script>
</body>
</html>