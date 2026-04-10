SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/      
/* Store procedure: isp_ShipLabel06_RP                                     */      
/* Copyright      : Maersk                                                 */      
/*                                                                         */      
/* Date       Rev  Author    Purposes                                      */      
/* 2026-04-10 1.0  NYE018    FCR-12284 Created                             */
/***************************************************************************/      
      
CREATE OR ALTER PROC [dbo].[isp_ShipLabel06_RP] (      
   @nMobile          INT,       
   @nFunc            INT,       
   @cLangCode        NVARCHAR( 3),       
   @cStorerKey       NVARCHAR( 15),       
   @cByRef1          NVARCHAR( 20),       
   @cByRef2          NVARCHAR( 20),       
   @cByRef3          NVARCHAR( 20),       
   @cByRef4          NVARCHAR( 20),       
   @cByRef5          NVARCHAR( 20),       
   @cByRef6          NVARCHAR( 20),       
   @cByRef7          NVARCHAR( 20),       
   @cByRef8          NVARCHAR( 20),       
   @cByRef9          NVARCHAR( 20),       
   @cByRef10         NVARCHAR( 20),       
   @cPrintTemplate   NVARCHAR( MAX),       
   @cPrintData       NVARCHAR( MAX) OUTPUT,      
   @nErrNo           INT            OUTPUT,      
   @cErrMsg          NVARCHAR( 20)  OUTPUT,
   @cCodePage        NVARCHAR( 50) = ''  OUTPUT          
)      
AS      
   SET NOCOUNT ON      
   SET QUOTED_IDENTIFIER OFF      
   SET ANSI_NULLS OFF      
   SET CONCAT_NULL_YIELDS_NULL OFF    
       
   DECLARE @cShipperKey    NVARCHAR( 15)
         , @cLabelNo       NVARCHAR(20)
         , @cBase64Data    NVARCHAR(MAX)
         , @cDecodedData   NVARCHAR(MAX)
         , @cDecodeErrMsg  NVARCHAR(200)

   SET @nErrNo = 0
   SET @cErrMsg = ''
   SET @cPrintTemplate = ''


   SET @cLabelNo           = @cByRef1

   SELECT @cShipperKey = ShipperKey
   FROM dbo.ORDERS WITH (NOLOCK)
   WHERE OrderKey = @cLabelNo

   SELECT @cBase64Data = PrintData
   FROM dbo.CartonTrack WITH (NOLOCK)
   WHERE LabelNo = @cLabelNo
   AND   CarrierName = @cShipperKey

   -- Decode base64 data
   IF @cBase64Data IS NOT NULL AND LEN(@cBase64Data) > 0
   BEGIN
      EXEC master.dbo.isp_BASe64Decode 'UTF-8', @cBase64Data, @cDecodedData OUTPUT, @cDecodeErrMsg OUTPUT

      IF @cDecodeErrMsg <> ''
      BEGIN
         SET @nErrNo = 263701
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 263701^Base64DecodeErr
         GOTO Quit
      END

      SET @cPrintTemplate = @cDecodedData
   END

   SET @cPrintData = @cPrintTemplate

   SET @cCodePage = '850'     
   
   GOTO Quit      
         
Quit:      
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [dbo].[isp_ShipLabel06_RP] TO [NSQL]
GO
