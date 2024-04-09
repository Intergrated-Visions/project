-- insert_package.sql

-- Template for inserting a new package record into the 'packages' table
-- You need to replace the placeholder values with the actual ones when running this script

INSERT INTO packages (name, path, created_at)
VALUES ('<package_name>', '<package_path>', NOW());

