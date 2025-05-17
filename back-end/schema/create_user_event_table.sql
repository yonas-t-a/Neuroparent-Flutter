CREATE TABLE IF NOT EXISTS user_event(
    user_event_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    event_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (event_id) REFERENCES event(event_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE

);
