<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="DBConnection.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer userID = (Integer) session.getAttribute("userID");
    if (userID == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String groupIdParam = request.getParameter("groupId");
    if (groupIdParam == null) {
        out.println("<p style='color:red;'>Group ID is missing!</p>");
        return;
    }

    int groupId = Integer.parseInt(groupIdParam);

    PreparedStatement checkStmt = null;
    ResultSet checkRs = null;

    try {
        String checkSql = "SELECT Role FROM group_members WHERE Group_ID = ? AND User_ID = ?";
        checkStmt = conn.prepareStatement(checkSql);
        checkStmt.setInt(1, groupId);
        checkStmt.setInt(2, userID);
        checkRs = checkStmt.executeQuery();

        if (!checkRs.next() || !"Leader".equals(checkRs.getString("Role"))) {
            out.println("<p style='color:red;'>Access denied. Only group leaders can manage members.</p>");
            return;
        }

        checkRs.close();
        checkStmt.close();

        String sql = "SELECT gm.User_ID, u.Username, gm.Role, g.Group_Name, gm.Group_ID, " +
             "t.Subject, t.Description, s.Name AS StatusName, t.Start_Date, t.Due_Date " +
             "FROM group_members gm " +
             "JOIN user u ON gm.User_ID = u.User_ID " +
             "JOIN groups g ON gm.Group_ID = g.Group_ID " +
             "JOIN tasks_group t ON gm.Group_ID = t.Group_ID " +
             "JOIN status s ON t.Status_ID = s.Status_ID " +
             "WHERE gm.Group_ID = ? AND gm.Role = 'Member'";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, groupId);
        ResultSet rs = stmt.executeQuery();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Group Members</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            padding: 20px;
            background-color: #f3f0ff;
            color: #333;
        }

        h2 {
            text-align: center;
            color: #4b0082;
            margin-bottom: 20px;
        }

        table {
            margin-top: 2rem;
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            border: 1px solid #ccc;
            padding: 10px;
            text-align: center;
        }

        th {
            background-color: #c3b9ec;
        }

        tr:hover {
            background-color: #ece7ff;
        }

        button {
            background-color: #6a5acd;
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        button:hover {
            background-color: #4b0082;
        }

        .status-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-weight: bold;
            color: white;
            font-size: 0.85em;
        }

        .status-todo {
            background-color: #ff9800;
        }

        .status-inprogress {
            background-color: #2196f3;
        }

        .status-done {
            background-color: #4caf50;
        }

        form {
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .status-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 0.85em;
            font-weight: bold;
            color: white;
        }

        .status-todo {
            background-color: #aaa;
        }

        .status-inprogress {
            background-color: #f0ad4e;
        }

        .status-done {
            background-color: #5cb85c;
        }
    </style>

</head>
<body>
    <h2>Manage Group Members</h2>

    <table>
        <tr>
            <th>ID</th>
            <th>Username</th>
            <th>Role</th>
            <th>Action</th>
            <th>Group Name</th>
            <th>Subject</th>
            <th>Description</th>
            <th>Status</th>
            <th>Start Date</th>
            <th>Due Date</th>
        </tr>

<%
        boolean hasMember = false;
        while (rs.next()) {
            hasMember = true;
%>
        <tr>
            <td><%= rs.getInt("User_ID") %></td>
            <td><%= rs.getString("Username") %></td>
            <td><%= rs.getString("Role") %></td>
            <td>
                <!-- Edit Task Form -->
                <form action="editGroupTask.jsp" method="get" style="display:inline-block;">
                    <input type="hidden" name="groupId" value="<%= rs.getInt("Group_ID") %>">
                    <input type="hidden" name="subject" value="<%= rs.getString("Subject") %>">
                    <input type="hidden" name="description" value="<%= rs.getString("Description") %>">
                    <input type="hidden" name="status" value="<%= rs.getString("StatusName") %>">
                    <button type="submit">Edit Task</button>
                </form>
            </td>
            <td><%= rs.getString("Group_Name") %></td>
            <td><%= rs.getString("Subject") %></td>
            <td><%= rs.getString("Description") %></td>
            <td>
                <%
                    String status = rs.getString("StatusName");
                    String statusClass = "status-badge ";
                    if ("To Do".equalsIgnoreCase(status)) {
                        statusClass += "status-todo";
                    } else if ("In Progress".equalsIgnoreCase(status)) {
                        statusClass += "status-inprogress";
                    } else if ("Done".equalsIgnoreCase(status)) {
                        statusClass += "status-done";
                    } else {
                        statusClass += "status-todo"; 
                    }
                %>
                <span class="<%= statusClass %>"><%= status %></span>
            </td>

            <td><%= rs.getDate("Start_Date") %></td>
            <td><%= rs.getDate("Due_Date") %></td>
        </tr>
<%
        }

        if (!hasMember) {
%>
        <tr>
            <td colspan="10">No members found in this group.</td>
        </tr>
<%
        }

        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("<tr><td colspan='7'>Error loading tasks: " + e.getMessage() + "</td></tr>");
        e.printStackTrace();
    }
%>
    </table>
</body>
</html>
