package controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.myapp.database.DBConnection;

@WebServlet("/AddGroupTaskServlet")
public class AddGroupTaskServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int groupId = Integer.parseInt(request.getParameter("group_id"));
        String description = request.getParameter("description");

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "INSERT INTO tasks_group (Group_ID, Description) VALUES (?, ?)";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, groupId);
            stmt.setString(2, description);
            stmt.executeUpdate();

            response.sendRedirect("groupDashboard.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("groupDashboard.jsp?error=AddTaskFailed");
        } finally {
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}
