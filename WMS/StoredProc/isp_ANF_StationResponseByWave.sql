IF (objectProperty(object_id('dbo.isp_ANF_StationResponseByWave'), 'IsProcedure') is not null)
	DROP PROCEDURE [dbo].[isp_ANF_StationResponseByWave] 
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO   

/******************************************************************************/ 
/* Copyright: IDS                                                             */ 
/* Purpose:                                                                   */
/*                                                                            */ 
/* Modifications log:                                                         */ 
/*                                                                            */ 
/* Date       Rev  Author     Purposes                                        */ 
/* 2014-05-19 1.0  ChewKP     Created                                         */
/******************************************************************************/

CREATE PROC [dbo].[isp_ANF_StationResponseByWave] 
(
   @cStorerKey  NVARCHAR(15) 
  ,@cWaveKey    NVARCHAR(10) = ''
  ,@b_Success   INT OUTPUT  
  ,@n_Err       INT OUTPUT
  ,@c_ErrMsg    NVARCHAR(215) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   SELECT O.UserDefine09 AS WAVEKEY,  PD.DropID , SUBSTRING(PD.DropID, PATINDEX('%[^0]%',PD.DropID), 18) AS BOXNUMBER , SP.STATION
   --, SP.Station, SP.Reading_Time
   FROM dbo.PickDetail PD WITH (NOLOCK) 
   INNER JOIN dbo.Orders O WITH (NOLOCK) ON O.OrderKey = PD.OrderKey AND O.StorerKey = PD.StorerKey
   INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON PD.OrderKey = OD.OrderKey AND PD.OrderLineNumber = OD.OrderLineNumber 
   INNER JOIN SDCWCS01.dbo.STATION_RESPONSE SP WITH (NOLOCK) ON CAST(SUBSTRING(ISNULL(PD.DropID,0), PATINDEX('%[^0]%',ISNULL(PD.DropID,0)), 18) AS NUMERIC)  = SP.BoxNumber 
   WHERE O.UserDefine09 = @cWaveKey
   AND PD.StorerKey = @cStorerKey
   AND ISNULL(PD.DropID,'') <> '' 
   --AND PD.Status <> '9'   
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [dbo].[isp_ANF_StationResponseByWave] to nSQL
GO  