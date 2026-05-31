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

    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        String sql = "SELECT s.Name FROM tasks_group tg " +
             "JOIN status s ON tg.Status_ID = s.Status_ID " +
             "JOIN groups g ON tg.Group_ID = g.Group_ID " +
             "JOIN group_members gm ON g.Group_ID = gm.Group_ID " +
             "WHERE gm.User_ID = ?";

        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userID);
        rs = stmt.executeQuery();

        while (rs.next()) {
            String statusName = rs.getString("Name");
            switch (statusName) {
                case "Pending": pending++; break;
                case "In Progress": inProgress++; break;
                case "Cancelled": cancelled++; break;
                case "Completed": completed++; break;
            }
        }

        totalTasks = pending + inProgress + completed;

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
    }
%>

<style>
    body {
    font-family: 'Segoe UI', sans-serif;
    background-color: #f3f0ff;
    margin: 0;
    padding: 0;
}

h2 {
    color: #4b0082;
}

h3 {
        margin: 0;
    }

.task-box {
    display: flex;
    gap: 1.5rem;
    margin-top: 10px;
}

.status-box {
    flex: 1;
    background-color: #d1c4f7;
    padding: 1rem;
    border-radius: 10px;
    text-align: center;
}

.status-box h3 {
    margin: 0;
    font-size: 28px;
}

.status-box p {
    margin: 0;
    color: #555;
}

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
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
}

.dashboard-controls a,
.dashboard-controls button {
    padding: 8px 12px;
    border: none;
    border-radius: 5px;
    background-color: #6a5acd;
    color: white;
    text-decoration: none;
    cursor: pointer;
}

.dashboard-controls input,
.dashboard-controls select {
    padding: 6px;
    border-radius: 4px;
    border: 1px solid #aaa;
}

table {
    margin-top: 20px;
    margin-bottom: 20px;
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

.status-label {
    padding: 4px 8px;
    border-radius: 4px;
    color: white;
    font-weight: bold;
    display: inline-block;
    width: 80px;
}

.Pending {
    background-color: #ff9800;
}

.InProgress {
    background-color: #2196f3;
}

.Cancelled {
    background-color: #f44336;
}

.Completed {
    background-color: #4caf50;
}

.action-button {
    padding: 5px 10px;
    border: none;
    border-radius: 4px;
    color: white;
    cursor: pointer;
}

.action-button.manage {
    background-color: green;
}

.action-button.delete {
    background-color: red;
}

.action-button.view {
    background-color: gray;
    cursor: not-allowed;
}
</style>

<div class="task-box">
    <div class="status-box"><h3><%= pending %></h3><p>Pending</p></div>
    <div class="status-box"><h3><%= inProgress %></h3><p>In Progress</p></div>
    <div class="status-box"><h3><%= cancelled %></h3><p>Cancelled</p></div>
 <div class="status-box"><h3><%= completed %></h3><p>Completed</p></div>
</div>

<%
    int progressPercent = totalTasks > 0 ? (completed * 100 / totalTasks) : 0;
%>
<div class="progress-bar">
    <div class="progress-fill" style="width: <%= progressPercent %>%; background-color: <%= (progressPercent == 100) ? "#4caf50" : "#a5d6a7" %>;"></div>
</div>
<p style="margin-top: 5px;"><%= completed %> / <%= totalTasks %> group tasks completed</p>

<!-- Task Filters and Table -->
<div class="dashboard-controls">
    <a href="addGroupTask.jsp">Add Group Task</a>
    <form method="get" action="index.jsp" style="display: flex; gap: 10px; align-items: center;">
        <input type="hidden" name="page" value="group">
        <input type="text" name="search" placeholder="Search..." />
        <select name="filter">
            <option value="Group">Group Name</option>
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

<h3>Created Groups Tasks</h3>
<table>
    <tr>
        <th>ID</th>
        <th>Group Name</th>
        <th>Subject</th>
        <th>Description</th>
        <th>Member</th>
        <th>Status</th>
        <th>Start Date</th>
        <th>Due Date</th>
        <th>Leader</th>
        <th>Action</th>
    </tr>
<%
    try {
        String sql = "SELECT tg.ID_task, g.Group_Name, tg.Subject, tg.Description, " +
                     "s.Name AS StatusName, tg.Start_Date, tg.Due_Date,u.Username, " +
                     "gm.Role, g.Group_ID, " +
                     "(SELECT COUNT(*) FROM group_members gm2 WHERE gm2.Group_ID = g.Group_ID) AS MemberCount " +
                     "FROM tasks_group tg " +
                     "JOIN status s ON tg.Status_ID = s.Status_ID " +
                     "JOIN groups g ON tg.Group_ID = g.Group_ID " +
                     "JOIN group_members gm ON tg.Group_ID = gm.Group_ID AND gm.User_ID = ? " +
                     "JOIN user u ON gm.User_ID = u.User_ID " +
                     "WHERE gm.Role = 'Leader' AND gm.User_ID = ? ";
                     
        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userID);
        stmt.setInt(2, userID);
        rs = stmt.executeQuery();

        while (rs.next()) {
            String statusName = rs.getString("StatusName");
            String role = rs.getString("Role");
            int taskId = rs.getInt("ID_task");
%>
    <tr>
        <td><%= rs.getInt("ID_task") %></td>
        <td><%= rs.getString("Group_Name") %></td>
        <td><%= rs.getString("Subject") %></td>
        <td><%= rs.getString("Description") %></td>
        <td><%= rs.getInt("MemberCount") %></td>
        <td><span class="status-label <%= statusName.replace(" ", "") %>"><%= statusName %></span></td>
        <td><%= rs.getDate("Start_Date") %></td>
        <td><%= rs.getDate("Due_Date") %></td>
        <td><%= rs.getString("Username") %></td>
        <td>
            <% if ("Leader".equalsIgnoreCase(role)) { %>
                <form method="get" action="memberManagement.jsp">
                    <input type="hidden" name="groupId" value="<%= rs.getInt("Group_ID") %>" />
                    <button type="submit" style="background-color: green; color: white;">Manage</button>
                </form>
                <form method="post" action="deleteGroupTask.jsp" onsubmit="return confirm('Are you sure you want to delete this group task?');">
                    <input type="hidden" name="taskId" value="<%= rs.getInt("ID_task") %>" />
                    <button type="submit" style="background-color: red; color: white;">Delete</button>
                </form>
            <% } else { %>
                <button disabled style="background-color: gray; color: white;">View</button>
            <% } %>
        </td>
    </tr>
<%
        }
    } catch (SQLException e) {
        out.println("<tr><td colspan='10'>Error loading tasks: " + e.getMessage() + "</td></tr>");
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt .close();
    }
