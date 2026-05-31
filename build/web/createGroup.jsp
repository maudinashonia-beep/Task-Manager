<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%@ include file="DBConnection.jsp" %>

<%
    Integer userID = (Integer) session.getAttribute("userID");

    if (request.getMethod().equalsIgnoreCase("POST")) {
        String groupName = request.getParameter("groupName");

        if (userID == null || groupName == null || groupName.trim().isEmpty()) {
            out.println("Invalid session or group name.");
            return;
        }

        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            String sql = "INSERT INTO groups (Group_Name, Leader_ID, Created_At) VALUES (?, ?, NOW())";
            stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, groupName);
            stmt.setInt(2, userID);
            stmt.executeUpdate();

            rs = stmt.getGeneratedKeys();
            int groupId = 0;
            if (rs.next()) {
                groupId = rs.getInt(1);
            }

            try (PreparedStatement memberStmt = conn.prepareStatement(
                    "INSERT INTO group_members (Group_ID, User_ID, Role) VALUES (?, ?, ?)")) {
                memberStmt.setInt(1, groupId);
                memberStmt.setInt(2, userID);
                memberStmt.setString(3, "Leader");
                memberStmt.executeUpdate();
            }

            response.sendRedirect("groupDashboard.jsp");

        } catch (Exception e) {
            out.println("Error creating group: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ignored) {}
            if (stmt != null) try { stmt.close(); } catch (Exception ignored) {}
            if (conn != null) try { conn.close(); } catch (Exception ignored) {}
        }

        return;
    }
%>
