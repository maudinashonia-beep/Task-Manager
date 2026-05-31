import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.myapp.database.DBConnection;

@WebServlet("/JoinGroupServlet")
public class JoinGroupServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String groupName = request.getParameter("group_name");
        String description = request.getParameter("description");

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT Group_ID, Member_Limit FROM `groups` WHERE Group_Name = ? AND Description = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, groupName);
            stmt.setString(2, description);
            rs = stmt.executeQuery();

            if (rs.next()) {
                int groupId = rs.getInt("Group_ID");
                int memberLimit = rs.getInt("Member_Limit");

                stmt.close();
                rs.close();
                sql = "SELECT COUNT(*) FROM group_members WHERE Group_ID = ?";
                stmt = conn.prepareStatement(sql);
                stmt.setInt(1, groupId);
                rs = stmt.executeQuery();

                int currentMembers = 0;
                if (rs.next()) {
                    currentMembers = rs.getInt(1);
                }

                if (currentMembers >= memberLimit) {
                    request.setAttribute("error", "Group is full.");
                    request.getRequestDispatcher("index.jsp").forward(request, response);
                } else {
                    request.setAttribute("groupId", groupId);
                    request.setAttribute("groupName", groupName);
                    request.setAttribute("description", description);
                    request.getRequestDispatcher("joinGroupSelectTask.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Group not found.");
                request.getRequestDispatcher("index.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Internal error.");
            request.getRequestDispatcher("index.jsp").forward(request, response);
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}
