CREATE PROCEDURE usp_POST_MaintenanceStaffInformation
    @jsonInput NVARCHAR(MAX),
    @operation_type VARCHAR(10),  -- Expected values: INSERT, UPDATE, DELETE
    @changed_by NVARCHAR(100) = SYSTEM_USER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @staff_id INT = JSON_VALUE(@jsonInput, '$.staff_id');

    -- Table variable to parse input
    DECLARE @staffData TABLE (
        staff_id          INT,
        First_name        VARCHAR(50),
        Last_name         VARCHAR(50),
        role              VARCHAR(50),
        phone_number      VARCHAR(15)
    );

    -- Parse input JSON
    INSERT INTO @staffData (staff_id, First_name, Last_name, role, phone_number)
    SELECT
        JSON_VALUE(@jsonInput, '$.staff_id'),
        JSON_VALUE(@jsonInput, '$.First_name'),
        JSON_VALUE(@jsonInput, '$.Last_name'),
        JSON_VALUE(@jsonInput, '$.role'),
        JSON_VALUE(@jsonInput, '$.phone_number');

    BEGIN TRY
        IF @operation_type = 'INSERT'
        BEGIN
            DECLARE @Inserted TABLE (
                staff_id INT,
                First_name VARCHAR(50),
                Last_name VARCHAR(50),
                role VARCHAR(50),
                phone_number VARCHAR(15)
            );

            INSERT INTO TBL_DIM_MaintenanceStaff (First_name, Last_name, role, phone_number)
            OUTPUT 
                INSERTED.staff_id,
                INSERTED.First_name,
                INSERTED.Last_name,
                INSERTED.role,
                INSERTED.phone_number
            INTO @Inserted
            SELECT First_name, Last_name, role, phone_number
            FROM @staffData;

            -- Audit logging
            INSERT INTO TBL_Fact_MaintenanceStaff_AuditLog (
                staff_id, operation_type, changed_at, changed_by, old_data, new_data
            )
            SELECT 
                staff_id, 'INSERT', GETDATE(), @changed_by, NULL,
                (SELECT * FROM @Inserted i WHERE i.staff_id = ins.staff_id FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
            FROM @Inserted ins;

            PRINT 'Maintenance staff inserted successfully with audit log.';
        END

        ELSE IF @operation_type = 'UPDATE'
        BEGIN
            -- Capture old data
            DECLARE @OldData TABLE (
                staff_id INT,
                First_name VARCHAR(50),
                Last_name VARCHAR(50),
                role VARCHAR(50),
                phone_number VARCHAR(15)
            );

            INSERT INTO @OldData
            SELECT * FROM TBL_DIM_MaintenanceStaff WHERE staff_id = @staff_id;

            -- Update
            UPDATE TBL_DIM_MaintenanceStaff
            SET 
                First_name = d.First_name,
                Last_name = d.Last_name,
                role = d.role,
                phone_number = d.phone_number
            FROM TBL_DIM_MaintenanceStaff t
            INNER JOIN @staffData d ON t.staff_id = d.staff_id;

            -- Capture new state
            DECLARE @NewData TABLE (
                staff_id INT,
                First_name VARCHAR(50),
                Last_name VARCHAR(50),
                role VARCHAR(50),
                phone_number VARCHAR(15)
            );

            INSERT INTO @NewData
            SELECT * FROM TBL_DIM_MaintenanceStaff WHERE staff_id = @staff_id;

            -- Audit log
            INSERT INTO TBL_Fact_MaintenanceStaff_AuditLog (
                staff_id, operation_type, changed_at, changed_by, old_data, new_data
            )
            SELECT 
                staff_id, 'UPDATE', GETDATE(), @changed_by,
                (SELECT * FROM @OldData FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
                (SELECT * FROM @NewData FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
            FROM @NewData;

            PRINT 'Maintenance staff updated successfully with audit log.';
        END

        ELSE IF @operation_type = 'DELETE'
        BEGIN
            DECLARE @DeletedData TABLE (
                staff_id INT,
                First_name VARCHAR(50),
                Last_name VARCHAR(50),
                role VARCHAR(50),
                phone_number VARCHAR(15)
            );

            -- Capture data before delete
            INSERT INTO @DeletedData
            SELECT * FROM TBL_DIM_MaintenanceStaff WHERE staff_id = @staff_id;

            -- Delete
            DELETE FROM TBL_DIM_MaintenanceStaff WHERE staff_id = @staff_id;

            -- Audit log
            INSERT INTO TBL_Fact_MaintenanceStaff_AuditLog (
                staff_id, operation_type, changed_at, changed_by, old_data, new_data
            )
            SELECT 
                staff_id, 'DELETE', GETDATE(), @changed_by,
                (SELECT * FROM @DeletedData FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
                NULL
            FROM @DeletedData;

            PRINT 'Maintenance staff deleted successfully with audit log.';
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
