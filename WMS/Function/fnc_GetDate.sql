
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: fnc_GetDate                                        */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 23-May-2025  Shong         Replacing GetDate() for UTC Date          */
/************************************************************************/
CREATE OR ALTER FUNCTION [dbo].[fnc_GetDate] ()
RETURNS DATETIME AS
BEGIN
   DECLARE @d_WMS_Date DATETIME = GETDATE()

   RETURN @d_WMS_Date  
END 
GO
GRANT EXECUTE ON  [dbo].[fnc_GetDate] TO [NSQL]
GO

