<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="DBConnection.jsp" %>
<%
    int groupId = (Integer) request.getAttribute("groupId");
    String groupName = (String) request.getAttribute("groupName");
    String description = (String) request.getAttribute("description");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Select Task</title>
</head>
<body>
    <h2>Join Group: <%= groupName %></h2>
    <form action="FinalizeJoinServlet" method="post">
        <input type="hidden" name="group_id" value="<%= groupId %>">
        <input type="hidden" name="group_name" value="<%= groupName %>">
        <input type="hidden" name="description" value="<%= description %>">

        <label>Select Task Description:</label>
        <select name="task_id" required>
        <%
            PreparedStatement stmt = null;
            ResultSet rs = null;

            try {
                String sql = "SELECT tg.ID_task, tg.Description FROM tasks_group tg " +
                             "WHERE tg.Group_ID = ? AND tg.ID_task NOT IN (" +
                             "SELECT Task_ID FROM group_members WHERE Group_ID = ? AND Task_ID IS NOT NULL)";
                stmt = conn.prepareStatement(sql);
                stmt.setInt(1, groupId);
                stmt.setInt(2, groupId);
                rs = stmt.executeQuery();

                while (rs.next()) {
                    int taskId = rs.getInt("ID_task");
                    String taskDesc = rs.getString("Description");
        %>
                    <option value="<%= taskId %>"><%= taskDesc %></option>
        <%
                }

            } catch (Exception e) {
                e.printStackTrace();
        %>
            <option disabled>Error loading tasks</option>
        <%
            } finally {
                try { if (rs != null) rs.close(); } catch (Exception e) {}
                try { if (stmt != null) stmt.close(); } catch (Exception e) {}
                try { if (conn != null) conn.close(); } catch (Exception e) {}
            }
        %>
        </select>
        <br><br>
        <input type="submit" value="Join Task">
    </form>
</body>
</html>
