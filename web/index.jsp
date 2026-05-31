<%@ page import="java.sql.*" %>
    <%@ include file="DBConnection.jsp" %>
        <% String username=(String) session.getAttribute("username"); String email=(String)
            session.getAttribute("email"); Integer userID=(Integer) session.getAttribute("userID"); if (username==null
            || userID==null) { response.sendRedirect("login.jsp"); return; } String
            currentPage=request.getParameter("page"); int totalIndividualTasks=0; int totalGroupTasks=0;
            PreparedStatement stmt=null; ResultSet rs=null; try { String
            sql1="SELECT COUNT(*) FROM tasks WHERE User_ID = ?" ; stmt=conn.prepareStatement(sql1); stmt.setInt(1,
            userID); rs=stmt.executeQuery(); if (rs.next()) totalIndividualTasks=rs.getInt(1); rs.close(); stmt.close();
            String
            sql2="SELECT COUNT(*) FROM tasks_group g INNER JOIN group_members gm ON g.Group_ID = gm.Group_ID WHERE gm.User_ID = ?"
            ; stmt=conn.prepareStatement(sql2); stmt.setInt(1, userID); rs=stmt.executeQuery(); if (rs.next())
            totalGroupTasks=rs.getInt(1); } catch (Exception e) { e.printStackTrace(); } finally { if (rs !=null) try {
            rs.close(); } catch (Exception e) {} if (stmt !=null) try { stmt.close(); } catch (Exception e) {} if (conn
            !=null) try { conn.close(); } catch (Exception e) {} } %>

            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <title>Task Manager - Dashboard</title>
                <link rel="stylesheet"
                    href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
                <style>
                    @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap');

                    body {
                        margin: 0;
                        font-family: 'Outfit', sans-serif;
                        background-color: #080614;
                        display: flex;
                        height: 100vh;
                        overflow: hidden;
                        color: #cbd5e1;
                        position: relative;
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
                        position: absolute;
                        top: 0;
                        left: 0;
                        width: 100%;
                        height: 100%;
                        z-index: 0;
                        overflow: hidden;
                        pointer-events: none;
                    }

                    .glow-1,
                    .glow-2,
                    .glow-3 {
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
                        0% {
                            transform: translate(0, 0) scale(1) rotate(0deg);
                        }

                        50% {
                            transform: translate(4vw, 5vh) scale(1.1) rotate(180deg);
                        }

                        100% {
                            transform: translate(-2vw, -4vh) scale(0.95) rotate(360deg);
                        }
                    }

                    /* Sidebar Solid Premium Styling */
                    .sidebar {
                        background: #0e0c20;
                        border-right: 1px solid rgba(255, 255, 255, 0.08);
                        width: 260px;
                        display: flex;
                        flex-direction: column;
                        justify-content: space-between;
                        padding: 30px 20px;
                        box-sizing: border-box;
                        z-index: 10;
                        box-shadow: 4px 0 25px rgba(0, 0, 0, 0.3);
                    }

                    .sidebar-brand h1 {
                        font-size: 24px;
                        font-weight: 800;
                        margin: 0 0 40px 0;
                        background: linear-gradient(135deg, #a78bfa, #c084fc, #818cf8);
                        -webkit-background-clip: text;
                        -webkit-text-fill-color: transparent;
                        letter-spacing: 1.5px;
                        text-align: center;
                        filter: drop-shadow(0 0 15px rgba(167, 139, 250, 0.2));
                    }

                    .sidebar nav {
                        display: flex;
                        flex-direction: column;
                        gap: 12px;
                        flex: 1;
                    }

                    .sidebar a {
                        color: rgba(255, 255, 255, 0.55);
                        text-decoration: none;
                        font-weight: 500;
                        font-size: 15px;
                        padding: 14px 18px;
                        border-radius: 12px;
                        display: flex;
                        align-items: center;
                        transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
                        border-left: 3px solid transparent;
                        background: transparent;
                    }

                    .sidebar a:hover {
                        color: #fff;
                        background: rgba(255, 255, 255, 0.03);
                        transform: translateX(4px);
                    }

                    .sidebar a.active {
                        color: #a78bfa;
                        background: linear-gradient(135deg, rgba(139, 92, 246, 0.12), rgba(99, 102, 241, 0.12));
                        border-left: 3px solid #8b5cf6;
                        font-weight: 600;
                        text-shadow: 0 0 10px rgba(167, 139, 250, 0.3);
                    }

                    .sidebar .profile {
                        background: rgba(20, 18, 43, 0.45) !important;
                        backdrop-filter: blur(8px) saturate(110%) !important;
                        -webkit-backdrop-filter: blur(8px) saturate(110%) !important;
                        border: 1px solid rgba(255, 255, 255, 0.08);
                        padding: 16px;
                        border-radius: 16px;
                        font-size: 14px;
                        margin-bottom: 12px;
                        box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.06);
                    }

                    .sidebar .profile strong {
                        color: #fff;
                        font-size: 15px;
                        display: block;
                        margin-bottom: 4px;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        white-space: nowrap;
                    }

                    .sidebar .profile span {
                        color: rgba(255, 255, 255, 0.45);
                        font-size: 12px;
                        display: block;
                        word-break: break-all;
                    }

                    .sidebar .logout {
                        background: rgba(239, 68, 68, 0.08);
                        border: 1px solid rgba(239, 68, 68, 0.15);
                        text-align: center;
                        padding: 12px;
                        border-radius: 12px;
                        text-decoration: none;
                        display: block;
                        color: #fca5a5;
                        font-weight: 600;
                        transition: all 0.3s ease;
                        border-left: none;
                    }

                    .sidebar .logout:hover {
                        background: #ef4444;
                        color: white;
                        transform: translateY(-2px);
                        box-shadow: 0 8px 20px rgba(239, 68, 68, 0.3);
                    }

                    /* Main Workspace Solid Contrast styling */
                    .main {
                        flex: 1;
                        padding: 40px 60px;
                        overflow-y: auto;
                        z-index: 10;
                        box-sizing: border-box;
                        background: #080614;
                    }

                    /* Smooth Entry Fade-In-Up Animation */
                    .main>* {
                        animation: fadeInUp 0.7s cubic-bezier(0.16, 1, 0.3, 1) both;
                    }

                    @keyframes fadeInUp {
                        from {
                            opacity: 0;
                            transform: translateY(20px);
                        }

                        to {
                            opacity: 1;
                            transform: translateY(0);
                        }
                    }

                    .home-container {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        gap: 40px;
                        margin-bottom: 40px;
                        flex-wrap: wrap;
                    }

                    .welcome-panel {
                        flex: 1.2;
                        min-width: 300px;
                        margin-bottom: 0px !important;
                    }

                    .welcome-panel h2 {
                        font-size: 16px;
                        font-weight: 600;
                        color: rgba(255, 255, 255, 0.45);
                        letter-spacing: 3px;
                        margin: 0 0 8px 0;
                        text-transform: uppercase;
                    }

                    .welcome-panel h1 {
                        font-size: 42px;
                        font-weight: 800;
                        margin: 0;
                        background: linear-gradient(135deg, #fff 30%, rgba(255, 255, 255, 0.7));
                        -webkit-background-clip: text;
                        -webkit-text-fill-color: transparent;
                    }

                    .welcome-panel h3 {
                        font-size: 32px;
                        font-weight: 700;
                        margin: 8px 0 0 0;
                        color: #a78bfa;
                        text-shadow: 0 0 20px rgba(167, 139, 250, 0.25);
                    }

                    /* 3D CSS Holographic Widget */
                    .hologram-widget {
                        flex: 0.8;
                        min-width: 250px;
                        height: 220px;
                        position: relative;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        perspective: 1000px;
                        z-index: 2;
                    }

                    .hologram-sphere {
                        width: 100px;
                        height: 100px;
                        background: radial-gradient(circle at 30% 30%, #a78bfa 0%, #8b5cf6 30%, #3b82f6 70%, transparent 100%);
                        border-radius: 50%;
                        box-shadow: 0 0 45px rgba(139, 92, 246, 0.5),
                            inset -10px -10px 30px rgba(0, 0, 0, 0.8),
                            inset 10px 10px 25px rgba(255, 255, 255, 0.35);
                        position: relative;
                        animation: floatSph 6s infinite ease-in-out;
                        z-index: 3;
                    }

                    .hologram-ring-1,
                    .hologram-ring-2,
                    .hologram-ring-3 {
                        position: absolute;
                        border: 2px dashed rgba(167, 139, 250, 0.35);
                        border-radius: 50%;
                        pointer-events: none;
                    }

                    .hologram-ring-1 {
                        width: 160px;
                        height: 160px;
                        transform: rotateX(70deg) rotateY(15deg);
                        box-shadow: 0 0 15px rgba(167, 139, 250, 0.1);
                        animation: rotRing1 10s infinite linear;
                    }

                    .hologram-ring-2 {
                        width: 210px;
                        height: 210px;
                        transform: rotateX(60deg) rotateY(-25deg);
                        border-color: rgba(99, 102, 241, 0.35);
                        box-shadow: 0 0 20px rgba(99, 102, 241, 0.1);
                        animation: rotRing2 14s infinite linear;
                    }

                    .hologram-ring-3 {
                        width: 120px;
                        height: 120px;
                        transform: rotateX(80deg) rotateY(35deg);
                        border-color: rgba(236, 72, 153, 0.35);
                        box-shadow: 0 0 10px rgba(236, 72, 153, 0.1);
                        animation: rotRing3 7s infinite linear;
                    }

                    @keyframes floatSph {
                        0% {
                            transform: translateY(0px) rotate(0deg) scale(1);
                        }

                        50% {
                            transform: translateY(-16px) rotate(180deg) scale(1.04);
                        }

                        100% {
                            transform: translateY(0px) rotate(360deg) scale(1);
                        }
                    }

                    @keyframes rotRing1 {
                        from {
                            transform: rotateX(70deg) rotateY(15deg) rotateZ(0deg);
                        }

                        to {
                            transform: rotateX(70deg) rotateY(15deg) rotateZ(360deg);
                        }
                    }

                    @keyframes rotRing2 {
                        from {
                            transform: rotateX(60deg) rotateY(-25deg) rotateZ(360deg);
                        }

                        to {
                            transform: rotateX(60deg) rotateY(-25deg) rotateZ(0deg);
                        }
                    }

                    @keyframes rotRing3 {
                        from {
                            transform: rotateX(80deg) rotateY(35deg) rotateZ(0deg);
                        }

                        to {
                            transform: rotateX(80deg) rotateY(35deg) rotateZ(360deg);
                        }
                    }

                    /* Dashboard Stats Cards */
                    .task-box {
                        display: flex;
                        gap: 24px;
                        margin-top: 30px;
                        flex-wrap: wrap;
                    }

                    .status-box {
                        background: rgba(20, 18, 43, 0.45) !important;
                        backdrop-filter: blur(16px) saturate(120%) !important;
                        -webkit-backdrop-filter: blur(16px) saturate(120%) !important;
                        border: 1px solid rgba(255, 255, 255, 0.08) !important;
                        padding: 30px;
                        border-radius: 20px;
                        text-align: center;
                        flex: 1;
                        min-width: 250px;
                        box-sizing: border-box;
                        transition: transform 0.4s cubic-bezier(0.165, 0.84, 0.44, 1),
                            box-shadow 0.4s cubic-bezier(0.165, 0.84, 0.44, 1),
                            border-color 0.4s ease;
                        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3),
                            inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
                    }

                    .status-box:hover {
                        transform: translateY(-5px);
                        box-shadow: 0 20px 45px rgba(139, 92, 246, 0.15),
                            inset 0 1px 0 rgba(255, 255, 255, 0.15) !important;
                        border-color: rgba(167, 139, 250, 0.25) !important;
                    }

                    .status-box h3 {
                        margin: 0 0 15px 0;
                        font-size: 20px;
                        color: rgba(255, 255, 255, 0.85);
                        font-weight: 600;
                    }

                    .no-task {
                        margin: 0;
                        font-size: 36px;
                        font-weight: 800;
                        background: linear-gradient(135deg, #a78bfa, #818cf8);
                        -webkit-background-clip: text;
                        -webkit-text-fill-color: transparent;
                    }

                    .group-buttons {
                        display: flex;
                        gap: 12px;
                        justify-content: center;
                        margin-top: 5px;
                    }

                    .group-buttons a {
                        flex: 1;
                        padding: 12px 18px;
                        background: linear-gradient(135deg, #8b5cf6, #6366f1);
                        color: white;
                        text-decoration: none;
                        border-radius: 12px;
                        font-weight: 600;
                        font-size: 14px;
                        box-shadow: 0 4px 15px rgba(139, 92, 246, 0.2);
                        transition: all 0.3s ease;
                        box-sizing: border-box;
                    }

                    .group-buttons a:hover {
                        background: linear-gradient(135deg, #a78bfa, #818cf8);
                        transform: translateY(-2px);
                        box-shadow: 0 8px 25px rgba(139, 92, 246, 0.4);
                    }

                    /* Solid Contrast Modals */
                    .modal {
                        display: none;
                        position: fixed;
                        z-index: 100;
                        left: 0;
                        top: 0;
                        width: 100%;
                        height: 100%;
                        background-color: rgba(6, 4, 14, 0.8);
                        backdrop-filter: blur(10px);
                        -webkit-backdrop-filter: blur(10px);
                    }

                    .modal-content {
                        background: rgba(20, 18, 43, 0.6) !important;
                        backdrop-filter: blur(20px) saturate(120%) !important;
                        -webkit-backdrop-filter: blur(20px) saturate(120%) !important;
                        border: 1px solid rgba(255, 255, 255, 0.08) !important;
                        margin: 12% auto;
                        padding: 40px;
                        width: 90%;
                        max-width: 420px;
                        border-radius: 24px;
                        position: relative;
                        box-shadow: 0 30px 60px rgba(0, 0, 0, 0.5),
                            inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
                        box-sizing: border-box;
                        animation: modalFade 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);
                    }

                    @keyframes modalFade {
                        from {
                            opacity: 0;
                            transform: translateY(-20px);
                        }

                        to {
                            opacity: 1;
                            transform: translateY(0);
                        }
                    }

                    .modal-content h2 {
                        margin-top: 0;
                        margin-bottom: 25px;
                        color: #fff;
                        text-align: center;
                        font-size: 24px;
                        font-weight: 700;
                        letter-spacing: 0.5px;
                    }

                    .modal-content input[type="text"],
                    .modal-content input[type="number"],
                    .modal-content input[type="submit"] {
                        width: 100%;
                        margin: 8px 0 16px 0;
                        padding: 14px 16px;
                        border-radius: 12px;
                        border: 1px solid rgba(255, 255, 255, 0.08);
                        background: #1c1a38;
                        color: white;
                        box-sizing: border-box;
                        font-size: 15px;
                        font-family: inherit;
                        transition: all 0.3s ease;
                    }

                    .modal-content input[type="text"]::placeholder,
                    .modal-content input[type="number"]::placeholder {
                        color: rgba(255, 255, 255, 0.3);
                    }

                    .modal-content input[type="text"]:focus,
                    .modal-content input[type="number"]:focus {
                        background: #252248;
                        border-color: #a78bfa;
                        outline: none;
                        box-shadow: 0 0 15px rgba(167, 139, 250, 0.25);
                    }

                    .modal-content input[type="submit"] {
                        background: linear-gradient(135deg, #8b5cf6, #6366f1);
                        color: white;
                        border: none;
                        font-weight: 600;
                        cursor: pointer;
                        box-shadow: 0 6px 20px rgba(139, 92, 246, 0.25);
                        margin-top: 10px;
                        margin-bottom: 0;
                    }

                    .modal-content input[type="submit"]:hover {
                        background: linear-gradient(135deg, #a78bfa, #818cf8);
                        transform: translateY(-2px);
                        box-shadow: 0 8px 25px rgba(139, 92, 246, 0.4);
                    }

                    .close {
                        position: absolute;
                        right: 20px;
                        top: 15px;
                        cursor: pointer;
                        font-size: 24px;
                        color: rgba(255, 255, 255, 0.4);
                        transition: color 0.3s ease;
                    }

                    .close:hover {
                        color: #fff;
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

                    <!-- Sidebar Brand & Navigation -->
                    <div class="sidebar">
                        <div>
                            <div class="sidebar-brand">
                                <h1>TASK MANAGER</h1>
                            </div>
                            <nav>
                                <a href="index.jsp" class="<%= (currentPage == null) ? " active" : "" %>">Home</a>
                                <a href="index.jsp?page=individual" class="<%= " individual".equals(currentPage)
                                    ? "active" : "" %>">Your Tasks</a>
                                <a href="index.jsp?page=group" class="<%= " group".equals(currentPage) ? "active" : ""
                                    %>">Group Tasks</a>
                            </nav>
                        </div>
                        <div>
                            <div class="profile">
                                <strong>
                                    <%= username %>
                                </strong>
                                <span>
                                    <%= email !=null ? email : "" %>
                                </span>
                            </div>
                            <a class="logout" href="logout.jsp">LOGOUT</a>
                        </div>
                    </div>

                    <!-- Main Workspace -->
                    <div class="main">
                        <%-- Logika tampil halaman --%>
                            <% if ("individual".equals(currentPage)) { %>
                                <jsp:include page="individualDashboard.jsp" />
                                <% } else if ("group".equals(currentPage)) { %>
                                    <jsp:include page="groupDashboard.jsp" />
                                    <% } else { %>
                                        <div class="home-container">
                                            <div class="welcome-panel">
                                                <h2>WELCOME TO</h2>
                                                <h1>TASK MANAGER,</h1>
                                                <h3>
                                                    <%= username %>!
                                                </h3>
                                                <p
                                                    style="color: rgba(255, 255, 255, 0.45); font-size: 15px; margin-top: 15px; line-height: 1.6; font-weight: 500;">
                                                    Cybernetic system active. Orbiting in full productivity mode to
                                                    track all your missions :D
                                                </p>
                                            </div>

                                            <!-- 3D CSS Holographic command center projecting the abstract glowing tech sphere -->
                                            <div class="hologram-widget">
                                                <div class="hologram-sphere"
                                                    style="display: flex; align-items: center; justify-content: center;">
                                                    <!-- Custom vector wireframe tech star inside the sphere to make it look extremely premium! -->
                                                    <svg viewBox="0 0 100 100" width="55" height="55"
                                                        style="animation: spinRing 12s infinite linear; filter: drop-shadow(0 0 12px #c084fc);">
                                                        <path
                                                            d="M50 5 L60 40 L95 50 L60 60 L50 95 L40 60 L5 50 L40 40 Z"
                                                            fill="none" stroke="rgba(255,255,255,0.85)"
                                                            stroke-width="2" />
                                                        <circle cx="50" cy="50" r="14" fill="none" stroke="white"
                                                            stroke-width="1.5" stroke-dasharray="4 2" />
                                                        <circle cx="50" cy="50" r="4" fill="#22d3ee" />
                                                    </svg>
                                                </div>
                                                <div class="hologram-ring-1"></div>
                                                <div class="hologram-ring-2"></div>
                                                <div class="hologram-ring-3"></div>
                                            </div>
                                        </div>

                                        <div class="task-box">
                                            <div class="status-box">
                                                <h3>Individual Tasks</h3>
                                                <p class="no-task">
                                                    <%= totalIndividualTasks %> tasks
                                                </p>
                                            </div>
                                            <div class="status-box">
                                                <h3>Group Tasks</h3>
                                                <div class="group-buttons">
                                                    <a href="#" id="createGroupBtn">Create Group</a>
                                                    <a href="#" id="joinGroupBtn">Join Group</a>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- CREATE GROUP MODAL -->
                                        <div id="createGroupModal" class="modal">
                                            <div class="modal-content">
                                                <span class="close" id="closeCreateModal">&times;</span>
                                                <h2>Create Group</h2>
                                                <form action="CreateGroupServlet" method="post">
                                                    <input type="text" name="group_name" placeholder="Enter Group Name"
                                                        required>
                                                    <input type="text" name="description"
                                                        placeholder="Enter Group Description" required>
                                                    <input type="number" name="member_limit"
                                                        placeholder="Enter Member Limit" min="1" max="100" value="5"
                                                        required>
                                                    <input type="submit" value="Create">
                                                </form>
                                            </div>
                                        </div>

                                        <!-- JOIN GROUP MODAL -->
                                        <div id="joinGroupModal" class="modal">
                                            <div class="modal-content">
                                                <span class="close" id="closeJoinModal">&times;</span>
                                                <h2>Join Group</h2>
                                                <form action="JoinGroupServlet" method="post">
                                                    <input type="text" name="group_name" placeholder="Enter Group Name"
                                                        required>
                                                    <input type="text" name="description"
                                                        placeholder="Enter Group Description" required>
                                                    <input type="submit" value="Join">
                                                </form>
                                            </div>
                                        </div>

                                        <script>
                                            const createBtn = document.getElementById('createGroupBtn');
                                            const joinBtn = document.getElementById('joinGroupBtn');
                                            const createModal = document.getElementById('createGroupModal');
                                            const joinModal = document.getElementById('joinGroupModal');
                                            const closeCreateModal = document.getElementById('closeCreateModal');
                                            const closeJoinModal = document.getElementById('closeJoinModal');

                                            createBtn.onclick = () => createModal.style.display = 'block';
                                            joinBtn.onclick = () => joinModal.style.display = 'block';

                                            closeCreateModal.onclick = () => createModal.style.display = 'none';
                                            closeJoinModal.onclick = () => joinModal.style.display = 'none';

                                            window.onclick = function (event) {
                                                if (event.target === createModal) createModal.style.display = 'none';
                                                if (event.target === joinModal) joinModal.style.display = 'none';
                                            };
                                        </script>
                                        <% } %>
                    </div>
            </body>

            </html>