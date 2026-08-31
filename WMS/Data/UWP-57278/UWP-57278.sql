USE [GTApps];
BEGIN TRY
    BEGIN TRANSACTION

    UPDATE SCE_DLGroups SET GroupName='GVT Admin'  WHERE ConfigID IN (SELECT ConfigID FROM SCE_DLConfig WHERE WebApiConfigID IN
                        (SELECT WebApiConfigID FROM SCE_DLWebApiConfig WHERE Application='GVT'))
                        AND GroupName='Administrator';

    COMMIT TRANSACTION;
    PRINT 'Update Successful.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

    PRINT 'Update Failed due to an Error.';
	PRINT ERROR_MESSAGE();
END CATCH;
