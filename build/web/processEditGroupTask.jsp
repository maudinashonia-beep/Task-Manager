<%@ page import="java.sql.*" %>
<%@ include file="DBConnection.jsp" %>
<%
    int groupId = Integer.parseInt(request.getParameter("groupId"));
    String subject = request.getParameter("subject");
    String description = request.getParameter("description");
    int statusId = Integer.parseInt(request.getParameter("status"));

    PreparedStatement stmt = null;

    try {
        String sql = "UPDATE tasks_group SET Subject = ?, Description = ?, Status_ID = ? WHERE Group_ID = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, subject);
        stmt.setString(2, description);
        stmt.setInt(3, statusId);
        stmt.setInt(4, groupId);

        int rows = stmt.executeUpdate();

        if (rows > 0) {
            response.sendRedirect("manageGroup.jsp?groupId=" + groupId);
        } else {
            out.println("<p style='color:red;'>Update failed. No task updated.</p>");
        }

        stmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        e.printStackTrace();
    }
%>
