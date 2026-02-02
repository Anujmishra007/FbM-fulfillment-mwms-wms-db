SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_CheckDropID_09                                  */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: Check Drop ID must equal Orders.ExternOrderKey              */
/*          (For Orders.DocType = 'E' only)                             */
/*                                                                      */
/* Called from: rdtfnc_Cluster_Pick                                     */
/*                                                                      */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2022-09-07  1.0  James       WMS-20636. Created                      */
/* 2025-05-15  1.1  Dennis      FCR-3774 Add Validation                 */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_CheckDropID_09] (
   @cFacility                 NVARCHAR( 5),
   @cStorerKey                NVARCHAR( 15),
   @cOrderKey                 NVARCHAR( 10),
   @cDropID                   NVARCHAR( 18),
   @nValid                    INT            OUTPUT,
   @nErrNo                    INT            OUTPUT,
   @cErrMsg                   NVARCHAR( 20)  OUTPUT  -- screen limitation, 20 char max
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @nValid = 1
   
   DECLARE @cExternOrderKey NVARCHAR( 50)
   DECLARE @cDocType        NVARCHAR( 1)
   DECLARE @nFunc           INT
   DECLARE @cLangCode       NVARCHAR( 3),
   @cOutField09             NVARCHAR( 60)
   
   SELECT 
      @cExternOrderKey = ExternOrderKey, 
      @cDocType = DocType
   FROM dbo.Orders WITH (NOLOCK)
   WHERE OrderKey = @cOrderKey

   SELECT 
      @nFunc = Func,
      @cLangCode = Lang_Code,
      @cOutField09 = O_Field09
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE UserName = SUSER_SNAME()

   IF ISNULL(@cOutField09,'') <> '' AND @cDropID <> @cOutField09
   BEGIN
      SET @nErrNo = 238351
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Drop ID cannot be different
      GOTO Quit
   END

   IF @cDocType = 'E'
   BEGIN
      IF @cDropID <> @cExternOrderKey
         SET @nValid = 0
   END
   ELSE
   BEGIN
      IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'EXTDROPID', @cDropID) = 0
         SET @nValid = 0
   END
   
   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON  [RDT].[rdt_CheckDropID_09] TO [NSQL]
GO
