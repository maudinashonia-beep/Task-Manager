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
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap');
        
        body {
            margin: 0;
            font-family: 'Outfit', sans-serif;
            background-color: #080614;
            color: #cbd5e1;
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
        }

        /* Subtle Blueprint Tech Grid Background */
        body::before {
            content: "";
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: 
                radial-gradient(rgba(255, 255, 255, 0.015) 1.5px, transparent 1.5px),
                linear-gradient(rgba(139, 92, 246, 0.008) 1px, transparent 1px),
                linear-gradient(90deg, rgba(139, 92, 246, 0.008) 1px, transparent 1px);
            background-size: 24px 24px, 48px 48px, 48px 48px;
            z-index: 1;
            pointer-events: none;
        }

        /* Animated Glowing Orbs Background */
        .bg-glow {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 0;
            overflow: hidden;
            pointer-events: none;
        }

        .glow-1, .glow-2, .glow-3 {
            position: absolute;
            border-radius: 50%;
            filter: blur(140px);
            opacity: 0.15;
            animation: float 25s infinite alternate ease-in-out;
        }

        .glow-1 {
            top: -10%;
            left: -10%;
            width: 45vw;
            height: 45vw;
            background: radial-gradient(circle, #8b5cf6 20%, transparent 70%);
            animation-duration: 22s;
        }

        .glow-2 {
            bottom: -15%;
            right: -5%;
            width: 50vw;
            height: 50vw;
            background: radial-gradient(circle, #3b82f6 20%, transparent 70%);
            animation-duration: 30s;
            animation-delay: -7s;
        }

        .glow-3 {
            top: 40%;
            left: 30%;
            width: 35vw;
            height: 35vw;
            background: radial-gradient(circle, #ec4899 10%, transparent 75%);
            animation-duration: 25s;
            animation-delay: -12s;
        }

        @keyframes float {
            0% { transform: translate(0, 0) scale(1) rotate(0deg); }
            50% { transform: translate(4vw, 5vh) scale(1.1) rotate(180deg); }
            100% { transform: translate(-2vw, -4vh) scale(0.95) rotate(360deg); }
        }

        .container {
            z-index: 10;
            position: relative;
            max-width: 540px !important;
        }

        h2 {
            font-size: 32px;
            font-weight: 800;
            margin: 0 0 10px 0;
            background: linear-gradient(135deg, #fff 40%, rgba(255, 255, 255, 0.7));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            display: inline-block;
            letter-spacing: -0.5px;
        }

        .card {
            background: rgba(20, 18, 43, 0.45) !important;
            backdrop-filter: blur(16px) saturate(120%) !important;
            -webkit-backdrop-filter: blur(16px) saturate(120%) !important;
            border: 1px solid rgba(255, 255, 255, 0.08) !important;
            border-radius: 24px !important;
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.4),
                        inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
            padding: 10px;
        }

        .card-body {
            padding: 30px !important;
        }

        .form-label {
            color: rgba(255, 255, 255, 0.65);
            font-weight: 600;
            font-size: 14px;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .form-control, .form-select {
            background: #1c1a38 !important;
            border: 1px solid rgba(255, 255, 255, 0.08) !important;
            border-radius: 14px !important;
            color: white !important;
            padding: 12px 16px !important;
            font-size: 15px !important;
            transition: all 0.3s ease !important;
        }

        .form-control:focus, .form-select:focus {
            background: rgba(37, 34, 72, 0.6) !important;
            border-color: #a78bfa !important;
            outline: none !important;
            box-shadow: 0 0 18px rgba(167, 139, 250, 0.35) !important;
        }

        .form-control::placeholder {
            color: rgba(255, 255, 255, 0.3) !important;
        }

        .form-select option {
            background: #0e0c20;
            color: white;
        }

        .btn-primary {
            background: linear-gradient(135deg, #8b5cf6, #6366f1) !important;
            border: none !important;
            font-weight: 700 !important;
            font-size: 15px !important;
            padding: 14px 20px !important;
            border-radius: 14px !important;
            box-shadow: 0 6px 20px rgba(139, 92, 246, 0.25) !important;
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1) !important;
            cursor: pointer;
        }

        .btn-primary:hover {
            background: linear-gradient(135deg, #a78bfa, #818cf8) !important;
            transform: translateY(-2px) !important;
            box-shadow: 0 8px 25px rgba(139, 92, 246, 0.4) !important;
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.05) !important;
            border: 1px solid rgba(255, 255, 255, 0.08) !important;
            color: white !important;
            font-weight: 600 !important;
            font-size: 14px !important;
            padding: 10px 18px !important;
            border-radius: 12px !important;
            transition: all 0.3s ease !important;
            margin-bottom: 24px !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 8px !important;
        }

        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.12) !important;
            border-color: rgba(255, 255, 255, 0.15) !important;
            transform: translateY(-1px) !important;
        }

        /* Solid Contrast Modal Styling */
        .modal-content {
            background: #14122b !important;
            border: 1px solid rgba(255, 255, 255, 0.08) !important;
            border-radius: 24px !important;
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.6) !important;
            color: white !important;
        }

        .modal-header {
            border-bottom: 1px solid rgba(255, 255, 255, 0.06) !important;
        }

        .modal-footer {
            border-top: 1px solid rgba(255, 255, 255, 0.06) !important;
        }

        .modal-title {
            font-weight: 700 !important;
            color: white !important;
        }

        /* Alert Styling */
        .alert {
            background: rgba(255, 255, 255, 0.02) !important;
            backdrop-filter: blur(20px) !important;
            border-radius: 14px !important;
            color: white !important;
            border: 1px solid rgba(255, 255, 255, 0.05) !important;
            padding: 16px 20px !important;
        }

        .alert-success {
            border-color: rgba(16, 185, 129, 0.2) !important;
            background: rgba(16, 185, 129, 0.05) !important;
            color: #34d399 !important;
        }

        .alert-danger {
            border-color: rgba(239, 68, 68, 0.2) !important;
            background: rgba(239, 68, 68, 0.05) !important;
            color: #fca5a5 !important;
        }
    </style>
</head>
<body>
    <!-- Animated Glowing Orbs Background -->
    <div class="bg-glow">
        <div class="glow-1"></div>
        <div class="glow-2"></div>
        <div class="glow-3"></div>
    </div>

    <!-- Premium 3D Tech & Glass Elements -->
    <%@ include file="glowingTechElements.jsp" %>
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
