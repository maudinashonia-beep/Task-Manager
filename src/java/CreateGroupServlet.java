import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.myapp.database.DBConnection;

@WebServlet("/CreateGroupServlet")
public class CreateGroupServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String groupName = request.getParameter("group_name");
        String description = request.getParameter("description");
        String memberLimitStr = request.getParameter("member_limit");

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userID");

        if (groupName == null || description == null || memberLimitStr == null || userId == null) {
            response.sendRedirect("index.jsp?error=Missing+required+fields");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // Insert ke tabel groups (Group_ID auto-increment)
            String insertGroup = "INSERT INTO `groups` (Group_Name, Description, Member_Limit, Created_At) VALUES (?, ?, ?, NOW())";
            PreparedStatement stmtGroup = conn.prepareStatement(insertGroup, Statement.RETURN_GENERATED_KEYS);
            stmtGroup.setString(1, groupName);
            stmtGroup.setString(2, description);
            stmtGroup.setInt(3, Integer.parseInt(memberLimitStr));
            stmtGroup.executeUpdate();

            // Ambil Group_ID yang baru saja dibuat
            ResultSet generatedKeys = stmtGroup.getGeneratedKeys();
            int groupId = -1;
            if (generatedKeys.next()) {
                groupId = generatedKeys.getInt(1);
            }
            stmtGroup.close();

            if (groupId != -1) {
                // Insert ke tabel group_members sebagai Leader
                String insertMember = "INSERT INTO group_members (User_ID, Group_ID, Role) VALUES (?, ?, 'Leader')";
                PreparedStatement stmtMember = conn.prepareStatement(insertMember);
                stmtMember.setInt(1, userId);
                stmtMember.setInt(2, groupId);
                stmtMember.executeUpdate();
                stmtMember.close();
            }

            response.sendRedirect("index.jsp?page=group");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Failed to create group. Please try again.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("index.jsp");
            dispatcher.forward(request, response);
        }
    }
}
