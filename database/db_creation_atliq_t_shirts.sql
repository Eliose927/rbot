-- Create the database
-- Create the database and switch to it
CREATE DATABASE IF NOT EXISTS atliq_tshirts;
USE atliq_tshirts;

-- Drop tables if they already exist
DROP TABLE IF EXISTS discounts;
DROP TABLE IF EXISTS t_shirts;

-- Create the t_shirts table
CREATE TABLE t_shirts (
    t_shirt_id INT AUTO_INCREMENT PRIMARY KEY,
    brand ENUM('Van Huesen', 'Levi', 'Nike', 'Adidas') NOT NULL,
    color ENUM('Red', 'Blue', 'Black', 'White') NOT NULL,
    size ENUM('XS', 'S', 'M', 'L', 'XL') NOT NULL,
    price INT CHECK (price BETWEEN 10 AND 50),
    stock_quantity INT NOT NULL,
    UNIQUE KEY brand_color_size (brand, color, size)
);

-- Create the discounts table
CREATE TABLE discounts (
    discount_id INT AUTO_INCREMENT PRIMARY KEY,
    t_shirt_id INT NOT NULL,
    pct_discount DECIMAL(5,2) CHECK (pct_discount BETWEEN 0 AND 100),
    FOREIGN KEY (t_shirt_id) REFERENCES t_shirts(t_shirt_id)
);

-- Create a stored procedure to populate the t_shirts table
DELIMITER $$
CREATE PROCEDURE PopulateTShirt()
BEGIN
    DECLARE counter INT DEFAULT 0;
    DECLARE max_records INT DEFAULT 100;
    DECLARE attempts INT DEFAULT 0;
    DECLARE max_attempts INT DEFAULT 1000;
    DECLARE brand ENUM('Van Huesen', 'Levi', 'Nike', 'Adidas');
    DECLARE color ENUM('Red', 'Blue', 'Black', 'White');
    DECLARE size ENUM('XS', 'S', 'M', 'L', 'XL');
    DECLARE price INT;
    DECLARE stock INT;
    DECLARE v_duplicate BOOLEAN;

    -- Seed the random number generator
    SET SESSION rand_seed1 = UNIX_TIMESTAMP();

    WHILE counter < max_records AND attempts < max_attempts DO
        SET v_duplicate = FALSE;

        -- Generate random values
        SET brand = ELT(FLOOR(1 + RAND() * 4), 'Van Huesen', 'Levi', 'Nike', 'Adidas');
        SET color = ELT(FLOOR(1 + RAND() * 4), 'Red', 'Blue', 'Black', 'White');
        SET size = ELT(FLOOR(1 + RAND() * 5), 'XS', 'S', 'M', 'L', 'XL');
        SET price = FLOOR(10 + RAND() * 41); -- Prices between 10 and 50
        SET stock = FLOOR(10 + RAND() * 91); -- Stock quantity between 10 and 100

        BEGIN
            DECLARE CONTINUE HANDLER FOR SQLSTATE '23000' SET v_duplicate = TRUE;
            INSERT INTO t_shirts (brand, color, size, price, stock_quantity)
            VALUES (brand, color, size, price, stock);
        END;
        
        IF NOT v_duplicate THEN
            SET counter = counter + 1;
        END IF;
        
        SET attempts = attempts + 1;
    END WHILE;
END$$
DELIMITER ;

-- Call the stored procedure to populate the t_shirts table
CALL PopulateTShirt();

-- Insert discounts based on existing t_shirt_ids
INSERT INTO discounts (t_shirt_id, pct_discount)
SELECT t_shirt_id, ROUND(RAND()*35+5, 2) -- Generates a random discount between 5.00 and 40.00
FROM t_shirts
ORDER BY t_shirt_id
LIMIT 10; -- Limits the insert to the first 10 t_shirt_ids for demonstration
