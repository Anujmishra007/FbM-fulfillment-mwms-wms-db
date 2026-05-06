SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_523ExtInfo13                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2025-11-14 1.0  ELB012   UWP-45366 PROJECT - RITM8172881             */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_523ExtInfo13]
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nAfterStep      INT,
   @nInputKey       INT,
   @cStorerKey      NVARCHAR( 15),
   @cFacility       NVARCHAR( 5),
   @cLOC            NVARCHAR( 10),
   @cID             NVARCHAR( 18),
   @cSKU            NVARCHAR( 20),
   @nQTY            INT,
   @cSuggestedLOC   NVARCHAR( 10),
   @cFinalLOC       NVARCHAR( 10),
   @cOption         NVARCHAR( 1),
   @cExtendedInfo1  NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nQtyAvlLoc           INT
   DECLARE @nLLI_Qty             INT
   DECLARE @nLLI_QtyPicked       INT
   DECLARE @nLLI_PendingMoveIn   INT
   DECLARE @cPickLoc             NVARCHAR( 10)
   DECLARE @nCaseCNT	            INT
   DECLARE @cPndM1               NVARCHAR(10)
   DECLARE @cPndM2               NVARCHAR(10)
   DECLARE @cPndM3               NVARCHAR(10)
   DECLARE @cPndM4               NVARCHAR(10)
   DECLARE @cPndRk               NVARCHAR(10)


-- Get Pnds Loc 
   SELECT  
      @cPndM1    = ISNULL(UDF01,''), --ONBR PND M1
      @cPndM2    = ISNULL(UDF02,''), --ONBR PND M2
      @cPndM3    = ISNULL(UDF03,''), --ONBR PND M3
      @cPndM4    = ISNULL(UDF04,''), --ONBR PND M4
      @cPndRk    = ISNULL(UDF05,'')  --ONBR PND RK
   FROM dbo.CodeLKUP WITH (NOLOCK)
   WHERE ListName = 'ONBRBFFPND'
      AND StorerKey = @cStorerKey
      AND Code = 'PND'
   
   IF @nFunc = 523 -- Putaway by SKU
   BEGIN
      IF @nAfterStep = 3 AND @cLOC IN(@cPndM1, @cPndM2, @cPndM3, @cPndM4) -- QTY PWY, QTY ACT
      BEGIN
         SELECT TOP 1 @cPickLoc = Loc,
            @nQtyAvlLoc = QtyLocationLimit - Qty
         FROM dbo.SKUxLOC WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND Sku = @cSKU
            AND LocationType = 'PICK'
            AND QtyLocationLimit > 0
            AND QtyLocationLimit - QTY > 0
      
         SELECT TOP 1 @nCaseCNT = CASECNT 
         FROM DBO.PACK WITH (NOLOCK)
         INNER JOIN DBO.SKU WITH(NOLOCK)
            ON SKU.PACKKey = PACK.PackKey
            AND SKU = @cSKU

         IF @nQtyAvlLoc > 0
         BEGIN
            SET @cExtendedInfo1 = 'HL Disp: ' + CAST( @nQtyAvlLoc AS NVARCHAR( 5)) + '/ CX: ' + CAST(@nCaseCNT AS NVARCHAR(5))
            GOTO Quit
         END
         ELSE
         BEGIN
            SET @cExtendedInfo1 = 'CX: ' + CAST(@nCaseCNT AS NVARCHAR(5))
            GOTO Quit
         END
      END
   END

Quit:

END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_523ExtInfo13 TO NSQL
GO
