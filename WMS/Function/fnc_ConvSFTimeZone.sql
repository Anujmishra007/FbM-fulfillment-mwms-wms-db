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
/* Date         Author        Purposes                                  */
/* 2023-09-14   1.0      Initial Version								         */
/************************************************************************/
CREATE OR ALTER FUNCTION [dbo].[fnc_ConvSFTimeZone]
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

 
   SELECT TOP 1 
      @cTimeZone=ISNULL([SValue],'')
   FROM [dbo].[StorerConfig] WITH (NOLOCK) 
   WHERE [StorerKey] = @cStorerKey
   AND [Facility] = @cFacility
   AND [ConfigKey] = 'TimeZone'

   IF ISNULL(@cTimeZone,'') = ''
   BEGIN
      SELECT TOP 1 
         @cTimeZone=ISNULL([SValue],'')
      FROM [dbo].[StorerConfig] WITH (NOLOCK) 
      WHERE [StorerKey] = @cStorerKey
      AND [Facility] = ''
      AND [ConfigKey] = 'TimeZone'       
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

   RETURN @dLocalTime

END