%>
</table>

<h3>Joined Groups Tasks</h3>
<table>
    <tr>
        <th>ID</th>
        <th>Group Name</th>
        <th>Subject</th>
        <th>Description</th>
        <th>Member</th>
        <th>Status</th>
        <th>Start Date</th>
        <th>Due Date</th>
        <th>Leader</th>
    </tr>
<%
    try {
        String sql = "SELECT tg.ID_task, g.Group_Name, tg.Subject, tg.Description, " +
             "s.Name AS StatusName, tg.Start_Date, tg.Due_Date, " +
             "gm.Role, g.Group_ID, " +
             "(SELECT u.Username FROM group_members gm_leader " +
             " JOIN user u ON gm_leader.User_ID = u.User_ID " +
             " WHERE gm_leader.Group_ID = g.Group_ID AND gm_leader.Role = 'Leader' LIMIT 1) AS LeaderUsername, " +
             "(SELECT COUNT(*) FROM group_members gm3 WHERE gm3.Group_ID = g.Group_ID) AS MemberCount " +
             "FROM tasks_group tg " +
             "JOIN status s ON tg.Status_ID = s.Status_ID " +
             "JOIN groups g ON tg.Group_ID = g.Group_ID " +
             "JOIN group_members gm ON tg.Group_ID = gm.Group_ID AND gm.User_ID = ? " +
             "WHERE gm.User_ID = ? AND gm.Role != 'Leader' ";


        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userID);
        stmt.setInt(2, userID);
        rs = stmt.executeQuery();

        while (rs.next()) {
            String statusName = rs.getString("StatusName");
            String role = rs.getString("Role");
            int groupId = rs.getInt("Group_ID");
%>
    <tr>
        <td><%= rs.getInt("ID_task") %></td>
        <td><%= rs.getString("Group_Name") %></td>
        <td><%= rs.getString("Subject") %></td>
        <td><%= rs.getString("Description") %></td>
        <td><%= rs.getInt("MemberCount") %></td>
        <td><span class="status-label <%= statusName.replace(" ", "") %>"><%= statusName %></span></td>
        <td><%= rs.getDate("Start_Date") %></td>
        <td><%= rs.getDate("Due_Date") %></td>
        <td><%= rs.getString("LeaderUsername") %></td>


        <td>
            <% if ("Leader".equalsIgnoreCase(role)) { %>
                <form method="get" action="memberManagement.jsp" style="display:inline;">
                    <input type="hidden" name="groupId" value="<%= groupId %>" />
                    <button type="submit" class="action-button manage">Manage</button>
                </form>
            <% } %>
        </td>

    </tr>
<%
        }
    } catch (SQLException e) {
        out.println("<tr><td colspan='10'>Error loading tasks: " + e.getMessage() + "</td></tr>");
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>
</table>
