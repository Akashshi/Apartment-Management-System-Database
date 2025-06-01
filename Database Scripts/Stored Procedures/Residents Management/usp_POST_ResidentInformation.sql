CREATE PROCEDURE usp_Post_ResidentInformation
    @jsonInput NVARCHAR(MAX),
    @changed_by NVARCHAR(100) = SYSTEM_USER -- Optional input: tracks who made the change
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Declare a table variable to parse JSON
    DECLARE @residentData TABLE (
        First_name       VARCHAR(50),
        Last_name        VARCHAR(50),
        flat_number      VARCHAR(20),
        email            VARCHAR(100),
        phone_number     VARCHAR(15),
        ownership_status VARCHAR(10),
        join_date        DATE
    );

    -- Step 2: Parse JSON into table variable
    INSERT INTO @residentData (First_name, Last_name, flat_number, email, phone_number, ownership_status, join_date)
    SELECT 
        JSON_VALUE(@jsonInput, '$.First_name'),
        JSON_VALUE(@jsonInput, '$.Last_name'),
        JSON_VALUE(@jsonInput, '$.flat_number'),
        JSON_VALUE(@jsonInput, '$.email'),
        JSON_VALUE(@jsonInput, '$.phone_number'),
        JSON_VALUE(@jsonInput, '$.ownership_status'),
        TRY_CAST(JSON_VALUE(@jsonInput, '$.join_date') AS DATE);

    -- Step 3: Capture inserted record and insert into main table + audit log
    BEGIN TRY
        DECLARE @InsertedResidents TABLE (
            resident_id INT,
            First_name       VARCHAR(50),
            Last_name        VARCHAR(50),
            flat_number      VARCHAR(20),
            email            VARCHAR(100),
            phone_number     VARCHAR(15),
            ownership_status VARCHAR(10),
            join_date        DATE
        );

        -- Insert into main table and capture output
        INSERT INTO TBL_DIM_Residents (First_name, Last_name, flat_number, email, phone_number, ownership_status, join_date)
        OUTPUT 
            INSERTED.resident_id,
            INSERTED.First_name,
            INSERTED.Last_name,
            INSERTED.flat_number,
            INSERTED.email,
            INSERTED.phone_number,
            INSERTED.ownership_status,
            INSERTED.join_date
        INTO @InsertedResidents
        SELECT First_name, Last_name, flat_number, email, phone_number, ownership_status, join_date
        FROM @residentData;

        -- Insert audit log for each inserted resident
        INSERT INTO TBL_Fact_Residents_AuditLog (
            resident_id,
            operation_type,
            changed_at,
            changed_by,
            old_data,
            new_data
        )
        SELECT
            resident_id,
            'INSERT',
            GETDATE(),
            @changed_by,
            NULL,
            (
                SELECT
                    resident_id,
                    First_name,
                    Last_name,
                    flat_number,
                    email,
                    phone_number,
                    ownership_status,
                    join_date
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            )
        FROM @InsertedResidents;

        PRINT 'Resident inserted and audit log recorded successfully.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;
GO
