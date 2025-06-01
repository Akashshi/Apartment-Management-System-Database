CREATE PROCEDURE usp_Post_Notice
    @jsonInput NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @title VARCHAR(100),
            @message TEXT,
            @posted_by VARCHAR(100);

    -- Parse JSON input
    SET @title      = JSON_VALUE(@jsonInput, '$.title');
    SET @message    = JSON_VALUE(@jsonInput, '$.message');
    SET @posted_by  = JSON_VALUE(@jsonInput, '$.posted_by');

    BEGIN TRY
        INSERT INTO TBL_DIM_Notices (title, message, posted_by)
        VALUES (@title, @message, @posted_by);

        PRINT 'Notice posted successfully.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;
GO
