SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Store procedure: rdt_1855MatrixSP03                                  */  
/* Copyright      : IDS                                                 */  
/*                                                                      */  
/* Purpose: Show carton matrix                                          */  
/*                                                                      */  
/* Called from: rdtfnc_TM_Assist_ClusterPick                            */  
/*                                                                      */  
/* Date         Rev  Author   Purposes                                  */  
/* 2026-03-03   1.0  NickT    FCR-10824 Created                         */  
/************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_1855MatrixSP03] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cPickZone      NVARCHAR( 10),
   @cCartID        NVARCHAR( 10),
   @cMethod        NVARCHAR( 1),
   @cResult01      NVARCHAR( 20) OUTPUT,
   @cResult02      NVARCHAR( 20) OUTPUT,
   @cResult03      NVARCHAR( 20) OUTPUT,
   @cResult04      NVARCHAR( 20) OUTPUT,
   @cResult05      NVARCHAR( 20) OUTPUT,
   @nNextPage      INT           OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @curDisplay     CURSOR
   DECLARE 
      @nCartLimit       INT,
      @nCount           INT,
      @cWaveKey         NVARCHAR(10),
      @cGroupKey        NVARCHAR(10),
      @cUserName        NVARCHAR(128)

   SELECT @cWaveKey = C_String1,
      @cGroupKey = V_String12,
      @cUserName = UserName
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile
     
   SELECT @nCartLimit = Short
   FROM dbo.CODELKUP WITH (NOLOCK)
   WHERE LISTNAME = 'TMPICKMTD'
      AND Code = @cMethod
      AND Storerkey = @cStorerKey

   IF @cMethod = '1'
   BEGIN
      SET @cResult01 = 'B2C Singles'
      SET @cResult02 = '1 ToteID is needed'
   END
   ELSE
   BEGIN
      SET @nCount = 1

      SELECT @nCount = COUNT(DISTINCT TD.OrderKey)
      FROM dbo.TaskDetail TD WITH (NOLOCK)
      WHERE TD.Storerkey = @cStorerKey
         AND TD.TaskType = 'ASTCPK'
         AND TD.Status = '3'
         AND TD.UserKey = @cUserName
         AND TD.DeviceID = @cCartID
         AND TD.WaveKey = @cWaveKey
         AND TD.GroupKey = @cGroupKey

      SET @cResult01 = 'B2C Multies'
      SET @cResult02 =  CAST(IIF(@nCartLimit > @nCount, @nCount, @nCartLimit) AS NVARCHAR(5)) + ' ToteID is needed'
   END

   Quit:
END  
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1855MatrixSP03 to nSQL
GO 