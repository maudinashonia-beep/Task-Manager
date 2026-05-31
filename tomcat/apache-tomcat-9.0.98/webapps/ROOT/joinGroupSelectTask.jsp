<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="DBConnection.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Ensure safety
    Object groupIdAttr = request.getAttribute("groupId");
    Object groupNameAttr = request.getAttribute("groupName");
    Object descriptionAttr = request.getAttribute("description");

    if (groupIdAttr == null || groupNameAttr == null) {
        response.sendRedirect("index.jsp?error=Invalid+group+join+request");
        return;
    }

    int groupId = (Integer) groupIdAttr;
    String groupName = (String) groupNameAttr;
    String description = descriptionAttr != null ? (String) descriptionAttr : "";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>Join Group - Select Task</title>
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
            background: #14122b !important;
            border: 1px solid rgba(255, 255, 255, 0.08) !important;
            border-radius: 24px !important;
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.6) !important;
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

        .form-select {
            background: #1c1a38 !important;
            border: 1px solid rgba(255, 255, 255, 0.08) !important;
            border-radius: 14px !important;
            color: white !important;
            padding: 12px 16px !important;
            font-size: 15px !important;
            transition: all 0.3s ease !important;
        }

        .form-select:focus {
            background: #252248 !important;
            border-color: #a78bfa !important;
            outline: none !important;
            box-shadow: 0 0 15px rgba(167, 139, 250, 0.25) !important;
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
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
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

        .group-desc {
            color: rgba(255, 255, 255, 0.5);
            font-size: 15px;
            line-height: 1.6;
            margin-bottom: 20px;
            background: rgba(255, 255, 255, 0.02);
            padding: 15px;
            border-radius: 12px;
            border: 1px solid rgba(255, 255, 255, 0.05);
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

    <div class="container">
        <div class="row">
            <div class="col">
                <a href="index.jsp?page=group" class="btn-secondary">
                    <i class="bi bi-arrow-left"></i> Cancel & Back
                </a>
                <div class="d-block mb-3">
                    <h2>Join Group: <%= groupName %></h2>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-body">
                <% if (!description.trim().isEmpty()) { %>
                    <div class="group-desc">
                        <strong class="text-white d-block mb-1">Group Description:</strong>
                        <%= description %>
                    </div>
                <% } %>

                <form action="FinalizeJoinServlet" method="post">
                    <input type="hidden" name="group_id" value="<%= groupId %>">
                    <input type="hidden" name="group_name" value="<%= groupName %>">
                    <input type="hidden" name="description" value="<%= description %>">

                    <div class="mb-4">
                        <label for="task_id" class="form-label">Select Task to Join</label>
                        <select id="task_id" name="task_id" class="form-select" required>
                            <option value="" disabled selected>Choose a task description...</option>
                            <%
                                PreparedStatement stmt = null;
                                ResultSet rs = null;
                                boolean hasTasks = false;

                                try {
                                    String sql = "SELECT tg.ID_task, tg.Description FROM tasks_group tg " +
                                                 "WHERE tg.Group_ID = ? AND tg.ID_task NOT IN (" +
                                                 "SELECT Task_ID FROM group_members WHERE Group_ID = ? AND Task_ID IS NOT NULL)";
                                    stmt = conn.prepareStatement(sql);
                                    stmt.setInt(1, groupId);
                                    stmt.setInt(2, groupId);
                                    rs = stmt.executeQuery();

                                    while (rs.next()) {
                                        hasTasks = true;
                                        int taskId = rs.getInt("ID_task");
                                        String taskDesc = rs.getString("Description");
                            %>
                                        <option value="<%= taskId %>"><%= taskDesc %></option>
                            <%
                                    }
                                    
                                    if (!hasTasks) {
                            %>
                                        <option value="" disabled>No available tasks to join in this group</option>
                            <%
                                    }

                                } catch (Exception e) {
                                    e.printStackTrace();
                            %>
                                    <option value="" disabled>Error loading tasks</option>
                            <%
                                } finally {
                                    if (rs != null) try { rs.close(); } catch (Exception e) {}
                                    if (stmt != null) try { stmt.close(); } catch (Exception e) {}
                                    if (conn != null) try { conn.close(); } catch (Exception e) {}
                                }
                            %>
                        </select>
                    </div>

                    <button type="submit" class="btn-primary" <%= !hasTasks ? "disabled" : "" %>>
                        <i class="bi bi-person-plus-fill"></i> Join Task
                    </button>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
