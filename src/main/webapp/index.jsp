<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Student Attendance Management System</title>
</head>
<body style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f7f7f7; color: #333;">

<!-- Navbar -->
<div style="background-color: #007BFF; padding: 15px; text-align: center; display: flex; justify-content: center; align-items: center;">
  <div style="display: flex; align-items: center; gap: 10px;">
    <img src="your-logo.png" alt="Logo" style="width: 50px; height: 50px; vertical-align: middle;">
    <span style="font-size: 1.5rem; color: white;">Student Attendance Management System</span>
  </div>
<%--  <a href="home.jsp" style="color: white; text-decoration: none; padding: 12px 20px; font-size: 1.1rem; margin: 0 15px; transition: background-color 0.3s;">Home</a>--%>
<%--  <a href="register.jsp" style="color: white; text-decoration: none; padding: 12px 20px; font-size: 1.1rem; margin: 0 15px; transition: background-color 0.3s;">Register</a>--%>
<%--  <a href="login.jsp" style="color: white; text-decoration: none; padding: 12px 20px; font-size: 1.1rem; margin: 0 15px; transition: background-color 0.3s;">Login</a>--%>
<%--  <a href="about.jsp" style="color: white; text-decoration: none; padding: 12px 20px; font-size: 1.1rem; margin: 0 15px; transition: background-color 0.3s;">About</a>--%>
</div>

<!-- Header -->
<div style="text-align: center; padding: 50px 20px;">
  <h1 style="font-size: 3rem; color: #4CAF50; margin-bottom: 20px;">Welcome to the Student Attendance System</h1>
  <p style="font-size: 1.2rem; color: #555; margin-bottom: 30px;">Manage student attendance with ease. Register or log in to get started.</p>
</div>

<!-- Main Content -->
<div style="display: flex; justify-content: center; align-items: center; height: 70vh;">
  <div style="background-color: #fff; padding: 40px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); text-align: center;">
    <a href="Registryform" style="text-decoration: none; background-color: #4CAF50; color: white; padding: 12px 25px; border-radius: 5px; font-size: 1rem; margin: 10px; display: inline-block; transition: background-color 0.3s;">Register</a>
    <a href="Loginform" style="text-decoration: none; background-color: #007BFF; color: white; padding: 12px 25px; border-radius: 5px; font-size: 1rem; margin: 10px; display: inline-block; transition: background-color 0.3s;">Login</a>
  </div>
</div>

<!-- Footer -->
<div style="background-color: #007BFF; color: white; text-align: center; padding: 20px; position: absolute; bottom: 0; width: 100%;">
  <p style="margin: 0; font-size: 1rem;">&copy; 2025 Student Attendance System. All rights reserved.</p>
</div>

</body>
</html>
