CREATE PROCEDURE usp_Post_ResidentInformation
    @jsonInput NVARCHAR(MAX),
    @operation_type VARCHAR(10),  -- Expected: 'INSERT', 'UPDATE', or 'DELETE'
    @changed_by NVARCHAR(100) = SYSTEM_USER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @resident_id INT = JSON_VALUE(@jsonInput, '$.resident_id');

    -- Table to hold parsed input
    DECLARE @residentData TABLE (
        resident_id       INT,
        First_name        VARCHAR(50),
        Last_name         VARCHAR(50),
        flat_number       VARCHAR(20),
        email             VARCHAR(100),
        phone_number      VARCHAR(15),
        ownership_status  VARCHAR(10),
        join_date         DATE
    );

    -- Parse input JSON
    INSERT INTO @residentData (resident_id, First_name, Last_name, flat_number, email, phone_number, ownership_status, join_date)
    SELECT
        JSON_VALUE(@jsonInput, '$.resident_id'),
        JSON_VALUE(@jsonInput, '$.First_name'),
        JSON_VALUE(@jsonInput, '$.Last_name'),
        JSON_VALUE(@jsonInput, '$.flat_number'),
        JSON_VALUE(@jsonInput, '$.email'),
        JSON_VALUE(@jsonInput, '$.phone_number'),
        JSON_VALUE(@jsonInput, '$.ownership_status'),
        TRY_CAST(JSON_VALUE(@jsonInput, '$.join_date') AS DATE);

    BEGIN TRY
        IF @operation_type = 'INSERT'
        BEGIN
            DECLARE @Inserted TABLE (
                resident_id INT,
                First_name VARCHAR(50),
                Last_name VARCHAR(50),
                flat_number VARCHAR(20),
                email VARCHAR(100),
                phone_number VARCHAR(15),
                ownership_status VARCHAR(10),
                join_date DATE
            );

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
            INTO @Inserted
            SELECT First_name, Last_name, flat_number, email, phone_number, ownership_status, join_date
            FROM @residentData;

            INSERT INTO TBL_Fact_Residents_AuditLog (
                resident_id, operation_type, changed_at, changed_by, old_data, new_data
            )
            SELECT 
                resident_id, 'INSERT', GETDATE(), @changed_by, NULL,
                (SELECT * FROM @Inserted i WHERE i.resident_id = ins.resident_id FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
            FROM @Inserted ins;

            PRINT 'Resident inserted successfully with audit log.';
        END

        ELSE IF @operation_type = 'UPDATE'
        BEGIN
            DECLARE @OldData TABLE (
                resident_id INT,
                First_name VARCHAR(50),
                Last_name VARCHAR(50),
                flat_number VARCHAR(20),
                email VARCHAR(100),
                phone_number VARCHAR(15),
                ownership_status VARCHAR(10),
                join_date DATE
            );

            -- Capture existing record before update
            INSERT INTO @OldData
            SELECT * FROM TBL_DIM_Residents WHERE resident_id = @resident_id;

            -- Perform update
            UPDATE TBL_DIM_Residents
            SET 
                First_name = r.First_name,
                Last_name = r.Last_name,
                flat_number = r.flat_number,
                email = r.email,
                phone_number = r.phone_number,
                ownership_status = r.ownership_status,
                join_date = r.join_date
            FROM TBL_DIM_Residents tr
            INNER JOIN @residentData r ON tr.resident_id = r.resident_id;

            -- Capture new state
            DECLARE @NewData TABLE (
                resident_id INT,
                First_name VARCHAR(50),
                Last_name VARCHAR(50),
                flat_number VARCHAR(20),
                email VARCHAR(100),
                phone_number VARCHAR(15),
                ownership_status VARCHAR(10),
                join_date DATE
            );

            INSERT INTO @NewData
            SELECT * FROM TBL_DIM_Residents WHERE resident_id = @resident_id;

            -- Log into audit table
            INSERT INTO TBL_Fact_Residents_AuditLog (
                resident_id, operation_type, changed_at, changed_by, old_data, new_data
            )
            SELECT 
                resident_id, 'UPDATE', GETDATE(), @changed_by,
                (SELECT * FROM @OldData FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
                (SELECT * FROM @NewData FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
            FROM @NewData;

            PRINT 'Resident updated successfully with audit log.';
        END

        ELSE IF @operation_type = 'DELETE'
        BEGIN
            DECLARE @DeletedData TABLE (
                resident_id INT,
                First_name VARCHAR(50),
                Last_name VARCHAR(50),
                flat_number VARCHAR(20),
                email VARCHAR(100),
                phone_number VARCHAR(15),
                ownership_status VARCHAR(10),
                join_date DATE
            );

            -- Capture row before deletion
            INSERT INTO @DeletedData
            SELECT * FROM TBL_DIM_Residents WHERE resident_id = @resident_id;

            -- Perform delete
            DELETE FROM TBL_DIM_Residents WHERE resident_id = @resident_id;

            -- Log into audit
            INSERT INTO TBL_Fact_Residents_AuditLog (
                resident_id, operation_type, changed_at, changed_by, old_data, new_data
            )
            SELECT 
                resident_id, 'DELETE', GETDATE(), @changed_by,
                (SELECT * FROM @DeletedData FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
                NULL
            FROM @DeletedData;

            PRINT 'Resident deleted successfully with audit log.';
        END

        ELSE
        BEGIN
            RAISERROR('Invalid operation_type. Expected: INSERT, UPDATE, DELETE.', 16, 1);
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;
GO
