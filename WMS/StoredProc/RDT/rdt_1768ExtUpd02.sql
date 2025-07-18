SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/**************************************************************************/
/* Store procedure: rdt_1768ExtUpd02                                      */
/* Purpose: Release inventory by LOC/LOT/ID once CC is done               */
/* Customer: Chile PUMA                                                   */
/*                                                                        */
/* Modifications log:                                                     */
/*                                                                        */
/* Date       Rev    Author     Purposes                                  */
/* 2025-07-18 1.0.0  NickT      FCR-4885. Created                         */
/**************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1768ExtUpd02] (
   @nMobile         INT,   
   @nFunc           INT,   
   @cLangCode       NVARCHAR( 3), 
   @nStep           INT, 
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

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF


   IF @nFunc = 1768
   BEGIN
      IF @nStep = 3
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF ISNULL(@cOptions, '') = '2'
            BEGIN
               SELECT @cLoc = FromLoc,
                  @cHoldType = Message01,
                  @cLot = Lot,
                  @cID = ID,
                  @cLoc = FromLoc
               FROM dbo.TaskDetail WITH (NOLOCK)
               WHERE TaskDetailKey = @cTaskdetailkey
                  AND Status = '9'
                  AND SourceType = 'rdt_ActionByReason'
                  AND Holdkey = 'UNHOLD'

               SELECT @nRowCount = @@RowCount

               IF ISNULL(@nRowCount, 0) = 1
               BEGIN
                  IF ISNULL(@cHoldType,'') IN ('LOC','LOT','ID')
                  BEGIN
                     IF @cHoldType = 'LOC'
                     BEGIN
                        SET @cLot = ''
                        SET @cID = ''
                     END
                     ELSE IF @cHoldType = 'ID'
                     BEGIN
                        SET @cLoc = ''
                        SET @cLot = ''
                     END
                     ELSE IF @cHoldType = 'LOT'
                     BEGIN
                        SET @cLoc = ''
                        SET @cID = ''
                     END
                     
                     EXEC dbo.nspInventoryHoldWrapper
                        @c_lot = @cLot
                        ,@c_Loc = @cLoc
                        ,@c_ID  = @cID
                        ,@c_StorerKey    = @cStorerKey
                        ,@c_SKU          = ''
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
                        ,@c_Status = 'CCUNHOLD'
                        ,@c_Hold = 0
                        ,@b_success = @b_Success OUTPUT
                        ,@n_Err = @nErrNo OUTPUT
                        ,@c_Errmsg = @cErrMsg OUTPUT
                        ,@c_Remark  = ''
                  END
                  
                  IF @nErrNo <> 0
                  BEGIN
                     GOTO Quit 
                  END
               END
            END
         END
      END
   END

GO
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1768ExtUpd02 TO NSQL
GO
