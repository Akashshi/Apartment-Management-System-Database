CREATE PROCEDURE usp_Get_AvailableResidents
    @flat_number VARCHAR(20) = NULL,
    @ownership_status VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Declare the result set
    SELECT
        resident_id,
        First_name,
        Last_name,
        flat_number,
        email,
        phone_number,
        ownership_status,
        join_date
	FROM TBL_DIM_Residents
    WHERE
        (@flat_number IS NULL OR flat_number = @flat_number)
        AND (@ownership_status IS NULL OR ownership_status = @ownership_status)
    FOR JSON AUTO, INCLUDE_NULL_VALUES;
END;
GO
