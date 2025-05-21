<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Error</title>
    <style>
        .error-container {
            text-align: center;
            padding: 50px;
            font-family: Arial, sans-serif;
        }
        .error-message {
            color: #dc3545;
            margin: 20px 0;
        }
        .back-button {
            display: inline-block;
            padding: 10px 20px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin-top: 20px;
        }
        .back-button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <h1>Error</h1>
        <div class="error-message">
            <% 
            String errorMessage = (String) request.getAttribute("errorMessage");
            if (errorMessage != null) {
                if (errorMessage.equals("database_error")) {
                    out.println("A database error occurred. Please try again later.");
                } else {
                    out.println(errorMessage);
                }
            } else {
                out.println("An unexpected error occurred.");
            }
            %>
        </div>
        <a href="${pageContext.request.contextPath}/login" class="back-button">Return to Login</a>
    </div>
</body>
</html> 