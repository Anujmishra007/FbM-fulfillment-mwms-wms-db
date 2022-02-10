if exists (select * from dbo.sysobjects where id = object_id(N'[rdt].[rdt_593ConvOrCtnLB]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [rdt].[rdt_593ConvOrCtnLB]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_593ConvOrCtnLB                                        */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2017-04-13 1.0  Ung        WMS-1612 Created                                */
/******************************************************************************/

CREATE PROC rdt.rdt_593ConvOrCtnLB (
   @nMobile    INT,
   @nFunc      INT,
   @nStep      INT,
   @cLangCode  NVARCHAR( 3),
   @cStorerKey NVARCHAR( 15),
   @cOption    NVARCHAR( 1),
   @cParam1    NVARCHAR(20),  -- Label no
   @cParam2    NVARCHAR(20),
   @cParam3    NVARCHAR(20),
   @cParam4    NVARCHAR(20),
   @cParam5    NVARCHAR(20),
   @nErrNo     INT OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cLabelPrinter NVARCHAR( 10)
   DECLARE @cLabelNo      NVARCHAR( 20)
   DECLARE @cPickMethod   NVARCHAR( 1)

   -- Parameter mapping
   SET @cLabelNo = @cParam1

   -- Check blank
   IF @cLabelNo = ''
   BEGIN
      SET @nErrNo = 108451
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --Need LabelNo
      GOTO Quit
   END

   -- Get login info
   SELECT @cLabelPrinter = Printer
   FROM rdt.rdtMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Check data window blank
   IF @cLabelPrinter = ''
   BEGIN
      SET @nErrNo = 108452
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoLabelPrinter
      GOTO Quit
   END

   -- Get PickDetail info
   SELECT TOP 1
      @cPickMethod = PickMethod
   FROM PickDetail (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND Status <> '9'
      AND DropID = @cLabelNo

   -- Check LabelNo valid
   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 108453
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --InvalidLabelNo
      GOTO Quit
   END
   
   /**********************************************************************************************
                                               Routing label
   **********************************************************************************************/
   IF @cPickMethod <> 'P'
   BEGIN   
      EXEC rdt.rdt_593ConveyorLBL01 @nMobile, @nFunc, @nStep, @cLangCode, 
         @cStorerKey,
         @cOption,
         @cParam1,  -- DropID
         @cParam2,
         @cParam3,
         @cParam4,
         @cParam5,
         @nErrNo     OUTPUT,
         @cErrMsg    OUTPUT
   END

   /**********************************************************************************************
                                               Ship label
   **********************************************************************************************/
   IF @cPickMethod = 'P'
   BEGIN   
      EXEC rdt.rdt_593CartonLBL01 @nMobile, @nFunc, @nStep, @cLangCode, 
         @cStorerKey,
         @cOption,
         @cParam1,  -- DropID
         @cParam2,
         @cParam3,
         @cParam4,
         @cParam5,
         @nErrNo     OUTPUT,
         @cErrMsg    OUTPUT
   END      

Quit:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_593ConvOrCtnLB TO NSQL
GO