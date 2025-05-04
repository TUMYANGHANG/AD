<%--
  Created by IntelliJ IDEA.
  User: Umar
  Date: 4/16/2025
  Time: 9:40 PM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Register for Itahari International College's Student Attendance Management System.">
    <meta name="keywords" content="Itahari International College, user registration, attendance management">
    <meta name="author" content="Itahari International College">
    <title>User Registration - Itahari International College</title>
    <!-- Favicon -->
    <link rel="icon" type="image/png" href="favicon.png">
    <!-- AOS Animation Library -->
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
    <!-- Font Awesome for Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            line-height: 1.6;
            background-color: #f5f5f5;
            color: #4B5563;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* Navbar */
        .navbar {
            background-color: #fff;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            z-index: 50;
            transition: all 0.3s ease;
        }

        .navbar.scrolled {
            background-color: rgba(255, 255, 255, 0.95);
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }

        /* Form Container */
        .form-container {
            max-width: 500px;
            margin: 120px auto 80px;
            background-color: #fff;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
            text-align: left;
        }

        .form-container h1 {
            font-size: 36px;
            font-weight: bold;
            color: #2f4f4f;
            text-align: center;
            margin-bottom: 16px;
        }

        .form-container p {
            font-size: 18px;
            color: #4B5563;
            text-align: center;
            margin-bottom: 32px;
        }

        /* Note Styles */
        .note {
            background-color: #f0f8ff;
            border-left: 4px solid #1e90ff;
            padding: 16px;
            margin: 16px 0;
            font-size: 16px;
            color: #4B5563;
            border-radius: 4px;
        }

        .note.error {
            background-color: #ffe6e6;
            border-left-color: #ff4d4d;
            color: #b71c1c;
        }

        /* Form Fields */
        label {
            display: block;
            font-size: 16px;
            font-weight: 600;
            color: #2f4f4f;
            margin-bottom: 8px;
        }

        input[type="text"],
        input[type="email"],
        input[type="password"],
        select {
            width: 100%;
            padding: 12px;
            margin-bottom: 16px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 16px;
            transition: border-color 0.3s ease;
        }

        input:focus,
        select:focus {
            outline: none;
            border-color: #1e90ff;
            box-shadow: 0 0 5px rgba(30, 144, 255, 0.3);
        }

        /* Submit Button */
        input[type="submit"] {
            width: 100%;
            padding: 12px;
            background-color: #1e90ff;
            color: #fff;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        input[type="submit"]:hover {
            background-color: #ffd700;
            color: #1e90ff;
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        }

        /* Role-Specific Fields */
        #studentFields,
        #teacherFields {
            margin-top: 16px;
            padding-top: 16px;
            border-top: 1px solid #eee;
        }

        /* Back Link */
        .back-link {
            display: block;
            text-align: center;
            margin-top: 16px;
            color: #1e90ff;
            text-decoration: none;
            font-size: 16px;
            transition: color 0.3s ease;
        }

        .back-link:hover {
            color: #ffd700;
        }

        /* Footer */
        footer {
            background-color: #2f4f4f;
            padding: 40px 16px;
            color: #fff;
            text-align: center;
            margin-top: auto;
        }

        .footer-container {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            gap: 32px;
        }

        .footer-column {
            flex: 1;
            min-width: 200px;
        }

        .footer-column h3 {
            color: #fff;
            font-size: 18px;
            margin-bottom: 16px;
        }

        .footer-column p,
        .footer-column a {
            color: #ccc;
            font-size: 14px;
            line-height: 1.8;
            text-decoration: none;
        }

        .footer-column a:hover {
            color: #ffd700;
        }

        .social-icons {
            display: flex;
            gap: 16px;
            justify-content: center;
        }

        .social-icons a {
            color: #fff;
            font-size: 20px;
            transition: color 0.3s ease;
        }

        .social-icons a:hover {
            color: #ffd700;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .form-container {
                margin: 100px 16px 40px;
                padding: 24px;
            }

            .form-container h1 {
                font-size: 28px;
            }

            .form-container p {
                font-size: 16px;
            }

            input[type="text"],
            input[type="email"],
            input[type="password"],
            select {
                padding: 10px;
                font-size: 14px;
            }

            input[type="submit"] {
                padding: 10px;
                font-size: 14px;
            }

            .footer-container {
                flex-direction: column;
                text-align: center;
            }

            .social-icons {
                justify-content: center;
            }
        }
    </style>
    <script>
        function updateForm() {
            var role = document.getElementById("role").value;
            document.getElementById("studentFields").style.display = "none";
            document.getElementById("teacherFields").style.display = "none";

            if (role === "student") {
                document.getElementById("studentFields").style.display = "block";
            } else if (role === "teacher") {
                document.getElementById("teacherFields").style.display = "block";
            }
        }

        function validateForm() {
            var role = document.getElementById("role").value;
            if (role === "") {
                alert("Please select a role before submitting!");
                return false;
            }

            var password = document.getElementById("password").value;
            var confirmPassword = document.getElementById("confirmPassword").value;
            if (password !== confirmPassword) {
                alert("Passwords do not match!");
                return false;
            }

            return true;
        }
    </script>
