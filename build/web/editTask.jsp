<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="DBConnection.jsp" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Task</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
</head>
<body>
<%
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    
    int taskId = 0;
    String message = "";
    String alertClass = "";
    
    try {
        taskId = Integer.parseInt(request.getParameter("id"));
    } catch (NumberFormatException e) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String description = "";
    String status = "";
    Date startDate = null;
    Date dueDate = null;

    try {
        String selectSql = "SELECT t.Description, s.Name AS Status, t.Start_date, t.Due_date " +
                            "FROM tasks t JOIN status s ON t.Status_id = s.Status_id WHERE t.ID = ?";
        
        try (PreparedStatement selectStmt = conn.prepareStatement(selectSql)) {
            selectStmt.setInt(1, taskId);
            ResultSet rs = selectStmt.executeQuery();
            if (rs.next()) {
                description = rs.getString("Description");
                status = rs.getString("Status");
                startDate = rs.getDate("Start_date");
                dueDate = rs.getDate("Due_date");
            } else {
                message = "Task not found.";
                alertClass = "alert-danger";
            }
        }

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String newDescription = request.getParameter("description");
            String newStatus = request.getParameter("status");
            String newStartDate = request.getParameter("startDate");
            String newDueDate = request.getParameter("dueDate");

            if (newDescription == null || newDescription.trim().isEmpty()) {
                message = "Description cannot be empty!";
                alertClass = "alert-danger";
            } else {
                String updateSql = "UPDATE tasks SET Description = ?, Start_date = ?, Status_id = ?, Due_date = ? WHERE ID = ?";
                try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                    updateStmt.setString(1, newDescription.trim());
                    updateStmt.setDate(2, java.sql.Date.valueOf(newStartDate));
                    updateStmt.setInt(3, Integer.parseInt(newStatus)); 
                    updateStmt.setDate(4, java.sql.Date.valueOf(newDueDate));
                    updateStmt.setInt(5, taskId);

                    int result = updateStmt.executeUpdate();
                    if (result > 0) {
                        message = "Task updated successfully!";
                        alertClass = "alert-success";
                    } else {
                        message = "Failed to update task.";
                        alertClass = "alert-danger";
                    }
                }
            }
        }
    } catch (Exception e) {
        message = "Error: " + e.getMessage();
        alertClass = "alert-danger";
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>

<div class="container mt-4">
    <div class="row mb-3">
        <div class="col">
            <h2>Edit Task</h2>
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
            <form method="POST" action="editTask.jsp?id=<%= taskId %>">
                <div class="mb-3">
                    <label for="description" class="form-label">Description</label>
                    <input type="text" class="form-control" id="description" name="description" 
                           value="<%= description %>" required>
                </div>

                <div class="mb-3">
                    <label for="status" class="form-label">Status</label>
                    <select class="form-select" id="status" name="status">
                        <option value="1" <%= "Pending".equals(status) ? "selected" : "" %>>Pending</option>
                        <option value="2" <%= "Inprogress".equals(status) ? "selected" : "" %>>In Progress</option>
                        <option value="3" <%= "Cancel".equals(status) ? "selected" : "" %>>Cancelled</option>
                        <option value="4" <%= "Completed".equals(status) ? "selected" : "" %>>Completed</option>
                    </select>
                </div>

                <div class="mb-3">
                    <label for="startDate" class="form-label">Start Date</label>
                    <input type="date" class="form-control" id="startDate" name="startDate" 
                           value="<%= startDate != null ? dateFormat.format(startDate) : "" %>" required>
                </div>

                <div class="mb-3">
                    <label for="dueDate" class="form-label">Due Date</label>
                    <input type="date" class="form-control" id="dueDate" name="dueDate" 
                           value="<%= dueDate != null ? dateFormat.format(dueDate) : "" %>" required>
                </div>

                <div class="d-grid gap-2">
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-save"></i> Save Changes
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
                <h5 class="modal-title" id="taskModalLabel">Task Update Status</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <%= message %>
            </div>
            <div class="modal-footer">
                <a href="index.jsp?page=individual" class="back-button">Back to Task List</a>
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
