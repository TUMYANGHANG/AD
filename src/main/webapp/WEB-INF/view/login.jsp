<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.text.SimpleDateFormat, java.util.Date" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // File handling for error logging
    String logFilePath = application.getRealPath("/WEB-INF/logs/error.log");
    File logDir = new File(application.getRealPath("/WEB-INF/logs"));
    if (!logDir.exists()) {
        logDir.mkdirs(); // Create logs directory if it doesn't exist
    }

    // Helper method to log errors
    class ErrorLogger {
        public static void logError(String logFilePath, String message, Exception e) {
            try (FileWriter fw = new FileWriter(logFilePath, true);
                 BufferedWriter bw = new BufferedWriter(fw)) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                String timestamp = sdf.format(new Date());
                bw.write("[" + timestamp + "] " + message);
                bw.newLine();
                if (e != null) {
                    StringWriter sw = new StringWriter();
                    PrintWriter pw = new PrintWriter(sw);
                    e.printStackTrace(pw);
                    bw.write(sw.toString());
                    bw.newLine();
                }
                bw.write("----------------------------------------");
                bw.newLine();
            } catch (IOException ioException) {
                System.err.println("Failed to write to error log: " + ioException.getMessage());
            }
        }
    }

    // Initialize message variables
    String successMessage = null;
    String errorMessage = null;

    try {
        // Retrieve success or error attributes
        if (request.getAttribute("success") != null) {
            successMessage = (String) request.getAttribute("success");
        }
        if (request.getAttribute("error") != null) {
            String rawError = (String) request.getAttribute("error");
            // Provide user-friendly error messages
            if (rawError.contains("invalid") || rawError.contains("credential")) {
                errorMessage = "Invalid username, password, or role. Please try again.";
            } else if (rawError.contains("database")) {
                errorMessage = "Unable to connect to the server. Please try again later.";
            } else {
                errorMessage = "An unexpected error occurred. Please contact support.";
            }
            // Log the raw error for debugging
            ErrorLogger.logError(logFilePath, "Login Error: " + rawError, null);
        }
    } catch (Exception e) {
        errorMessage = "An unexpected error occurred. Please try again.";
        ErrorLogger.logError(logFilePath, "Unexpected error in login.jsp", e);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Login to Itahari International College's Student Attendance Management System">
    <meta name="keywords" content="Itahari International College, attendance management, login">
    <meta name="author" content="Itahari International College">
    <title>Login - Student Attendance Management System</title>
    <!-- Favicon -->
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/favicon.png">
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
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .navbar {
            transition: all 0.3s ease;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            z-index: 50;
            background-color: #fff;
        }

        .navbar.scrolled {
            background-color: rgba(255, 255, 255, 0.95);
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }

        .note {
            background-color: #f0f8ff;
            border-left: 4px solid #1e90ff;
            padding: 16px;
            margin: 16px 0;
            font-size: 16px;
            color: #4B5563;
            border-radius: 4px;
            text-align: center;
        }

        .note.success {
            background-color: #e0f7fa;
            border-left: 4px solid #2ecc71;
            color: #00695c;
        }

        .note.error {
            background-color: #ffebee;
            border-left: 4px solid #e74c3c;
            color: #c0392b;
        }

        .login-card {
            background-color: #fff;
            border-radius: 12px;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
            padding: 2.5rem;
            width: 100%;
            max-width: 450px;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .login-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.15);
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
            color: #2f4f4f;
        }

        .form-control {
            width: 100%;
            padding: 0.8rem 1rem;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }

        .form-control:focus {
            outline: none;
            border-color: #1e90ff;
            box-shadow: 0 0 5px rgba(30, 144, 255, 0.3);
        }

        .btn {
            display: inline-block;
            background-color: #1e90ff;
            color: #fff;
            padding: 0.8rem 1.5rem;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.3s ease, transform 0.3s ease;
            width: 100%;
        }

        .btn:hover {
            background-color: #ffd700;
            color: #1e90ff;
            transform: scale(1.05);
        }

        .register-link {
            text-align: center;
            margin-top: 1.5rem;
            color: #4B5563;
        }

        .register-link a {
            color: #1e90ff;
            text-decoration: none;
            font-weight: 500;
        }

        .register-link a:hover {
            color: #ffd700;
        }

        footer {
            background-color: #2f4f4f;
            padding: 40px 16px;
            color: #fff;
            text-align: center;
            margin-top: auto;
        }

        @media (max-width: 768px) {
            .login-card {
                padding: 1.5rem;
                max-width: 90%;
            }

            .navbar-container {
                flex-direction: column;
                align-items: flex-start;
            }

            .navbar-links {
                margin-top: 1rem;
                flex-direction: column;
                gap: 12px;
            }
        }

        /* Popup notification styles */
        .popup {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 25px;
            border-radius: 5px;
            color: white;
            font-weight: 500;
            display: none;
            z-index: 1000;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
            animation: slideIn 0.5s ease-out;
        }

        .popup.success {
            background-color: #4CAF50;
        }

        .popup.error {
            background-color: #f44336;
        }

        .popup i {
            margin-right: 10px;
        }

        @keyframes slideIn {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }

        @keyframes slideOut {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(100%);
                opacity: 0;
            }
        }

        .popup.hide {
            animation: slideOut 0.5s ease-out forwards;
        }
    </style>
