<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat, model.User, model.Student, dao.StudentDAO, java.sql.SQLException" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"student".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
        return;
    }

    StudentDAO studentDAO = new StudentDAO();
    Student student = null;
    try {
        student = studentDAO.getStudentData(user.getId());
    } catch (SQLException e) {
        java.util.logging.Logger.getLogger("StudentDashboard").log(java.util.logging.Level.SEVERE, "Error fetching student data", e);
        request.setAttribute("error", "Unable to load student profile. Please contact support.");
    }

    if (student == null) {
        request.setAttribute("error", "Unable to load student profile. Please contact support.");
    }

    List<Map<String, String>> attendanceRecords = new ArrayList<>();
    Map<String, String> record1 = new HashMap<>();
    record1.put("date", "2025-04-28");
    record1.put("subject", "Database Management");
    record1.put("status", "Present");
    Map<String, String> record2 = new HashMap<>();
    record2.put("date", "2025-04-27");
    record2.put("subject", "Web Development");
    record2.put("status", "Absent");
    attendanceRecords.add(record1);
    attendanceRecords.add(record2);
    request.setAttribute("attendanceRecords", attendanceRecords);

    List<Map<String, String>> classSchedule = new ArrayList<>();
    Map<String, String> class1 = new HashMap<>();
    class1.put("day", "Monday");
    class1.put("time", "10:00 AM - 11:30 AM");
    class1.put("subject", "Database Management");
    class1.put("room", "Room 305");
    Map<String, String> class2 = new HashMap<>();
    class2.put("day", "Monday");
    class2.put("time", "12:00 PM - 1:30 PM");
    class2.put("subject", "Web Development");
    class2.put("room", "Lab 2");
    classSchedule.add(class1);
    classSchedule.add(class2);
    request.setAttribute("classSchedule", classSchedule);

    List<String> notifications = Arrays.asList(
            "Submit your Web Development project by May 5, 2025.",
            "Missed class on Apr 27? Contact your teacher."
    );
    request.setAttribute("notifications", notifications);

    SimpleDateFormat sdf = new SimpleDateFormat("MMMM dd, yyyy");
    String currentDate = sdf.format(new Date());
    request.setAttribute("currentDate", currentDate);

    Map<String, String> studentProfile = new HashMap<>();
    studentProfile.put("attendancePercentage", "92");
    studentProfile.put("totalClasses", "100");
    studentProfile.put("classesAttended", "92");
    request.setAttribute("studentProfile", studentProfile);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Student Dashboard - Itahari International College Student Attendance Management System">
    <meta name="keywords" content="Itahari International College, student dashboard, attendance, schedule">
    <meta name="author" content="Itahari International College">
    <title>Student Dashboard - Itahari International College</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/favicon.png">
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
            transition: width 0.3s ease;
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

        .hero-bg {
            background: linear-gradient(135deg, rgba(70, 130, 180, 0.8), rgba(0, 0, 0, 0.6)), url('/');
            background-size: cover;
            background-position: center;
            height: 35vh;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            color: #fff;
            border-radius: 16px;
        }

        .id-card {
            background: linear-gradient(90deg, #ffffff, #e6f0fa);
            border: 2px solid #4682b4;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
            margin: 20px auto;
            max-width: 600px;
            display: flex;
            gap: 20px;
            align-items: center;
            flex-wrap: wrap;
        }

        .id-photo {
            width: 150px;
            height: 150px;
            border-radius: 8px;
            background-color: #e0e0e0;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            position: relative;
        }

        .id-photo img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .id-photo-placeholder {
            font-size: 14px;
            color: #4B5563;
            text-align: center;
        }

        .id-info {
            flex: 1;
            min-width: 200px;
        }

        .id-info h3 {
            font-size: 22px;
            font-weight: 600;
            color: #4682b4;
            margin-bottom: 12px;
        }

        .id-info div {
            font-size: 16px;
            color: #2f4f4f;
            margin-bottom: 8px;
        }

        .id-actions {
            display: flex;
            gap: 12px;
            margin-top: 12px;
            flex-wrap: wrap;
        }

        .dashboard-container {
            max-width: 1000px;
            margin: 0 auto;
        }

        .card {
            background-color: #fff;
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .card:hover {
            transform: translateY(-8px);
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.15);
        }

        .note {
            background: linear-gradient(90deg, #e6f0fa, #f5f5f5);
            border-left: 5px solid #4682b4;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 16px;
            color: #2f4f4f;
            margin: 16px 0;
        }

        .success-message {
            background: linear-gradient(90deg, #d4edda, #f5f5f5);
            border-left: 5px solid #28a745;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 16px;
            color: #155724;
            margin: 16px 0;
        }

        .error-message {
            background: linear-gradient(90deg, #f8d7da, #f5f5f5);
            border-left: 5px solid #dc3545;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 16px;
            color: #721c24;
            margin: 16px 0;
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
        }

        .btn:hover {
            background-color: #f4a261;
            color: #2f4f4f;
            transform: scale(1.1);
        }

        .progress-circle {
            position: relative;
            width: 120px;
            height: 120px;
            margin: 0 auto;
        }

        .progress-circle svg {
            transform: rotate(-90deg);
        }

        .progress-circle .circle-bg {
            fill: none;
            stroke: #e6f0fa;
            stroke-width: 10;
        }

        .progress-circle .circle-fg {
            fill: none;
            stroke: #4682b4;
            stroke-width: 10;
            stroke-linecap: round;
            transition: stroke-dashoffset 0.5s ease;
        }

        .progress-circle span {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 24px;
            font-weight: bold;
            color: #2f4f4f;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 24px;
            margin-top: 24px;
        }

        .notification-panel {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.3s ease;
        }

        .notification-panel.active {
            max-height: 300px;
        }

        .notification-list {
            list-style: none;
            padding: 0;
            margin: 16px 0 0;
        }

        .notification-list li {
            background-color: #f5f5f5;
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 8px;
            font-size: 15px;
            color: #4B5563;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .schedule-list {
            list-style: none;
            padding: 0;
            margin: 16px 0 0;
        }

        .schedule-list li {
            background-color: #f5f5f5;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 8px;
            font-size: 15px;
            color: #4B5563;
            display: flex;
            justify-content: space-between;
            align-items: center;
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

            .hero-bg {
                height: 30vh;
            }

            .hero-bg h1 {
                font-size: 28px;
            }

            .hero-bg p {
                font-size: 16px;
            }

            .id-card {
                flex-direction: column;
                align-items: flex-start;
            }

            .grid {
                grid-template-columns: 1fr;
            }

            .card {
                padding: 16px;
            }

            .progress-circle {
                width: 100px;
                height: 100px;
            }

            .progress-circle span {
                font-size: 20px;
            }
        }
    </style>
</head>
<body>
<aside class="sidebar" id="sidebar">
    <div class="toggle-btn" onclick="toggleSidebar()">
        <i class="fas fa-bars"></i>
    </div>
    <div class="logo">Itahari International</div>
    <a href="${pageContext.request.contextPath}/student-dash" title="Go to Dashboard"><i class="fas fa-home"></i><span class="nav-text">Dashboard</span></a>
    <a href="${pageContext.request.contextPath}/student-dash#attendance" title="View Attendance"><i class="fas fa-clipboard-check"></i><span class="nav-text">Attendance</span></a>
    <a href="${pageContext.request.contextPath}/student-dash#schedule" title="View Schedule"><i class="fas fa-calendar-alt"></i><span class="nav-text">Schedule</span></a>
    <a href="${pageContext.request.contextPath}/student-dash#notifications" title="View Notifications"><i class="fas fa-bell"></i><span class="nav-text">Notifications</span></a>
    <a href="${pageContext.request.contextPath}/student-dash#profile" title="View Profile"><i class="fas fa-user-circle"></i><span class="nav-text">Profile</span></a>
    <a href="${pageContext.request.contextPath}/logout" title="Log Out"><i class="fas fa-sign-out-alt"></i><span class="nav-text">Logout</span></a>
</aside>

<div class="sidebar-toggle" id="sidebar-toggle">
    <i class="fas fa-bars"></i>
</div>

<div class="main-content">
    <section class="hero-bg" data-aos="zoom-in">
        <div style="max-width: 800px; padding: 16px;">
            <h1 style="font-size: 36px; font-weight: bold; margin-bottom: 12px;">Welcome, <%= user.getUsername() %>!</h1>
            <p style="font-size: 18px; margin-bottom: 16px;">Your student hub for tracking attendance, schedules, and staying updated.</p>
            <div class="note" style="background: rgba(255, 255, 255, 0.2); color: #fff; max-width: 500px; margin: 0 auto;">
                Today is <%= currentDate %>. Let's make it a great day!
            </div>
        </div>
    </section>

    <% if (session.getAttribute("photoUploadSuccess") != null) { %>
    <div class="success-message" data-aos="fade-up">
        <%= session.getAttribute("photoUploadSuccess") %>
        <% session.removeAttribute("photoUploadSuccess"); %>
    </div>
    <% } %>
    <% if (request.getAttribute("error") != null) { %>
    <div class="error-message" data-aos="fade-up">
        <%= request.getAttribute("error") %>
    </div>
    <% } %>

    <div class="id-card" data-aos="fade-up" id="profile">
        <div class="id-photo">
            <% if (student != null && student.getPhotoPath() != null && !student.getPhotoPath().isEmpty()) { %>
            <img src="${pageContext.request.contextPath}/Images/<%= student.getPhotoPath() %>" alt="Student Photo"
                 onerror="console.error('Failed to load image: ${pageContext.request.contextPath}/Images/<%= student.getPhotoPath() %>'); this.style.display='none'; this.nextElementSibling.style.display='block';">
            <% } %>
            <div class="id-photo-placeholder" <%= (student != null && student.getPhotoPath() != null && !student.getPhotoPath().isEmpty()) ? "style='display: none;'" : "" %>>No Photo</div>
        </div>
        <div class="id-info">
            <h3><i class="fas fa-user-circle fa-lg"></i> Student ID</h3>
            <div><strong>Username:</strong> <%= user.getUsername() %></div>
            <div><strong>Roll No:</strong> <%= student != null && student.getRollNumber() != null ? student.getRollNumber() : "Not Set" %></div>
            <div><strong>Class:</strong> <%= student != null && student.getClassName() != null ? student.getClassName() : "Not Set" %></div>
            <div><strong>Email:</strong> <%= user.getEmail() %></div>
        </div>
        <div class="id-actions">
            <a href="${pageContext.request.contextPath}/upload_photo" class="btn"><i class="fas fa-upload"></i> Upload Photo</a>
            <a href="${pageContext.request.contextPath}/editProfile" class="btn"><i class="fas fa-edit"></i> Edit Profile</a>
            <a href="${pageContext.request.contextPath}/contactTeacher" class="btn"><i class="fas fa-envelope"></i> Contact Teacher</a>
        </div>
    </div>

    <section class="dashboard-container">
        <h2 style="font-size: 32px; font-weight: bold; color: #2f4f4f; text-align: center; margin-bottom: 24px;" data-aos="fade-up">Your Student Hub</h2>
        <div class="note" data-aos="fade-up" data-aos-delay="100">Tip: Use the sidebar to navigate or click buttons below for details!</div>

        <div class="grid">
            <div class="card" data-aos="fade-right" id="attendance">
                <h3 style="font-size: 22px; font-weight: 600; color: #4682b4; margin-bottom: 16px;"><i class="fas fa-clipboard-check fa-lg"></i> Attendance</h3>
                <div class="progress-circle" data-progress="<%= studentProfile.get("attendancePercentage") %>">
                    <svg width="120" height="120">
                        <circle class="circle-bg" cx="60" cy="60" r="50"></circle>
                        <circle class="circle-fg" cx="60" cy="60" r="50" stroke-dasharray="314" stroke-dashoffset="<%=(100 - Integer.parseInt(studentProfile.get("attendancePercentage"))) * 3.14%>"></circle>
                    </svg>
                    <span><%= studentProfile.get("attendancePercentage") %>%</span>
                </div>
                <p style="text-align: center; margin: 12px 0; font-size: 16px; color: #4B5563;"><%= studentProfile.get("classesAttended") %>/<%= studentProfile.get("totalClasses") %> classes attended</p>
                <a href="${pageContext.request.contextPath}/fullAttendance" class="btn"><i class="fas fa-eye"></i> View Details</a>
            </div>

            <div class="card" data-aos="fade-left" id="schedule">
                <h3 style="font-size: 22px; font-weight: 600; color: #4682b4; margin-bottom: 16px;"><i class="fas fa-calendar-alt fa-lg"></i> Today’s Schedule</h3>
                <ul class="schedule-list">
                    <%
                        List<Map<String, String>> schedule = (List<Map<String, String>>) request.getAttribute("classSchedule");
                        for (Map<String, String> classItem : schedule) {
                    %>
                    <li>
                        <span><strong><%= classItem.get("subject") %></strong> at <%= classItem.get("time") %></span>
                        <span><%= classItem.get("room") %></span>
                    </li>
                    <%
                        }
                    %>
                </ul>
                <a href="${pageContext.request.contextPath}/fullSchedule" class="btn"><i class="fas fa-calendar"></i> Full Schedule</a>
            </div>

            <div class="card" data-aos="fade-up" id="notifications">
                <h3 style="font-size: 22px; font-weight: 600; color: #4682b4; margin-bottom: 16px; cursor: pointer;" onclick="toggleNotifications()"><i class="fas fa-bell fa-lg"></i> Notifications <i class="fas fa-chevron-down" id="notif-icon"></i></h3>
                <div class="notification-panel" id="notification-panel">
                    <ul class="notification-list">
                        <%
                            List<String> notifs = (List<String>) request.getAttribute("notifications");
                            for (String notification : notifs) {
                        %>
                        <li><i class="fas fa-info-circle"></i> <%= notification %></li>
                        <%
                            }
                        %>
                    </ul>
                </div>
                <a href="${pageContext.request.contextPath}/allNotifications" class="btn"><i class="fas fa-bell"></i> View All</a>
            </div>
        </div>
    </section>
</div>

<footer>
    <div style="max-width: 1200px; margin: 0 auto;">
        <p style="font-size: 16px;">© <%= new java.util.Date().getYear() + 1900 %> Itahari International College. All rights reserved.</p>
    </div>
</footer>

<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
<script>
    AOS.init({ duration: 1000 });

    const sidebar = document.getElementById('sidebar');
    const toggle = document.getElementById('sidebar-toggle');

    function toggleSidebar() {
        sidebar.classList.toggle('collapsed');
    }

    toggle.addEventListener('click', () => {
        sidebar.classList.toggle('active');
        sidebar.classList.toggle('collapsed');
    });

    function toggleNotifications() {
        const panel = document.getElementById('notification-panel');
        const icon = document.getElementById('notif-icon');
        panel.classList.toggle('active');
        icon.classList.toggle('fa-chevron-down');
        icon.classList.toggle('fa-chevron-up');
    }
</script>
</body>
</html>