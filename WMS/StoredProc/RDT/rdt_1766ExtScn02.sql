SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/**************************************************************************/
/* Store procedure: rdt_1766ExtScn02                                      */
/*                                                                        */
/* Modifications log:                                                     */
/* Customer: Granite                                                      */
/*                                                                        */
/* Date       Rev    Author     Purposes                                  */
/* 2024-06-13 1.0.0  NLT013     UWP-46877. Created                        */
/**************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1766ExtScn02] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep INT,
   @nScn  INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),

   @tExtScnData   VariableTable READONLY,

   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  @cLottable01 NVARCHAR( 18) OUTPUT,
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  @cLottable02 NVARCHAR( 18) OUTPUT,
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  @cLottable03 NVARCHAR( 18) OUTPUT,
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,  @dLottable05 DATETIME      OUTPUT,
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,  @cLottable06 NVARCHAR( 30) OUTPUT,
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  @cLottable07 NVARCHAR( 30) OUTPUT,
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  @cLottable08 NVARCHAR( 30) OUTPUT,
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  @cLottable09 NVARCHAR( 30) OUTPUT,
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  @cLottable10 NVARCHAR( 30) OUTPUT,
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  @cLottable11 NVARCHAR( 30) OUTPUT,
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  @cLottable12 NVARCHAR( 30) OUTPUT,
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  @dLottable13 DATETIME      OUTPUT,
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  @dLottable14 DATETIME      OUTPUT,
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  @dLottable15 DATETIME      OUTPUT,
   @nAction      INT, --0 Jump Screen, 2. Prepare output fields, Step = 99 is a new screen
   @nAfterScn    INT OUTPUT, @nAfterStep    INT OUTPUT,
   @nErrNo             INT            OUTPUT,
   @cErrMsg            NVARCHAR( 20)  OUTPUT,
   @cUDF01  NVARCHAR( 250) OUTPUT, @cUDF02 NVARCHAR( 250) OUTPUT, @cUDF03 NVARCHAR( 250) OUTPUT,
   @cUDF04  NVARCHAR( 250) OUTPUT, @cUDF05 NVARCHAR( 250) OUTPUT, @cUDF06 NVARCHAR( 250) OUTPUT,
   @cUDF07  NVARCHAR( 250) OUTPUT, @cUDF08 NVARCHAR( 250) OUTPUT, @cUDF09 NVARCHAR( 250) OUTPUT,
   @cUDF10  NVARCHAR( 250) OUTPUT, @cUDF11 NVARCHAR( 250) OUTPUT, @cUDF12 NVARCHAR( 250) OUTPUT,
   @cUDF13  NVARCHAR( 250) OUTPUT, @cUDF14 NVARCHAR( 250) OUTPUT, @cUDF15 NVARCHAR( 250) OUTPUT,
   @cUDF16  NVARCHAR( 250) OUTPUT, @cUDF17 NVARCHAR( 250) OUTPUT, @cUDF18 NVARCHAR( 250) OUTPUT,
   @cUDF19  NVARCHAR( 250) OUTPUT, @cUDF20 NVARCHAR( 250) OUTPUT, @cUDF21 NVARCHAR( 250) OUTPUT,
   @cUDF22  NVARCHAR( 250) OUTPUT, @cUDF23 NVARCHAR( 250) OUTPUT, @cUDF24 NVARCHAR( 250) OUTPUT,
   @cUDF25  NVARCHAR( 250) OUTPUT, @cUDF26 NVARCHAR( 250) OUTPUT, @cUDF27 NVARCHAR( 250) OUTPUT,
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, @cUDF30 NVARCHAR( 250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cUserName           NVARCHAR(18),
      @cCCKey              NVARCHAR(10),
      @cTaskDetailKey      NVARCHAR(10),
      @cSKU                NVARCHAR(20),
      @cSKUDescr           NVARCHAR(60),
      @cLoc                NVARCHAR(10),
      @cID                 NVARCHAR(18),
      @cOptions            NVARCHAR(1),
      @nCurrentScn         INT,
      @nCurrentStep        INT,
      @nCurrentFunc        INT

   SELECT 
      @cUserName           = UserName,
      @cCCKey              = V_String1,
      @cLoc                = V_String10,
      @cID                 = V_ID,
      @cTaskDetailKey      = V_TaskDetailKey,
      @nCurrentFunc        = Func,
      @nCurrentScn         = Scn,
      @nCurrentStep        = Step
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   SELECT @cOptions = Value FROM @tExtScnData WHERE Variable = '@cOptions'

   IF @nCurrentFunc = 1766 -- TM Cycle Count 
   BEGIN
      IF @nCurrentStep = 4 -- Empty Location?
      BEGIN
         IF @nInputKey = 1 -- Enter
         BEGIN
            IF @cOptions IN ('1') -- YES
            BEGIN
               IF EXISTS(SELECT 1 FROM dbo.TaskDetail WITH(NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey AND TaskType = 'CC' AND Status = '9')
                  AND NOT EXISTS(SELECT 1
                              FROM dbo.LOTXLOCXID WITH(NOLOCK)
                              WHERE Loc = @cLoc
                                 AND Qty > 0
                                 AND Qty - QtyPicked > 0)
               BEGIN
                  DECLARE 
                     @cCCSheetNo          NVARCHAR( 10),
                     @cCCDetailKey        NVARCHAR( 10),
                     @bSuccess            INT

                  SET @cCCSheetNo = @cTaskDetailKey

                  IF NOT EXISTS(SELECT 1 FROM dbo.StockTakeSheetParameters WITH(NOLOCK) WHERE StockTakeKey = @cCCKey)
                  BEGIN
                     BEGIN TRY
                        INSERT INTO dbo.StockTakeSheetParameters (StockTakeKey, Facility, StorerKey, ExcludeQtyPicked, AdjReasonCode, AdjType)
                        VALUES (@cCCKey, @cFacility, @cStorerKey, 'Y', '', '' )
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 256251
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Insert StockTakeSheetParameters Failed
                        GOTO Quit
                     END CATCH
                  END

                  IF NOT EXISTS(SELECT 1 FROM dbo.CCDETAIL WITH(NOLOCK) WHERE cckey = @cCCKey AND ccsheetno = @cCCSheetNo)
                  BEGIN

                     EXECUTE nspg_getkey
                        'CCDetailKey'
                        , 10
                        , @cCCDetailKey OUTPUT
                        , @bSuccess OUTPUT
                        , @nErrNo OUTPUT
                        , @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                        GOTO Quit

                     BEGIN TRY
                        INSERT dbo.CCDETAIL (cckey, ccdetailkey, StorerKey, sku, lot, loc, id, qty, ccsheetno, Lottable01,
                           Lottable02, Lottable03, Lottable04, Lottable05,Lottable06, Lottable07, Lottable08, Lottable09,
                           Lottable10, Lottable11, Lottable12, Lottable13,Lottable14, Lottable15,SystemQty, RefNo)
                        VALUES (@cCCKey, @cCCDetailKey, @cStorerKey, '', '', @cLoc, '', 0, @cCCSheetNo,
                              @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
                              @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, @cLottable11,
                              @cLottable12, @dLottable13, @dLottable14, @dLottable15, 0, '')
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 256252
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Insert CCDetail Failed
                        GOTO Quit
                     END CATCH
                  END
               END
            END
         END
      END
   END

   GOTO Quit

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1766ExtScn02 to nSQL
GO
