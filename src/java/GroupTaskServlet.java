import com.myapp.database.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.*;

public class GroupTaskServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String groupId = request.getParameter("groupId");
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        List<Map<String, Object>> tasks = new ArrayList<>();
        
        try {
            con = DBConnection.getConnection();
            String query = "SELECT * FROM tasks WHERE group_id = ?";
            ps = con.prepareStatement(query);
            ps.setString(1, groupId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> task = new HashMap<>();
                task.put("task_id", rs.getInt("task_id"));
                task.put("subject", rs.getString("subject"));
                task.put("description", rs.getString("description"));
                task.put("status", rs.getString("status"));
                task.put("start_date", rs.getDate("start_date"));
                task.put("due_date", rs.getDate("due_date"));
                tasks.add(task);
            }
            
            request.setAttribute("tasks", tasks);  // Set the tasks as a request attribute
            request.getRequestDispatcher("/viewGroupTask.jsp").forward(request, response);  // Forward to JSP
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().write("Error: " + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }
}
