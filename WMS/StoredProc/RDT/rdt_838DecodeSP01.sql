if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_838DecodeSP01]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdt_838DecodeSP01]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Store procedure: ispDysonLBLNoDecode                                 */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Purpose: Default QTY base on Receipt.DocType                         */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 04-05-2017  1.0  Ung         WMS-1817 Created                        */
/************************************************************************/

CREATE PROCEDURE rdt.rdt_838DecodeSP01
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
   
   DECLARE @bSuccess INT
   DECLARE @cUPC NVARCHAR( 30)
   
   SELECT @cUPC = LEFT( @cBarcode, 30)
   
   -- Get SKU
   EXEC rdt.rdt_GetSKU
       @cStorerKey  = @cStorerKey
      ,@cSKU        = @cUPC      OUTPUT
      ,@bSuccess    = @bSuccess  OUTPUT
      ,@nErr        = @nErrNo    OUTPUT
      ,@cErrMsg     = @cErrMsg   OUTPUT
   IF @bSuccess <> 1
      GOTO Quit
      
   SET @cSKU = @cUPC
      
   -- Get SKU info
   IF EXISTS( SELECT 1 FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU AND SerialNoCapture = '1')
      SET @nQTY = 1

Quit:

END
GO

GRANT EXECUTE ON rdt.rdt_838DecodeSP01 TO NSQL 
GO   

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
