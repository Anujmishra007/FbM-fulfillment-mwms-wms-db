
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: rdt_838DecodeSP09                                   */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Purpose: Abstract UPC, SerialNo                                      */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 20-03-2023  1.0  Ung         WMS-21946 Created                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_838DecodeSP09
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
   @cSerialNo        NVARCHAR( 30)  OUTPUT,
   @nErrNo           INT            OUTPUT, 
   @cErrMsg          NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   IF LEN( @cBarcode) = 24 -- SerialNo
   BEGIN
      SET @cSerialNo = @cBarcode
      SET @cSKU = LEFT( @cBarcode, 18)
      SET @nQTY = 1
   END
END
GO

GRANT EXECUTE ON rdt.rdt_838DecodeSP09 TO NSQL 
GO   

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
