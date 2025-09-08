--
-- Return all active users who signed up before Jan 1, 2024.
--
SELECT * FROM USERS WHERE signup_date < '2024-01-01';

--
-- List distinct cities from which users signed up using a free trial.
--
SELECT DISTINCT u.city 
FROM USERS u 
JOIN SUBSCRIPTIONS s ON s.user_id = u.user_id 
WHERE s.subscription_type = 'trial';

--
-- Find all users who signed up in the same month as the campaign named 'Summer Sale'.
--
SELECT u.* FROM USERS u
WHERE MONTH(u.signup_date) = (
    SELECT MONTH(c.start_date)
    FROM CAMPAIGN c
    WHERE c.campaign_name = 'Summer Sale'
);

--
-- Retrieve the top 10 most recently signed-up users.
--
SELECT u.* FROM USERS u
ORDER BY u.signup_date DESC
LIMIT 10;

--
-- Join users and notifications to find all users who received a push notification in March 2024.
--
SELECT DISTINCT u.* FROM USERS u
INNER JOIN NOTIFICATIONS n ON n.user_id = u.user_id
INNER JOIN CAMPAIGN c ON c.campaign_id = n.campaign_id
WHERE MONTH(n.sent_at) = 3 AND YEAR(n.sent_at) = 2024
AND c.campaign_type = 'push';

--
-- Which users received more than one campaign in April 2024? 
--
SELECT u.*
FROM USERS u
INNER JOIN NOTIFICATIONS n ON n.user_id = u.user_id
INNER JOIN CAMPAIGN c ON c.campaign_id = n.campaign_id
WHERE MONTH(n.sent_at) = 4 AND YEAR(n.sent_at) = 2024
GROUP BY u.user_id
HAVING COUNT(DISTINCT n.campaign_id);

--
-- Join users, notifications, and campaigns to find users who received both an email and a push campaign.
--
SELECT u.*
FROM USERS u
INNER JOIN NOTIFICATIONS n ON n.user_id = u.user_id
INNER JOIN CAMPAIGN c ON c.campaign_id = n.campaign_id
WHERE c.campaign_type IN ('email', 'push')
GROUP BY u.user_id, u.username
HAVING COUNT(DISTINCT c.campaign_type) = 2;

--
-- Find all users who were notified but never opened any notification.
--
SELECT u.*
FROM USERS u
INNER JOIN NOTIFICATIONS n ON n.user_id = u.user_id
WHERE n.opened_at IS NULL;

--
-- Count the number of users per campaign who opened their notification.
--
SELECT c.campaign_id, COUNT(DISTINCT n.user_id) AS user_count
FROM CAMPAIGN c
INNER JOIN NOTIFICATIONS n ON c.campaign_id = n.campaign_id
WHERE n.opened_at IS NOT NULL
GROUP BY c.campaign_id;

--
-- What is the average number of notifications per user?
--
SELECT AVG(notification_count) AS average_notifications_per_user
FROM (
    SELECT n.user_id, COUNT(n.notification_id) AS notification_count
    FROM NOTIFICATIONS n
    GROUP BY n.user_id
) AS user_notifications;

--
-- Calculate the percentage of users who opened at least one notification.
--
SELECT (COUNT(DISTINCT n.user_id) * 100.0 / COUNT(DISTINCT u.user_id)) AS percentage_users_opened
FROM USERS u
LEFT JOIN NOTIFICATIONS n ON u.user_id = n.user_id AND n.opened_at IS NOT NULL;

--
-- Count the number of cities with more than 50 active users.
--
SELECT COUNT(DISTINCT u.city) AS city_count, c.city
FROM USERS u
LEFT JOIN SUBSCRIPTION s ON s.user_id = u.user_id
WHERE s.status = 'active'
GROUP BY c.city
HAVING city_count > 50;


--
-- Use a CTE to return each user's total number of notifications received and sort by the highest count.
--
WITH UserNotificationCounts AS (
    SELECT 
        n.user_id, 
        COUNT(n.notification_id) AS total_notifications
    FROM 
        NOTIFICATIONS n
    GROUP BY 
        n.user_id
)

SELECT 
    u.user_id, 
    u.username, 
    unc.total_notifications
FROM 
    USERS u
LEFT JOIN 
    UserNotificationCounts unc ON u.user_id = unc.user_id
ORDER BY 
    total_notifications DESC;

--
-- Use a window function to get each user's most recent notification date.
--
WITH RankedNotifications AS (
    SELECT 
        n.user_id,
        n.sent_at,
        ROW_NUMBER() OVER (PARTITION BY n.user_id ORDER BY n.sent_at DESC) AS rn
    FROM 
        NOTIFICATIONS n
)

SELECT 
    u.user_id,
    u.username,
    rn.sent_at AS most_recent_notification_date
FROM 
    USERS u
LEFT JOIN 
    RankedNotifications rn ON u.user_id = rn.user_id
WHERE 
    rn.rn = 1;
