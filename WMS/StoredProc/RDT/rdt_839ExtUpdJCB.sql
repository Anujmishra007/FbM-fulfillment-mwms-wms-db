
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
/* 20/11/2025   3.0   SKE140   Close related tasks when piece picks completed        */
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

   DECLARE @cOrderKey      AS NVARCHAR( 20)
   DECLARE @cOrderType     AS NVARCHAR( 20)
   DECLARE @cLocToMoveTo   AS NVARCHAR( 20)
   DECLARE @cFromLot       AS NVARCHAR( 20)
   DECLARE @cPickDetailKey AS NVARCHAR( 20)
   DECLARE @nCounter       AS INT = 0

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
      SET @nCounter = @nCounter + 1
      IF @nCounter >= 100
      BEGIN
         GOTO ExitLoop
      END

      -- Clear previous attempt
      DELETE FROM @ToProcess

      -- Try to fetch ONE concrete row
      INSERT INTO @ToProcess (PickDetailKey, Lot, Qty)
      SELECT TOP (1)
         PickDetailKey,
         Lot,
         Qty
      FROM dbo.PICKDETAIL WITH (NOLOCK)
      WHERE Status = '5'
         AND OrderKey = @cOrderKey
         AND Loc = @cLOC
         AND ID = ''
         AND DropID = @cDropID
         AND SKU = @cSKU
         AND Storerkey = @cStorerKey
         AND ISNULL(Notes,'') NOT IN ('Moved','MoveFailed')

      -- If nothing was inserted, we are DONE
      IF NOT EXISTS (SELECT 1 FROM @ToProcess)
      BEGIN
         GOTO ExitLoop
      END

      -- Fetch the row we just captured
      SELECT
         @cPickDetailKey = PickDetailKey,
         @cFromLot = Lot,
         @nQTY = Qty
      FROM @ToProcess

	  SET @nErrNo = 0

      -- Execute move
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

         IF @nErrNo = 0
         BEGIN
            UPDATE PICKDETAIL WITH (ROWLOCK)
            SET Notes = 'Moved'
            WHERE PickDetailKey = @cPickDetailKey
               AND Storerkey = @cStorerKey
         END
		 ELSE 
         BEGIN
            UPDATE PICKDETAIL WITH (ROWLOCK)
            SET Notes = LEFT('MoveFailed: ' + ISNULL(@cErrMsg,''), 4000)
            WHERE PickDetailKey = @cPickDetailKey
               AND Storerkey = @cStorerKey
         END

      -- Loop again
      GOTO INSERTTOUPD

      ExitLoop:

         -- This handles the scenario where piece picks are done via pickslip while 
         -- active tasks exist in the task manager
         
         -- Close tasks that are related to the completed PICKDETAIL records
         UPDATE dbo.TASKDETAIL WITH(ROWLOCK)
         SET [STATUS] = '9',           -- Closed/Completed status
             UserKey = 'rdt839',       -- System user
             TrafficCop = NULL,        -- Release traffic control
             EndTime = GETDATE(),      -- Set completion time
             EditDate = GETDATE(),     -- Set edit timestamp
             EditWho = SUSER_SNAME()   -- Set edit user
         FROM dbo.TASKDETAIL TD
         INNER JOIN dbo.PICKDETAIL PD WITH(NOLOCK) 
            ON TD.TaskDetailKey = PD.TaskDetailKey
         WHERE PD.OrderKey = @cOrderKey
            AND PD.Status = '5'        -- Picked status
            AND PD.Loc =@cLocToMoveTo
            --AND PD.DropID = @cDropID
            AND PD.SKU = @cSKU
            AND PD.Storerkey = @cStorerKey
            AND ISNULL(PD.Notes,'') = 'Moved'
            AND TD.TaskType = 'FCP'     -- Pick task type
            AND TD.PickMethod = 'PP'   -- Piece pick method
            AND TD.[Status] IN ('0','3') -- Available or Inprocess status
         
         -- Log if any tasks were closed
         /*IF @@ROWCOUNT > 0
         BEGIN
            -- Tasks were successfully closed
            PRINT 'Closed related tasks for OrderKey: ' + @cOrderKey
         END */
      END
   END
Quit:
END
GO

GRANT EXECUTE ON rdt_839ExtUpdJCB TO NSQL
GO

