# 🛰️ TaskManager - Futuristic Tech & Glassmorphic Command Center

Welcome to **TaskManager**, a premium, high-end Java JSP & Servlet task management platform featuring a breathtaking **Futuristic Tech & Glassmorphic UI** inspired by top-tier modern dark interfaces (Vercel, Linear, and Stripe). 

This application bridges Java JSP backends with a beautifully polished, hardware-accelerated frontend using pure SVG, CSS3, and dynamic micro-interactions.

---

## 🎨 Premium UI/UX Highlights

* **Glassmorphic Glass Panels:** Elegant container panels with translucent backgrounds (`rgba(20, 18, 43, 0.45)`), saturated backdrop blurring (`backdrop-filter: blur(16px)`), upper inset reflections, and soft glowing semi-transparent borders.
* **Abstract 3D Floating SVG Elements:** Interactive background featuring concentric neon cyber-rings rotating in 3D projection, dynamic glowing glass spheres, and twinkling space dust.
* **3D Holographic Beranda Center:** A custom wireframe rotating tech star inside concentric orbiting vector rings on the homepage command center.
* **Cybernetic Radar Empty-States:** When no tasks are detected, a custom turquoise glowing radar with an active rotating scanning sweep beam will animate to scan the workstation.
* **Siber Glow Focus Inputs:** Interactive text inputs and selects that emit a soft purple lilac aura (`rgba(167, 139, 250, 0.35)`) and upscale action buttons with lift translation effects upon hover.
* **Unified Dark theme:** Harmonious custom palette utilizing deep space indigo, neon purple, cyan accents, and glowing pink aurora gradients.

---

## 🚀 Key Features

* **Multi-user Authentication:** Premium registration and login screens with glowing input validations.
* **Individual Tasks Command Center:** Track personal tasks with progress bars, status counters, and instant Search/Filter/Sort capabilities.
* **Group Collaboration Hub:** Create or join task groups, manage collaborative task cards, and assign roles.
* **Interactive Member Management:** Group leaders can add/remove members and assign active tasks within a glassmorphic dashboard table.
* **Automated Runner Script:** Fully portable launcher script to download, deploy, and execute the entire project locally without IDE configurations.

---

## 💻 Tech Stack

* **Backend Engine:** Java EE JSP (Java Server Pages) & Servlet.
* **Database Layer:** MySQL Database (Connector/J).
* **Frontend Design System:** Pure HTML5, Vanilla CSS3 (with Custom Keyframe Animations), JavaScript, Bootstrap 5.3, Bootstrap Icons.
* **Local Web Server:** Apache Tomcat 9.0.98.

---

## 🛠️ Step-by-Step Local Installation

To run this application locally without configuring complex IDE environments like NetBeans or Eclipse, a convenient automation script (`run_locally.ps1`) is provided.

### Prerequisites
* **Java JDK:** Ensure Java JDK (version 8 or newer, JDK 23 recommended) is installed on your Windows machine.
* **MySQL Server:** Ensure MySQL (e.g., via XAMPP, WampServer, or direct installation) is running on port `3306`.

### 1. Database Setup
Create a database named `task_manager` in your MySQL server. You can find the connection settings inside [DBConnection.jsp](web/DBConnection.jsp):
```jsp
conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/task_manager", "root", "");
```

### 2. Run with One-Click PowerShell Script
1. Open your **PowerShell** terminal in the root directory of this project.
2. Run the following command:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\run_locally.ps1
   ```

**What the script does automatically:**
1. Detects your local `JAVA_HOME` configuration.
2. Downloads portable **Apache Tomcat 9** zip if not already present.
3. Unzips and structures Tomcat directories.
4. Cleans old server builds and deploys fresh JSP, HTML, and compiled servlet class assets.
5. Re-configures Tomcat ports to `8082` to prevent standard web server conflicts.
6. Launches the Tomcat server console in a dedicated persistent window.

---

## 🧭 Application Access

Once the startup process completes successfully, open your favorite browser and access:

👉 **[http://localhost:8082/](http://localhost:8082/)**

You can register a new cybernetic account on the spot or sign in to begin organizing your galactic missions!

---

## 📁 Repository Structure
```
TaskManager/
├── tomcat/                 # Portable Tomcat files (generated upon run)
├── web/                    # JSP pages, assets, and styling components
│   ├── glowingTechElements.jsp  # Reusable 3D SVG visual decorator
│   ├── individualDashboard.jsp  # Individual task dashboard
│   ├── groupDashboard.jsp       # Collaborative group task dashboard
│   ├── memberManagement.jsp     # Active group member control list
│   └── ...
├── src/                    # Java Backend Source Classes & Servlets
├── build/                  # Compiled class outputs
├── run_locally.ps1         # One-click Windows PowerShell Launcher
└── README.md               # Repository documentation
```

---

*Made with love for premium interfaces. Organisasi misi kamu menjadi jauh lebih indah dan futuristik! 🛰️✨*
