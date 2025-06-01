CREATE PROCEDURE usp_Get_VisitorLogsWithResidentInfo
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        V.visitor_id,
        V.resident_id,
        V.visitor_name,
        V.purpose,
        V.in_time,
        V.out_time,
        R.First_name AS resident_first_name,
        R.Last_name AS resident_last_name,
        R.flat_number,
        R.email,
        R.phone_number
    FROM TBL_DIM_VisitorLogs V
    INNER JOIN TBL_DIM_Residents R ON V.resident_id = R.resident_id
    FOR JSON PATH, ROOT('VisitorLogsWithResidents');
END;
GO
