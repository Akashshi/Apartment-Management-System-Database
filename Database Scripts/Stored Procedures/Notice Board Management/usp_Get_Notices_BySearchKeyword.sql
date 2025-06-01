CREATE PROCEDURE usp_Get_Notices_BySearchKeyword
    @SearchKeyword NVARCHAR(100) = NULL,
    @PostedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT
            notice_id,
            title,
            message,
            posted_on,
            posted_by,
            Validity
        FROM TBL_DIM_Notices
        WHERE
            Validity >= CAST(GETDATE() AS DATE) AND
            (@SearchKeyword IS NULL OR 
             title LIKE '%' + @SearchKeyword + '%' OR 
             message LIKE '%' + @SearchKeyword + '%') AND
            (@PostedBy IS NULL OR posted_by = @PostedBy)
        ORDER BY posted_on DESC
        FOR JSON PATH, ROOT('ValidNotices');
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;
GO
