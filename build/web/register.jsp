<%@ page import="java.sql.*" %>
<%@ include file="DBConnection.jsp" %>

<%
    String message = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");

        try {
            String checkSql = "SELECT * FROM user WHERE Username=?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, username);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                message = "Username already exists!";
            } else {
                String sql = "INSERT INTO user (Username, Password, Email) VALUES (?, ?, ?)";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, username);
                stmt.setString(2, password);
                stmt.setString(3, email);
                stmt.executeUpdate();
                response.sendRedirect("login.jsp");
            }

            rs.close();
            checkStmt.close();
            conn.close();
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(to right, #f7f0ff, #e7eaf6);
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            overflow: hidden;
        }

        .app-title {
            position: absolute;
            top: 40px;
            font-size: 40px;
            color: #4b3f72;
            font-weight: bold;
            text-align: center;
            width: 100%;
        }

        .register-container {
            background: white;
            padding: 30px 40px;
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 400px;
            margin-top: 70px;
        }

        h2 {
            text-align: center;
            margin-top: 0;
            margin-bottom: 10px;
            color: #4b3f72;
        }

        input[type="text"],
        input[type="email"],
        input[type="password"] {
            width: 100%;
            padding: 12px;
            margin: 8px 0 16px 0;
            border: 1px solid #ccc;
            border-radius: 8px;
            box-sizing: border-box;
            transition: 0.3s;
        }

        input:focus {
            border-color: #7f72bd;
            outline: none;
            box-shadow: 0 0 5px rgba(127, 114, 189, 0.5);
        }

        button {
            width: 100%;
            background-color: #7f72bd;
            color: white;
            padding: 12px;
            border: none;
            border-radius: 8px;
            font-size: 20px;
            font-weight: bold;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        button:hover {
            background-color: #6a60a9;
        }

        .message {
            color: red;
            text-align: center;
            margin-top: 10px;
        }

        .login-link {
            text-align: center;
            margin-top: 15px;
        }

        .login-link a {
            color: #6a60a9;
            text-decoration: none;
        }

        .login-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div style="display: flex; flex-direction: column; align-items: center;">
        <h1 class="app-title">TASK MANAGER</h1>
    <div class="register-container">
        <h2>Register</h2>
        <form method="post">
            <input type="text" name="username" placeholder="Username" required>
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">REGISTER</button>
        </form>
        <div class="message"><%= message %></div>
        <div class="login-link">
            Already have an account? <a href="login.jsp">Login</a>
        </div>
    </div>
</body>
</html>