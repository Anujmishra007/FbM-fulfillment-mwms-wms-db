USE [HKWMS]
GO

/****** Object:  StoredProcedure [RDT].[rdt_1628ExtValid01]    Script Date: 6/1/2018 1:45:51 AM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_1628ExtValid01                                  */
/* Purpose: Cluster Pick Drop ID validation (ID+LoadKey)                */
/*                                                                      */
/* Called from: rdtfnc_Cluster_Pick                                     */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 30-Nov-2017 1.0  James      WMS3572. Created                         */
/************************************************************************/

ALTER PROC [RDT].[rdt_1628ExtValid01] (
   @nMobile          INT,
   @nFunc            INT, 
   @cLangCode        NVARCHAR( 3), 
   @nStep            INT, 
   @nInputKey        INT, 
   @cStorerkey       NVARCHAR( 15), 
   @cWaveKey         NVARCHAR( 10), 
   @cLoadKey         NVARCHAR( 10), 
   @cOrderKey        NVARCHAR( 10), 
   @cLoc             NVARCHAR( 10), 
   @cDropID          NVARCHAR( 20), 
   @cSKU             NVARCHAR( 20), 
   @nQty             INT, 
   @nErrNo           INT           OUTPUT, 
   @cErrMsg          NVARCHAR( 20) OUTPUT
)
AS

   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF  

   SET @nErrNo = 0

   IF @nInputKey = 1
   BEGIN
      IF @nStep = 7
      BEGIN
         IF ISNULL( @cLoadKey, '') = ''
         BEGIN
            SET @nErrNo = 117551
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'No LoadKey'
            GOTO Quit
         END

         IF SUBSTRING(@cDropID, 1, 2) + SUBSTRING(@cDropID, 3, 10) <> 'ID' + @cLoadKey
         BEGIN
            SET @nErrNo = 117552
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'Invalid DropId'
            GOTO Quit
         END
      END
   END

QUIT:

GO


