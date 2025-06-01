CREATE PROCEDURE usp_Get_Notices
    @FromDate DATE = NULL,
    @ToDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        notice_id,
        title,
        message,
        posted_on,
        posted_by
    FROM TBL_DIM_Notices
    WHERE 
        (@FromDate IS NULL OR posted_on >= @FromDate) AND
        (@ToDate IS NULL OR posted_on <= @ToDate)
    ORDER BY posted_on DESC
    FOR JSON PATH, ROOT('Notices');
END;
GO
