CREATE PROCEDURE usp_POST_AssignMaintenanceRequestToStaff
    @jsonInput NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Step 1: Declare table variable to parse JSON
        DECLARE @Assignments TABLE (
            request_id INT,
            staff_id INT,
            request_status VARCHAR(20),
            completed_on DATETIME NULL
        );

        -- Step 2: Parse JSON into table variable
        INSERT INTO @Assignments (request_id, staff_id, request_status, completed_on)
        SELECT 
            JSON_VALUE(@jsonInput, '$.request_id'),
            JSON_VALUE(@jsonInput, '$.staff_id'),
            JSON_VALUE(@jsonInput, '$.request_status'),
            JSON_VALUE(@jsonInput, '$.completed_on');

        -- Step 3: Validate input values
        IF NOT EXISTS (
            SELECT 1 
            FROM TBL_DIM_MaintenanceRequests 
            WHERE request_id = (SELECT request_id FROM @Assignments)
        )
        BEGIN
            RAISERROR('Invalid request_id: No such maintenance request found.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1 
            FROM TBL_DIM_MaintenanceStaff 
            WHERE staff_id = (SELECT staff_id FROM @Assignments)
        )
        BEGIN
            RAISERROR('Invalid staff_id: No such maintenance staff found.', 16, 1);
            RETURN;
        END

        DECLARE @validStatusList TABLE (status VARCHAR(20));
        INSERT INTO @validStatusList (status)
        VALUES ('Open'), ('In Progress'), ('Resolved');

        IF NOT EXISTS (
            SELECT 1
            FROM @validStatusList
            WHERE status = (SELECT request_status FROM @Assignments)
        )
        BEGIN
            RAISERROR('Invalid request_status: Must be Open, In Progress, Resolved, or Closed.', 16, 1);
            RETURN;
        END

        -- Step 4: Insert assignment data
        INSERT INTO TBL_Fact_WorkAssignments (request_id, staff_id, request_status, completed_on)
        SELECT request_id, staff_id, request_status, completed_on
        FROM @Assignments;

        PRINT 'Maintenance request assigned to staff successfully.';

    END TRY
    BEGIN CATCH
        -- Step 5: Handle exceptions
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;
GO
