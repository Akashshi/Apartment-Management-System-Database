CREATE PROCEDURE usp_Get_MaintenanceRequests
    @flat_number VARCHAR(20),
    @start_date DATE = NULL,
    @end_date DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        r.flat_number,
        r.name AS resident_name,
        mr.request_id,
        mr.category,
        mr.description,
        mr.status,
        mr.created_at,
        mr.resolved_at
    FROM TBL_DIM_MaintenanceRequests mr
    INNER JOIN TBL_DIM_Residents r ON mr.resident_id = r.resident_id
    WHERE r.flat_number = @flat_number
      AND (@start_date IS NULL OR mr.created_at >= @start_date)
      AND (@end_date IS NULL OR mr.created_at <= @end_date)
    ORDER BY mr.created_at DESC
    FOR JSON PATH, ROOT('MaintenanceRequests');
END;
GO
