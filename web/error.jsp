<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Error</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
</head>
<body>
    <div class="container mt-5">
        <div class="row">
            <div class="col-md-8 offset-md-2">
                <div class="card">
                    <div class="card-header bg-danger text-white">
                        <h4><i class="bi bi-exclamation-triangle-fill"></i> Error Occurred</h4>
                    </div>
                    <div class="card-body">
                        <h5 class="card-title">Something went wrong</h5>
                        <p class="card-text">
                            We apologize for the inconvenience. An error has occurred while processing your request.
                        </p>
                        
                        <% if (exception != null) { %>
                        <div class="alert alert-danger">
                            <p><strong>Error Details:</strong> <%= exception.getMessage() %></p>
                        </div>
                        <% } %>
                        
                        <a href="index.jsp" class="btn btn-primary">
                            <i class="bi bi-house-fill"></i> Return to Home
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>