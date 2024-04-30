-- Create database if it does not exist
CREATE DATABASE IF NOT EXISTS test123;

-- Use the 'test123' database for the following operations
USE test123;

-- Create user with specified password if not exists
CREATE USER IF NOT EXISTS 'Cyrus'@'localhost' IDENTIFIED BY 'Man0nMoon';

-- Grant all privileges on the 'test123' database to the user
GRANT ALL PRIVILEGES ON test123.* TO 'Cyrus'@'localhost';

-- Apply the changes
FLUSH PRIVILEGES;

-- Create table 'Users' if it does not exist
CREATE TABLE IF NOT EXISTS Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY, 
    Username VARCHAR(255) NOT NULL UNIQUE, -- Ensure Username is UNIQUE
    Password VARCHAR(255) NOT NULL, -- Consider using a BLOB for hashed passwords
    Email VARCHAR(255) NOT NULL UNIQUE, -- Ensure Email is UNIQUE
    Height FLOAT, 
    Weight FLOAT, 
    Goal VARCHAR(255)
);

-- Create table 'user_sessions' if it does not exist
CREATE TABLE IF NOT EXISTS user_sessions (
    session_id VARCHAR(255) NOT NULL PRIMARY KEY, 
    UserID INT NOT NULL, -- Foreign key must reference 'UserID'
    expired_at DATETIME NOT NULL, 
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Create DietaryRestrictions table
CREATE TABLE IF NOT EXISTS DietaryRestrictions (
    RestrictionID INT AUTO_INCREMENT PRIMARY KEY, 
    RestrictionName VARCHAR(255) NOT NULL
);

-- Create UserDietaryRestrictions table (Many-to-Many Relationship)
CREATE TABLE IF NOT EXISTS UserDietaryRestrictions (
    UserID INT, 
    RestrictionID INT, 
    FOREIGN KEY (UserID) REFERENCES Users(UserID), 
    FOREIGN KEY (RestrictionID) REFERENCES DietaryRestrictions(RestrictionID), 
    PRIMARY KEY (UserID, RestrictionID)
);

-- Create Workouts table
CREATE TABLE IF NOT EXISTS Workouts (
    WorkoutID INT AUTO_INCREMENT PRIMARY KEY, 
    WorkoutName VARCHAR(255) NOT NULL, 
    Description TEXT, 
    DifficultyLevel INT
);

-- Create Meals table
CREATE TABLE IF NOT EXISTS Meals (
    MealID INT AUTO_INCREMENT PRIMARY KEY, 
    MealName VARCHAR(255) NOT NULL, 
    Description TEXT, 
    Calories FLOAT
);

-- Create Ratings table
CREATE TABLE IF NOT EXISTS Ratings (
    RatingID INT AUTO_INCREMENT PRIMARY KEY, 
    UserID INT, 
    ItemType ENUM('Exercise', 'Meal') NOT NULL, 
    ItemID INT, 
    Rating INT, 
    Comment TEXT, 
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Create ForumPosts table
CREATE TABLE IF NOT EXISTS ForumPosts (
    PostID INT AUTO_INCREMENT PRIMARY KEY, 
    UserID INT, 
    PostContent TEXT, 
    PostDate DATETIME, 
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Create Friendships table (Many-to-Many Relationship)
CREATE TABLE IF NOT EXISTS Friendships (
    UserID1 INT, 
    UserID2 INT, 
    Status ENUM('Pending', 'Accepted', 'Blocked'), 
    FOREIGN KEY (UserID1) REFERENCES Users(UserID), 
    FOREIGN KEY (UserID2) REFERENCES Users(UserID), 
    PRIMARY KEY (UserID1, UserID2)
);

-- Create Messages table
CREATE TABLE IF NOT EXISTS Messages (
    MessageID INT AUTO_INCREMENT PRIMARY KEY, 
    SenderID INT, 
    ReceiverID INT, 
    MessageContent TEXT, 
    Timestamp DATETIME, 
    FOREIGN KEY (SenderID) REFERENCES Users(UserID), 
    FOREIGN KEY (ReceiverID) REFERENCES Users(UserID)
);
