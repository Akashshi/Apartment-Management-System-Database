CREATE PROCEDURE usp_GetUnreadResidentNotifications
    @flat_number VARCHAR(20),
    @from_date DATE = NULL,
    @to_date DATE = NULL,
    @mark_as_read BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Get resident_id
    DECLARE @resident_id INT;

    SELECT @resident_id = resident_id
    FROM TBL_DIM_Residents
    WHERE flat_number = @flat_number;

    IF @resident_id IS NULL
    BEGIN
        RAISERROR('Resident not found for the provided flat number.', 16, 1);
        RETURN;
    END

    -- Step 2: Filter unread notifications based on date range
    DECLARE @notifications TABLE (
        notification_id INT
    );

    INSERT INTO @notifications (notification_id)
    SELECT notification_id
    FROM TBL_DIM_ResidentNotifications
    WHERE resident_id = @resident_id
      AND is_read = 0
      AND (@from_date IS NULL OR CAST(sent_at AS DATE) >= @from_date)
      AND (@to_date IS NULL OR CAST(sent_at AS DATE) <= @to_date);

    -- Step 3: Mark notifications as read if requested
    IF @mark_as_read = 1
    BEGIN
        UPDATE TBL_DIM_ResidentNotifications
        SET is_read = 1
        WHERE notification_id IN (SELECT notification_id FROM @notifications);
    END

    -- Step 4: Return unread notifications in JSON format
    SELECT
        N.notification_id,
        R.name AS resident_name,
        R.flat_number,
        N.message,
        N.sent_at,
        N.is_read
    FROM TBL_DIM_ResidentNotifications N
    INNER JOIN TBL_DIM_Residents R ON N.resident_id = R.resident_id
    WHERE N.notification_id IN (SELECT notification_id FROM @notifications)
    ORDER BY N.sent_at DESC
    FOR JSON PATH, ROOT('notifications');
END;
