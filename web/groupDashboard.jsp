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
             "JOIN `groups` g ON tg.Group_ID = g.Group_ID " +
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
    .page-title {
        font-size: 28px;
        font-weight: 800;
        margin: 0 0 24px 0;
        background: linear-gradient(135deg, #fff 40%, rgba(255, 255, 255, 0.7));
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        display: inline-block;
        letter-spacing: -0.5px;
    }
    .section-title {
        font-size: 20px;
        font-weight: 700;
        margin: 2.5rem 0 1rem 0;
        color: #a78bfa;
        text-shadow: 0 0 15px rgba(167, 139, 250, 0.2);
    }

    /* 2-Column Overview Grid Layout (Progress & Stats) */
    .overview-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 24px;
        margin-top: 10px;
        align-items: start;
    }

    @media (max-width: 1024px) {
        .overview-grid {
            grid-template-columns: 1fr;
        }
    }

    .overview-left {
        display: flex;
        flex-direction: column;
    }

    .overview-right {
        display: flex;
        flex-direction: column;
    }

    /* Sidebar Progress Card */
    .summary-card {
        background: rgba(20, 18, 43, 0.45) !important;
        backdrop-filter: blur(16px) saturate(120%) !important;
        -webkit-backdrop-filter: blur(16px) saturate(120%) !important;
        border: 1px solid rgba(255, 255, 255, 0.08) !important;
        padding: 24px;
        border-radius: 20px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3),
                    inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
        height: 100%;
        box-sizing: border-box;
    }

    .summary-card h3 {
        margin: 0 0 16px 0;
        font-size: 16px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        color: #a5a1c9;
    }

    .progress-bar {
        background-color: #1c1a38;
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 10px;
        height: 12px;
        width: 100%;
        overflow: hidden;
        box-shadow: inset 0 2px 4px rgba(0,0,0,0.3);
        margin-top: 8px;
    }

    .progress-fill {
        height: 100%;
        border-radius: 10px;
        transition: width 0.5s ease;
    }

    .progress-desc {
        margin-top: 12px;
        margin-bottom: 0;
        font-size: 14px;
        color: rgba(255, 255, 255, 0.6);
        font-weight: 500;
    }

    .progress-desc strong {
        color: #fff;
    }

    /* Stats Sidebar Grid */
    .stats-sidebar-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 16px;
    }

    @media (max-width: 576px) {
        .stats-sidebar-grid {
            grid-template-columns: 1fr;
        }
    }

    .status-box {
        background: rgba(20, 18, 43, 0.45) !important;
        backdrop-filter: blur(16px) saturate(120%) !important;
        -webkit-backdrop-filter: blur(16px) saturate(120%) !important;
        border: 1px solid rgba(255, 255, 255, 0.08) !important;
        padding: 20px;
        border-radius: 16px;
        display: flex;
        align-items: center;
        gap: 16px;
        text-align: left;
        transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2),
                    inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
        box-sizing: border-box;
    }

    .status-box:hover {
        transform: translateY(-3px);
        border-color: rgba(167, 139, 250, 0.3) !important;
        box-shadow: 0 12px 25px rgba(139, 92, 246, 0.15),
                    inset 0 1px 0 rgba(255, 255, 255, 0.15) !important;
    }

    .status-icon {
        font-size: 20px;
        display: flex;
        align-items: center;
        justify-content: center;
        width: 40px;
        height: 40px;
        border-radius: 10px;
        flex-shrink: 0;
        transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }

    .status-box:hover .status-icon {
        transform: scale(1.18) rotate(15deg);
    }

    .status-box.pending .status-icon {
        background: rgba(245, 158, 11, 0.1);
        color: #f59e0b;
        border: 1px solid rgba(245, 158, 11, 0.2);
    }

    .status-box.in-progress .status-icon {
        background: rgba(59, 130, 246, 0.1);
        color: #3b82f6;
        border: 1px solid rgba(59, 130, 246, 0.2);
    }

    .status-box.cancelled .status-icon {
        background: rgba(239, 68, 68, 0.1);
        color: #ef4444;
        border: 1px solid rgba(239, 68, 68, 0.2);
    }

    .status-box.completed .status-icon {
        background: rgba(16, 185, 129, 0.1);
        color: #10b981;
        border: 1px solid rgba(16, 185, 129, 0.2);
    }

    .status-details {
        display: flex;
        flex-direction: column;
    }

    .status-details h3 {
        margin: 0;
        font-size: 22px;
        font-weight: 800;
        line-height: 1.1;
    }

    .status-details p {
        margin: 2px 0 0 0;
        font-size: 11px;
        font-weight: 600;
        color: rgba(255, 255, 255, 0.4);
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .status-box.pending h3 { color: #f59e0b; }
    .status-box.in-progress h3 { color: #3b82f6; }
    .status-box.cancelled h3 { color: #ef4444; }
    .status-box.completed h3 { color: #10b981; }

    .dashboard-controls {
        margin-top: 2.5rem;
        margin-bottom: 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 16px;
        flex-wrap: wrap;
        background: rgba(20, 18, 43, 0.45) !important;
        backdrop-filter: blur(16px) saturate(120%) !important;
        -webkit-backdrop-filter: blur(16px) saturate(120%) !important;
        border: 1px solid rgba(255, 255, 255, 0.08) !important;
        border-radius: 16px;
        padding: 16px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2),
                    inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
    }
    .btn-add {
        background: linear-gradient(135deg, #8b5cf6, #6366f1);
        color: white !important;
        text-decoration: none;
        font-weight: 600;
        font-size: 14px;
        padding: 12px 24px;
        border-radius: 12px;
        box-shadow: 0 4px 15px rgba(139, 92, 246, 0.25);
        transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: none;
        cursor: pointer;
    }
    .btn-add:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(139, 92, 246, 0.4);
        background: linear-gradient(135deg, #a78bfa, #818cf8);
    }
    .search-form {
        display: flex;
        gap: 12px;
        flex-wrap: wrap;
        align-items: center;
    }
    .search-form input[type="text"],
    .search-form select {
        background: #1c1a38;
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 12px;
        color: white;
        padding: 10px 16px;
        font-family: inherit;
        font-size: 14px;
        outline: none;
        transition: all 0.3s ease;
    }
    .search-form input[type="text"]::placeholder {
        color: rgba(255, 255, 255, 0.3);
    }
    .search-form input[type="text"]:focus,
    .search-form select:focus {
        background: #252248;
        border-color: #a78bfa;
        box-shadow: 0 0 12px rgba(167, 139, 250, 0.25);
    }
    .search-form select option {
        background: #0e0c20;
        color: white;
    }
    .btn-search {
        background: rgba(255, 255, 255, 0.06);
        border: 1px solid rgba(255, 255, 255, 0.1);
        color: white;
        font-weight: 600;
        padding: 10px 20px;
        border-radius: 12px;
        cursor: pointer;
        transition: all 0.3s ease;
    }
    .btn-search:hover {
        background: rgba(255, 255, 255, 0.12);
        border-color: rgba(255, 255, 255, 0.2);
        transform: translateY(-1px);
    }

    table {
        margin-top: 15px;
        margin-bottom: 30px;
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
        background: rgba(20, 18, 43, 0.4) !important;
        backdrop-filter: blur(16px) saturate(110%) !important;
        -webkit-backdrop-filter: blur(16px) saturate(110%) !important;
        border: 1px solid rgba(255, 255, 255, 0.08) !important;
        border-radius: 16px;
        overflow: hidden;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3),
                    inset 0 1px 0 rgba(255, 255, 255, 0.08) !important;
    }
    th, td {
        padding: 16px 20px;
        text-align: left;
        border-bottom: 1px solid rgba(255, 255, 255, 0.06);
    }
    th {
        background: #1c1a38;
        color: #a5a1c9;
        font-weight: 700;
        font-size: 13px;
        text-transform: uppercase;
        letter-spacing: 1px;
        border-bottom: 1px solid rgba(255, 255, 255, 0.08);
    }
    tr {
        transition: all 0.3s ease;
    }
    tr:hover td {
        background: rgba(255, 255, 255, 0.01);
    }
    tr:last-child td {
        border-bottom: none;
    }
    td {
        color: #cbd5e1;
        font-size: 14px;
    }

    .status-label {
        display: inline-block;
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 600;
        letter-spacing: 0.5px;
        text-transform: uppercase;
        text-align: center;
        min-width: 90px;
        box-sizing: border-box;
    }
    .status-label.Pending {
        background: rgba(245, 158, 11, 0.1);
        color: #f59e0b;
        border: 1px solid rgba(245, 158, 11, 0.25);
        box-shadow: 0 0 10px rgba(245, 158, 11, 0.1);
    }
    .status-label.InProgress {
        background: rgba(59, 130, 246, 0.1);
        color: #3b82f6;
        border: 1px solid rgba(59, 130, 246, 0.25);
        box-shadow: 0 0 10px rgba(59, 130, 246, 0.1);
    }
    .status-label.Cancelled {
        background: rgba(239, 68, 68, 0.1);
        color: #ef4444;
        border: 1px solid rgba(239, 68, 68, 0.25);
        box-shadow: 0 0 10px rgba(239, 68, 68, 0.1);
    }
    .status-label.Completed {
        background: rgba(16, 185, 129, 0.1);
        color: #10b981;
        border: 1px solid rgba(16, 185, 129, 0.25);
        box-shadow: 0 0 10px rgba(16, 185, 129, 0.1);
    }

    .action-cell {
        display: flex;
        gap: 8px;
        align-items: center;
        justify-content: flex-start;
    }
    .action-cell form {
        margin: 0;
        display: inline-block;
    }

    .btn-action {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 6px 14px;
        border-radius: 8px;
        font-size: 13px;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        border: none;
        cursor: pointer;
    }
    .btn-action.manage {
        background: rgba(16, 185, 129, 0.1);
        color: #10b981;
        border: 1px solid rgba(16, 185, 129, 0.25);
    }
    .btn-action.manage:hover {
        background: #10b981;
        color: white;
        box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        transform: translateY(-1.5px);
    }
    .btn-action.delete {
        background: rgba(239, 68, 68, 0.1);
        color: #ef4444;
        border: 1px solid rgba(239, 68, 68, 0.25);
    }
    .btn-action.delete:hover {
        background: #ef4444;
        color: white;
        box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
        transform: translateY(-1.5px);
    }
    .btn-action.disabled {
        background: rgba(255, 255, 255, 0.03);
        color: rgba(255, 255, 255, 0.3);
        border: 1px solid rgba(255, 255, 255, 0.05);
        cursor: not-allowed;
    }
</style>

<div class="overview-grid">
    <!-- Left Column: Progress Card -->
    <div class="overview-left">
        <div class="summary-card">
            <h3>Overall Progress</h3>
            <%
                int progressPercent = totalTasks > 0 ? (completed * 100 / totalTasks) : 0;
                String fillGradient = (progressPercent == 100) ? "linear-gradient(90deg, #10b981, #34d399)" : "linear-gradient(90deg, #8b5cf6, #3b82f6)";
                String glowShadow = (progressPercent == 100) ? "0 0 12px rgba(16, 185, 129, 0.4)" : "0 0 12px rgba(139, 92, 246, 0.4)";
            %>
            <div class="progress-bar">
                <div class="progress-fill" style="width: <%= progressPercent %>%; background: <%= fillGradient %>; box-shadow: <%= glowShadow %>;"></div>
            </div>
            <p class="progress-desc"><strong><%= completed %> / <%= totalTasks %></strong> group tasks completed (<%= progressPercent %>%)</p>
        </div>
    </div>
    
    <!-- Right Column: Stats Mini Cards -->
    <div class="overview-right">
        <div class="stats-sidebar-grid">
            <div class="status-box pending">
                <div class="status-icon"><i class="bi bi-clock-history"></i></div>
                <div class="status-details">
                    <h3><%= pending %></h3>
                    <p>Pending</p>
                </div>
            </div>
            <div class="status-box in-progress">
                <div class="status-icon"><i class="bi bi-play-circle"></i></div>
                <div class="status-details">
                    <h3><%= inProgress %></h3>
                    <p>In Progress</p>
                </div>
            </div>
            <div class="status-box cancelled">
                <div class="status-icon"><i class="bi bi-x-circle"></i></div>
                <div class="status-details">
                    <h3><%= cancelled %></h3>
                    <p>Cancelled</p>
                </div>
            </div>
            <div class="status-box completed">
                <div class="status-icon"><i class="bi bi-check-circle-fill"></i></div>
                <div class="status-details">
                    <h3><%= completed %></h3>
                    <p>Completed</p>
                </div>
            </div>
        </div>
    </div>
</div>

<% if (totalTasks > 0) { %>
<!-- Task Filters and Table -->
<div class="dashboard-controls">
    <a href="addGroupTask.jsp" class="btn-add">Add Group Task</a>
    <form method="get" action="index.jsp" class="search-form">
        <input type="hidden" name="page" value="group">
        <input type="text" name="search" placeholder="Search tasks..." />
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
        <button type="submit" class="btn-search">Search</button>
    </form>
</div>

<h3 class="section-title">Created Groups Tasks</h3>
<table>
    <tr>
        <th style="width: 5%; text-align: center;">ID</th>
        <th style="width: 15%;">Group Name</th>
        <th style="width: 15%;">Subject</th>
        <th style="width: 25%;">Description</th>
        <th style="width: 8%; text-align: center;">Member</th>
        <th style="width: 10%;">Status</th>
        <th style="width: 9%;">Start Date</th>
        <th style="width: 9%;">Due Date</th>
        <th style="width: 10%;">Leader</th>
        <th style="width: 14%; text-align: center;">Action</th>
    </tr>
<%
    try {
        String sql = "SELECT tg.ID_task, g.Group_Name, tg.Subject, tg.Description, " +
                     "s.Name AS StatusName, tg.Start_Date, tg.Due_Date,u.Username, " +
                     "gm.Role, g.Group_ID, " +
                     "(SELECT COUNT(*) FROM group_members gm2 WHERE gm2.Group_ID = g.Group_ID) AS MemberCount " +
                     "FROM tasks_group tg " +
                     "JOIN status s ON tg.Status_ID = s.Status_ID " +
                     "JOIN `groups` g ON tg.Group_ID = g.Group_ID " +
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
        <td style="text-align: center; color: rgba(255,255,255,0.4);"><%= rs.getInt("ID_task") %></td>
        <td style="font-weight: 600;"><%= rs.getString("Group_Name") %></td>
        <td style="font-weight: 500;"><%= rs.getString("Subject") %></td>
        <td style="color: rgba(255, 255, 255, 0.65);"><%= rs.getString("Description") %></td>
        <td style="text-align: center; color: rgba(255,255,255,0.7);"><%= rs.getInt("MemberCount") %></td>
        <td><span class="status-label <%= statusName.replace(" ", "") %>"><%= statusName %></span></td>
        <td><%= rs.getDate("Start_Date") %></td>
        <td><%= rs.getDate("Due_Date") %></td>
        <td style="color: #c084fc;"><%= rs.getString("Username") %></td>
        <td style="text-align: center;">
            <div class="action-cell">
            <% if ("Leader".equalsIgnoreCase(role)) { %>
                <form method="get" action="memberManagement.jsp">
                    <input type="hidden" name="groupId" value="<%= rs.getInt("Group_ID") %>" />
                    <button type="submit" class="btn-action manage">Manage</button>
                </form>
                <form method="post" action="deleteGroupTask.jsp" onsubmit="return confirm('Are you sure you want to delete this group task?');">
                    <input type="hidden" name="taskId" value="<%= rs.getInt("ID_task") %>" />
                    <button type="submit" class="btn-action delete">Delete</button>
                </form>
            <% } else { %>
                <button class="btn-action disabled" disabled>View</button>
            <% } %>
            </div>
        </td>
    </tr>
<%
        }
    } catch (SQLException e) {
        out.println("<tr><td colspan='10' style='text-align: center; padding: 30px; color: #ef4444;'>Error loading tasks: " + e.getMessage() + "</td></tr>");
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
    }
%>
</table>

<h3 class="section-title">Joined Groups Tasks</h3>
<table>
    <tr>
        <th style="width: 5%; text-align: center;">ID</th>
        <th style="width: 15%;">Group Name</th>
        <th style="width: 15%;">Subject</th>
        <th style="width: 25%;">Description</th>
        <th style="width: 8%; text-align: center;">Member</th>
        <th style="width: 10%;">Status</th>
        <th style="width: 9%;">Start Date</th>
        <th style="width: 9%;">Due Date</th>
        <th style="width: 10%;">Leader</th>
        <th style="width: 14%; text-align: center;">Action</th>
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
             "JOIN `groups` g ON tg.Group_ID = g.Group_ID " +
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
        <td style="text-align: center; color: rgba(255,255,255,0.4);"><%= rs.getInt("ID_task") %></td>
        <td style="font-weight: 600;"><%= rs.getString("Group_Name") %></td>
        <td style="font-weight: 500;"><%= rs.getString("Subject") %></td>
        <td style="color: rgba(255, 255, 255, 0.65);"><%= rs.getString("Description") %></td>
        <td style="text-align: center; color: rgba(255,255,255,0.7);"><%= rs.getInt("MemberCount") %></td>
        <td><span class="status-label <%= statusName.replace(" ", "") %>"><%= statusName %></span></td>
        <td><%= rs.getDate("Start_Date") %></td>
        <td><%= rs.getDate("Due_Date") %></td>
        <td style="color: #c084fc;"><%= rs.getString("LeaderUsername") %></td>
        <td style="text-align: center;">
            <div class="action-cell">
            <% if ("Leader".equalsIgnoreCase(role)) { %>
                <form method="get" action="memberManagement.jsp">
                    <input type="hidden" name="groupId" value="<%= groupId %>" />
                    <button type="submit" class="btn-action manage">Manage</button>
                </form>
            <% } else { %>
                <button class="btn-action disabled" disabled>View</button>
            <% } %>
            </div>
        </td>
    </tr>
<%
        }
    } catch (SQLException e) {
        out.println("<tr><td colspan='10' style='text-align: center; padding: 30px; color: #ef4444;'>Error loading tasks: " + e.getMessage() + "</td></tr>");
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>
</table>
<% } else { %>
    <style>
        .empty-state-card {
            background: rgba(20, 18, 43, 0.45) !important;
            backdrop-filter: blur(16px) saturate(120%) !important;
            -webkit-backdrop-filter: blur(16px) saturate(120%) !important;
            border: 2px dashed rgba(167, 139, 250, 0.25) !important;
            border-radius: 20px;
            padding: 50px 40px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            margin-top: 40px;
            display: flex;
            flex-direction: column;
            align-items: center;
            animation: fadeInUp 0.7s cubic-bezier(0.16, 1, 0.3, 1) both;
        }
        .empty-state-card h4 {
            font-size: 18px;
            color: #fff;
            margin: 15px 0 8px 0;
            font-weight: 700;
            letter-spacing: -0.5px;
        }
        .empty-state-card p {
            color: rgba(203, 213, 225, 0.55);
            font-size: 14px;
            max-width: 380px;
            margin: 0 0 25px 0;
            line-height: 1.6;
        }
    </style>

    <div class="empty-state-card">
        <!-- Glowing Sweeping Tech Radar SVG -->
        <svg viewBox="0 0 100 100" width="85" height="85" style="margin-bottom: 10px; filter: drop-shadow(0 0 12px rgba(167,139,250,0.45));">
            <!-- Circular sweeps -->
            <circle cx="50" cy="50" r="45" fill="none" stroke="#8b5cf6" stroke-width="1" stroke-dasharray="6 4" opacity="0.4"/>
            <circle cx="50" cy="50" r="30" fill="none" stroke="#22d3ee" stroke-width="0.8" stroke-dasharray="10 5" opacity="0.6"/>
            <circle cx="50" cy="50" r="15" fill="none" stroke="#a78bfa" stroke-width="0.8" opacity="0.7"/>
            <!-- Radar crosshairs -->
            <line x1="50" y1="5" x2="50" y2="95" stroke="#8b5cf6" stroke-width="0.7" opacity="0.3" stroke-dasharray="4 4"/>
            <line x1="5" y1="50" x2="95" y2="50" stroke="#8b5cf6" stroke-width="0.7" opacity="0.3" stroke-dasharray="4 4"/>
            <!-- Radar sweeping line -->
            <line x1="50" y1="50" x2="78" y2="22" stroke="#22d3ee" stroke-width="1.5" stroke-linecap="round">
                <animateTransform attributeName="transform" type="rotate" from="0 50 50" to="360 50 50" dur="4s" repeatCount="indefinite"/>
            </line>
            <!-- Center glowing point -->
            <circle cx="50" cy="50" r="4" fill="#a78bfa">
                <animate attributeName="opacity" values="0.4;1;0.4" dur="2s" repeatCount="indefinite"/>
            </circle>
        </svg>

        <h4>Radar Active: "Group Workstation Quiet!"</h4>
        <p>No active group tasks currently. Let's create your first group task with your team!</p>
        <a href="addGroupTask.jsp" class="btn-add">Add Group Task</a>
    </div>
<% } %>
