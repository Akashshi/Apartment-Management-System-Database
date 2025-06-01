CREATE PROCEDURE usp_POST_UpdateMaintenanceRequestStatus
    @jsonInput NVARCHAR(MAX),
    @changed_by NVARCHAR(100) = SYSTEM_USER
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Extract JSON values
    DECLARE @request_id INT = JSON_VALUE(@jsonInput, '$.request_id');
    DECLARE @status VARCHAR(20) = JSON_VALUE(@jsonInput, '$.status');
    DECLARE @comments TEXT = JSON_VALUE(@jsonInput, '$.maintenance_comments');

    -- Step 2: Validate status
    IF @status NOT IN ('Open', 'In Progress', 'Resolved')
    BEGIN
        RAISERROR('Invalid status value provided. Valid values: Open, In Progress, Resolved.', 16, 1);
        RETURN;
    END

    -- Step 3: Check if request exists
    IF NOT EXISTS (SELECT 1 FROM TBL_DIM_MaintenanceRequests WHERE request_id = @request_id)
    BEGIN
        RAISERROR('Request ID does not exist or has already been resolved.', 16, 1);
        RETURN;
    END

    -- Step 4: Update the maintenance request
    UPDATE TBL_DIM_MaintenanceRequests
    SET 
        status = @status,
        maintenance_comments = @comments,
        resolved_On = CASE WHEN @status IN ('Resolved') THEN GETDATE() ELSE deleted_at END
    WHERE request_id = @request_id;

    -- Step 5: Notify resident if resolved or closed
    IF @status IN ('Resolved')
    BEGIN
        DECLARE @resident_id INT;
        SELECT @resident_id = resident_id FROM TBL_DIM_MaintenanceRequests WHERE request_id = @request_id;

        INSERT INTO TBL_ResidentNotifications (resident_id, message)
        VALUES (
            @resident_id,
            CONCAT('Your maintenance request (ID: ', @request_id, ') has been marked as "', @status, '". Comments: ', ISNULL(@comments, 'None'), '. Thank you!')
        );
    END

    PRINT 'Maintenance request status updated successfully.';
END;
