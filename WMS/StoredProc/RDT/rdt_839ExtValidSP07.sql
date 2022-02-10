IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[RDT].[rdt_839ExtValidSP07]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_839ExtValidSP07]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  

/************************************************************************/  
/* Store procedure: rdt_839ExtValidSP07                                 */  
/* Purpose: Validate multiple users performing on same pick task        */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2021-07-06 1.0  James      WMS-17324. Created                        */  
/************************************************************************/  
CREATE PROC rdt.rdt_839ExtValidSP07 (  
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,           
   @nInputKey    INT,           
   @cFacility    NVARCHAR( 5) , 
   @cStorerKey   NVARCHAR( 15), 
   @cType        NVARCHAR( 10), 
   @cPickSlipNo  NVARCHAR( 10), 
   @cPickZone    NVARCHAR( 10),  
   @cDropID      NVARCHAR( 20), 
   @cLOC         NVARCHAR( 10), 
   @cSKU         NVARCHAR( 20), 
   @nQTY         INT,           
   @nErrNo       INT           OUTPUT, 
   @cErrMsg      NVARCHAR(250) OUTPUT  
)  
AS  

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF
  
IF @nFunc = 839  
BEGIN  
   DECLARE @cUserName         NVARCHAR( 18)
          ,@cMobUserName      NVARCHAR( 18)
          ,@cMobPickZone      NVARCHAR( 10)
          ,@nMobStep          INT

          
   SET @nErrNo          = 0
   SET @cErrMSG         = ''

   SELECT @cUserName = UserName
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   
   IF @nStep = 2 
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         SELECT @cMobUserName = UserName,
                @nMobStep = Step,
                @cMobPickZone = V_Zone 
         FROM rdt.RDTMOBREC WITH (NOLOCK)
         WHERE Func = @nFunc
         AND   V_PickSlipNo = @cPickSlipNo
         AND   UserName <> @cUserName
         
         -- Not yet start picking, no need further check
         IF @@ROWCOUNT = 0
            GOTO QUIT

         -- No pickzone key in, check whether pickslip scanin by other user before
         IF ISNULL( @cPickZone, '') = '' AND ISNULL( @cMobPickZone, '') = ''
         BEGIN
            IF @cUserName <> @cMobUserName   
            BEGIN  
               SET @nErrNo = 170401
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'PSNo In Progress'
               GOTO QUIT  
            END  
         END

         -- Check if one of the user didn't key in pickzone (meaning pick all zone)
         -- and another user key in pickzone
         IF (( ISNULL( @cPickZone, '') = '' AND ISNULL( @cMobPickZone, '') <> '') AND @nMobStep > 2) OR
            (( ISNULL( @cPickZone, '') <> '' AND ISNULL( @cMobPickZone, '') = '') AND @nMobStep > 2) 
         BEGIN
            IF @cUserName <> @cMobUserName
            BEGIN  
               SET @nErrNo = 170402
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'ZoneInProgress'
               GOTO QUIT  
            END
         END  

         -- If both user key in same pickzone
         IF ISNULL( @cPickZone, '') = ISNULL( @cMobPickZone, '') 
         BEGIN
            IF @cUserName <> @cMobUserName
            BEGIN  
               SET @nErrNo = 170403
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'ZoneInProgress'
               GOTO QUIT  
            END
         END  
      END
   END
END  
  
QUIT:  

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON RDT.rdt_839ExtValidSP07 TO NSQL
GO
  
 