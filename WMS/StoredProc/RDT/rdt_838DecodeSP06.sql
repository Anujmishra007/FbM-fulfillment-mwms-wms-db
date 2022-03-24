SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_838DecodeSP06                                   */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Purpose: Decode SKU                                                  */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2022-02-21  1.0  Ung         WMS-18939 Created                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_838DecodeSP06]
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @cPickSlipNo      NVARCHAR( 10),
   @cFromDropID      NVARCHAR( 20),
   @cBarcode         NVARCHAR( 60),
   @cSKU             NVARCHAR( 20)  OUTPUT,
   @nQTY             INT            OUTPUT,
   @cPackDtlRefNo    NVARCHAR( 20)  OUTPUT,
   @cPackDtlRefNo2   NVARCHAR( 20)  OUTPUT,
   @cPackDtlUPC      NVARCHAR( 30)  OUTPUT,
   @cPackDtlDropID   NVARCHAR( 20)  OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- Get UPC, for saving into PackDetail.UPC
   SELECT 
      @cSKU = SKU, 
      @cPackDtlUPC = UPC
   FROM dbo.UPC WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND UPC = LEFT( @cBarcode, 30)

   IF @@ROWCOUNT <> 1
   BEGIN
      SET @cSKU = ''
      SET @cPackDtlUPC = ''
   END
   
Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_838DecodeSP06] TO [NSQL]
GO
