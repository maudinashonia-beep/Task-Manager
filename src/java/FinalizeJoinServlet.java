import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.myapp.database.DBConnection;

@WebServlet("/FinalizeJoinServlet")
public class FinalizeJoinServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int groupId = Integer.parseInt(request.getParameter("group_id"));
        int taskId = Integer.parseInt(request.getParameter("task_id"));
        HttpSession session = request.getSession();
        int userId = (Integer) session.getAttribute("userID");

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DBConnection.getConnection();

            String sql = "INSERT INTO group_members (Group_ID, User_ID, Task_ID, Role) VALUES (?, ?, ?, 'Member')";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, groupId);
            stmt.setInt(2, userId);
            stmt.setInt(3, taskId);
            stmt.executeUpdate();

            response.sendRedirect("index.jsp?page=group");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?error=Join+failed");
        } finally {
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}
