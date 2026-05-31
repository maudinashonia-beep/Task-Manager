<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="DBConnection.jsp" %>

<%
    String idParam = request.getParameter("id");
    int taskId = 0; 

    if (idParam == null || idParam.trim().isEmpty()) {
        session.setAttribute("message", "Invalid task ID.");
        session.setAttribute("alertClass", "alert-danger");
        response.sendRedirect("index.jsp");
        return; 
    }

    try {
        taskId = Integer.parseInt(idParam);
    } catch (NumberFormatException e) {
        session.setAttribute("message", "Task ID must be a valid number.");
        session.setAttribute("alertClass", "alert-danger");
        response.sendRedirect("index.jsp");
        return; 
    }

    boolean success = false;
    String errorMessage = "";

    try {
        try (PreparedStatement stmt = conn.prepareStatement("DELETE FROM tasks WHERE id = ?")) {
            stmt.setInt(1, taskId);
            int rowsAffected = stmt.executeUpdate();
            success = rowsAffected > 0;
        }
    } catch (Exception e) {
        errorMessage = e.getMessage();
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }

    if (success) {
        session.setAttribute("message", "Task deleted successfully!");
        session.setAttribute("alertClass", "alert-success");
    } else {
        session.setAttribute("message", "Failed to delete task. " + errorMessage);
        session.setAttribute("alertClass", "alert-danger");
    }

    response.sendRedirect("index.jsp?page=individual");
%>