</head>
<body>
<!-- Navbar -->
<nav class="navbar" data-aos="fade-down">
    <div class="navbar-container" style="max-width: 1200px; margin: 0 auto; padding: 16px; display: flex; justify-content: space-between; align-items: center;">
        <div style="font-size: 24px; font-weight: bold; color: #1e90ff;">Itahari International College</div>
        <div class="navbar-links" style="display: flex; gap: 24px;">
            <a href="${pageContext.request.contextPath}/#home" style="color: #4B5563; text-decoration: none; font-size: 16px;">Home</a>
            <a href="${pageContext.request.contextPath}/#about" style="color: #4B5563; text-decoration: none; font-size: 16px;">About</a>
            <a href="${pageContext.request.contextPath}/#features" style="color: #4B5563; text-decoration: none; font-size: 16px;">Features</a>
            <a href="${pageContext.request.contextPath}/#contact" style="color: #4B5563; text-decoration: none; font-size: 16px;">Contact</a>
            <%
                String username = (String) session.getAttribute("username");
                if (username != null) {
            %>
            <a href="${pageContext.request.contextPath}/logout" style="background-color: #1e90ff; color: #fff; padding: 8px 16px; border-radius: 4px; text-decoration: none; font-size: 16px;">Logout</a>
            <%
            } else {
            %>
            <a href="${pageContext.request.contextPath}/login" style="background-color: #1e90ff; color: #fff; padding: 8px 16px; border-radius: 4px; text-decoration: none; font-size: 16px;">Login</a>
            <a href="${pageContext.request.contextPath}/register" style="background-color: #1e90ff; color: #fff; padding: 8px 16px; border-radius: 4px; text-decoration: none; font-size: 16px;">Register</a>
            <%
                }
            %>
        </div>
    </div>
</nav>

<!-- Popup notification -->
<div id="popup" class="popup">
    <i class="fas"></i>
    <span id="popup-message"></span>
</div>

<!-- Main Content -->
<main class="main-container" style="flex: 1; display: flex; justify-content: center; align-items: center; padding: 2rem;">
    <div class="container">
        <div class="login-card">
            <h2>Login</h2>
            <% if (successMessage != null) { %>
                <div class="note success"><%= successMessage %></div>
            <% } %>
            <% if (errorMessage != null) { %>
                <div class="note error"><%= errorMessage %></div>
            <% } %>
            <form action="${pageContext.request.contextPath}/Nav_login" method="post">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" class="form-control" required>
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" class="form-control" required>
                </div>
                <button type="submit" class="btn">Login</button>
            </form>
            <div class="register-link">
                Don't have an account? <a href="${pageContext.request.contextPath}/Nav_register">Register here</a>
            </div>
        </div>
    </div>
</main>

<!-- Footer -->
<footer>
    <div style="max-width: 1200px; margin: 0 auto;">
        <p style="font-size: 16px;">© <%= new java.util.Date().getYear() + 1900 %> Itahari International College. All rights reserved.</p>
    </div>
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

<!-- Password Toggle -->
<script>
    function togglePassword(id) {
        var input = document.getElementById(id);
        var icon = input.nextElementSibling;
        if (input.type === "password") {
            input.type = "text";
            icon.classList.replace("fa-eye", "fa-eye-slash");
        } else {
            input.type = "password";
            icon.classList.replace("fa-eye-slash", "fa-eye");
        }
    }
</script>

<!-- Loading State -->
<script>
    document.querySelector("form").addEventListener("submit", function() {
        var button = document.getElementById("submitButton");
        button.innerText = "Logging in...";
        button.disabled = true;
    });
</script>

<!-- Add this before the closing body tag -->
<script>
    function showPopup(message, type) {
        const popup = document.getElementById('popup');
        const popupMessage = document.getElementById('popup-message');
        const icon = popup.querySelector('i');

        // Set message and type
        popupMessage.textContent = message;
        popup.className = 'popup ' + type;
        
        // Set icon based on type
        if (type === 'success') {
            icon.className = 'fas fa-check-circle';
        } else {
            icon.className = 'fas fa-exclamation-circle';
        }

        // Show popup
        popup.style.display = 'block';

        // Hide popup after 5 seconds
        setTimeout(() => {
            popup.classList.add('hide');
            setTimeout(() => {
                popup.style.display = 'none';
                popup.classList.remove('hide');
            }, 500);
        }, 5000);
    }

    // Check for messages on page load
    window.onload = function() {
        <c:if test="${not empty success}">
            showPopup('${success}', 'success');
        </c:if>
        <c:if test="${not empty error}">
            showPopup('${error}', 'error');
        </c:if>
    };
</script>

<!-- Hidden fields for messages -->
<input type="hidden" id="success-message" value="${requestScope.success}">
<input type="hidden" id="error-message" value="${requestScope.error}">
</body>
</html>