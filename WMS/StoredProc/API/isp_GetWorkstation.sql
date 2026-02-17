SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: isp_GetWorkstation                                        */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2020-05-05   1.0  Chermaine  Created                                       */
/* 2021-09-05   1.1  Chermaine  TPS-11 ErrMsg add to rdtmsg (cc01)            */
/* 2025-02-14   1.2  yeekung    TPS-995 Change Error Message (yeekung01)      */
/* 2025-02-20   1.3  yeekung    UWP-27764 Add New Params (yeekung02)          */
/* 2025-03-26   1.4  yeekung    UWP-31832 Filter out userid in appsection     */
/*                              (yeekung03)                                   */
/* 2025-04-25   2.2  GCH225     Enhanced the whole logic with support V0 & V2 */
/* 2025-07-24   2.3  GCH225     UWP-38019 New Shared Workstation Flow         */
/******************************************************************************/

CREATE OR ALTER PROC [API].[isp_GetWorkstation] (
   @json       NVARCHAR( MAX),
   @jResult    NVARCHAR( MAX) OUTPUT,
   @b_Success  INT = 1  OUTPUT,
   @n_Err      INT = 0  OUTPUT,
   @c_ErrMsg   NVARCHAR( 255) = ''  OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE
   @cLangCode           NVARCHAR( 3),
   @cUserName           NVARCHAR( 128),
   @cStorerKey          NVARCHAR( 15) = '',
   @cFacility           NVARCHAR( 5) = '',
   @nFunc               INT,
   @cDeviceID           NVARCHAR( 50),
   @cDefaultWorkstation NVARCHAR( 30),
   @cTargetVersion      NVARCHAR( 12),
   @cCurrentVersion     NVARCHAR( 12),
   @cSQL                NVARCHAR( 1000),
   @cSQLParam           NVARCHAR( 1000)

DECLARE @tempworkstation TABLE (
   workstation NVARCHAR( 30)
)

--Decode Json Format
SELECT @nFunc=Func, @cLangCode = LangCode, @cDeviceID = Device, @cStorerKey = Storerkey ,@cFacility  = Facility, @cUserName = UserName
FROM OPENJSON(@json)
WITH (
	   Func        INT,
      LangCode    NVARCHAR( 3),
      Device      NVARCHAR( 50),
      Storerkey   NVARCHAR( 15),
      Facility    NVARCHAR(  5),
      UserName      NVARCHAR( 128)
)

IF @cDeviceID <>''
BEGIN
   IF ISNULL(@cDeviceID,'') NOT LIKE 'Web%'
   BEGIN
      SELECT @cDefaultWorkstation = workstation, @cTargetVersion = ISNULL(TargetVersion,''), @cCurrentVersion = ISNULL(CurrentVersion,'')
      FROM API.AppWorkstation (NOLOCK)  
      WHERE DeviceID = @cDeviceID

      IF ISNULL(@cDefaultWorkstation,'') = '' 
      BEGIN
         IF NOT EXISTS (SELECT TOP 1 1 FROM Api.AppWorkstation WITH (NOLOCK) WHERE DeviceID ='')
         BEGIN
            SET @b_Success = 0
            SET @n_Err = 1001301
            SET @c_ErrMsg =  API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No workstation available for device setup. Please ensure workstation has been setup. Funtion : isp_GetWorkstation'
            GOTO EXIT_SP
         END
      END

      INSERT INTO @tempworkstation (workstation)
      SELECT WorkStation 
      FROM Api.AppWorkstation WITH (NOLOCK)
      WHERE DeviceID = ''
   END
   ELSE
   BEGIN
      SET @cDeviceID = @cDeviceID + @cUserName
      SELECT @cDefaultWorkstation = workstation, @cTargetVersion = ISNULL(TargetVersion,''), @cCurrentVersion = ISNULL(CurrentVersion,'')
      FROM API.AppWorkstation (NOLOCK)  
      WHERE DeviceID = @cDeviceID
      AND DefaultStorerkey = @cStorerKey
      AND DefaultFacility = @cFacility

      INSERT INTO @tempworkstation (workstation)
      SELECT WorkStation 
      FROM Api.AppWorkstation WITH (NOLOCK)
      WHERE DeviceID = ''
      AND ((DefaultStorerkey = @cStorerKey AND DefaultFacility = @cFacility)
      OR (DefaultStorerkey = 'SHARE' AND DefaultFacility = @cFacility))
   END

   SET @jResult =(
      SELECT @cDefaultWorkstation AS DefaultWorkstation,@cCurrentVersion AS CurrentVersion, @cTargetVersion AS TargetVersion,* FROM (
      SELECT '[' +STUFF(( SELECT ',' + '"' + workstation  + '"' FROM @tempworkstation FOR XML PATH('')),1,1,'')+ ']' as WorkStationList
      )WorkStationList1
      FOR JSON AUTO , INCLUDE_NULL_VALUES
      )
END
ELSE
BEGIN
	SET @b_Success = 0
   SET @n_Err = 1001302
   SET @c_ErrMsg =  API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Device ID setup not done. Please setup the Device ID. Funtion : isp_GetWorkstation'

   GOTO EXIT_SP
END

EXIT_SP:
   REVERT

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_GetWorkstation TO NSQL
GO


