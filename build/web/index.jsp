<%@ page import="java.sql.*" %>
<%@ include file="DBConnection.jsp" %>
<%
    String username = (String) session.getAttribute("username");
    String email = (String) session.getAttribute("email");
    Integer userID = (Integer) session.getAttribute("userID");

    if (username == null || userID == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String currentPage = request.getParameter("page");

    int totalIndividualTasks = 0;
    int totalGroupTasks = 0;
    
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        String sql1 = "SELECT COUNT(*) FROM tasks WHERE User_ID = ?";
        stmt = conn.prepareStatement(sql1);
        stmt.setInt(1, userID);
        rs = stmt.executeQuery();
        if (rs.next()) totalIndividualTasks = rs.getInt(1);
        rs.close();
        stmt.close();

        String sql2 = "SELECT COUNT(*) FROM group_tasks g INNER JOIN group_members gm ON g.Group_ID = gm.Group_ID WHERE gm.User_ID = ?";
        stmt = conn.prepareStatement(sql2);
        stmt.setInt(1, userID);
        rs = stmt.executeQuery();
        if (rs.next()) totalGroupTasks = rs.getInt(1);
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (stmt != null) try { stmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Task Manager</title>
    <style>
        body {
            margin: 0;
            font-family: 'Segoe UI', sans-serif;
            background-color: #ede9fe;
            display: flex;
            height: 100vh;
            overflow: hidden;
        }

        .sidebar {
            background-color: #7c69c3;
            width: 250px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding: 20px;
            color: white;
        }

        .sidebar h1 {
            font-size: 40px;
            margin-top: 5px;
            margin-bottom: 30px;
        }

        .sidebar a {
            color: white;
            text-decoration: none;
            font-weight: bold;
            margin: 10px 0;
            display: block;
        }

        .sidebar .profile {
            margin-top: auto;
            background-color: #6d5bb3;
            padding: 10px;
            border-radius: 8px;
            font-size: 14px;
        }

        .sidebar .logout {
            background-color: #2c235e;
            text-align: center;
            padding: 8px;
            margin-top: 10px;
            border-radius: 6px;
            text-decoration: none;
            display: block;
            color: white;
        }

        .main {
            flex: 1;
            padding: 40px 60px;
            overflow-y: auto;
        }

        .main h2 {
            font-size: 24px;
            color: #5f4bb6;
            margin: 0;
        }

        .main h1 {
            font-size: 50px;
            margin: 0;
            color: #4b0082;
        }

        .main h3 {
            font-size: 40px;
            margin-top: 0;
            color: #555;
        }

        .task-box {
            display: flex;
            gap: 2rem;
            margin-top: 2rem;
        }
        
        .task-box h3 {
            margin-bottom: 20px;
        }

        .status-box {
            background-color: #d1c4f7;
            padding: 1rem;
            border-radius: 10px;
            text-align: center;
            flex: 1;
        }

        .no-task {
            margin-top: 0;
            font-size: 18px;
            color: #333;
        }

        .group-buttons a {
            display: inline-block;
            margin-top: 0;
            margin: 5px;
            padding: 0.5rem 1rem;
            background-color: #5f4bb6;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }

        .modal {
            display: none;
            position: fixed;
            z-index: 1;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgb(0,0,0);
            background-color: rgba(0,0,0,0.4);
            padding-top: 60px;
        }

        .modal-content {
            background-color: #fefefe;
            margin: 5% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80%;
            max-width: 500px;
        }

        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
        }

        .close:hover,
        .close:focus {
            color: black;
            text-decoration: none;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <div>
            <h1>TASK MANAGER</h1>
            <a href="index.jsp">Home</a>
            <a href="index.jsp?page=individual">Your Tasks</a>
            <a href="index.jsp?page=group">Group Tasks</a>
        </div>
        <div>
            <div class="profile">
                <strong><%= username %></strong><br>
                <%= email != null ? email : "" %>
            </div>
            <a class="logout" href="logout.jsp">LOGOUT</a>
        </div>
    </div>

    <div class="main">
        <%-- Logika tampil halaman --%>
        <%
            if ("individual".equals(currentPage)) {
        %>
            <jsp:include page="individualDashboard.jsp" />
        <%
            } else if ("group".equals(currentPage)) {
        %>
            <jsp:include page="groupDashboard.jsp" />
        <%
            } else {
        %>
            <h2>WELCOME TO</h2>
            <h1>TASK MANAGER,</h1>
            <h3><%= username %>!</h3>

            <div class="task-box">
                <div class="status-box">
                    <h3>Individual Tasks</h3>
                    <p class="no-task"><%= totalIndividualTasks %> tasks</p>
                </div>
                <div class="status-box">
                <h3>Group Tasks</h3>
                <div class="group-buttons">
                    <a href="#" id="createGroupBtn">Create Group</a>
                    <a href="#" id="joinGroupBtn">Join Group</a>
                </div>
            </div>

<!-- CREATE GROUP MODAL -->
<div id="createGroupModal" class="modal">
    <div class="modal-content">
        <span class="close" id="closeCreateModal">&times;</span>
        <h2>Create Group</h2>
        <form action="CreateGroupServlet" method="post">
            <input type="text" name="group_name" placeholder="Enter Group Name" required>
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
            <input type="text" name="group_name" placeholder="Enter Group Name" required>
            <input type="text" name="description" placeholder="Enter Group Description" required>
            <input type="submit" value="Join">
        </form>
    </div>
</div>

<style>
.modal {
    display: none;
    position: fixed;
    z-index: 100;
    left: 0; top: 0;
    width: 100%; height: 100%;
    background-color: rgba(0,0,0,0.5);
}

.modal-content {
    background-color: #fff;
    margin: 10% auto;
    padding: 20px;
    width: 300px;
    border-radius: 8px;
    position: relative;
    box-shadow: 0 4px 8px rgba(0,0,0,0.2);
    box-sizing: border-box;
}

.modal-content h2 {
    margin-top: 0;
    color: #4b0082;
    text-align: center;
}

.modal-content input[type="text"],
.modal-content input[type="submit"] {
    width: 100%;
    margin: 8px 0;
    padding: 10px;
    border-radius: 5px;
    border: 1px solid #ccc;
    box-sizing: border-box;
}

.modal-content input[type="submit"] {
    background-color: #5f4bb6;
    color: white;
    border: none;
    cursor: pointer;
    transition: background-color 0.3s;
}

.modal-content input[type="submit"]:hover {
    background-color: #48309e;
}

.close {
    position: absolute;
    right: 10px;
    top: 5px;
    cursor: pointer;
    font-size: 20px;
    color: #888;
}
</style>

<script>
    function showJoinModal() {
        document.getElementById('joinModal').style.display = 'block';
    }

    function showCreateModal() {
        document.getElementById('createModal').style.display = 'block';
    }

    function closeModal(id) {
        document.getElementById(id).style.display = 'none';
    }
</script>

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

                window.onclick = function(event) {
                    if (event.target === createModal) createModal.style.display = 'none';
                    if (event.target === joinModal) joinModal.style.display = 'none';
                };
            </script>
        <%
            }
        %>
    </div>
</body>
</html>