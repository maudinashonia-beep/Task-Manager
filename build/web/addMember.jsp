<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ include file="DBConnection.jsp" %>
<% 
    String groupId = request.getParameter("groupId");
    PreparedStatement ps = null;
    ResultSet rs = null;
    String message = "";

    int userId = (int) session.getAttribute("userId");
    
    try {
        String query = "SELECT * FROM groups WHERE group_id = ? AND leader_id = ?";
        ps = conn.prepareStatement(query);
        ps.setInt(1, Integer.parseInt(groupId));
        ps.setInt(2, userId);
        rs = ps.executeQuery();
        
        if (rs.next()) {
        } else {
            message = "You must be the leader to add members.";
        }
    } catch (Exception e) {
        message = "Error: " + e.getMessage();
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException se) {
            message = "Error closing resources: " + se.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Add Member</title>
</head>
<body>
    <h2>Add Member to Group</h2>
    <form action="addMemberProcess.jsp" method="post">
        <label for="email">Member Email:</label>
        <input type="email" id="email" name="email" required>
        <input type="hidden" name="groupId" value="<%= groupId %>">
        <button type="submit">Add Member</button>
    </form>
    <p><%= message %></p>
</body>
</html>