<%@ page import="java.sql.*" %>
<%@ include file="DBConnection.jsp" %>
<%
    String taskIdStr = request.getParameter("taskId");
    if (taskIdStr == null || taskIdStr.isEmpty()) {
        out.println("Task ID is missing.");
        return;
    }

    int taskId = 0;
    try {
        taskId = Integer.parseInt(taskIdStr);
    } catch (NumberFormatException e) {
        out.println("Invalid Task ID.");
        return;
    }

    try {
        String checkSql = "SELECT * FROM tasks_group WHERE ID_task = ?";
        PreparedStatement psCheck = conn.prepareStatement(checkSql);
        psCheck.setInt(1, taskId);
        ResultSet rsCheck = psCheck.executeQuery();

        if (!rsCheck.next()) {
            out.println("Task not found.");
            rsCheck.close();
            psCheck.close();
            return;
        }
        rsCheck.close();
        psCheck.close();

        String deleteSql = "DELETE FROM tasks_group WHERE ID_task = ?";
        PreparedStatement psDelete = conn.prepareStatement(deleteSql);
        psDelete.setInt(1, taskId);
        int affectedRows = psDelete.executeUpdate();
        psDelete.close();

        if (affectedRows > 0) {
            response.sendRedirect("index.jsp?page=group&msg=Task+deleted+successfully");
        } else {
            out.println("Failed to delete task.");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("Error: " + e.getMessage());
    } finally {
        if (conn != null) conn.close();
    }
%>
