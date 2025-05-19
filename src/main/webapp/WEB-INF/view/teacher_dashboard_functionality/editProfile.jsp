<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat, java.util.Date, model.User, model.Teacher, dao.TeacherDAO, java.sql.SQLException, java.time.Year" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"teacher".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
        return;
    }

    TeacherDAO teacherDAO = new TeacherDAO();
    Teacher teacher = null;
    try {
        teacher = teacherDAO.getTeacherData(user.getId());
        if (teacher == null) {
            response.sendRedirect(request.getContextPath() + "/teacher-dash?error=profileNotFound");
            return;
        }
    } catch (SQLException e) {
        java.util.logging.Logger.getLogger("EditProfile").log(java.util.logging.Level.SEVERE, "Error fetching teacher data", e);
        response.sendRedirect(request.getContextPath() + "/teacher-dash?error=databaseError");
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
    <meta name="description" content="Edit Teacher Profile - Itahari International College Student Attendance Management System">
    <meta name="keywords" content="Itahari International College, teacher profile, edit profile, attendance">
    <meta name="author" content="Itahari International College">
    <title>Edit Teacher Profile - Itahari International College</title>
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
            background: linear-gradient(135deg, rgba(72, 187, 120, 0.9), rgba(0, 0, 0, 0.6)), url('/images/classes.jpg');
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
            max-width: 700px;
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

        .success-message {
            background: linear-gradient(90deg, #c6f6d5, #f7fafc);
            border-left: 5px solid #48bb78;
            padding: 10px 15px;
            border-radius: 6px;
            font-size: 14px;
            color: #2f855a;
            margin: 15px 0;
        }

        .error-message {
            background: linear-gradient(90deg, #fed7d7, #f7fafc);
            border-left: 5px solid #f56565;
            padding: 10px 15px;
            border-radius: 6px;
            font-size: 14px;
            color: #9b2c2c;
            margin: 15px 0;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            font-size: 14px;
            font-weight: 500;
            color: #1a202c;
            margin-bottom: 5px;
        }

        .form-group input,
        .form-group select {
            width: 100%;
            padding: 10px;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.3s, box-shadow 0.3s;
        }

        .form-group input:focus,
        .form-group select:focus {
            border-color: #48bb78;
            box-shadow: 0 0 6px rgba(72, 187, 120, 0.3);
        }

        .form-group input[type="file"] {
            padding: 3px;
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

        .btn.cancel {
            background: #e2e8f0;
            color: #1a202c;
        }

        .btn.cancel:hover {
            background: #cbd5e0;
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
            margin: 0 auto 15px;
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

        footer {
            background: linear-gradient(90deg, #1a202c, #2d3748);
            padding: 20px;
            color: #e2e8f0;
            text-align: center;
            width: 100%;
            margin-top: auto;
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

            .dashboard-container {
                max-width: 100%;
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
        <li><a href="${pageContext.request.contextPath}/teacher-dash"><i class="fas fa-home"></i> Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/students"><i class="fas fa-users"></i> Students</a></li>
        <li><a href="${pageContext.request.contextPath}/manageAttendance"><i class="fas fa-clipboard-check"></i> Attendance</a></li>
        <li><a href="${pageContext.request.contextPath}/fullSchedule"><i class="fas fa-calendar-alt"></i> Schedule</a></li>
        <li><a href="${pageContext.request.contextPath}/sendNotification"><i class="fas fa-bell"></i> Notifications</a></li>
        <li><a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
    </ul>
</nav>
<div class="sidebar-btn" id="sidebar-btn" onclick="toggleSidebar()">Hide Sidebar</div>

<div class="main-content">
    <section class="hero-bg" data-aos="zoom-in">
        <div style="max-width: 700px; padding: 15px;">
            <h1>Edit Your Profile</h1>
            <p>Update your personal and professional details below.</p>
            <div class="note" style="background: rgba(255, 255, 255, 0.3); color: #fff; max-width: 450px; margin: 0 auto;">
                Today is <%= currentDate %>.
            </div>
        </div>
    </section>

    <% if (session.getAttribute("successMessage") != null) { %>
    <div class="success-message" data-aos="fade-up">
        <%= session.getAttribute("successMessage") %>
        <% session.removeAttribute("successMessage"); %>
    </div>
    <% } %>
    <% if (request.getAttribute("error") != null) { %>
    <div class="error-message" data-aos="fade-up">
        <%= request.getAttribute("error") %>
    </div>
    <% } %>

    <section class="dashboard-container">
        <div class="card" data-aos="fade-up" data-aos-delay="100">
            <h3 style="font-size: 22px; font-weight: 500; color: #48bb78; margin-bottom: 15px;">
                <i class="fas fa-user-edit"></i> Edit Profile
            </h3>
            <form action="${pageContext.request.contextPath}/EditProfileServlet" method="post" enctype="multipart/form-data">
                <div class="profile-photo">
                    <% if (teacher.getPhotoPath() != null && !teacher.getPhotoPath().isEmpty()) { %>
                    <img src="${pageContext.request.contextPath}/Images/<%= teacher.getPhotoPath() %>" alt="Teacher Photo"
                         onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                    <div class="profile-photo-placeholder" style="display: none;">No Photo</div>
                    <% } else { %>
                    <div class="profile-photo-placeholder">No Photo</div>
                    <% } %>
                </div>
                <div class="form-group">
                    <label for="photo">Profile Photo</label>
                    <input type="file" id="photo" name="photo" accept="image/*">
                </div>
                <div class="form-group">
                    <label for="username">Username <span style="color: #f56565;">*</span></label>
                    <input type="text" id="username" name="username" value="<%= teacher.getUsername() %>"
                           required>
                </div>
                <div class="form-group">
                    <label for="email">Email <span style="color: #f56565;">*</span></label>
                    <input type="email" id="email" name="email" value="<%= teacher.getEmail() %>"
                           required>
                </div>
                <div class="form-group">
                    <label for="department">Department <span style="color: #f56565;">*</span></label>
                    <input type="text" id="department" name="department"
                           value="<%= teacher.getDepartment() != null ? teacher.getDepartment() : "" %>"
                           required>
                </div>
                <div class="form-group">
                    <label for="employeeID">Employee ID <span style="color: #f56565;">*</span></label>
                    <input type="text" id="employeeID" name="employeeID"
                           value="<%= teacher.getEmployeeId() != null ? teacher.getEmployeeId() : "" %>"
                           required>
                </div>
                <div style="display: flex; gap: 10px; justify-content: center;">
                    <button type="submit" class="btn"><i class="fas fa-save"></i> Save Changes</button>
                    <a href="${pageContext.request.contextPath}/teacher-dash" class="btn cancel"><i class="fas fa-times"></i> Cancel</a>
                </div>
            </form>
        </div>
    </section>
</div>

<footer>
    <div style="max-width: 1100px; margin: 0 auto;">
        <p style="font-size: 14px;">© <%= Year.now().getValue() %> Itahari International College. All rights reserved.</p>
    </div>
</footer>

<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
<script>
    AOS.init({ duration: 800 });

    function toggleSidebar() {
        const sidebar = document.getElementById('sidebar');
        const btn = document.getElementById('sidebar-btn');
        if (sidebar.style.display === 'none') {
            sidebar.style.display = 'block';
            btn.textContent = 'Hide Sidebar';
        } else {
            sidebar.style.display = 'none';
            btn.textContent = 'Show Sidebar';
        }
    }
</script>
</body>
</html>