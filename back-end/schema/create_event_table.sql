CREATE TABLE IF NOT EXISTS event(
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_title VARCHAR(255) NOT NULL,
    event_description TEXT NOT NULL,
    event_date DATE NOT NULL,
    event_time TIME NOT NULL,
    event_location VARCHAR(255) NOT NULL,
    event_category VARCHAR(100) NOT NULL,
    creator_id INT,
    event_status BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (creator_id) REFERENCES user(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);