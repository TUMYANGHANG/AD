<%--
  Created by IntelliJ IDEA.
  User: Umar
  Date: 4/16/2025
  Time: 9:40 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Registration</title>
    <script>
        function updateForm() {
            var role = document.getElementById("role").value;
            document.getElementById("studentFields").style.display = "none";
            document.getElementById("teacherFields").style.display = "none";

            if(role === "student") {
                document.getElementById("studentFields").style.display = "block";
            } else if(role === "teacher") {
                document.getElementById("teacherFields").style.display = "block";
            }
        }

        function validateForm() {
            var role = document.getElementById("role").value;
            if(role === "") {
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
<body style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f7f7f7; color: #333; min-height: 100vh; display: flex; flex-direction: column;">

<!-- Navbar -->
<div style="background-color: #007BFF; padding: 15px; text-align: center; display: flex; justify-content: center; align-items: center;">
    <div style="display: flex; align-items: center; gap: 10px;">
        <img src="your-logo.png" alt="Logo" style="width: 50px; height: 50px;">
        <span style="font-size: 1.5rem; color: white;">Student Attendance Management System</span>
    </div>
</div>

<!-- Header -->
<div style="text-align: center; padding: 50px 20px;">
    <h1 style="font-size: 3rem; color: #4CAF50; margin-bottom: 20px;">User Registration</h1>
    <p style="font-size: 1.2rem; color: #555; margin-bottom: 30px;">Fill out the form to create your account.</p>
</div>

<!-- Error Message -->
<% String error = (String) request.getAttribute("error"); %>
<% if (error != null && !error.isEmpty()) { %>
<div style="color: red; text-align: center; margin: 10px 0;"><%= error %></div>
<% } %>

<!-- Main Form -->
<div style="flex: 1; display: flex; justify-content: center; align-items: center;">
    <div style="background-color: #fff; padding: 40px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); width: 100%; max-width: 400px;">
        <form action="register" method="post" onsubmit="return validateForm()">

            <!-- Role Selection -->
            <label for="role" style="display: block; text-align: left; margin-bottom: 8px;">Role:</label>
            <select name="role" id="role" onchange="updateForm()" required style="width: 100%; padding: 12px; margin: 8px 0; border-radius: 5px; border: 1px solid #ccc;">
                <option value="">Select Role</option>
                <option value="admin">Admin</option>
                <option value="student">Student</option>
                <option value="teacher">Teacher</option>
            </select>

            <!-- Common Fields -->
            <label for="username" style="display: block; text-align: left; margin-bottom: 8px;">Username:</label>
            <input type="text" name="username" id="username" required style="width: 100%; padding: 12px; margin: 8px 0; border-radius: 5px; border: 1px solid #ccc;">

            <label for="email" style="display: block; text-align: left; margin-bottom: 8px;">Email:</label>
            <input type="email" name="email" id="email" required style="width: 100%; padding: 12px; margin: 8px 0; border-radius: 5px; border: 1px solid #ccc;">

            <label for="password" style="display: block; text-align: left; margin-bottom: 8px;">Password:</label>
            <input type="password" name="password" id="password" required style="width: 100%; padding: 12px; margin: 8px 0; border-radius: 5px; border: 1px solid #ccc;">

            <label for="confirmPassword" style="display: block; text-align: left; margin-bottom: 8px;">Confirm Password:</label>
            <input type="password" name="confirmPassword" id="confirmPassword" required style="width: 100%; padding: 12px; margin: 8px 0; border-radius: 5px; border: 1px solid #ccc;">

            <!-- Student Specific Fields -->
            <div id="studentFields" style="display: none; margin-top: 15px; border-top: 1px solid #eee; padding-top: 15px;">
                <label for="rollno" style="display: block; text-align: left; margin-bottom: 8px;">Roll Number:</label>
                <input type="text" name="rollno" id="rollno" style="width: 100%; padding: 12px; margin: 8px 0; border-radius: 5px; border: 1px solid #ccc;">

                <label for="classname" style="display: block; text-align: left; margin-bottom: 8px;">Class Name:</label>
                <input type="text" name="classname" id="classname" style="width: 100%; padding: 12px; margin: 8px 0; border-radius: 5px; border: 1px solid #ccc;">
            </div>

            <!-- Teacher Specific Fields -->
            <div id="teacherFields" style="display: none; margin-top: 15px; border-top: 1px solid #eee; padding-top: 15px;">
                <label for="employeeID" style="display: block; text-align: left; margin-bottom: 8px;">Employee ID:</label>
                <input type="text" name="employeeID" id="employeeID" style="width: 100%; padding: 12px; margin: 8px 0; border-radius: 5px; border: 1px solid #ccc;">

                <label for="department" style="display: block; text-align: left; margin-bottom: 8px;">Department:</label>
                <input type="text" name="department" id="department" style="width: 100%; padding: 12px; margin: 8px 0; border-radius: 5px; border: 1px solid #ccc;">
            </div>

            <input type="submit" value="Register" style="width: 100%; padding: 12px; margin: 20px 0 0 0; border-radius: 5px; border: none; background-color: #4CAF50; color: white; cursor: pointer; transition: background-color 0.3s;">
        </form>
    </div>
</div>

<!-- Footer -->
<div style="background-color: #007BFF; color: white; text-align: center; padding: 20px;">
    <p style="margin: 0;">&copy; 2025 Student Attendance System. All rights reserved.</p>
</div>

</body>
</html>