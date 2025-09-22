
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************************/
/* Store procedure: [rdt_839ExtUpdJCB]                                               */
/* Copyright: Maersk                                                                 */
/*                                                                                   */
/* Date         Rev   Author   Purposes                                              */
/* 16/09/2025   1.0   PPA374   Mark order as started                                 */
/* 22/09/2025   2.0   PPA374   Move DropID to relatd KIT staging                     */
/*************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_839ExtUpdJCB] (
   @nMobile         INT          
   ,@nFunc           INT          
   ,@cLangCode       NVARCHAR( 3)              
   ,@nStep           INT          
   ,@nInputKey       INT          
   ,@cFacility       NVARCHAR( 5)              
   ,@cStorerKey      NVARCHAR( 15)             
   ,@cPickSlipNo     NVARCHAR( 10)             
   ,@cPickZone       NVARCHAR( 10)             
   ,@cDropID         NVARCHAR( 20)             
   ,@cLOC            NVARCHAR( 10)             
   ,@cSKU            NVARCHAR( 20)             
   ,@nQTY            INT          
   ,@cOption         NVARCHAR( 1)              
   ,@cLottableCode   NVARCHAR( 30)             
   ,@cLottable01     NVARCHAR( 18)             
   ,@cLottable02     NVARCHAR( 18)             
   ,@cLottable03     NVARCHAR( 18)             
   ,@dLottable04     DATETIME     
   ,@dLottable05     DATETIME     
   ,@cLottable06     NVARCHAR( 30)             
   ,@cLottable07     NVARCHAR( 30)             
   ,@cLottable08     NVARCHAR( 30)             
   ,@cLottable09     NVARCHAR( 30)             
   ,@cLottable10     NVARCHAR( 30)             
   ,@cLottable11     NVARCHAR( 30)             
   ,@cLottable12     NVARCHAR( 30)             
   ,@dLottable13     DATETIME     
   ,@dLottable14     DATETIME     
   ,@dLottable15     DATETIME     
   ,@cPackData1      NVARCHAR( 30)             
   ,@cPackData2      NVARCHAR( 30)             
   ,@cPackData3      NVARCHAR( 30)             
   ,@nErrNo          INT           OUTPUT      
   ,@cErrMsg         NVARCHAR(250) OUTPUT     
) AS

BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cOrderKey    AS NVARCHAR( 20)
   DECLARE @cOrderType   AS NVARCHAR( 20)
   DECLARE @cLocToMoveTo   AS NVARCHAR( 20)
   DECLARE @cFromLot       AS NVARCHAR( 20)
   DECLARE @cPickDetailKey AS NVARCHAR( 20)

   SELECT TOP 1
      @cOrderKey = OrderKey 
   FROM dbo.PICKHEADER WITH(NOLOCK) 
   WHERE PickHeaderKey = @cPickSlipNo

   SELECT TOP 1
      @cOrderType = Type
   FROM dbo.ORDERS WITH(NOLOCK)
   WHERE OrderKey = @cOrderKey

   SELECT TOP 1
      @cLocToMoveTo = Long
   FROM dbo.CODELKUP WITH(NOLOCK) 
   WHERE LISTNAME = 'JCBMVPPKIT' 
      AND Code = @cOrderType

   IF @nFunc = 839
   BEGIN
      IF @nStep = 1
	     AND @nInputKey = 1 --PickSlipNo
      BEGIN
	     UPDATE dbo.PICKDETAIL WITH(ROWLOCK)
		 SET Notes = 'Started'
		 WHERE OrderKey = @cOrderKey
	  END

	  IF @nStep = 2
	     AND @nInputKey = 0 --PickSlipNo
      BEGIN
	     UPDATE dbo.PICKDETAIL WITH(ROWLOCK)
		 SET Notes = ''
		 WHERE OrderKey = @cOrderKey
		    AND Notes = 'Started'
	  END

	  IF @nStep = 3
	     AND @nInputKey = 1
	  BEGIN
         -- Step 1: Capture rows into a temporary table with unique RowID
         DECLARE @ToProcess TABLE (
            PickDetailKey NVARCHAR(20),
            Lot NVARCHAR(20),
            Qty INT
         )

	     INSERTTOUPD:
         INSERT INTO @ToProcess (PickDetailKey, Lot, Qty)
         SELECT TOP 1
	        PickDetailKey,
	        Lot,
            Qty
         FROM dbo.PICKDETAIL WITH(NOLOCK)
         WHERE Status = '5'
            AND OrderKey = @cOrderKey
            AND Loc = @cLOC
            AND ID = ''
            AND DropID = @cDropID
            AND SKU = @cSKU
			AND Storerkey = @cStorerKey
	        AND ISNULL(Notes,'') <> 'Moved'

         IF EXISTS (SELECT 1 FROM @ToProcess)
         BEGIN
            -- Pick the next row
            SELECT TOP 1 
		       @cPickDetailKey = PickDetailKey,
               @cFromLot = Lot,
               @nQTY = Qty
            FROM @ToProcess

            -- Execute your procedure
            EXECUTE rdt.rdt_Move
               @nMobile     = @nMobile,
               @cLangCode   = @cLangCode,
               @nErrNo      = @nErrNo  OUTPUT,
               @cErrMsg     = @cErrMsg OUTPUT,
               @cSourceType = 'rdt_839ExtUpdJCB',
               @cStorerKey  = @cStorerKey,
               @cFacility   = @cFacility,
               @cFromLOC    = @cLOC,
               @cToLOC      = @cLocToMoveTo,
               @cFromID     = '',
               @cToID       = @cDropID,
               @cSKU        = @cSKU,
               @nQTY        = @nQTY,
               @cFromLot    = @cFromLot,
               @nQTYAlloc   = 0,
               @nQTYPick    = @nQTY,
               @cDropID     = @cDropID,
               @nFunc       = @nFunc;

			IF @nErrNo <> 0
			BEGIN
			   GOTO SKIPRECORD
			END

		    UPDATE PICKDETAIL WITH(ROWLOCK)
		    SET Notes = 'Moved'
		    WHERE PickDetailKey = @cPickDetailKey
		       AND Storerkey = @cStorerKey

			SKIPRECORD:
            DELETE FROM @ToProcess --Deleting all records, to refresh and check if any split has happened
		    GOTO INSERTTOUPD
         END
      END
   END
Quit:
END
GO

GRANT EXECUTE ON rdt_839ExtUpdJCB TO NSQL
GO

