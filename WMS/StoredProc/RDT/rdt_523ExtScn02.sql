
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/  
/* Store procedure: rdt_523ExtScn02                                     */  
/*                                                                      */
/* Customer:                                                            */
/*                                                                      */
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2026-03-04 1.0  Dennis     FCR-10248. Created                        */  
/************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_523ExtScn02] (
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

   DECLARE @nDebugFlag       INT = 0

   DECLARE 
      --rdtmobrec
      @cUserName              NVARCHAR( 18),
      @nMenu                  INT,
      @nMOBRECStep            INT,
      @nMOBRECScn             INT,
      
      --config variable
      @nRowCount              INT,
      @cExtendedUpdateSP      NVARCHAR( 20),
      @cExtendedValidateSP    NVARCHAR( 20),
      @cExtendedInfoSP        NVARCHAR( 20),
      @cPABySKUAndLOT         NVARCHAR( 1),
      @cPASuggestSKU          NVARCHAR( 1)

   DECLARE -- business
      @cSKU                NVARCHAR( 20),
      @cSuggestSKU         NVARCHAR( 20),
      @cSKUDesc            NVARCHAR( 60),
      @cID                 NVARCHAR( 18),
      @cLot                NVARCHAR( 10),
      @cNextLOT            NVARCHAR( 10),
      @cLOC                NVARCHAR( 10),
      @cSuggestedLOC       NVARCHAR( 10),
      @cFinalLOC           NVARCHAR( 10),
      @cUCC                NVARCHAR( 20),
      @cToLOC              NVARCHAR( 18),
      @cToLocPAZone        NVARCHAR( 10),
      @cToID               NVARCHAR( 18),
      @cLottableCode       NVARCHAR( 30),
      @cPQTY               NVARCHAR( 5),
      @cMQTY               NVARCHAR( 5),
      @cPUOM               NVARCHAR( 1),
      @cPUOM_Desc          NVARCHAR( 5),  -- Pref UOM 
      @cMUOM_Desc          NVARCHAR( 5),
      @cChkFacility        NVARCHAR( 5),
      @cChkToLoc           NVARCHAR( 18),
      @cOption             NVARCHAR( 1),
      @cQTY_Avail          NVARCHAR( 5),
      @cQTY_Alloc          NVARCHAR( 5),
      @cQTY_PMoveIn        NVARCHAR( 5),

      @cPAMatchSuggestLOC  NVARCHAR( 1),
      @cPAMatchQTY         NVARCHAR( 1),
      @cDefaultQTY         NVARCHAR( 1),
      @cDefaultSuggestSKU  NVARCHAR( 1),

      @nPUOM_Div           INT,
      @nPQTY_PWY           INT,
      @nMQTY_PWY           INT,
      @nQTY_PWY            INT,
      @nPQTY               INT,
      @nMQTY               INT,
      @nQTY                INT,
      @nTotalPreAlloQty    INT = 0,
      @nMovedQty           INT = 0,
      @nPreAlloQty         INT,
      @nPABookingKey       INT,
      @nRec                INT,
      @nTotalRec           INT,
      @nLoopIndex          INT = -1,
      @nTranCount          INT
   DECLARE @nLottableNo INT
   DECLARE @cVisible    NVARCHAR(1)
   DECLARE @cEditable   NVARCHAR(1)
   DECLARE @cRequired   NVARCHAR(1)
   DECLARE @cDesc       NVARCHAR(100)
   DECLARE @cLottable   NVARCHAR(100)
   DECLARE @cFieldAttr  NVARCHAR(1)
   DECLARE @cFormatSP   NVARCHAR(50)
   DECLARE @nSequence   INT
   -- Temp table for lottable
   DECLARE @tLC TABLE 
   (
      RowRef      INT           IDENTITY( 1,1), 
      LottableNo  INT           NOT NULL, 
      Visible     NVARCHAR(  1) NOT NULL, 
      Editable    NVARCHAR(  1) NOT NULL, 
      Required    NVARCHAR(  1) NOT NULL, 
      Sequence    INT           NOT NULL, 
      Description NVARCHAR( 20) NOT NULL, 
      FormatSP    NVARCHAR( 50) NOT NULL
   )


   SET @cExtendedUpdateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerkey)
   IF @cExtendedUpdateSP = '0'
      SET @cExtendedUpdateSP = ''
   SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerkey)
   IF @cExtendedValidateSP = '0'
      SET @cExtendedValidateSP = ''
   SET @cExtendedInfoSP = rdt.RDTGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerkey)
   IF @cExtendedInfoSP = '0'
      SET @cExtendedInfoSP = ''
   

   SELECT 
      @nMOBRECStep         = Step,
      @nMOBRECScn          = Scn,
      @nMenu               = Menu,
      @cUserName           = UserName,

      @cID                 = V_ID,
      @cLOC                = V_LOC,
      @cSKU                = V_SKU,
      @cSKUDesc            = V_SKUDescr,
      @cPUOM               = V_UOM,
      @cLOT                = V_LOT,
      --@cLottable01         = V_Lottable01,
      --@cLottable02         = V_Lottable02,
      --@cLottable03         = V_Lottable03,
      --@dLottable04         = V_Lottable04,
      @cUCC                = V_UCC,
      @cSuggestSKU         = V_String1,
      @cSuggestedLOC       = V_String2,
      @cFinalLOC           = V_String3,
      @cMUOM_Desc          = V_String4,
      @cPUOM_Desc          = V_String5,
      @cQTY_Avail          = V_String7,
      @cQTY_Alloc          = V_String8,
      @cQTY_PMoveIn        = V_String9,
      @cPASuggestSKU       = V_String20,
      @cPABySKUAndLOT      = V_String21,
      @cPAMatchSuggestLOC  = V_String27,
      @cPAMatchQTY         = V_String28,
      @cDefaultQTY         = V_String29,
      @cDefaultSuggestSKU  = V_String30,
      @nPUOM_Div           = V_PUOM_Div,
      @nPQTY               = V_PQTY,
      @nMQTY               = V_MQTY,
      @nPQTY_PWY           = V_Integer1,
      @nMQTY_PWY           = V_Integer2,
      @nQTY_PWY            = V_Integer3,
      @nQTY                = V_Integer4,
      @nRec                = V_Integer5,
      @nTotalRec           = V_Integer6,
      @nPABookingKey       = V_Integer7,
      @nPreAlloQty         = C_Integer1
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_523ExtScn02'

   IF @nFunc = 523
   BEGIN
      IF @nScn = 2882
      BEGIN
         SELECT @cSKU = Value FROM @tExtScnData WHERE Variable = '@cSKU'
         SELECT @cLot = Value FROM @tExtScnData WHERE Variable = '@cLot'
         -- Get SKU info
         SELECT
               @cLottableCode = LottableCode
         FROM dbo.SKU S (NOLOCK)
            INNER JOIN dbo.Pack Pack (nolock) ON (S.PackKey = Pack.PackKey)
         WHERE StorerKey = @cStorerkey
         AND SKU = @cSKU

         IF ISNULL(@cLottableCode,'') = ''
            GOTO Quit
         
         IF @nFunc > 0
            IF NOT EXISTS( SELECT TOP 1 1 
               FROM rdt.rdtLottableCode WITH (NOLOCK)
               WHERE LottableCode = @cLottableCode
                  AND Function_ID = @nFunc
                  AND StorerKey = @cStorerKey)
               SET @nFunc = 0
         
         DELETE FROM @tLC
         INSERT INTO @tLC (LottableNo, Visible, Editable, Required, Sequence, Description, FormatSP) 
         SELECT TOP 4
            LottableNo, Visible, Editable, Required, Sequence, Description, FormatSP
         FROM rdt.rdtLottableCode WITH (NOLOCK)
         WHERE LottableCode = @cLottableCode
            AND Function_ID = @nFunc
            AND StorerKey = @cStorerKey
            AND Visible = '1'
         ORDER BY Sequence

         IF NOT EXISTS( SELECT 1 FROM @tLC)
            GOTO Quit

         WHILE(1=1)
         BEGIN
            SELECT TOP 1 
               @nLoopIndex = RowRef,
               @nLottableNo = LottableNo,
               @nSequence = Sequence,
               @cDesc = Description
            FROM @tLC
            WHERE RowRef > @nLoopIndex
            SET @nRowCount = @@ROWCOUNT
            IF @nRowCount = 0
               BREAK
            
            SELECT @cLottable = CASE WHEN @nLottableNo = 1 THEN CONCAT('1 ', @cLottable01)
                                    WHEN @nLottableNo = 2 THEN CONCAT('2 ', @cLottable02)
                                    WHEN @nLottableNo = 3 THEN CONCAT('3 ', @cLottable03)
                                    WHEN @nLottableNo = 4 THEN CONCAT('4 ',rdt.rdtFormatDate(@dLottable04))
                                    WHEN @nLottableNo = 5 THEN CONCAT('5 ',rdt.rdtFormatDate(@dLottable05))
                                    WHEN @nLottableNo = 6 THEN CONCAT('6 ', @cLottable06)
                                    WHEN @nLottableNo = 7 THEN CONCAT('7 ', @cLottable07)
                                    WHEN @nLottableNo = 8 THEN CONCAT('8 ', @cLottable08)
                                    WHEN @nLottableNo = 9 THEN CONCAT('9 ', @cLottable09)
                                    WHEN @nLottableNo = 10 THEN CONCAT('10 ', @cLottable10)
                                    WHEN @nLottableNo = 11 THEN CONCAT('11 ', @cLottable11)
                                    WHEN @nLottableNo = 12 THEN CONCAT('12 ', @cLottable12)
                                    WHEN @nLottableNo = 13 THEN CONCAT('13 ',rdt.rdtFormatDate(@dLottable13))
                                    WHEN @nLottableNo = 14 THEN CONCAT('14 ',rdt.rdtFormatDate(@dLottable14))
                                    WHEN @nLottableNo = 15 THEN CONCAT('15 ',rdt.rdtFormatDate(@dLottable15)) END

            FROM LOTATTRIBUTE WITH (NOLOCK)
            WHERE LOT = @cLOT

            IF @nLoopIndex = 1  SET @cOutField04 = CONCAT(@nLottableNo,' ',@cLottable)
            ELSE IF @nLoopIndex = 2  SET @cOutField05 = CONCAT(@nLottableNo,' ',@cLottable)
            ELSE IF @nLoopIndex = 3  SET @cOutField06 = CONCAT(@nLottableNo,' ',@cLottable)
            ELSE IF @nLoopIndex = 4  SET @cOutField07 = CONCAT(@nLottableNo,' ',@cLottable)
         END

         SET @nAfterScn = 6843
         GOTO Quit
      END
   END -- 523

   GOTO Quit

   Quit:

   
END--SP
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_523ExtScn02 TO NSQL
GO


