CREATE PROCEDURE usp_Get_WorkAssignments
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT
            fa.assignment_id,
            fa.assigned_on,
            fa.request_status,
            fa.completed_on,

            -- Maintenance Request Info
            mr.request_id,
            mr.category,
            mr.description,
            mr.status AS request_current_status,
            mr.created_on,
            mr.resolved_on,

            -- Assigned Staff Info
            ms.staff_id,
            ms.name AS staff_name,
            ms.role AS staff_role,
            ms.phone_number AS staff_phone

        FROM TBL_Fact_WorkAssignments fa
        INNER JOIN TBL_DIM_MaintenanceRequests mr ON fa.request_id = mr.request_id
        INNER JOIN TBL_Dim_MaintenanceStaff ms ON fa.staff_id = ms.staff_id

        FOR JSON PATH, ROOT('WorkAssignments');
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;
GO
