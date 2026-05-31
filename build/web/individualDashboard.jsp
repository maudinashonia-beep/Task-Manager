<%@ page import="java.sql.*" %>
<%@ include file="DBConnection.jsp" %>
<%
    Integer userID = (Integer) session.getAttribute("userID");
    if (userID == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int pending = 0, inProgress = 0, cancelled = 0, completed = 0;
    int totalTasks = 0;

    String filter = request.getParameter("filter");
    String search = request.getParameter("search");
    String sort = request.getParameter("sort");

    String sql = "SELECT t.ID, t.Subject, t.Description, s.Name, t.Start_date, t.Due_date " +
                 "FROM tasks t JOIN status s ON t.Status_id = s.Status_ID " +
                 "WHERE t.User_ID = ? AND t.Group_ID IS NULL";

    if (search != null && !search.isEmpty()) {
        if (filter != null) {
            if (filter.equals("Subject")) {
                sql += " AND t.Subject LIKE ?";
            } else if (filter.equals("Description")) {
                sql += " AND t.Description LIKE ?";
            } else if (filter.equals("Status")) {
                sql += " AND s.Name LIKE ?";
            }
        }
    }

    if (sort != null && !sort.isEmpty()) {
        if (sort.equals("asc")) {
            sql += " ORDER BY t.Due_date ASC";
        } else if (sort.equals("desc")) {
            sql += " ORDER BY t.Due_date DESC";
        }
    } else {
        sql += " ORDER BY t.ID";
    }

    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userID);
        if (search != null && !search.isEmpty()) {
            stmt.setString(2, "%" + search + "%");
        }
        rs = stmt.executeQuery();
        while (rs.next()) {
            String statusName = rs.getString(4);
            switch (statusName) {
                case "Pending": pending++; break;
                case "In Progress": inProgress++; break;
                case "Cancel": cancelled++; break;
                case "Completed": completed++; break;
            }
        }
        totalTasks = pending + inProgress + completed;
        rs.close();
        stmt.close();

        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userID);
        if (search != null && !search.isEmpty()) {
            stmt.setString(2, "%" + search + "%");
        }
        rs = stmt.executeQuery();
%>

<!DOCTYPE html>
<html>
<head>
    <title>Individual Task Dashboard</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background-color: #f3f0ff;
            margin: 0;
            padding: 0px;
            box-sizing: border-box;
            min-height: 100vh;
        }
        h2 { color: #4b0082; }
        .task-box {
            display: flex;
            gap: 1.5rem;
            margin-top: 1rem;
        }
        .status-box {
            flex: 1;
            background-color: #d1c4f7;
            padding: 1rem;
            border-radius: 10px;
            text-align: center;
        }
        .status-box h3 { margin: 0; font-size: 28px; }
        .status-box p { margin: 0; color: #555; }
        .progress-bar {
            margin-top: 2rem;
            background-color: #ccc;
            border-radius: 10px;
            height: 20px;
            width: 80%;
            max-width: 600px;
        }
        .progress-fill {
            height: 100%;
            border-radius: 10px;
        }
        .dashboard-controls {
            margin-top: 2rem;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        .dashboard-controls a,
        .dashboard-controls button {
            padding: 8px 12px;
            border-radius: 5px;
            background-color: #6a5acd;
            color: white;
            text-decoration: none;
            cursor: pointer;
            border: none;
        }
        .dashboard-controls input,
        .dashboard-controls select {
            padding: 6px;
            border-radius: 4px;
            border: 1px solid #aaa;
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
        td .status-label {
            padding: 4px 8px;
            border-radius: 4px;
            color: white;
            font-weight: bold;
        }
        .Pending { background-color: #ff9800; }
        .InProgress { background-color: #2196f3; }
        .Cancel { background-color: #f44336; }
        .Completed { background-color: #4caf50; }
    </style>
</head>
<body>

<h2>Individual Task Dashboard</h2>

<div class="task-box">
    <div class="status-box"><h3><%= pending %></h3><p>Pending</p></div>
    <div class="status-box"><h3><%= inProgress %></h3><p>In Progress</p></div>
    <div class="status-box"><h3><%= cancelled %></h3><p>Cancelled</p></div>
    <div class="status-box"><h3><%= completed %></h3><p>Completed</p></div>
</div>

<div class="progress-bar">
    <div class="progress-fill" style="width: <%= (totalTasks > 0 ? (completed * 100 / totalTasks) : 0) %>%; background-color: <%= (completed == totalTasks && totalTasks > 0) ? "#4caf50" : "#a5d6a7" %>;"></div>
</div>
<p style="margin-top: 5px;"><%= completed %> / <%= totalTasks %> individual tasks completed</p>

<div class="dashboard-controls">
    <a href="addTask.jsp">Add Individual Task</a>
    <form method="get" action="index.jsp" style="display: flex; gap: 10px; align-items: center;">
        <input type="hidden" name="page" value="individual">
        <input type="text" name="search" placeholder="Search..." />
        <select name="filter">
            <option value="Subject">Subject</option>
            <option value="Description">Description</option>
            <option value="Status">Status</option>
        </select>
        <select name="sort">
            <option value="asc">Deadline Nearest</option>
            <option value="desc">Deadline Farthest</option>
        </select>
        <button type="submit">Search</button>
    </form>
</div>

<table>
    <tr>
        <th>ID</th>
        <th>Subject</th>
        <th>Description</th>
        <th>Status</th>
        <th>Start Date</th>
        <th>Due Date</th>
        <th>Action</th>
    </tr>
<%
        int counter = 1;
        while (rs.next()) {
            String statusName = rs.getString(4);
%>
    <tr>
        <td><%= counter++ %></td>
        <td><%= rs.getString(2) %></td>
        <td><%= rs.getString(3) %></td>
        <td><span class="status-label <%= statusName.replace(" ", "") %>"><%= statusName %></span></td>
        <td><%= rs.getDate(5) %></td>
        <td><%= rs.getDate(6) %></td>
        <td>
            <a href="editTask.jsp?id=<%= rs.getInt(1) %>" 
               style="background-color: green; color: white; padding: 2px 6px; text-decoration: none; border-radius: 4px;">Edit</a>
            <a href="deleteTask.jsp?id=<%= rs.getInt(1) %>" 
               style="background-color: red; color: white; padding: 2px 6px; text-decoration: none; border-radius: 4px;" 
               onclick="return confirm('Are you sure?')">Delete</a>

        </td>
    </tr>
<%
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='7'>Error loading tasks: " + e.getMessage() + "</td></tr>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignored) {}
        if (stmt != null) try { stmt.close(); } catch (Exception ignored) {}
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }
%>
</table>
</body>
</html>
