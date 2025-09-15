CREATE DATABASE twitter_clone;
USE twitter_clone;


CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password BINARY(64) NOT NULL, -- سيتم تخزينه مشفر
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Profile (
    profile_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    profile_picture VARCHAR(255), -- رابط أو اسم الصورة
    bio TEXT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);


CREATE TABLE Tweet (
    tweet_id INT AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    tweet_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (tweet_id) REFERENCES Tweet(tweet_id)
);


CREATE TABLE Retweet (
    retweet_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    tweet_id INT NOT NULL,
    retweeted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (tweet_id) REFERENCES Tweet(tweet_id)
);

CREATE TABLE Follow (
    follow_id INT AUTO_INCREMENT PRIMARY KEY,
    follower_id INT NOT NULL,
    followed_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (follower_id) REFERENCES Users(user_id),
    FOREIGN KEY (followed_id) REFERENCES Users(user_id),
    CONSTRAINT unique_follow UNIQUE (follower_id, followed_id) -- يمنع التكرار
);



INSERT INTO Users (username, email, password)
VALUES 
('Sara', 'sara@example.com', UNHEX(MD5('12345'))),
('Noor', 'noor@example.com', UNHEX(MD5('12345')));




INSERT INTO Profile (user_id, profile_picture, bio)
VALUES 
(1, 'sara_pic.png', 'Software Engineer | AI Enthusiast'),
(2, 'noor_pic.png', 'Data Scientist');



INSERT INTO Tweet (content, user_id)
VALUES
('Hello Twitter!', 1),
('My first tweet 🚀', 2);


INSERT INTO Likes (user_id, tweet_id)
VALUES (1, 2); -- سارة أعجبت بتغريدة نوره



INSERT INTO Follow (follower_id, followed_id)
VALUES (1, 2); -- سارة تتابع نوره


-- قم بإنشاء Procedure باسم createAccount سوف نمرر لها بيانات المستخدم والملف الشخصي ويتم إضافتها لكل الجدولين.
DELIMITER $$
CREATE PROCEDURE createAccount (
    IN p_username VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(100),
    IN p_profile_picture VARCHAR(255),
    IN p_bio TEXT
)
BEGIN
    DECLARE new_user_id INT;

    INSERT INTO Users (username, email, password)
    VALUES (p_username, p_email, UNHEX(MD5(p_password)));

    SET new_user_id = LAST_INSERT_ID();

    INSERT INTO Profile (user_id, profile_picture, bio)
    VALUES (new_user_id, p_profile_picture, p_bio);
END$$
DELIMITER ;




-- قم بإنشاء Procedure باسم User_Follow سوف نمرر له اسم المستخدم نفسه واسم المستخدم المراد متابعته فسوف يبحث عن الرقم التسلسلي الخاص لكلا المستخدمين وسيتم إضافته بجدول المتابعة.
DELIMITER $$
CREATE PROCEDURE User_Follow (
    IN p_follower_username VARCHAR(50),
    IN p_followed_username VARCHAR(50)
)
BEGIN
    DECLARE follower_id INT;
    DECLARE followed_id INT;

    SELECT user_id INTO follower_id FROM Users WHERE username = p_follower_username;
    SELECT user_id INTO followed_id FROM Users WHERE username = p_followed_username;

    INSERT INTO Follow (follower_id, followed_id)
    VALUES (follower_id, followed_id);
END$$
DELIMITER ;


-- اعرض عدد التغريدات لمستخدم واحد فقط.

SELECT u.username, COUNT(t.tweet_id) AS total_tweets
FROM Users u
JOIN Tweet t ON u.user_id = t.user_id
WHERE u.username = 'Sara'
GROUP BY u.username;




