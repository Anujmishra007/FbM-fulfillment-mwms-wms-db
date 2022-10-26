SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_805ExtInfo04                                    */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Purpose: Get next SKU to Pick                                        */
/*                                                                      */
/* Date       Rev Author   Purposes                                     */
/* 19-10-2022 1.0 Ung      WMS-21024 Created (base on rdt_805ExtInfo01) */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_805ExtInfo04] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nAfterStep     INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @tVar           VariableTable READONLY,
   @cExtendedInfo  NVARCHAR( 20) OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cStation1 NVARCHAR(10)
   DECLARE @cStation2 NVARCHAR(10)
   DECLARE @cStation3 NVARCHAR(10)
   DECLARE @cStation4 NVARCHAR(10)
   DECLARE @cStation5 NVARCHAR(10)
   DECLARE @cSKU      NVARCHAR(20)
   DECLARE @cMsg      NVARCHAR(20)
   DECLARE @nExp      INT
   DECLARE @nQTY      INT
   DECLARE @nBal      INT

   IF @nFunc = 805 -- PTLStation
   BEGIN
      IF @nAfterStep = 4 -- Matrix
      BEGIN
         -- Variable mapping
         SELECT @cStation1 = Value FROM @tVar WHERE Variable = '@cStation1'
         SELECT @cStation2 = Value FROM @tVar WHERE Variable = '@cStation2'
         SELECT @cStation3 = Value FROM @tVar WHERE Variable = '@cStation3'
         SELECT @cStation4 = Value FROM @tVar WHERE Variable = '@cStation4'
         SELECT @cStation5 = Value FROM @tVar WHERE Variable = '@cStation5'
         SELECT @cSKU      = Value FROM @tVar WHERE Variable = '@cSKU'

         DECLARE @tOrders TABLE
         (
            OrderKey NVARCHAR(10) NOT NULL PRIMARY KEY CLUSTERED, 
            RowRef   INT          NOT NULL
         )

         INSERT INTO @tOrders (OrderKey, RowRef) 
         SELECT OrderKey, RowRef
         FROM rdt.rdtPTLStationLog WITH (NOLOCK) 
         WHERE Station IN (@cStation1, @cStation2, @cStation3, @cStation4, @cStation5)
            AND OrderKey <> ''

         SELECT 
            @nExp = ISNULL( SUM( T.ExpectedQTY), 0), 
            @nQTY = ISNULL( SUM( CASE WHEN T.Status = '9' THEN T.ExpectedQTY ELSE 0 END), 0)
         FROM @tOrders O 
            JOIN PTL.PTLTran T WITH (NOLOCK) ON (O.OrderKey = T.OrderKey AND O.RowRef = T.GroupKey)
         WHERE T.SKU = @cSKU

         SET @nBal = @nExp - @nQTY
         
         SET @cMsg = rdt.rdtgetmessage( 193001, @cLangCode, 'DSP') --BAL:
         SET @cMsg = 
            RTRIM( @cMsg) + ' ' + 
            CAST( @nBal AS NVARCHAR(10)) + '/' + 
            CAST( @nExp AS NVARCHAR(10))

         SET @cExtendedInfo = rdt.rdtRightAlign( @cMsg, 20)
      END
   END

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_805ExtInfo04] TO [NSQL]
GO
