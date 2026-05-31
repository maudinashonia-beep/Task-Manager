-- Task Manager Database Schema

CREATE DATABASE IF NOT EXISTS task_manager;
USE task_manager;

-- 1. Create status table
CREATE TABLE IF NOT EXISTS status (
    Status_ID INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL
);

-- Insert default statuses if they do not exist
INSERT IGNORE INTO status (Status_ID, Name) VALUES 
(1, 'Pending'),
(2, 'In Progress'),
(3, 'Cancelled'),
(4, 'Completed');

-- 2. Create user table
CREATE TABLE IF NOT EXISTS user (
    User_ID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(100) NOT NULL UNIQUE,
    Password VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL
);

-- 3. Create groups table
CREATE TABLE IF NOT EXISTS `groups` (
    Group_ID INT AUTO_INCREMENT PRIMARY KEY,
    Group_Name VARCHAR(100) NOT NULL,
    Description TEXT,
    Member_Limit INT DEFAULT 5,
    Leader_ID INT,
    Created_At DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 4. Create group_members table
CREATE TABLE IF NOT EXISTS group_members (
    Group_ID INT NOT NULL,
    User_ID INT NOT NULL,
    Role VARCHAR(50) DEFAULT 'Member',
    Task_ID INT DEFAULT NULL,
    PRIMARY KEY (Group_ID, User_ID)
);

-- 5. Create tasks table (Individual tasks)
CREATE TABLE IF NOT EXISTS tasks (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Subject VARCHAR(255) NOT NULL,
    Description TEXT,
    Status_id INT NOT NULL,
    Start_date DATE,
    Due_date DATE,
    User_ID INT NOT NULL,
    Group_ID INT DEFAULT NULL,
    FOREIGN KEY (Status_id) REFERENCES status(Status_ID)
);

-- 6. Create tasks_group table
CREATE TABLE IF NOT EXISTS tasks_group (
    ID_task INT AUTO_INCREMENT PRIMARY KEY,
    Subject VARCHAR(255) NOT NULL,
    Description TEXT,
    Status_ID INT NOT NULL,
    Start_Date DATE,
    Due_Date DATE,
    Group_ID INT NOT NULL,
    User_ID INT NOT NULL,
    Max_Members INT DEFAULT 5,
    FOREIGN KEY (Status_ID) REFERENCES status(Status_ID)
);
