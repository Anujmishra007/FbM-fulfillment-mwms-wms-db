CREATE PROCEDURE UpdateStorerConfig
AS
BEGIN
    BEGIN TRY
        -- Perform the update
        UPDATE dbo.StorerConfig
        SET SValue = '0'
        WHERE ConfigKey = 'RealTimeShip'
          AND SValue = '1';

        -- Print success message
        PRINT 'Update completed successfully.';
    END TRY
    BEGIN CATCH
        -- Handle errors
        PRINT 'An error occurred while updating StorerConfig.';
        THROW; -- Re-throw the error for debugging
    END CATCH
END;
