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
             "JOIN `groups` g ON gm.Group_ID = g.Group_ID " +
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
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap');
        
        body {
            margin: 0;
            font-family: 'Outfit', sans-serif;
            background-color: #080614;
            color: #e2e8f0;
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
            padding: 40px;
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

        .container-fluid {
            z-index: 10;
            position: relative;
            max-width: 1200px;
            margin: 0 auto;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            margin-bottom: 24px;
        }

        .page-title {
            font-size: 32px;
            font-weight: 800;
            margin: 0;
            background: linear-gradient(135deg, #fff 40%, rgba(255, 255, 255, 0.7));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: -0.5px;
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
            display: inline-flex !important;
            align-items: center !important;
            gap: 8px !important;
            text-decoration: none;
        }

        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.12) !important;
            border-color: rgba(255, 255, 255, 0.15) !important;
            transform: translateY(-1px) !important;
        }

        table {
            margin-top: 1.5rem;
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            background: #14122b;
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
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
            background: rgba(139, 92, 246, 0.1);
            color: #a78bfa;
            border: 1px solid rgba(139, 92, 246, 0.25);
        }
        .btn-action:hover {
            background: #8b5cf6;
            color: white;
            box-shadow: 0 4px 12px rgba(139, 92, 246, 0.3);
            transform: translateY(-1.5px);
        }

        .status-badge {
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
        .status-todo {
            background: rgba(245, 158, 11, 0.1) !important;
            color: #f59e0b !important;
            border: 1px solid rgba(245, 158, 11, 0.25) !important;
            box-shadow: 0 0 10px rgba(245, 158, 11, 0.1);
        }
        .status-inprogress {
            background: rgba(59, 130, 246, 0.1) !important;
            color: #3b82f6 !important;
            border: 1px solid rgba(59, 130, 246, 0.25) !important;
            box-shadow: 0 0 10px rgba(59, 130, 246, 0.1);
        }
        .status-done {
            background: rgba(16, 185, 129, 0.1) !important;
            color: #10b981 !important;
            border: 1px solid rgba(16, 185, 129, 0.25) !important;
            box-shadow: 0 0 10px rgba(16, 185, 129, 0.1);
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

    <div class="container-fluid">
        <div class="page-header">
            <h2 class="page-title">Manage Group Members</h2>
            <a href="index.jsp?page=group" class="btn btn-secondary">
                <i class="bi bi-arrow-left"></i> Back to Group Tasks
            </a>
        </div>

        <table>
            <tr>
                <th style="width: 5%; text-align: center;">ID</th>
                <th style="width: 12%;">Username</th>
                <th style="width: 10%;">Role</th>
                <th style="width: 12%; text-align: center;">Action</th>
                <th style="width: 12%;">Group Name</th>
                <th style="width: 12%;">Subject</th>
                <th style="width: 17%;">Description</th>
                <th style="width: 10%;">Status</th>
                <th style="width: 10%;">Start Date</th>
                <th style="width: 10%;">Due Date</th>
            </tr>

    <%
            boolean hasMember = false;
            while (rs.next()) {
                hasMember = true;
    %>
            <tr>
                <td style="text-align: center; color: rgba(255,255,255,0.4);"><%= rs.getInt("User_ID") %></td>
                <td style="font-weight: 600;"><%= rs.getString("Username") %></td>
                <td style="color: #c084fc;"><%= rs.getString("Role") %></td>
                <td style="text-align: center;">
                    <!-- Edit Task Form -->
                    <form action="editGroupTask.jsp" method="get" style="display:inline-block; margin: 0;">
                        <input type="hidden" name="groupId" value="<%= rs.getInt("Group_ID") %>">
                        <input type="hidden" name="subject" value="<%= rs.getString("Subject") %>">
                        <input type="hidden" name="description" value="<%= rs.getString("Description") %>">
                        <input type="hidden" name="status" value="<%= rs.getString("StatusName") %>">
                        <button type="submit" class="btn-action">Edit Task</button>
                    </form>
                </td>
                <td style="font-weight: 500;"><%= rs.getString("Group_Name") %></td>
                <td><%= rs.getString("Subject") %></td>
                <td style="color: rgba(255, 255, 255, 0.65);"><%= rs.getString("Description") %></td>
                <td>
                    <%
                        String status = rs.getString("StatusName");
                        String statusClass = "status-badge ";
                        if ("To Do".equalsIgnoreCase(status) || "Pending".equalsIgnoreCase(status)) {
                            statusClass += "status-todo";
                        } else if ("In Progress".equalsIgnoreCase(status)) {
                            statusClass += "status-inprogress";
                        } else if ("Done".equalsIgnoreCase(status) || "Completed".equalsIgnoreCase(status)) {
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
                <td colspan="10" style="text-align: center; padding: 30px; color: rgba(255, 255, 255, 0.45);">No members found in this group.</td>
            </tr>
    <%
            }

            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            out.println("<tr><td colspan='10' style='text-align: center; padding: 30px; color: #ef4444;'>Error loading tasks: " + e.getMessage() + "</td></tr>");
            e.printStackTrace();
        }
    %>
        </table>
    </div>
</body>
</html>
