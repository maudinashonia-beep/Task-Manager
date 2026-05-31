<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="DBConnection.jsp" %>
<%
    String username = (String) session.getAttribute("username");
    Integer userID   = (Integer) session.getAttribute("userID");

    if (username == null || userID == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String message = "";
    int groupID = request.getParameter("groupID") != null ? Integer.parseInt(request.getParameter("groupID")) : -1;

    boolean isLeader = false;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        String checkRole = "SELECT Role FROM group_members WHERE Group_ID = ? AND User_ID = ?";
        ps = conn.prepareStatement(checkRole);
        ps.setInt(1, groupID);
        ps.setInt(2, userID);
        rs = ps.executeQuery();
        if (rs.next() && "Leader".equals(rs.getString("Role"))) {
            isLeader = true;
        }
        rs.close();
        ps.close();
    } catch (Exception e) {
        e.printStackTrace();
    }

    if (!isLeader) {
        response.sendRedirect("index.jsp?page=group");
        return;
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String subject = request.getParameter("subject");
        String description = request.getParameter("description");
        String dueDate = request.getParameter("due_date");
        int assigneeID = Integer.parseInt(request.getParameter("assignee"));

        try {
            String insertTask = "INSERT INTO group_tasks (Subject, Description, Start_Date, Due_Date, Status_ID, Group_ID, Assigned_To) VALUES (?, ?, NOW(), ?, 1, ?, ?)";
            ps = conn.prepareStatement(insertTask);
            ps.setString(1, subject);
            ps.setString(2, description);
            ps.setString(3, dueDate);
            ps.setInt(4, groupID);
            ps.setInt(5, assigneeID);
            ps.executeUpdate();

            response.sendRedirect("viewGroupTask.jsp?groupID=" + groupID);
            return;
        } catch (Exception e) {
            e.printStackTrace();
            message = "Failed to assign task.";
        }
    }

    ResultSet members = null;
    try {
        String memberQuery = "SELECT u.User_ID, u.Fullname FROM users u INNER JOIN group_members gm ON u.User_ID = gm.User_ID WHERE gm.Group_ID = ?";
        ps = conn.prepareStatement(memberQuery);
        ps.setInt(1, groupID);
        members = ps.executeQuery();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Assign Task</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background-color: #f3e8ff; padding: 50px; }
        .box { background: white; max-width: 600px; margin: auto; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 6px rgba(0,0,0,0.1); }
        h2 { color: #5f4bb6; }
        label { display: block; margin-top: 1rem; font-weight: bold; }
        input, textarea, select { width: 100%; padding: .5rem; margin-top: .3rem; border-radius: 4px; border: 1px solid #ccc; }
        button { margin-top: 1.5rem; padding: .6rem 1rem; background-color: #5f4bb6; color: white; border: none; border-radius: 5px; cursor: pointer; }
        .msg { color: red; margin-top: 1rem; }
        .back { margin-top: 1rem; text-align: center; }
    </style>
</head>
<body>
<div class="box">
    <h2>Assign Task to Member</h2>
    <form method="post" action="assignTask.jsp?groupID=<%= groupID %>">
        <label>Subject</label>
        <input type="text" name="subject" required />

        <label>Description</label>
        <textarea name="description" rows="4" required></textarea>

        <label>Due Date</label>
        <input type="date" name="due_date" required />

        <label>Assign To</label>
        <select name="assignee" required>
            <%
                while (members.next()) {
                    int id = members.getInt("User_ID");
                    String name = members.getString("Fullname");
            %>
                <option value="<%= id %>"><%= name %></option>
            <%
                }
            %>
        </select>

        <button type="submit">Assign Task</button>
    </form>
    <% if (!message.isEmpty()) { %>
        <div class="msg"><%= message %></div>
    <% } %>
    <div class="back"><a href="viewGroupTask.jsp?groupID=<%= groupID %>">← Back to Group Tasks</a></div>
</div>
</body>
</html>
<%
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (members != null) members.close(); } catch (Exception ignored) {}
        try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        try { if (conn != null) conn.close(); } catch (Exception ignored) {}
    }
%>