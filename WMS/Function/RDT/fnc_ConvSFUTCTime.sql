/****** Object:  UserDefinedFunction [dbo].[fnc_ConvSFUTCTime]    Script Date: 11/16/2023 4:49:31 PM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Function: fnc_ConvSFUTCTime                                   */
/* Creation Date: 2023-09-14                                            */
/* Copyright: Maersk                                                    */
/* Written by:Shong                                                     */
/*                                                                      */
/* Purpose: Support multi TimeZone, convert Local time to UTC Time      */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* GIT Version: 1.0                                                     */
/*                                                                      */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 2023-09-14   1.0      SWT  Initial Version								   */
/* 2024-01-22   1.1      SWT  Not doing any convertion if Input Date not*/
/*                            timestamp                                 */
/************************************************************************/
CREATE OR ALTER   FUNCTION [dbo].[fnc_ConvSFUTCTime]
(
    @cStorerKey NVARCHAR(15)='',
	 @cFacility  NVARCHAR(5)='',
    @dLocalTime DATETIME
)
RETURNS DATETIME
AS
BEGIN
   DECLARE @cTimeZone VARCHAR(100)= '', 
           @dUTCDate  DATETIME 

   -- If UTC Date do not have time, then do nothing
   IF @dLocalTime = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dLocalTime, 120))
   BEGIN
       SET @dUTCDate = @dLocalTime
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

      IF ISNULL(@cTimeZone,'') = '' AND 
         NOT EXISTS(SELECT 1 FROM sys.[time_zone_info]
                    WHERE [name]= @cTimeZone)
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
         SET @dUTCDate = @dLocalTime
      END
      ELSE
      BEGIN      
         SELECT @dUTCDate = CONVERT(DATETIME,
                   @dLocalTime AT TIME ZONE @cTimeZone
                       AT TIME ZONE 'UTC');
      END
   END

   RETURN @dUTCDate

END
GO


