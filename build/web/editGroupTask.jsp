<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="DBConnection.jsp" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Group Task</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
</head>
<body>
<%
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    
    int groupId = 0;
    String message = "";
    String alertClass = "";
    
    try {
        groupId = Integer.parseInt(request.getParameter("groupId"));
    } catch (NumberFormatException e) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String subject = "";
    String description = "";
    String status = "";
    Date startDate = null;
    Date dueDate = null;

    try {
        String selectSql = "SELECT g.Subject, g.Description, s.Status_id, s.Name AS Status, g.Start_date, g.Due_date " +
                            "FROM tasks_group g JOIN status s ON g.Status_id = s.Status_id WHERE g.Group_ID = ?";

        try (PreparedStatement selectStmt = conn.prepareStatement(selectSql)) {
            selectStmt.setInt(1, groupId);
            ResultSet rs = selectStmt.executeQuery();
            if (rs.next()) {
                subject = rs.getString("Subject");
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
            String newSubject = request.getParameter("subject");
            String newDescription = request.getParameter("description");
            String newStatus = request.getParameter("status");
            String newStartDate = request.getParameter("startDate");
            String newDueDate = request.getParameter("dueDate");

            if (newDescription == null || newDescription.trim().isEmpty()) {
                message = "Description cannot be empty!";
                alertClass = "alert-danger";
            } else {
                String updateSql = "UPDATE tasks_group SET Status_id = ?, Description = ?, Start_date = ?, Due_date = ? WHERE Group_ID = ?";
                try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                    updateStmt.setInt(1, Integer.parseInt(newStatus));
                    updateStmt.setString(2, newDescription.trim());
                    updateStmt.setDate(3, java.sql.Date.valueOf(newStartDate));
                    updateStmt.setDate(4, java.sql.Date.valueOf(newDueDate));
                    updateStmt.setInt(5, groupId);

                    int result = updateStmt.executeUpdate();
                    if (result > 0) {
                        message = "Group Task updated successfully!";
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
            <h2>Edit Group Task</h2>
            <a href="index.jsp?page=group" class="btn btn-secondary mb-3">
                <i class="bi bi-arrow-left"></i> Back 
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
            <form method="POST" action="editGroupTask.jsp?groupId=<%= groupId %>">
                <div class="mb-3">
                    <label for="subject" class="form-label">Subject</label>
                    <input type="text" class="form-control" id="subject" name="subject" 
                           value="<%= subject %>" required>
                </div>
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
                        <option value="3" <%= "Cancelled".equals(status) ? "selected" : "" %>>Cancelled</option>
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

<!-- Modal -->
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
                <a href="index.jsp?page=group" class="btn btn-secondary mb-3">
                    <i class="bi bi-arrow-left"></i> Back to Group Tasks
                </a>
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
