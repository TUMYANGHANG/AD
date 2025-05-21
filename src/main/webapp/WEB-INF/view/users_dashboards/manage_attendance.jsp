<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, model.Student, model.User, java.util.Set, java.util.HashSet, java.text.SimpleDateFormat, java.util.Date" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"teacher".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login?error=unauthenticated");
        return;
    }
    List<Student> students = (List<Student>) request.getAttribute("students");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String currentDate = sdf.format(new Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Attendance - Itahari International College</title>
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

        .attendance-controls {
            background: #fff;
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            align-items: center;
        }

        .date-picker {
            flex: 1;
            min-width: 200px;
        }

        .date-picker input {
            width: 100%;
            padding: 12px 20px;
            border: 1px solid #e2e8f0;
            border-radius: 25px;
            font-size: 14px;
            outline: none;
            transition: all 0.3s;
        }

        .date-picker input:focus {
            border-color: #48bb78;
            box-shadow: 0 0 0 3px rgba(72, 187, 120, 0.1);
        }

        .class-filter {
            flex: 1;
            min-width: 200px;
        }

        .class-filter select {
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

        .class-filter select:focus {
            border-color: #48bb78;
            box-shadow: 0 0 0 3px rgba(72, 187, 120, 0.1);
        }

        .submit-btn {
            background: #48bb78;
            color: #fff;
            padding: 12px 24px;
            border: none;
            border-radius: 25px;
            font-size: 14px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s;
        }

        .submit-btn:hover {
            background: #38a169;
            transform: translateY(-2px);
        }

        .attendance-table {
            width: 100%;
            background: #fff;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        .attendance-table th,
        .attendance-table td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
        }

        .attendance-table th {
            background: #48bb78;
            color: #fff;
            font-weight: 500;
        }

        .attendance-table tr:hover {
            background: #f7fafc;
        }

        .student-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .student-photo {
            width: 40px;
            height: 40px;
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
            font-size: 10px;
            color: #718096;
            text-align: center;
        }

        .attendance-radio {
            display: flex;
            gap: 20px;
        }

        .radio-group {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .radio-group input[type="radio"] {
            width: 18px;
            height: 18px;
            cursor: pointer;
        }

        .radio-group label {
            cursor: pointer;
            user-select: none;
        }

        .success-message {
            background: linear-gradient(90deg, #c6f6d5, #f7fafc);
            border-left: 5px solid #48bb78;
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .error-message {
            background: linear-gradient(90deg, #fed7d7, #f7fafc);
            border-left: 5px solid #f56565;
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .close-btn {
            background: none;
            border: none;
            color: inherit;
            font-size: 18px;
            cursor: pointer;
            padding: 0;
        }

        @media (max-width: 768px) {
            .main-content {
                padding: 15px;
            }

            .page-header h1 {
                font-size: 24px;
            }

            .attendance-controls {
                flex-direction: column;
            }

            .date-picker,
            .class-filter {
                width: 100%;
            }

            .submit-btn {
                width: 100%;
                justify-content: center;
            }

            .attendance-table {
                font-size: 14px;
            }

            .attendance-table th,
            .attendance-table td {
                padding: 10px;
            }

            .attendance-radio {
                flex-direction: column;
                gap: 10px;
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
            <h1>Manage Attendance</h1>
            <p>Mark student attendance for your class</p>
        </div>

        <% if (session.getAttribute("successMessage") != null) { %>
        <div class="success-message" data-aos="fade-up">
            <span><%= session.getAttribute("successMessage") %></span>
            <button class="close-btn" onclick="this.parentElement.remove()">&times;</button>
            <% session.removeAttribute("successMessage"); %>
        </div>
        <% } %>

        <% if (session.getAttribute("errorMessage") != null) { %>
        <div class="error-message" data-aos="fade-up">
            <span><%= session.getAttribute("errorMessage") %></span>
            <button class="close-btn" onclick="this.parentElement.remove()">&times;</button>
            <% session.removeAttribute("errorMessage"); %>
        </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/SaveAttendanceServlet" method="post" id="attendanceForm">
            <div class="attendance-controls" data-aos="fade-up" data-aos-delay="100">
                <div class="date-picker">
                    <input type="date" name="attendanceDate" id="attendanceDate" value="<%= currentDate %>" required>
                </div>
                <div class="class-filter">
                    <select name="className" id="className" onchange="filterStudents()" required>
                        <option value="">Select Class</option>
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
                <button type="submit" class="submit-btn">
                    <i class="fas fa-save"></i> Save Attendance
                </button>
            </div>

            <div class="attendance-table" data-aos="fade-up" data-aos-delay="200">
                <table>
                    <thead>
                        <tr>
                            <th>Student</th>
                            <th>Roll No</th>
                            <th>Class</th>
                            <th>Attendance</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (students.isEmpty()) { %>
                            <tr>
                                <td colspan="4" style="text-align: center; padding: 20px;">No students found</td>
                            </tr>
                        <% } else {
                            for (Student student : students) { %>
                            <tr class="student-row" data-class="<%= student.getClassName() != null ? student.getClassName() : "" %>">
                                <td>
                                    <div class="student-info">
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
                                        <div>
                                            <div><%= student.getUsername() %></div>
                                            <div style="font-size: 12px; color: #718096;"><%= student.getEmail() != null ? student.getEmail() : "No Email" %></div>
                                        </div>
                                    </div>
                                </td>
                                <td><%= student.getRollNumber() != null ? student.getRollNumber() : "N/A" %></td>
                                <td><%= student.getClassName() != null ? student.getClassName() : "Not Assigned" %></td>
                                <td>
                                    <div class="attendance-radio">
                                        <div class="radio-group">
                                            <input type="radio" 
                                                   name="attendance_<%= student.getId() %>" 
                                                   id="present_<%= student.getId() %>" 
                                                   value="present" 
                                                   required>
                                            <label for="present_<%= student.getId() %>">Present</label>
                                        </div>
                                        <div class="radio-group">
                                            <input type="radio" 
                                                   name="attendance_<%= student.getId() %>" 
                                                   id="absent_<%= student.getId() %>" 
                                                   value="absent">
                                            <label for="absent_<%= student.getId() %>">Absent</label>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        <% }} %>
                    </tbody>
                </table>
            </div>
        </form>
    </div>

    <script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
    <script>
        // Initialize AOS animations
        AOS.init({ duration: 800 });

        // Filter students by class
        function filterStudents() {
            const selectedClass = document.getElementById('className').value;
            const rows = document.querySelectorAll('.student-row');
            
            rows.forEach(row => {
                const studentClass = row.getAttribute('data-class');
                row.style.display = !selectedClass || studentClass === selectedClass ? '' : 'none';
            });
        }

        // Form submission handling
        document.getElementById('attendanceForm').addEventListener('submit', function(e) {
            const selectedClass = document.getElementById('className').value;
            if (!selectedClass) {
                e.preventDefault();
                alert('Please select a class first');
                return;
            }
        });
    </script>
</body>
</html> 