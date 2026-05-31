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
            try {
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
            } catch (NumberFormatException e) {
                message = "Please select a valid group and status, and fill out all fields.";
            }
        }

        // Ambil daftar grup user
        String sqlGroups = "SELECT g.Group_ID, g.Group_Name FROM `groups` g JOIN group_members gm ON g.Group_ID = gm.Group_ID WHERE gm.User_ID = ?";
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
            width: 100%;
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
            text-decoration: none;
        }

        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.12) !important;
            border-color: rgba(255, 255, 255, 0.15) !important;
            transform: translateY(-1px) !important;
        }

        /* Alert Styling */
        .alert {
            background: rgba(255, 255, 255, 0.02) !important;
            backdrop-filter: blur(20px) !important;
            border-radius: 14px !important;
            color: white !important;
            border: 1px solid rgba(255, 255, 255, 0.05) !important;
            padding: 16px 20px !important;
            z-index: 20;
            position: relative;
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

    <div class="container">
        <div class="row">
            <div class="col">
                <a href="index.jsp?page=group" class="btn-secondary">
                    <i class="bi bi-arrow-left"></i> Back to Group Tasks
                </a>
                <div class="d-block mb-3">
                    <h2>Add Group Task</h2>
                </div>
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

                <button type="submit" class="btn-primary">
                    <i class="bi bi-save"></i> Add Group Task
                </button>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<%
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p style='color:red; text-align:center;'>Error: " + e.getMessage() + "</p>");
    } finally {
        if (rsGroups != null) try { rsGroups.close(); } catch (Exception ignored) {}
        if (rsStatus != null) try { rsStatus.close(); } catch (Exception ignored) {}
        if (statusStmt != null) try { statusStmt.close(); } catch (Exception ignored) {}
        if (stmt != null) try { stmt.close(); } catch (Exception ignored) {}
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }
%>
