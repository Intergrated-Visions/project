-- Check and Create USER IF NOT EXISTS
CREATE USER IF NOT EXISTS 'Cyrus'@'localhost' IDENTIFIED BY 'Man0nMoon';

-- Grant all privileges on `packageDB` to the user. Adjust if needed.
GRANT ALL PRIVILEGES ON packageDB.* TO 'Cyrus'@'localhost';

-- Flush the privileges to ensure they are applied
FLUSH PRIVILEGES;

-- Create the new database if it doesn't already exist
CREATE DATABASE IF NOT EXISTS packageDB;

-- Select the database to use
USE packageDB;

-- Create the 'packages' table
CREATE TABLE IF NOT EXISTS packages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    path VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL
);

-- Optionally, set the default character set and collate
ALTER DATABASE packageDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
