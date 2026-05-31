<%@ page import="java.sql.*" %>
<%@ include file="DBConnection.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String username = (String) session.getAttribute("username");
    Integer userID = (Integer) session.getAttribute("userID");

    if (username == null || userID == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String message = "";
    PreparedStatement stmt = null;
    PreparedStatement statusStmt = null;
    ResultSet rsGroups = null;
    ResultSet rsStatus = null;

    try {
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String subject = request.getParameter("subject");
            String description = request.getParameter("description");
            int groupId = Integer.parseInt(request.getParameter("group_id"));
            int statusId = Integer.parseInt(request.getParameter("status_id"));
            String startDate = request.getParameter("start_date");
            String dueDate = request.getParameter("due_date");
            String maxMemberStr = request.getParameter("max_member");

            int maxMember = 5;
            if (maxMemberStr != null && !maxMemberStr.trim().isEmpty()) {
                try {
                    maxMember = Integer.parseInt(maxMemberStr);
                } catch (NumberFormatException e) {
                    maxMember = 5; // default
                }
            }

            // Cek apakah user adalah leader grup
            String roleCheckSql = "SELECT Role FROM group_members WHERE User_ID = ? AND Group_ID = ?";
            PreparedStatement roleStmt = conn.prepareStatement(roleCheckSql);
            roleStmt.setInt(1, userID);
            roleStmt.setInt(2, groupId);
            ResultSet roleRs = roleStmt.executeQuery();

            if (roleRs.next()) {
                String role = roleRs.getString("Role");
                if (!"Leader".equalsIgnoreCase(role)) {
                    message = "Only group leaders can add tasks.";
                } else {
                    String sqlInsert = "INSERT INTO tasks_group (Subject, Description, Status_ID, Start_Date, Due_Date, Group_ID, User_ID, Max_Members) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                    stmt = conn.prepareStatement(sqlInsert);
                    stmt.setString(1, subject);
                    stmt.setString(2, description);
                    stmt.setInt(3, statusId);
                    stmt.setString(4, startDate);
                    stmt.setString(5, dueDate);
                    stmt.setInt(6, groupId);
                    stmt.setInt(7, userID);
                    stmt.setInt(8, maxMember);

                    int result = stmt.executeUpdate();
                    if (result > 0) {
                        message = "Group task added successfully.";
                    } else {
                        message = "Failed to add group task.";
                    }
                }
            } else {
                message = "You are not a member of the selected group.";
            }
            roleRs.close();
            roleStmt.close();
        }

        // Ambil daftar grup user
        String sqlGroups = "SELECT g.Group_ID, g.Group_Name FROM groups g JOIN group_members gm ON g.Group_ID = gm.Group_ID WHERE gm.User_ID = ?";
        stmt = conn.prepareStatement(sqlGroups);
        stmt.setInt(1, userID);
        rsGroups = stmt.executeQuery();

        // Ambil daftar status
        String sqlStatus = "SELECT Status_ID, Name FROM status";
        statusStmt = conn.prepareStatement(sqlStatus);
        rsStatus = statusStmt.executeQuery();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>Add Group Task</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" />
</head>
<body>
<div class="container mt-4">
    <div class="row mb-3">
        <div class="col">
            <h2>Add Group Task</h2>
            <a href="index.jsp?page=group" class="btn btn-secondary mb-3">
                <i class="bi bi-arrow-left"></i> Back to Group Tasks
            </a>
        </div>
    </div>

    <% if (!message.isEmpty()) { %>
        <div class="alert <%= message.contains("successfully") ? "alert-success" : "alert-danger" %> alert-dismissible fade show" role="alert">
            <%= message %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <% } %>

    <div class="card">
        <div class="card-body">
            <form method="post" novalidate>
                <div class="mb-3">
                    <label for="subject" class="form-label">Subject</label>
                    <input type="text" id="subject" name="subject" class="form-control" required />
                </div>

                <div class="mb-3">
                    <label for="description" class="form-label">Description</label>
                    <textarea id="description" name="description" rows="3" class="form-control" required></textarea>
                </div>

                <div class="mb-3">
                    <label for="group_id" class="form-label">Group</label>
                    <select id="group_id" name="group_id" class="form-select" required>
                        <option value="">Select Group</option>
                        <% while (rsGroups != null && rsGroups.next()) { %>
                            <option value="<%= rsGroups.getInt("Group_ID") %>"><%= rsGroups.getString("Group_Name") %></option>
                        <% } %>
                    </select>
                </div>

                <div class="mb-3">
                    <label for="max_member" class="form-label">Number of Members</label>
                    <input type="number" id="max_member" name="max_member" class="form-control" min="1" max="100" value="5" required />
                </div>

                <div class="mb-3">
                    <label for="status_id" class="form-label">Status</label>
                    <select id="status_id" name="status_id" class="form-select" required>
                        <option value="">Select Status</option>
                        <% while (rsStatus != null && rsStatus.next()) { %>
                            <option value="<%= rsStatus.getInt("Status_ID") %>"><%= rsStatus.getString("Name") %></option>
                        <% } %>
                    </select>
                </div>

                <div class="mb-3">
                    <label for="start_date" class="form-label">Start Date</label>
                    <input type="date" id="start_date" name="start_date" class="form-control" required />
                </div>

                <div class="mb-3">
                    <label for="due_date" class="form-label">Due Date</label>
                    <input type="date" id="due_date" name="due_date" class="form-control" required />
                </div>

                <button type="submit" class="btn btn-primary">
                    <i class="bi bi-save"></i> Add Task
                </button>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<%
        // Tutup resource
        if (rsGroups != null) rsGroups.close();
        if (rsStatus != null) rsStatus.close();
        if (statusStmt != null) statusStmt.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p style='color:red; text-align:center;'>Error: " + e.getMessage() + "</p>");
    }
%>
