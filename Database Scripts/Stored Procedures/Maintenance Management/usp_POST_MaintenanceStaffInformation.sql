CREATE PROCEDURE usp_POST_MaintenanceStaffInformation
    @jsonInput NVARCHAR(MAX),
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

    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;
GO
