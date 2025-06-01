CREATE PROCEDURE usp_Get_MaintenanceStaff
    @role VARCHAR(50) = NULL,
    @available_only BIT = 1,
    @search_name NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        staff_id,
        First_name,
        Last_name,
        role,
        phone_number,
        availability_status,
    FROM TBL_DIM_MaintenanceStaff
    WHERE
        (@role IS NULL OR role = @role)
        AND (@available_only = 0 OR availability_status = 1)
        AND (
            @search_name IS NULL OR 
            First_name LIKE '%' + @search_name + '%' OR 
            Last_name LIKE '%' + @search_name + '%'
        )
    ORDER BY created_at DESC
    FOR JSON AUTO, INCLUDE_NULL_VALUES;
END;
GO
