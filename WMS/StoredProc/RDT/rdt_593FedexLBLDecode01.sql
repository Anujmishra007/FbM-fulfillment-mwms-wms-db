SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_593FedexLBLDecode01                                   */
/*                                                                            */
/* Customer: Granite                                                          */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2018-02-07 1.0  NLT03      FCR-727 Create                                  */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_593FedexLBLDecode01] (
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
   @cErrMsg          NVARCHAR( 20)  OUTPUT    
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cLabelNo    NVARCHAR(20)    
   DECLARE @c_OutputString NVARCHAR(MAX)
   DECLARE @c_InputString  NVARCHAR(MAX)
 

   SET @nErrNo = 0
   SET @cErrMsg = ''
   SET @cPrintTemplate = ''
   SET @cLabelNo = @cByRef1

   SELECT @c_InputString = PrintData
   FROM dbo.CartonTrack WITH (NOLOCK)
   WHERE CarrierRef1 = @cLabelNo

   EXEC master.dbo.isp_BASe64Decode 'UTF-8', @c_InputString, @c_OutputString OUTPUT,@cErrMsg OUTPUT

   SET @cPrintData = @c_OutputString

Fail:
   RETURN
Quit:
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [RDT].[rdt_593FedexLBLDecode01] TO [NSQL]
GO
