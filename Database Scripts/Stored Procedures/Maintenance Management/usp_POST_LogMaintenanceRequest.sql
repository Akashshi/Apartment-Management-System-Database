CREATE PROCEDURE usp_POST_LogMaintenanceRequest
    @jsonInput NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @flat_number VARCHAR(20),
        @category VARCHAR(50),
        @description TEXT,
        @resident_id INT;

    -- Extract values from JSON
    SET @flat_number = JSON_VALUE(@jsonInput, '$.flat_number');
    SET @category = JSON_VALUE(@jsonInput, '$.category');
    SET @description = JSON_VALUE(@jsonInput, '$.description');

    -- Fetch resident_id using flat_number
    SELECT @resident_id = resident_id
    FROM TBL_DIM_Residents
    WHERE flat_number = @flat_number;

    IF @resident_id IS NULL
    BEGIN
        RAISERROR('Flat number not found or resident is inactive.', 16, 1);
        RETURN;
    END

    -- Insert maintenance request
    BEGIN TRY
        INSERT INTO TBL_DIM_MaintenanceRequests (resident_id, category, description)
        VALUES (@resident_id, @category, @description);

        -- Confirmation message
        SELECT 
            'Maintenance team has received your request. They shall be reaching out soon.' AS message;
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
GO
