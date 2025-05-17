CREATE TABLE IF NOT EXISTS article(
    article_id INT AUTO_INCREMENT PRIMARY KEY,
    article_title VARCHAR(255) NOT NULL,
    article_content TEXT NOT NULL,
    article_image VARCHAR(255) NOT NULL,
    article_category VARCHAR(100) NOT NULL,
    article_creator_id INT,
    FOREIGN KEY (article_creator_id) REFERENCES user(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);