-- Create database
CREATE DATABASE IF NOT EXISTS test123;

-- Create user with specified password
CREATE USER IF NOT EXISTS 'Cyrus'@'localhost' IDENTIFIED BY 'Man0nMoon';

-- Grant all privileges on the 'test123' database to the user
GRANT ALL PRIVILEGES ON test123.* TO 'Cyrus'@'localhost';

-- Apply the changes
FLUSH PRIVILEGES;

-- Use the 'test123' database for the following operations
USE test123;

-- Create table 'users' if it does not exist
CREATE TABLE IF NOT EXISTS users (
    username VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    PRIMARY KEY (username)
);

-- Create table 'user_sessions' if it does not exist
CREATE TABLE IF NOT EXISTS user_sessions (
    session_id VARCHAR(255) NOT NULL PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    expiredAt DATETIME NOT NULL,
    FOREIGN KEY (username) REFERENCES users(username)
);