</head>
<body>
<!-- Navbar -->
<nav class="navbar" data-aos="fade-down">
    <div style="max-width: 1200px; margin: 0 auto; padding: 16px; display: flex; justify-content: space-between; align-items: center;">
        <div style="font-size: 24px; font-weight: bold; color: #1e90ff;">Itahari International College</div>
        <div style="display: flex; gap: 24px;">
            <a href="index.jsp" style="color: #4B5563; text-decoration: none; font-size: 16px;">Home</a>
            <a href="#about" style="color: #4B5563; text-decoration: none; font-size: 16px;">About</a>
            <a href="#contact" style="color: #4B5563; text-decoration: none; font-size: 16px;">Contact</a>
            <a href="LoginnavServlet" style="background-color: #1e90ff; color: #fff; padding: 8px 16px; border-radius: 4px; text-decoration: none; font-size: 16px;">Login</a>
        </div>
    </div>
</nav>

<!-- Main Form -->
<div class="form-container" data-aos="fade-up" data-aos-duration="1000">
    <h1>User Registration</h1>
    <p>Create your account to access the Student Attendance Management System.</p>
    <div class="note" data-aos="fade-up" data-aos-delay="100">
        Select your role to provide additional details specific to your account type.
    </div>

    <!-- Error Message -->
    <% String error = (String) request.getAttribute("error"); %>
    <% if (error != null && !error.isEmpty()) { %>
    <div class="note error" data-aos="fade-up" data-aos-delay="150"><%= error %></div>
    <% } %>

    <!-- Registration Form -->
    <form action="${pageContext.request.contextPath}/register" method="post" onsubmit="return validateForm()">
        <!-- Role Selection -->
        <label for="role">Role:</label>
        <select name="role" id="role" onchange="updateForm()" required aria-label="Select your role">
            <option value="">Select Role</option>
            <option value="admin">Admin</option>
            <option value="student">Student</option>
            <option value="teacher">Teacher</option>
        </select>

        <!-- Common Fields -->
        <label for="username">Username:</label>
        <input type="text" name="username" id="username" required placeholder="Enter your username" aria-label="Username">

        <label for="email">Email:</label>
        <input type="email" name="email" id="email" required placeholder="Enter your email" aria-label="Email">

        <label for="password">Password:</label>
        <input type="password" name="password" id="password" required placeholder="Enter your password" aria-label="Password">

        <label for="confirmPassword">Confirm Password:</label>
        <input type="password" name="confirmPassword" id="confirmPassword" required placeholder="Confirm your password" aria-label="Confirm Password">

        <!-- Student Specific Fields -->
        <div id="studentFields" style="display: none;">
            <label for="rollno">Roll Number:</label>
            <input type="text" name="rollno" id="rollno" placeholder="Enter your roll number" aria-label="Roll Number">

            <label for="classname">Class Name:</label>
            <input type="text" name="classname" id="classname" placeholder="Enter your class name" aria-label="Class Name">
        </div>

        <!-- Teacher Specific Fields -->
        <div id="teacherFields" style="display: none;">
            <label for="employeeID">Employee ID:</label>
            <input type="text" name="employeeID" id="employeeID" placeholder="Enter your employee ID" aria-label="Employee ID">

            <label for="department">Department:</label>
            <input type="text" name="department" id="department" placeholder="Enter your department" aria-label="Department">
        </div>

        <input type="submit" value="Register">
        <a href="index.jsp" class="back-link">Back to Home</a>
    </form>
</div>

<!-- Footer -->
<footer data-aos="fade-up">
    <div class="footer-container">
        <div class="footer-column">
            <h3>About Us</h3>
            <p>Itahari International College is committed to academic excellence and fostering a vibrant student community.</p>
        </div>
        <div class="footer-column">
            <h3>Contact Info</h3>
            <p>Email: <a href="mailto:info@itahariinternationalcollege.edu">info@itahariinternationalcollege.edu</a></p>
            <p>Phone: +977-123-456-7890</p>
            <p>Address: Itahari, Sunsari, Nepal</p>
        </div>
        <div class="footer-column">
            <h3>Follow Us</h3>
            <div class="social-icons">
                <a href="https://facebook.com" aria-label="Facebook"><i class="fab fa-facebook-f"></i></a>
                <a href="https://twitter.com" aria-label="Twitter"><i class="fab fa-twitter"></i></a>
                <a href="https://instagram.com" aria-label="Instagram"><i class="fab fa-instagram"></i></a>
                <a href="https://linkedin.com" aria-label="LinkedIn"><i class="fab fa-linkedin-in"></i></a>
            </div>
        </div>
    </div>
    <p>© <%= new java.util.Date().getYear() + 1900 %> Itahari International College. All rights reserved.</p>
</footer>

<!-- AOS Animation Script -->
<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
<script>
    AOS.init();
</script>

<!-- Navbar Scroll Effect -->
<script>
    window.addEventListener('scroll', () => {
        const navbar = document.querySelector('.navbar');
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    });
</script>
</body>
</html>