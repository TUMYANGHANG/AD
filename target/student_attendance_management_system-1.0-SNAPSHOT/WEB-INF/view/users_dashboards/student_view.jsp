<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, model.Student, model.User, java.util.Set, java.util.HashSet" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"teacher".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
        return;
    }
    List<Student> students = (List<Student>) request.getAttribute("students");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student List - Itahari International College</title>
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
        }

        .navbar {
            background: linear-gradient(90deg, #1a202c, #2d3748);
            padding: 12px 20px;
            display: flex;
            justify-content: space-between;
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

        .back-btn {
            background: #48bb78;
            color: #fff;
            padding: 8px 16px;
            border-radius: 20px;
            text-decoration: none;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 6px;
            transition: background 0.3s;
        }

        .back-btn:hover {
            background: #38a169;
        }

        .main-content {
            margin-top: 80px;
            padding: 25px;
            max-width: 1200px;
            margin-left: auto;
            margin-right: auto;
        }

        .page-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .page-header h1 {
            font-size: 32px;
            color: #1a202c;
            margin-bottom: 10px;
        }

        .page-header p {
            color: #718096;
        }

        .search-filter-container {
            display: flex;
            gap: 20px;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }

        .search-box {
            flex: 1;
            min-width: 300px;
        }

        .search-box input {
            width: 100%;
            padding: 12px 20px;
            border: 1px solid #e2e8f0;
            border-radius: 25px;
            font-size: 14px;
            outline: none;
            transition: all 0.3s;
        }

        .search-box input:focus {
            border-color: #48bb78;
            box-shadow: 0 0 0 3px rgba(72, 187, 120, 0.1);
        }

        .filter-box {
            min-width: 200px;
        }

        .filter-box select {
            width: 100%;
            padding: 12px 20px;
            border: 1px solid #e2e8f0;
            border-radius: 25px;
            font-size: 14px;
            outline: none;
            background: #fff;
            cursor: pointer;
            transition: all 0.3s;
        }

        .filter-box select:focus {
            border-color: #48bb78;
            box-shadow: 0 0 0 3px rgba(72, 187, 120, 0.1);
        }

        .student-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .student-card {
            background: #fff;
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s, box-shadow 0.3s;
        }

        .student-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 12px rgba(0, 0, 0, 0.15);
        }

        .student-header {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 15px;
        }

        .student-photo {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: #edf2f7;
            display: flex;
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
            font-size: 12px;
            color: #718096;
            text-align: center;
        }

        .student-info h3 {
            font-size: 18px;
            color: #1a202c;
            margin-bottom: 5px;
        }

        .student-info p {
            font-size: 14px;
            color: #718096;
        }

        .student-details {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #e2e8f0;
        }

        .detail-item {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 14px;
        }

        .detail-label {
            color: #718096;
        }

        .detail-value {
            color: #1a202c;
            font-weight: 500;
        }

        .student-actions {
            margin-top: 15px;
            display: flex;
            gap: 10px;
        }

        .action-btn {
            flex: 1;
            padding: 8px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            transition: all 0.3s;
        }

        .view-btn {
            background: #48bb78;
            color: #fff;
        }

        .view-btn:hover {
            background: #38a169;
        }

        .delete-btn {
            background: #f56565;
            color: #fff;
        }

        .delete-btn:hover {
            background: #c53030;
        }

        .no-students {
            text-align: center;
            padding: 40px;
            color: #718096;
            font-style: italic;
            grid-column: 1 / -1;
        }

        @media (max-width: 768px) {
            .main-content {
                padding: 15px;
            }

            .page-header h1 {
                font-size: 24px;
            }

            .search-filter-container {
                flex-direction: column;
            }

            .search-box, .filter-box {
                width: 100%;
            }

            .student-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="navbar-brand">Itahari International College</div>
        <a href="${pageContext.request.contextPath}/teacher-dashboard" class="back-btn">
            <i class="fas fa-arrow-left"></i> Back to Dashboard
        </a>
    </nav>

    <div class="main-content">
        <div class="page-header" data-aos="fade-up">
            <h1>Student Management</h1>
            <p>View and manage all registered students</p>
        </div>

        <div class="search-filter-container" data-aos="fade-up" data-aos-delay="100">
            <div class="search-box">
                <input type="text" id="searchInput" placeholder="Search students by name, roll number, or email..." onkeyup="searchStudents()">
            </div>
            <div class="filter-box">
                <select id="classFilter" onchange="filterStudents()">
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
        </div>

        <div class="student-grid" data-aos="fade-up" data-aos-delay="200">
            <% if (students.isEmpty()) { %>
                <div class="no-students">No students found</div>
            <% } else {
                for (Student student : students) { %>
                <div class="student-card">
                    <div class="student-header">
                        <div class="student-photo">
                            <% if (student.getPhotoPath() != null && !student.getPhotoPath().isEmpty()) { %>
                                <img src="${pageContext.request.contextPath}/Images/<%= student.getPhotoPath() %>" 
                                     alt="Student Photo"
                                     onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                                <div class="student-photo-placeholder" style="display: none;">No Photo</div>
                            <% } else { %>
                                <div class="student-photo-placeholder">No Photo</div>
                            <% } %>
                        </div>
                        <div class="student-info">
                            <h3><%= student.getUsername() %></h3>
                            <p><%= student.getRollNumber() != null ? student.getRollNumber() : "No Roll Number" %></p>
                        </div>
                    </div>
                    <div class="student-details">
                        <div class="detail-item">
                            <span class="detail-label">Class:</span>
                            <span class="detail-value"><%= student.getClassName() != null ? student.getClassName() : "Not Assigned" %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Email:</span>
                            <span class="detail-value"><%= student.getEmail() != null ? student.getEmail() : "Not Available" %></span>
                        </div>
                    </div>
                    <div class="student-actions">
                        <button class="action-btn view-btn" onclick="viewStudentDetails('<%= student.getId() %>')">
                            <i class="fas fa-eye"></i> View Details
                        </button>
                        <form action="${pageContext.request.contextPath}/DeleteStudentServlet" method="post" 
                              onsubmit="return confirmDeletion(this, '<%= student.getUsername() %>')" style="flex: 1;">
                            <input type="hidden" name="studentId" value="<%= student.getId() %>">
                            <button type="submit" class="action-btn delete-btn">
                                <i class="fas fa-trash"></i> Delete
                            </button>
                        </form>
                    </div>
                </div>
            <% }} %>
        </div>
    </div>

    <script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
    <script>
        // Initialize AOS animations
        AOS.init({ duration: 800 });

        // Search and filter functions
        function searchStudents() {
            const searchInput = document.getElementById('searchInput').value.toLowerCase();
            const classFilter = document.getElementById('classFilter').value;
            const cards = document.querySelectorAll('.student-card');

            cards.forEach(card => {
                const name = card.querySelector('h3').textContent.toLowerCase();
                const rollNo = card.querySelector('.student-info p').textContent.toLowerCase();
                const email = card.querySelector('.detail-value:last-child').textContent.toLowerCase();
                const className = card.querySelector('.detail-value:first-child').textContent;

                const matchesSearch = name.includes(searchInput) || 
                                    rollNo.includes(searchInput) || 
                                    email.includes(searchInput);
                const matchesClass = !classFilter || className === classFilter;

                card.style.display = matchesSearch && matchesClass ? '' : 'none';
            });
        }

        function filterStudents() {
            searchStudents();
        }

        // View student details
        function viewStudentDetails(studentId) {
            // Implement view details functionality
            alert('View details functionality will be implemented here');
        }

        // Delete confirmation
        function confirmDeletion(form, studentName) {
            if (confirm('Are you sure you want to delete ' + studentName + '? This action cannot be undone.')) {
                document.body.classList.add('deleting');
                return true;
            }
            return false;
        }
    </script>
</body>
</html> 