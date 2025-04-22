<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Student Attendance System</title>
</head>
<body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f7fa; color: #2c3e50; line-height: 1.6; min-height: 100vh; display: flex; flex-direction: column; margin: 0; padding: 0;">
<!-- Navbar -->
<nav class="navbar" style="background-color: #4169E1; color: white; padding: 1rem 2rem; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
    <div class="navbar-container" style="display: flex; justify-content: space-between; align-items: center; max-width: 1200px; margin: 0 auto;">
        <div class="logo" style="display: flex; align-items: center; gap: 1rem;">
            <img src="${pageContext.request.contextPath}/assets/logo.png" alt="Logo" style="width: 40px; height: 40px;">
            <span class="logo-text" style="font-size: 1.5rem; font-weight: 600;">Student Attendance System</span>
        </div>
    </div>
</nav>

<!-- Main Content -->
<main class="main-container" style="flex: 1; display: flex; justify-content: center; align-items: center; padding: 2rem;">
    <div class="login-card" style="background-color: white; border-radius: 8px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); padding: 2.5rem; width: 100%; max-width: 450px; transition: all 0.3s ease;">
        <div class="login-header" style="text-align: center; margin-bottom: 2rem;">
            <h2 style="color: #4169E1; margin-bottom: 0.5rem;">Welcome Back</h2>
            <p style="color: #7f8c8d;">Please login to access your account</p>
        </div>

        <!-- Success Message -->
        <% if (request.getAttribute("success") != null) { %>
        <div class="alert alert-success" style="padding: 1rem; border-radius: 8px; margin-bottom: 1.5rem; text-align: center; background-color: rgba(46, 204, 113, 0.2); color: #2ecc71; border: 1px solid #2ecc71;">
            <%= request.getAttribute("success") %>
        </div>
        <% } %>

        <!-- Error Message -->
        <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-error" style="padding: 1rem; border-radius: 8px; margin-bottom: 1.5rem; text-align: center; background-color: rgba(231, 76, 60, 0.2); color: #e74c3c; border: 1px solid #e74c3c;">
            <%= request.getAttribute("error") %>
        </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/login" method="post">
            <div class="form-group" style="margin-bottom: 1.5rem;">
                <label for="username" style="display: block; margin-bottom: 0.5rem; font-weight: 500; color: #2c3e50;">Username</label>
                <input type="text" id="username" name="username" class="form-control" style="width: 100%; padding: 0.8rem 1rem; border: 1px solid #ddd; border-radius: 8px; font-size: 1rem; transition: all 0.3s ease;" required>
            </div>

            <div class="form-group" style="margin-bottom: 1.5rem;">
                <label for="password" style="display: block; margin-bottom: 0.5rem; font-weight: 500; color: #2c3e50;">Password</label>
                <input type="password" id="password" name="password" class="form-control" style="width: 100%; padding: 0.8rem 1rem; border: 1px solid #ddd; border-radius: 8px; font-size: 1rem; transition: all 0.3s ease;" required>
            </div>

            <div class="form-group" style="margin-bottom: 1.5rem;">
                <label for="role" style="display: block; margin-bottom: 0.5rem; font-weight: 500; color: #2c3e50;">Role</label>
                <select id="role" name="role" class="form-control" style="width: 100%; padding: 0.8rem 1rem; border: 1px solid #ddd; border-radius: 8px; font-size: 1rem; transition: all 0.3s ease;" required>
                    <option value="">Select your role</option>
                    <option value="student">Student</option>
                    <option value="teacher">Teacher</option>
                    <option value="admin">Admin</option>
                </select>
            </div>

            <button type="submit" class="btn" style="display: inline-block; background-color: #4169E1; color: white; padding: 0.8rem 1.5rem; border: none; border-radius: 8px; font-size: 1rem; font-weight: 500; cursor: pointer; transition: all 0.3s ease; width: 100%;">Login</button>

            <div class="register-link" style="text-align: center; margin-top: 1.5rem; color: #7f8c8d;">
                Don't have an account? <a href="${pageContext.request.contextPath}/register" style="color: #4169E1; text-decoration: none; font-weight: 500;">Register here</a>
            </div>
        </form>
    </div>
</main>

<!-- Footer -->
<footer class="footer" style="background-color: #2c3e50; color: white; text-align: center; padding: 1.5rem; margin-top: auto;">
    <p>&copy; 2023 Student Attendance System. All rights reserved.</p>
</footer>
</body>
</html>