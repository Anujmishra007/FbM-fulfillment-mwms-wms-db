SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/**************************************************************************/
/* Store procedure: rdt_1768ExtUpd03                                      */
/* Purpose: Release inventory once CC is done                             */
/* Customer: Colombia GM                                                  */
/*                                                                        */
/* Modifications log:                                                     */
/*                                                                        */
/* Date       Rev    Author     Purposes                                  */
/* 2026-01-09 1.0.0  JackC      FCR-9547. Created                         */
/* 2026-02-02 1.0.1  JackC      FCR-9547. Call locxsku hold wrapper       */
/**************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1768ExtUpd03] (
   @nMobile         INT,   
   @nFunc           INT,   
   @cLangCode       NVARCHAR( 3), 
   @nStep           INT, 
   @nAfterStep      INT,
   @nInputKey       INT, 
   @cStorerKey      NVARCHAR( 15), 
   @cTaskDetailKey  NVARCHAR( 10), 
   @cCCKey          NVARCHAR( 10), 
   @cCCDetailKey    NVARCHAR( 10), 
   @cLoc            NVARCHAR( 10), 
   @cID             NVARCHAR( 18), 
   @cSKU            NVARCHAR( 20), 
   @nActQTY          INT, 
   @cOptions        NVARCHAR( 1), 
   @cLottable01     NVARCHAR( 18), 
   @cLottable02     NVARCHAR( 18), 
   @cLottable03     NVARCHAR( 18), 
   @dLottable04     DATETIME, 
   @dLottable05     DATETIME, 
   @cLottable06     NVARCHAR( 30), 
   @cLottable07     NVARCHAR( 30), 
   @cLottable08     NVARCHAR( 30), 
   @cLottable09     NVARCHAR( 30), 
   @cLottable10     NVARCHAR( 30), 
   @cLottable11     NVARCHAR( 30), 
   @cLottable12     NVARCHAR( 30), 
   @dLottable13     DATETIME, 
   @dLottable14     DATETIME, 
   @dLottable15     DATETIME, 
   @nErrNo          INT           OUTPUT, 
   @cErrMsg         NVARCHAR( 20) OUTPUT  
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 0

   DECLARE 
      @cHoldType        NVARCHAR(60),
      @cTaskLot         NVARCHAR(10),
      @cTaskSKU         NVARCHAR(20),
      @cTaskID          NVARCHAR( 18), 
      @cTaskLoc         NVARCHAR( 10),
      @nRowCount        INT,
      @bSuccess         INT,
      @cErrMsg1         NVARCHAR( 125),
      @cErrMsg2         NVARCHAR( 125),
      @cErrMsg3         NVARCHAR( 125)

   IF @nFunc = 1768
   BEGIN
      IF @nStep = 3
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF ISNULL(@cOptions, '') = '2'
            BEGIN
               SELECT
                  @cHoldType  = Message01,
                  @cTaskLot   = Lot,
                  @cTaskSKU   = SKU,
                  @cTaskID    = FromID,
                  @cTaskLoc   = FromLoc
               FROM dbo.TaskDetail WITH (NOLOCK)
               WHERE TaskDetailKey = @cTaskdetailkey
                  AND Status = '9'

               SELECT @nRowCount = @@RowCount

               IF EXISTS (SELECT 1 FROM LotxLocxID LLI WITH (NOLOCK)
                           JOIN InventoryHold H WITH (NOLOCK)
                           ON LLI.StorerKey = H.Storerkey
                              AND LLI.ID = H.Id
                           WHERE LLI.StorerKey = @cStorerkey
                              AND LLI.SKU = @cTaskSKU
                              AND LLI.Loc = @cTaskLoc
                              AND LLI.ID LIKE 'HSL-%'
                              AND LLI.Qty > 0
                              AND H.Hold = '1')
               BEGIN
                  EXEC dbo.nspInventoryHoldWrapper
                     @c_lot = ''
                     ,@c_Loc = @cTaskLoc
                     ,@c_ID  = ''
                     ,@c_StorerKey    = @cStorerKey
                     ,@c_SKU          = @cTaskSKU
                     ,@c_Lottable01   = ''
                     ,@c_Lottable02   = ''
                     ,@c_Lottable03   = ''
                     ,@dt_Lottable04  = NULL
                     ,@dt_Lottable05  = NULL
                     ,@c_Lottable06   = ''
                     ,@c_Lottable07   = ''
                     ,@c_Lottable08   = ''
                     ,@c_Lottable09   = ''
                     ,@c_Lottable10   = ''
                     ,@c_Lottable11   = ''
                     ,@c_Lottable12   = ''
                     ,@dt_Lottable13  = NULL
                     ,@dt_Lottable14  = NULL
                     ,@dt_Lottable15  = NULL
                     ,@c_Status = 'LOCSKUHOLD'
                     ,@c_Hold = 0
                     ,@b_success = @bSuccess OUTPUT
                     ,@n_Err = @nErrNo OUTPUT
                     ,@c_Errmsg = @cErrMsg OUTPUT
                     ,@c_Remark  = ''
                  
                  IF @nErrNo NOT IN (0, 60024) OR @bSuccess <> 1 --60024 means no inventory to unhold
                  BEGIN
                     SET @cErrMsg1 = CAST(@nErrNo AS NVARCHAR(6)) + '-' + @cErrMSG
                     SET @cErrMsg2 = 'Unhold Loc Failure, retry via Web'
                     SET @cErrMsg3 = ''
                     SET @nErrNo = 0

                     EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                     GOTO Quit
                  END

                  IF @nErrNo = 60024 AND @nDebugFlag = 1
                  BEGIN
                     SET @cErrMsg1 = CAST(@nErrNo AS NVARCHAR(6)) + '-' + @cErrMSG
                     SET @cErrMsg2 = 'Nothing to unhold'
                     SET @cErrMsg3 = 'SKU: ' + @cTaskSKU + ', Loc: ' + @cTaskLoc
                     SET @nErrNo = 0

                     EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                     GOTO Quit
                  END
               END
            END
         END
      END
   END
   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1768ExtUpd03 TO NSQL
GO
