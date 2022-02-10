if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_838DecodeSP03]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdt_838DecodeSP03]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Store procedure: rdt_838DecodeSP03                                   */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Purpose: Decode SKU                                                  */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2019-11-22  1.0  James       WMS-10890 Created                       */
/************************************************************************/

CREATE PROCEDURE rdt.rdt_838DecodeSP03
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
   
  
   IF LEN( RTRIM( @cBarcode)) = 14
      SELECT @cSKU = LEFT( @cBarcode, 13)
   ELSE
      SELECT @cSKU = @cBarcode
      
   SELECT @cPackDtlRefNo = V_String9
   FROM RDT.RDTMOBREC R WITH (NOLOCK)
   WHERE R.Mobile = @nMobile

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON rdt.rdt_838DecodeSP03 TO NSQL 
GO   