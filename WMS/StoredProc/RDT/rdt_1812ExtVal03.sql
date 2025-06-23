IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'rdt.rdt_1812ExtVal03') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE rdt.rdt_1812ExtVal03
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
/************************************************************************/  
/* Store procedure: rdt_1812ExtVal03                                    */  
/* Purpose: Validate DropID                                             */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date         Author    Ver.  Purposes                                */  
/* 2024-11-26   JCH507    1.0   FCR-989 Enhancement Qty >= stock qty    */  
/************************************************************************/  
  
CREATE PROCEDURE rdt.rdt_1812ExtVal03  
    @nMobile         INT   
   ,@nFunc           INT   
   ,@cLangCode       NVARCHAR( 3)   
   ,@nStep           INT   
   ,@nInputKey       INT  
   ,@cTaskdetailKey  NVARCHAR( 10)  
   ,@cDropID         NVARCHAR( 20)  
   ,@nQTY            INT  
   ,@cToLOC          NVARCHAR( 10)  
   ,@nErrNo          INT           OUTPUT   
   ,@cErrMsg         NVARCHAR( 20) OUTPUT  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE  @cStorerkey   NVARCHAR( 20),  
            @cTaskSku     NVARCHAR( 20),
            @cTaskFromLOC NVARCHAR( 10),
            @cTaskLot     NVARCHAR(10),
            @nInvQty      INT

   DECLARE @bDebugFlag  BINARY = 0

   IF @bDebugFlag = 1
    SELECT @nFunc AS Func, @nStep AS Step, @nInputKey AS InputKey 
  
   -- TM Case Pick  
   IF @nFunc = 1812  
   BEGIN  
      IF @nStep = 4 --SKUQty  
      BEGIN
         IF @nInputKey = 1
         BEGIN  
            SELECT
               @cStorerkey = Storerkey,
               @cTaskFromLOC = FromLoc,
               @cTaskSku = SKU,
               @cTaskLot = Lot
            FROM TaskDetail WITH (NOLOCK)
            WHERE TaskDetailKey = @cTaskdetailKey

            SELECT @nInvQty = SUM(Qty - QtyPicked)
            FROM LOTxLOCxID WITH (NOLOCK)
            WHERE StorerKey = @cStorerkey
               AND Loc = @cTaskFromLOC
               AND SKU = @cTaskSku
               AND Lot = @cTaskLot

            IF @bDebugFlag = 1
               SELECT @cTaskdetailKey AS TaskDetailKey, @nQty AS InputQty, @nInvQty AS StockQty

            IF @nQty > @nInvQty
            BEGIN
               SET @nErrNo = 229651
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No enough stock qty
               GOTO Quit
            END
         END --inputkey1
      END --step4 
   END  
   GOTO Quit  
  
Quit:  
  
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1812ExtVal03 TO NSQL
GO
