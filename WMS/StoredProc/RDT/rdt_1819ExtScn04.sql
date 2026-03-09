SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1819ExtScn04                                    */
/* Copyright      :  Maersk                                             */
/*                                                                      */
/* Purpose: DAIMLER TRUCK AG                                            */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2026-02-05 1.0.0  Jackc    FCR-9755-Create                           */
/* 2026-03-09 1.0.1  Jackc    FCR-9755 Update listname                  */
/*                                                                      */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1819ExtScn04] (
   @nMobile          INT,           
   @nFunc            INT,           
   @cLangCode        NVARCHAR( 3),  
   @nStep            INT,           
   @nScn             INT,           
   @nInputKey        INT,           
   @cFacility        NVARCHAR( 5),  
   @cStorerKey       NVARCHAR( 15), 
   @tExtScnData      VariableTable READONLY,
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
   @nAction          INT, --0 Jump Screen, 1 Validation(pass through all input fields), 2 Update, 3 Prepare output fields .....
   @nAfterScn        INT OUTPUT, @nAfterStep    INT OUTPUT, 
   @nErrNo           INT            OUTPUT, 
   @cErrMsg          NVARCHAR( 20)  OUTPUT,
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

   DECLARE @nDebugFlag        INT = 0

   DECLARE @nMobRecScn        INT
   DECLARE @nMobRecStep       INT
   DECLARE @cListSKU          NVARCHAR(20)
   DECLARE @cPrQty            NVARCHAR(4)
   DECLARE @nPrQty            INT
   DECLARE @nCounter          INT
   DECLARE @nRowNo            INT
   DECLARE @nMax              INT

   DECLARE
      @nTranCount             INT,
      @cUserName              NVARCHAR( 20),
      @cFromLOC               NVARCHAR( 10),
      @cFromID                NVARCHAR( 20),
      @cSuggLOC               NVARCHAR( 10),
      @cPickAndDropLOC        NVARCHAR( 10),
      @cToLOC                 NVARCHAR( 20),
      @cShowPASuccessScn      NVARCHAR( 1),
      @cDefaultToLOC          NVARCHAR( 1),
      @cSQL                   NVARCHAR( MAX),
      @cSQLParam              NVARCHAR( MAX),
      @cExtendedUpdateSP      NVARCHAR( 20),
      @cExtendedScreenSP      NVARCHAR( 20),
      @cLOCLookupSP           NVARCHAR( 20),
      @cExtendedValidateSP    NVARCHAR( 20),
      @cExtendedInfoSP        NVARCHAR( 20),
      @cExtendedInfo          NVARCHAR( 20),
      @cPAMatchSuggestLOC     NVARCHAR( 1),
      @cOption                NVARCHAR( 10),
      @nPABookingKey          INT

   DECLARE @tMovedLotQty TABLE
   (
      LOT            NVARCHAR(10) NOT NULL,
      TotalMovedQty  INT DEFAULT 0
   )

   DECLARE @tPreAlloSKUStat TABLE
   (
      RowNo          INT IDENTITY,
      SKU            NVARCHAR(20) NOT NULL,
      TotalMovedQty  INT DEFAULT 0,
      TotalPrQty     INT DEFAULT 0
   )


   SELECT
      @nMobRecScn          = Scn,
      @nMobRecStep         = Step,
      @cUserName           = UserName,
      @cFromID             = V_ID,
      @cFromLOC            = V_LOC,
      @nPABookingKey       = V_Integer1,
      @cSuggLOC            = V_String1,
      @cPickAndDropLOC     = V_String2,
      @cToLOC              = V_String3,
      @cExtendedValidateSP = V_String4,
      @cExtendedUpdateSP   = V_String5,
      @cExtendedInfoSP     = V_String6,
      @cDefaultToLOC       = V_String9,
      @cShowPASuccessScn   = V_String11,
      @cLOCLookupSP        = V_String18,
      @cPAMatchSuggestLOC  = V_String19
   FROM rdt.RDTMOBREC (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT '1819ExtScn04', @nMobRecScn MobScn, @nMobRecStep MobStep, @nStep Step, @nScn Scn

   IF @nFunc = 1819
   BEGIN
      IF @nMobRecScn = 4110 AND @nMobRecStep = 1 AND @nStep = 2 AND @nScn = 4111 --st1 to st2
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Step1 to step2, ext scn logic'

         SET @cFromID = @cInField01

         IF @nInputKey = 1
         BEGIN
            
            INSERT INTO @tMovedLotQty (LOT, TotalMovedQty)
            SELECT lli.Lot, SUM(lli.Qty+lli.PendingMoveIn - (lli.QtyAllocated + lli.QtyPicked))
            FROM dbo.LOTXLOCXID lli WITH (NOLOCK)
            WHERE lli.StorerKey = @cStorerKey
               AND EXISTS (
                  SELECT 1 FROM dbo.LOTXLOCXID lli2 WITH (NOLOCK)
                  WHERE lli2.StorerKey = lli.StorerKey 
                     AND lli2.Sku = lli.Sku 
                     AND lli2.Lot = lli.Lot 
                     AND lli2.Id = @cFromID
               )
               AND EXISTS (
                  SELECT 1 FROM dbo.LOC lc WITH (NOLOCK)
                  JOIN dbo.CODELKUP cd WITH (NOLOCK)
                     ON cd.CODE = lc.PUTAWAYZONE 
                     AND cd.CODE2 = lc.Facility 
                     AND cd.StorerKey = lli.StorerKey 
                     AND cd.LISTNAME = '1819ZONE' --V1.0.1
                  WHERE lc.LOC = lli.LOC
               )
            GROUP BY lli.Lot

            IF @nDebugFlag = 1
            BEGIN
               SELECT 'Moved Qty'
               SELECT * FROM @tMovedLotQty
            END

            INSERT INTO @tPreAlloSKUStat (SKU, TotalMovedQty, TotalPrQty)
            SELECT TotalPR.SKU, SUM(ISNULL(t.TotalMovedQty,0)), SUM(TotalPR.TotalPrQty)
            FROM
            (SELECT LOT, MAX(SKU) AS SKU, SUM(Qty) AS TotalPrQty
            FROM dbo.PreAllocatePickDetail PAPD WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND EXISTS (SELECT 1 FROM dbo.LOTXLOCXID lli WITH (NOLOCK)
                  WHERE lli.StorerKey = PAPD.StorerKey
                     AND lli.Sku = PAPD.Sku
                     AND lli.Lot = PAPD.Lot
                     AND lli.Id = @cFromID)
            GROUP BY LOT) TotalPR
            LEFT JOIN @tMovedLotQty t
            ON TotalPR.LOT = t.LOT
            GROUP BY TotalPR.SKU
            HAVING SUM(TotalPR.TotalPrQty) > SUM(ISNULL(t.TotalMovedQty, 0))

            IF @nDebugFlag = 1
            BEGIN
               SELECT 'PR Allo SKU'
               SELECT * FROM @tPreAlloSKUStat
            END

            SET @nCounter = 0
            SET @nRowNo = 0
            SET @nMax = 5

            IF EXISTS (SELECT 1 FROM @tPreAlloSKUStat)
            BEGIN
               SET @cOutField02 = ''
               SET @cOutField03 = ''
               SET @cOutField04 = ''
               SET @cOutField05 = ''
               SET @cOutField06 = ''

               WHILE @nCounter < @nMax
               BEGIN
                  SELECT TOP 1
                     @nCounter = RowNo,
                     @cListSKU = SKU
                     --@cPrQty = ISNULL(TRY_CAST((TotalPrQty - TotalMovedQty) AS NVARCHAR(4)),0)
                  FROM @tPreAlloSKUStat
                     WHERE RowNo > @nCounter
                  ORDER BY RowNo

                  IF @@ROWCOUNT = 0
                     BREAK

                  IF @nCounter = 1
                     SET @cOutField02 = @cListSKU
                  ELSE IF @nCounter = 2
                     SET @cOutField03 = @cListSKU
                  ELSE IF @nCounter = 3
                     SET @cOutField04 = @cListSKU
                  ELSE IF @nCounter = 4
                     SET @cOutField05 = @cListSKU
                  ELSE IF @nCounter = 5
                     SET @cOutField06 = @cListSKU
               END -- loop end

               SET @cOutField01 = @cFromID
               SET @nAfterStep = 99
               SET @nAfterScn = 6824
            END -- has prqty to handle
            ELSE
            BEGIN
               GOTO Quit -- run base workflow
            END 
         END -- Inputkey = 1
      END
      IF @nStep = 99
      BEGIN

         /********************************************************************************
         Scn 6824. PRY Qty screen
            Pallet      (Field01)
            SKU/Qty     (Field02)
            SKU/Qty     (Field03)
            SKU/Qty     (Field04)
            SKU/Qty     (Field05)
            SKU/Qty     (Field06)
         ********************************************************************************/
         IF @nScn = 6824
         BEGIN -- Copy from step_2
            IF @nPABookingKey <> 0
            BEGIN
               EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
                  ,@cFromLOC --FromLOC
                  ,@cFromID --FromID
                  ,'' --cSuggLOC
                  ,'' --Storer
                  ,@nErrNo  OUTPUT
                  ,@cErrMsg OUTPUT
               IF @nErrNo <> 0  
                  GOTO Scn_6824_Fail

               SET @nPABookingKey = 0
            END

            SET @nAfterStep = 1
            SET @nAfterScn = 4110

            -- Prepare next screen var
            SET @cOutField01 = '' --FromID

            GOTO Quit 

            Scn_6824_Fail:

         END --6824
      END--st99
   END

Quit:
   SET @cUDF01 = @cToLOC


END;

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1819ExtScn04 TO NSQL
GO
