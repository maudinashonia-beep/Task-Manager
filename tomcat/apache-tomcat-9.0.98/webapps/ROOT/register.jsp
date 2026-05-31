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
    <title>Register - Task Manager</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap');

        body {
            font-family: 'Outfit', sans-serif;
            background-color: #080614;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
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

        /* Extraordinary Floating Glow Orbs (Aurora Effect) */
        .bg-glow {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 0;
            overflow: hidden;
        }

        .glow-1, .glow-2, .glow-3 {
            position: absolute;
            border-radius: 50%;
            filter: blur(120px);
            opacity: 0.15;
            animation: float 25s infinite alternate ease-in-out;
        }

        .glow-1 {
            top: -15%;
            left: -10%;
            width: 50vw;
            height: 50vw;
            background: radial-gradient(circle, #8b5cf6 20%, transparent 70%);
            animation-duration: 20s;
        }

        .glow-2 {
            bottom: -20%;
            right: -10%;
            width: 55vw;
            height: 55vw;
            background: radial-gradient(circle, #3b82f6 20%, transparent 70%);
            animation-duration: 28s;
            animation-delay: -5s;
        }

        .glow-3 {
            top: 30%;
            left: 40%;
            width: 40vw;
            height: 40vw;
            background: radial-gradient(circle, #ec4899 10%, transparent 75%);
            animation-duration: 22s;
            animation-delay: -10s;
        }

        @keyframes float {
            0% {
                transform: translate(0, 0) scale(1) rotate(0deg);
            }
            50% {
                transform: translate(5vw, 6vh) scale(1.15) rotate(180deg);
            }
            100% {
                transform: translate(-3vw, -5vh) scale(0.9) rotate(360deg);
            }
        }

        .register-wrapper {
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 90%;
            max-width: 400px;
            z-index: 10; /* Ensures content is above the glowing orbs */
        }

        .app-title {
            font-size: 38px;
            font-weight: 800;
            margin-bottom: 25px;
            background: linear-gradient(135deg, #a78bfa, #c084fc, #818cf8);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-align: center;
            letter-spacing: 2px;
            filter: drop-shadow(0 0 25px rgba(167, 139, 250, 0.35));
            margin-top: 0;
        }

        .register-container {
            background: rgba(20, 18, 43, 0.45) !important;
            backdrop-filter: blur(16px) saturate(120%) !important;
            -webkit-backdrop-filter: blur(16px) saturate(120%) !important;
            border: 1px solid rgba(255, 255, 255, 0.08) !important;
            padding: 40px;
            border-radius: 24px;
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.4), 
                        inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
            width: 100%;
            box-sizing: border-box;
            transition: transform 0.4s cubic-bezier(0.165, 0.84, 0.44, 1), 
                        box-shadow 0.4s cubic-bezier(0.165, 0.84, 0.44, 1),
                        border-color 0.4s ease;
        }

        .register-container:hover {
            transform: translateY(-5px);
            box-shadow: 0 40px 80px rgba(139, 92, 246, 0.15),
                        inset 0 1px 0 rgba(255, 255, 255, 0.15) !important;
            border-color: rgba(167, 139, 250, 0.25) !important;
        }

        h2 {
            text-align: center;
            margin-top: 0;
            margin-bottom: 25px;
            color: #fff;
            font-weight: 700;
            font-size: 24px;
            letter-spacing: 0.5px;
        }

        input[type="text"],
        input[type="email"],
        input[type="password"] {
            width: 100%;
            padding: 14px 16px;
            margin: 8px 0 16px 0;
            background: #1c1a38;
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 12px;
            box-sizing: border-box;
            color: #fff;
            font-size: 15px;
            font-family: inherit;
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        }

        input[type="text"]::placeholder,
        input[type="email"]::placeholder,
        input[type="password"]::placeholder {
            color: rgba(255, 255, 255, 0.3);
        }

        input:focus {
            background: rgba(37, 34, 72, 0.6) !important;
            border-color: #a78bfa !important;
            outline: none;
            box-shadow: 0 0 18px rgba(167, 139, 250, 0.35) !important;
        }

        button {
            width: 100%;
            background: linear-gradient(135deg, #8b5cf6, #6366f1);
            color: white;
            padding: 14px;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            font-family: inherit;
            cursor: pointer;
            box-shadow: 0 8px 24px rgba(139, 92, 246, 0.35);
            transition: all 0.3s ease;
            margin-top: 15px;
        }

        button:hover {
            background: linear-gradient(135deg, #a78bfa, #818cf8);
            transform: translateY(-2px);
            box-shadow: 0 12px 30px rgba(139, 92, 246, 0.5);
        }

        button:active {
            transform: translateY(0);
            box-shadow: 0 4px 15px rgba(139, 92, 246, 0.3);
        }

        .message {
            color: #fca5a5;
            background: rgba(239, 68, 68, 0.15);
            border: 1px solid rgba(239, 68, 68, 0.25);
            border-radius: 8px;
            text-align: center;
            margin-top: 15px;
            padding: 10px;
            font-size: 14px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.25);
        }
        
        .message:empty {
            display: none;
        }

        .login-link {
            text-align: center;
            margin-top: 25px;
            font-size: 14px;
            color: rgba(255, 255, 255, 0.5);
        }

        .login-link a {
            color: #c084fc;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .login-link a:hover {
            color: #e9d5ff;
            text-shadow: 0 0 12px rgba(233, 213, 255, 0.4);
            text-decoration: underline;
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

    <div class="register-wrapper">
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
    </div>
</body>
</html>