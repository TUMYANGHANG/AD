<%-- 
    Document   : studentEditProfile
    Created on : Oct 26, 2023, 10:41:00 PM
    Author     : Bhair
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Edit Student Profile</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .profile-img {
            width: 150px;
            height: 150px;
            object-fit: cover;
            border-radius: 50%;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container mt-5">
        <h1 class="mb-4">Edit Student Profile</h1>

        <c:if test="${not empty error}">
            <div class="alert alert-danger" role="alert">
                ${error}
            </div>
        </c:if>
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success" role="alert">
                ${successMessage}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/student-edit-profile" method="post" enctype="multipart/form-data">
            <div class="mb-3 text-center">
                 <img src="${pageContext.request.contextPath}/Images/${student.photoPath != null ? student.photoPath : 'default-profile.png'}" alt="Profile Image" class="profile-img">
            </div>
             <div class="mb-3">
                <label for="username" class="form-label">Username:</label>
                <input type="text" class="form-control" id="username" name="username" value="${student.username}" required>
            </div>
            <div class="mb-3">
                <label for="email" class="form-label">Email:</label>
                <input type="email" class="form-control" id="email" name="email" value="${student.email}" required>
            </div>
            <div class="mb-3">
                <label for="className" class="form-label">Class Name:</label>
                <input type="text" class="form-control" id="className" name="className" value="${student.className}" required>
            </div>
             <div class="mb-3">
                <label for="rollNumber" class="form-label">Roll Number:</label>
                <input type="text" class="form-control" id="rollNumber" name="rollNumber" value="${student.rollNumber}" readonly>
            </div>
            <div class="mb-3">
                <label for="photo" class="form-label">Upload Photo:</label>
                <input type="file" class="form-control" id="photo" name="photo" accept="image/*">
            </div>
            <button type="submit" class="btn btn-primary">Save Changes</button>
             <a href="${pageContext.request.contextPath}/student-dashboard" class="btn btn-secondary">Cancel</a>
        </form>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 