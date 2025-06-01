CREATE PROCEDURE usp_POST_ManageVisitorLog
    @jsonInput NVARCHAR(MAX),
    @operation_type VARCHAR(10), -- 'INSERT', 'UPDATE', 'DELETE'
    @changed_by NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @visitor_id INT,
            @resident_id INT,
            @visitor_name VARCHAR(100),
            @purpose VARCHAR(50),
            @in_time DATETIME,
            @out_time DATETIME;

    -- Parse JSON values
    SET @visitor_id = TRY_CAST(JSON_VALUE(@jsonInput, '$.visitor_id') AS INT);
    SET @resident_id = TRY_CAST(JSON_VALUE(@jsonInput, '$.resident_id') AS INT);
    SET @visitor_name = JSON_VALUE(@jsonInput, '$.visitor_name');
    SET @purpose = JSON_VALUE(@jsonInput, '$.purpose');
    SET @in_time = TRY_CAST(JSON_VALUE(@jsonInput, '$.in_time') AS DATETIME);
    SET @out_time = TRY_CAST(JSON_VALUE(@jsonInput, '$.out_time') AS DATETIME);

    BEGIN TRY
        IF @operation_type = 'INSERT'
        BEGIN
            INSERT INTO TBL_DIM_VisitorLogs (resident_id, visitor_name, purpose, in_time, out_time)
            VALUES (@resident_id, @visitor_name, @purpose, ISNULL(@in_time, GETDATE()), @out_time);

            DECLARE @new_id INT = SCOPE_IDENTITY();

            INSERT INTO TBL_Fact_VisitorLogs_AuditLog (visitor_id, operation_type, changed_by, new_data)
            SELECT @new_id, 'INSERT', @changed_by,
                   (SELECT * FROM TBL_DIM_VisitorLogs WHERE visitor_id = @new_id FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
        END

        ELSE IF @operation_type = 'UPDATE'
        BEGIN
            -- Capture old state
            DECLARE @old_json NVARCHAR(MAX);
            SELECT @old_json = (SELECT * FROM TBL_DIM_VisitorLogs WHERE visitor_id = @visitor_id FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE TBL_DIM_VisitorLogs
            SET resident_id = @resident_id,
                visitor_name = @visitor_name,
                purpose = @purpose,
                in_time = @in_time,
                out_time = @out_time
            WHERE visitor_id = @visitor_id;

            -- Capture new state
            INSERT INTO TBL_Fact_VisitorLogs_AuditLog (visitor_id, operation_type, changed_by, old_data, new_data)
            SELECT @visitor_id, 'UPDATE', @changed_by, @old_json,
                   (SELECT * FROM TBL_DIM_VisitorLogs WHERE visitor_id = @visitor_id FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
        END

        ELSE IF @operation_type = 'DELETE'
        BEGIN
            DECLARE @old_del_json NVARCHAR(MAX);
            SELECT @old_del_json = (SELECT * FROM TBL_DIM_VisitorLogs WHERE visitor_id = @visitor_id FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            DELETE FROM TBL_DIM_VisitorLogs WHERE visitor_id = @visitor_id;

            INSERT INTO TBL_Fact_VisitorLogs_AuditLog (visitor_id, operation_type, changed_by, old_data)
            VALUES (@visitor_id, 'DELETE', @changed_by, @old_del_json);
        END
        ELSE
        BEGIN
            RAISERROR('Invalid operation type. Use INSERT, UPDATE, or DELETE.', 16, 1);
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;
GO
