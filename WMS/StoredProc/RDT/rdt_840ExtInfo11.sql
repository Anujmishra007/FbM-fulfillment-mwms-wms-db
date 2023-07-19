SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_840ExtInfo11                                    */
/* Copyright: LF Logistics                                              */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2023-03-31 1.0  James      WMS-22084. Created                        */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_840ExtInfo11 (
   @nMobile       INT,
   @nFunc         INT, 
   @cLangCode     NVARCHAR( 3), 
   @nStep         INT, 
   @nAfterStep    INT, 
   @nInputKey     INT, 
   @cStorerkey    NVARCHAR( 15), 
   @cOrderKey     NVARCHAR( 10), 
   @cPickSlipNo   NVARCHAR( 10), 
   @cTrackNo      NVARCHAR( 20), 
   @cSKU          NVARCHAR( 20), 
   @nCartonNo     INT,
   @cExtendedInfo NVARCHAR( 20) OUTPUT,
   @nErrNo        INT           OUTPUT, 
   @cErrMsg       NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cBillToKey     NVARCHAR( 15)
   DECLARE @cFacility      NVARCHAR( 5)
   
   IF @nFunc = 840 -- Pack by track no
   BEGIN
      IF 3 IN ( @nStep, @nAfterStep) -- SKU
      BEGIN
      	SELECT @cFacility = Facility
      	FROM rdt.RDTMOBREC WITH (NOLOCK)
      	WHERE Mobile = @nMobile
      	
      	SELECT @cBillToKey = BillToKey
      	FROM dbo.ORDERS WITH (NOLOCK)
      	WHERE OrderKey = @cOrderKey
      	
         IF EXISTS ( SELECT 1 
                     FROM dbo.Storer WITH (NOLOCK)
                     WHERE StorerKey = @cBillToKey
                     AND   [type] = '2'
                     AND   Facility = @cFacility
                     AND   ( LabelPrice = 'Y' OR SUSR1 = 'Y' OR SUSR2 = 'Y'))
            SET @cExtendedInfo = 'VAS Required'
      END
   END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_840ExtInfo11 TO NSQL
GO
