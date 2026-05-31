<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="DBConnection.jsp" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Task</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
</head>
<body>
<%
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

    String message = "";
    String alertClass = "";
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String newSubject = request.getParameter("subject");
        String newDescription = request.getParameter("description");
        String newStatus = request.getParameter("status");
        String newStartDate = request.getParameter("startDate");
        String newDueDate = request.getParameter("dueDate");

        if (newDescription == null || newDescription.trim().isEmpty() || newSubject == null || newSubject.trim().isEmpty()) {
            message = "Subject and Description cannot be empty!";
            alertClass = "alert-danger";
        } else {
            try {
                // Insert new task into the database
                String insertSql = "INSERT INTO tasks (Subject, Description, Status_id, Start_date, Due_date, User_ID) " +
                                   "VALUES (?, ?, ?, ?, ?, ?)";
                try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                    insertStmt.setString(1, newSubject.trim());
                    insertStmt.setString(2, newDescription.trim());
                    insertStmt.setInt(3, Integer.parseInt(newStatus)); 
                    insertStmt.setDate(4, java.sql.Date.valueOf(newStartDate));
                    insertStmt.setDate(5, java.sql.Date.valueOf(newDueDate));
                    insertStmt.setInt(6, (Integer) session.getAttribute("userID"));

                    int result = insertStmt.executeUpdate();
                    if (result > 0) {
                        message = "Task added successfully!";
                        alertClass = "alert-success";
                    } else {
                        message = "Failed to add task.";
                        alertClass = "alert-danger";
                    }
                }
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                alertClass = "alert-danger";
            } finally {
                if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
            }
        }
    }
%>

<div class="container mt-4">
    <div class="row mb-3">
        <div class="col">
            <h2>Add Task</h2>
            <a href="index.jsp?page=individual" class="btn btn-secondary mb-3">
                <i class="bi bi-arrow-left"></i> Back to Task List
            </a>
        </div>
    </div>

    <% if (!message.isEmpty()) { %>
        <div class="alert <%= alertClass %> alert-dismissible fade show" role="alert">
            <%= message %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <% } %>

    <div class="card">
        <div class="card-body">
            <form method="POST" action="addTask.jsp">
                <div class="mb-3">
                    <label for="subject" class="form-label">Subject</label>
                    <input type="text" class="form-control" id="subject" name="subject" required>
                </div>

                <div class="mb-3">
                    <label for="description" class="form-label">Description</label>
                    <input type="text" class="form-control" id="description" name="description" required>
                </div>

                <div class="mb-3">
                    <label for="status" class="form-label">Status</label>
                    <select class="form-select" id="status" name="status">
                        <option value="1">Pending</option>
                        <option value="2">In Progress</option>
                        <option value="3">Cancelled</option>
                        <option value="4">Completed</option>
                    </select>
                </div>

                <div class="mb-3">
                    <label for="startDate" class="form-label">Start Date</label>
                    <input type="date" class="form-control" id="startDate" name="startDate" required>
                </div>

                <div class="mb-3">
                    <label for="dueDate" class="form-label">Due Date</label>
                    <input type="date" class="form-control" id="dueDate" name="dueDate" required>
                </div>

                <div class="d-grid gap-2">
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-save"></i> Add Task
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="taskModal" tabindex="-1" aria-labelledby="taskModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="taskModalLabel">Task Addition Status</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <%= message %>
            </div>
            <div class="modal-footer">
                <a href="index.jsp?page=individual" class="btn btn-primary">Back to Task List</a>
            </div>
        </div>
    </div>
</div>

<% if (!message.isEmpty()) { %>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            var taskModal = new bootstrap.Modal(document.getElementById('taskModal'), {
                keyboard: false
            });
            taskModal.show();
        });
    </script>
<% } %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
