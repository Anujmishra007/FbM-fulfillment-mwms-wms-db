/****** Object:  UserDefinedFunction [dbo].[fnc_ConvSFTimeZone]    Script Date: 11/16/2023 4:49:19 PM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Function: fnc_ConvSFTimeZone                                  */
/* Creation Date: 2023-09-14                                            */
/* Copyright: Maersk                                                    */
/* Written by:Shong                                                     */
/*                                                                      */
/* Purpose: Support multi TimeZone, convert UTC date to Local Time      */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* GIT Version: 1.0                                                     */
/*                                                                      */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   By   Purposes                                  */
/* 2023-09-14   1.0      SWT  Initial Version								   */
/* 2024-01-22   1.1      SWT  Not doing any convertion if Input Date not*/
/*                            timestamp                                 */
/************************************************************************/
CREATE OR ALTER   FUNCTION [dbo].[fnc_ConvSFTimeZone]
(
    @cStorerKey NVARCHAR(15)='',
	 @cFacility  NVARCHAR(5)='',
    @dUTCDate   DATETIME
)
RETURNS DATETIME
AS
BEGIN
   DECLARE @cTimeZone VARCHAR(100)= '', 
           @dLocalTime DATETIME 

   -- If UTC Date do not have time, then do nothing
   IF @dUTCDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dUTCDate, 120))
   BEGIN
       SET @dLocalTime = @dUTCDate 
   END
   ELSE 
   BEGIN
      SELECT TOP 1 
         @cTimeZone=ISNULL([SValue],'')
      FROM [dbo].[StorerConfig] WITH (NOLOCK) 
      WHERE [StorerKey] = @cStorerKey
      AND [Facility] = @cFacility
      AND [ConfigKey] = 'TimeZone'
      ORDER BY [AddDate] DESC

      IF ISNULL(@cTimeZone,'') = ''
      BEGIN
         SELECT TOP 1 
            @cTimeZone=ISNULL([SValue],'')
         FROM [dbo].[StorerConfig] WITH (NOLOCK) 
         WHERE [StorerKey] = @cStorerKey
         AND [Facility] = ''
         AND [ConfigKey] = 'TimeZone'       
         ORDER BY [AddDate] DESC
      END

      IF ISNULL(@cTimeZone,'') = '' OR 
         NOT EXISTS(SELECT 1 FROM sys.[time_zone_info]
                    WHERE [name]= @cTimeZone)
      BEGIN
         SET @dLocalTime = @dUTCDate 
      END
      ELSE
      BEGIN
         SELECT @dLocalTime = CONVERT(DATETIME,
                   @dUTCDate AT TIME ZONE 'UTC'
                       AT TIME ZONE @cTimeZone);

      END       
   END

   RETURN @dLocalTime

END
GO

GRANT EXECUTE ON [dbo].[fnc_ConvSFTimeZone] TO NSQL

GO
