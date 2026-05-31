<%@ page import="java.sql.*" %>
<%@ include file="DBConnection.jsp" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page session="true" %>
<%
    String message = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try {
            String sql = "SELECT * FROM user WHERE Username=? AND Password=?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            stmt.setString(2, password);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                session.setAttribute("username", rs.getString("Username"));
                session.setAttribute("userID", rs.getInt("User_ID"));
                response.sendRedirect("index.jsp");
                return;
            } else {
                message = "Invalid username or password.";
            }

            rs.close();
            stmt.close();
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
    <title>Login</title>
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
            top: 50px;
            font-size: 40px;
            color: #4b3f72;
            font-weight: bold;
            text-align: center;
            width: 100%;
        }

        .login-container {
            background: white;
            padding: 30px 40px;
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 400px;
        }

        h2 {
            text-align: center;
            margin-top: 0;
            margin-bottom: 10px;
            color: #4b3f72;
        }

        input[type="text"],
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

        .register-link {
            text-align: center;
            margin-top: 15px;
        }

        .register-link a {
            color: #6a60a9;
            text-decoration: none;
        }

        .register-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <h1 class="app-title">TASK MANAGER</h1>
    <div class="login-container">
        <h2>Login</h2>
        <form method="post">
            <input type="text" name="username" placeholder="Username" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">LOGIN</button>
        </form>

        <div class="message"><%= message %></div>

        <div class="register-link">
            Don't have an account? <a href="register.jsp">Register</a>
        </div>
    </div>
</body>
</html>