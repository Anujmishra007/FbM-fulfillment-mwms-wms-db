SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_898ExtScn07                                           */
/*                                                                            */
/* Purpose: FCR-11903 Columbia Malaysia (CFS) UCC Receiving                   */
/*                                                                            */
/* ProcessType = 'CID': Only existing UCCs allowed                            */
/* ProcessType = 'NORMAL': Allow new UCC, skip confirmations, use stored SKU  */
/*                                                                            */
/* Flow:                                                                      */
/* - Screen 5 (Lottable): SKIP, execute code, go to Screen 6                  */
/* - Screen 6 (UCC): Validate UCC based on ProcessType                        */
/* - Screen 7 (Create New UCC?): SKIP for NORMAL, auto-YES, execute code      */
/* - Screen 8 (SKU): Use first SKU for subsequent UCCs, execute code          */
/* - Screen 9 (QTY): SKIP, auto QTY = PACK.CaseCnt, execute code              */
/* - Screen 10: Execute rdt_UCCReceive_Confirm, then navigate                 */
/*                                                                            */
/* Navigation after receiving:                                                */
/* - If UCC count not met: Go to Screen 6 (UCC)                               */
/* - If UCC count met: Go to Screen 3 (TO ID)                                 */
/* - If ASN fully received: Go to Screen 1 (ASN)                              */
/*                                                                            */
/* Date        Rev     Author      Purposes                                   */
/* 2026-04-24  1.0.0   NYE018      FCR-11903 Created                          */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_898ExtScn07] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nScn         INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),

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
   @nAction          INT,
   @nAfterScn        INT            OUTPUT,
   @nAfterStep       INT            OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 1024)  OUTPUT,
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

   -- Local variables
   DECLARE @cProcessType       NVARCHAR(20)
   DECLARE @cExternReceiptKey  NVARCHAR(50)
   DECLARE @cReceiptKey        NVARCHAR(10)
   DECLARE @cPOKey             NVARCHAR(10)
   DECLARE @cTotalCarton       NVARCHAR(4)
   DECLARE @cCartonCnt         NVARCHAR(4)
   DECLARE @cSkipEstUCCOnID    NVARCHAR(1)
   DECLARE @cMax               NVARCHAR(MAX)
   DECLARE @cUCC               NVARCHAR(20)
   DECLARE @cSKU               NVARCHAR(20)
   DECLARE @cStoredSKU         NVARCHAR(20)  -- First SKU stored for subsequent UCCs
   DECLARE @cStoredUCC         NVARCHAR(20)  -- Current UCC being processed (stored in V_String49)
   DECLARE @nQTY               INT
   DECLARE @nCaseCnt           INT
   DECLARE @nUCCExists         INT
   DECLARE @cCountDisplay      NVARCHAR(20)
   DECLARE @nCurrentCnt        INT
   DECLARE @nTotalCnt          INT
   DECLARE @cLoc               NVARCHAR(10)
   DECLARE @cToID              NVARCHAR(18)
   DECLARE @cPackKey           NVARCHAR(20)
   DECLARE @cUOM               NVARCHAR(10)
   DECLARE @nASNFullyReceived  INT
   DECLARE @cPOKeyValue        NVARCHAR(10)
   DECLARE @nNOPOFlag          INT
   DECLARE @cLott01            NVARCHAR(18)  -- Single Carton CUBE
   DECLARE @cLott02            NVARCHAR(18)  -- Single Carton Weight
   DECLARE @cLott06            NVARCHAR(30)  -- PO (ExternReceiptKey)
   DECLARE @cLott07            NVARCHAR(30)  -- SO (Signatory)
   DECLARE @nCube              DECIMAL(18,8)
   DECLARE @nGrossWgt          DECIMAL(18,8)
   DECLARE @nQtyExpected       DECIMAL(18,8)
   DECLARE @cSignatory         NVARCHAR(30)

   -- Screen/Step constants
   DECLARE @nStep_1 INT = 1, @nScn_1 INT = 1300  -- ASN Scan
   DECLARE @nStep_3 INT = 3, @nScn_3 INT = 1302  -- TO ID
   DECLARE @nStep_4 INT = 4, @nScn_4 INT = 1303  -- Estimated UCC on ID
   DECLARE @nStep_5 INT = 5, @nScn_5 INT = 1304  -- Lottable (SKIP)
   DECLARE @nStep_6 INT = 6, @nScn_6 INT = 1305  -- UCC Screen
   DECLARE @nStep_7 INT = 7, @nScn_7 INT = 1306  -- Create New UCC? (SKIP for NORMAL)
   DECLARE @nStep_8 INT = 8, @nScn_8 INT = 1307  -- SKU Screen (SKIP, use stored SKU)
   DECLARE @nStep_9 INT = 9, @nScn_9 INT = 1308  -- QTY Screen (SKIP, use PACK.CaseCnt)
   DECLARE @nStep_10 INT = 10, @nScn_10 INT = 1309  -- Extra Data / Confirm
   DECLARE @nStep_11 INT = 11, @nScn_11 INT = 1310  -- ESC Anyway? (1=YES, 2=NO)

   -- Local variable for option
   DECLARE @cOption NVARCHAR(1)
   DECLARE @nCurrentStep INT

   IF @nFunc <> 898
      GOTO Quit

   -- Get data from RDTMOBREC
   SELECT
      @nCurrentStep    = Step,
      @cReceiptKey     = ISNULL(V_ReceiptKey, ''),
      @cPOKey          = ISNULL(V_POKey, ''),
      @cMax            = ISNULL(V_Max, ''),
      @cTotalCarton    = ISNULL(NULLIF(RTRIM(V_String2), ''), '0'),
      @cCartonCnt      = ISNULL(NULLIF(RTRIM(V_String48), ''), '0'),  -- Use V_String48 for our counter
      @cSkipEstUCCOnID = ISNULL(V_String22, '0'),
      @cLoc            = ISNULL(V_Loc, ''),
      @cToID           = ISNULL(V_Id, ''),
      @cStoredSKU      = ISNULL(V_String50, ''),  -- Store first SKU in V_String50
      @cStoredUCC      = ISNULL(V_String49, '')   -- Store current UCC in V_String49
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile
   
   -- Get ProcessType, ExternReceiptKey and Signatory from RECEIPT
   SELECT @cProcessType = ISNULL(RTRIM(ProcessType), ''),
          @cExternReceiptKey = ISNULL(RTRIM(ExternReceiptKey), ''),
          @cSignatory = ISNULL(RTRIM(Signatory), '')
   FROM dbo.Receipt WITH(NOLOCK)
   WHERE ReceiptKey = @cReceiptKey
     AND StorerKey = @cStorerKey

   /*==========================================================================
   STEP 0: Screen 4 (Estimated UCC on ID) - Clear stored SKU for new batch
   When user enters a new UCC count, clear the stored SKU so first UCC of
   new batch will ask for SKU input.
   ==========================================================================*/
   IF @nStep = @nStep_4
   BEGIN
      IF @nInputKey = 1
      BEGIN
         -- Capture the estimated UCC count from user input
         SET @cTotalCarton = ISNULL(RTRIM(@cInField05), '0')

         -- Clear stored SKU, stored UCC for new batch and store the total carton count
         UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
         SET V_String50 = '',
             V_String49 = '',  -- Clear stored UCC (important for ProcessType C count tracking)
             V_String2 = @cTotalCarton,
             V_String48 = '0'  -- Reset carton count for new batch
         WHERE Mobile = @nMobile

      END
   END

   /*==========================================================================
   STEP 1: Screen 5 (Lottable) - SKIP IT, go to Screen 6
   Note: ExtScn is NOT called at Step 4 by main SP, so we detect new batch here
   ==========================================================================*/
   IF @nStep = @nStep_5
   BEGIN

      IF @nCurrentStep = @nStep_11
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SET @cOption = ISNULL(RTRIM(@cInField01), '')

            IF @cOption = '1'
            BEGIN
               -- Option 1: YES - Go to Estimated UCC on ID (Screen 4)
               -- Clear stored SKU for new batch
               UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
               SET V_String50 = '',
                  V_String48 = '0',
                  V_String49 = ''
               WHERE Mobile = @nMobile

               -- Set correct field values for Screen 4
               SET @cOutField01 = ISNULL(@cReceiptKey, '')  -- ASN
               SET @cOutField02 = ISNULL(@cPOKey, '')       -- PO
               SET @cOutField03 = ISNULL(@cLoc, '')         -- TO LOC
               SET @cOutField04 = ISNULL(@cToID, '')        -- TO ID
               SET @cOutField05 = ''                        -- Estimated UCC count (empty for input)
               SET @cOutField11 = ''

               SET @nAfterStep = @nStep_4
               SET @nAfterScn = @nScn_4
               GOTO Quit
            END
         END
      END

      IF @nInputKey = 1
      BEGIN
         -- Detect new batch: StoredSKU is empty (cleared when previous batch completed)
         -- Reset carton counter for new batch since Step 4 handler never runs
         -- Only for ProcessType N - ProcessType C doesn't use StoredSKU
         IF (@cStoredSKU = '' OR @cStoredSKU IS NULL) -- AND UPPER(@cProcessType) = 'N'
         BEGIN
            -- New batch detected - reset carton counter
            UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
            SET V_String48 = '0'
            WHERE Mobile = @nMobile

            SET @cCartonCnt = '0'

         END

         -- At Step 5, if this is fresh (carton count = 0), try to get total from @cInField05
         IF (@cTotalCarton = '0' OR @cTotalCarton = '') AND @cCartonCnt = '0'
         BEGIN
            -- Try to get total from @cInField05 (estimate entered at Step 4)
            DECLARE @cEstimate NVARCHAR(4)
            SET @cEstimate = ISNULL(RTRIM(@cInField05), '')

            -- Validate it's a number
            IF @cEstimate <> '' AND TRY_CAST(@cEstimate AS INT) IS NOT NULL
            BEGIN
               SET @cTotalCarton = @cEstimate

               -- Store it in V_String2 for subsequent calls
               UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
               SET V_String2 = @cTotalCarton
               WHERE Mobile = @nMobile

            END
         END

         SET @cCountDisplay = ISNULL(@cCartonCnt, '0') + '/' + ISNULL(@cTotalCarton, '0')
         SET @cOutField01 = ''
         SET @cOutField11 = @cCountDisplay

         SET @nAfterStep = @nStep_6
         SET @nAfterScn = @nScn_6

         GOTO Quit
      END

   END

   /*==========================================================================
   STEP 2: Screen 6 (UCC) - Validate based on ProcessType
   For NORMAL mode with new UCC: Execute Steps 7,8,9,10 logic and return here
   ==========================================================================*/
   IF @nStep = @nStep_6
   BEGIN

      IF @nCurrentStep = @nStep_11 
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SET @cOption = ISNULL(RTRIM(@cInField01), '')

            IF @cOption = '2'
            BEGIN
               -- Option 2: NO - Go back to UCC screen (Screen 6)
               SET @cCountDisplay = ISNULL(@cCartonCnt, '0') + '/' + ISNULL(@cTotalCarton, '0')

               SET @cOutField01 = ''  -- UCC (empty for input)
               SET @cOutField02 = ISNULL(@cStoredSKU, '')   -- SKU
               SET @cOutField11 = @cCountDisplay

               SET @nAfterStep = @nStep_6
               SET @nAfterScn = @nScn_6
               GOTO Quit
            END
         END

         -- ESC on this screen - go back to UCC screen
         IF @nInputKey = 0
         BEGIN
            SET @cCountDisplay = ISNULL(@cCartonCnt, '0') + '/' + ISNULL(@cTotalCarton, '0')

            SET @cOutField01 = ''
            SET @cOutField02 = ISNULL(@cStoredSKU, '')
            SET @cOutField11 = @cCountDisplay

            SET @nAfterStep = @nStep_6
            SET @nAfterScn = @nScn_6
            GOTO Quit
         END
      END
      ELSE IF @nCurrentStep = @nStep_8
      BEGIN

         -- ESC on this screen - go back to UCC screen
         IF @nInputKey = 0
         BEGIN
            SET @cCountDisplay = ISNULL(@cCartonCnt, '0') + '/' + ISNULL(@cTotalCarton, '0')

            SET @cOutField01 = ''
            SET @cOutField02 = ISNULL(@cStoredSKU, '')
            SET @cOutField11 = @cCountDisplay

            SET @nAfterStep = @nStep_6
            SET @nAfterScn = @nScn_6
            GOTO Quit
         END
      END
      -- Only set count display if we have valid total (not 0)
      -- Otherwise let main SP handle it
      IF @cTotalCarton <> '0' AND @cTotalCarton <> ''
      BEGIN
         SET @cCountDisplay = ISNULL(@cCartonCnt, '0') + '/' + ISNULL(@cTotalCarton, '0')
         SET @cOutField11 = @cCountDisplay
      END

      IF @nInputKey = 1
      BEGIN
         SET @cUCC = ISNULL(RTRIM(SUBSTRING(@cMax, 1, 20)), '')

         IF @cUCC = ''
         BEGIN
            SET @nErrNo = 264804
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')

            GOTO Quit
         END

         -- Validate UCC is 20-digit number
         IF LEN(@cUCC) > 20 OR @cUCC LIKE '%[^0-9]%'
         BEGIN
            SET @nErrNo = 264815
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            GOTO Quit
         END

         -- Check if UCC exists
         SET @nUCCExists = 0
         IF EXISTS (SELECT 1 FROM dbo.UCC WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND UCCNo = @cUCC)
            SET @nUCCExists = 1

         -- CID Mode: UCC must exist
         IF UPPER(@cProcessType) = 'C'
         BEGIN
            IF @nUCCExists = 0
            BEGIN
               SET @nErrNo = 264801
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               SET @cOutField01 = ''

               SET @nAfterStep = @nStep_6
               SET @nAfterScn = @nScn_6
               GOTO Quit
            END

            -- -- Check if a previous receive completed (V_String49 has a value from previous UCC)
            -- -- If so, increment count before processing the new UCC
            -- IF @cStoredUCC <> '' AND @cStoredUCC IS NOT NULL
            -- BEGIN
            --    -- Previous receive completed, increment count
            --    SET @nCurrentCnt = ISNULL(TRY_CAST(@cCartonCnt AS INT), 0) + 1
            --    SET @cCartonCnt = CAST(@nCurrentCnt AS NVARCHAR(4))

            --    -- Update counter
            --    UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
            --    SET V_String48 = @cCartonCnt
            --    WHERE Mobile = @nMobile
            -- END

            SET @nCurrentCnt = ISNULL(TRY_CAST(@cCartonCnt AS INT), 0) + 1
            SET @cCartonCnt = CAST(@nCurrentCnt AS NVARCHAR(4))

            -- Store current UCC in V_String49 to track this receive in progress
            UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
            SET V_String49 = @cUCC, V_String48 = @cCartonCnt
            WHERE Mobile = @nMobile

            -- Update count display
            SET @nTotalCnt = ISNULL(TRY_CAST(@cTotalCarton AS INT), 0)
            SET @cCountDisplay = @cCartonCnt + '/' + CAST(@nTotalCnt AS NVARCHAR(4))
            SET @cOutField11 = @cCountDisplay

            -- Check if count is full - navigate to TO ID or ASN screen
            IF @nTotalCnt > 0 AND @nCurrentCnt >= @nTotalCnt
            BEGIN
               -- Count full - check if ASN fully received
               SET @nASNFullyReceived = 0
               IF NOT EXISTS (
                  SELECT 1 FROM dbo.ReceiptDetail RD WITH(NOLOCK)
                  WHERE RD.ReceiptKey = @cReceiptKey
                    AND RD.QtyExpected > RD.QtyReceived
               )
                  SET @nASNFullyReceived = 1

               IF @nASNFullyReceived = 1
               BEGIN
                  -- ASN fully received, go to Screen 1 (ASN)
                  UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
                  SET V_String50 = '', V_String49 = ''
                  WHERE Mobile = @nMobile

                  SET @cOutField01 = ''
                  SET @cOutField02 = ''
                  SET @cOutField03 = ''
                  SET @cOutField04 = ''
                  SET @cOutField05 = ''
                  SET @cOutField11 = ''

                  SET @nAfterStep = @nStep_1
                  SET @nAfterScn = @nScn_1
                  GOTO Quit
               END
               ELSE
               BEGIN
                  -- Go to TO ID screen (Screen 3)
                  UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
                  SET V_String50 = '', V_String49 = ''
                  WHERE Mobile = @nMobile

                  SET @cOutField01 = ISNULL(@cReceiptKey, '')
                  SET @cOutField02 = ISNULL(@cPOKey, '')
                  SET @cOutField03 = ISNULL(@cLoc, '')
                  SET @cOutField04 = ''
                  SET @cOutField05 = ''
                  SET @cOutField11 = ''

                  SET @nAfterStep = @nStep_3
                  SET @nAfterScn = @nScn_3
                  GOTO Quit
               END
            END

            -- Count not full - let main SP handle the normal flow
         END

         -- NORMAL Mode: For new UCC, execute all hidden steps' logic
         IF UPPER(@cProcessType) = 'N'
         BEGIN
            IF @nUCCExists = 0
            BEGIN
               -- ============================================================
               -- Execute Step 8 logic (SKU)
               -- Use stored SKU if available, otherwise this is first UCC
               -- ============================================================
               IF @cStoredSKU = '' OR @cStoredSKU IS NULL
               BEGIN
                  -- First UCC - need to get SKU from user, go to SKU screen
                  -- Store UCC in V_String49 so we can retrieve it at Screen 8
                  UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
                  SET V_String49 = @cUCC
                  WHERE Mobile = @nMobile

                  SET @cOutField01 = @cUCC
                  SET @cOutField02 = ''
                  SET @cOutField03 = ISNULL(@cCartonCnt, '0') + '/' + ISNULL(@cTotalCarton, '0')

                  SET @nAfterStep = @nStep_8
                  SET @nAfterScn = @nScn_8

                  GOTO Quit
               END
               ELSE
               BEGIN
                  -- Subsequent UCC - use stored SKU
                  SET @cSKU = @cStoredSKU

                  -- Validate SKU
                  IF NOT EXISTS (SELECT 1 FROM dbo.SKU WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU)
                  BEGIN
                     SET @nErrNo = 264806
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')

                     GOTO Quit
                  END

                  -- ============================================================
                  -- Execute Step 9 logic (QTY = PACK.CaseCnt)
                  -- ============================================================
                  SET @nCaseCnt = 1
                  SELECT @nCaseCnt = ISNULL(P.CaseCnt, 1),
                         @cPackKey = S.PackKey,
                         @cUOM = ISNULL(P.PackUOM3, '')
                  FROM dbo.SKU S WITH(NOLOCK)
                  INNER JOIN dbo.PACK P WITH(NOLOCK) ON P.PackKey = S.PackKey
                  WHERE S.StorerKey = @cStorerKey
                    AND S.SKU = @cSKU

                  SET @nQTY = @nCaseCnt

                  -- ============================================================
                  -- Execute Step 10 logic (Call rdt_UCCReceive_Confirm)
                  -- ============================================================
                  SET @cPOKeyValue = CASE WHEN UPPER(@cPOKey) = 'NOPO' THEN '' ELSE @cPOKey END
                  SET @nNOPOFlag = CASE WHEN UPPER(@cPOKey) = 'NOPO' THEN 1 ELSE 0 END

                  -- Calculate Lottable values
                  -- Lottable01 = Single Carton CUBE, Lottable02 = Single Carton Weight
                  -- Lottable06 = PO (ExternReceiptKey), Lottable07 = SO (Signatory)
                  SET @cLott01 = ''
                  SET @cLott02 = ''
                  SET @cLott06 = @cExternReceiptKey
                  SET @cLott07 = @cSignatory

                  SELECT @nCube = ISNULL(RD.Cube, 0),
                         @nGrossWgt = ISNULL(RD.GrossWgt, 0),
                         @nQtyExpected = ISNULL(RD.QtyExpected, 0)
                  FROM dbo.ReceiptDetail RD WITH(NOLOCK)
                  WHERE RD.ReceiptKey = @cReceiptKey
                    AND RD.SKU = @cSKU
                    AND RD.StorerKey = @cStorerKey

                  IF @nQtyExpected > 0
                  BEGIN
                     SET @cLott01 = CAST(CAST(ROUND(@nCube / @nQtyExpected, 3) AS DECIMAL(18,3)) AS NVARCHAR(18))
                     SET @cLott02 = CAST(CAST(ROUND(@nGrossWgt / @nQtyExpected, 3) AS DECIMAL(18,3)) AS NVARCHAR(18))
                  END

                  -- Initialize error variables
                  SET @nErrNo = 0
                  SET @cErrMsg = ''

                  BEGIN TRY
                  BEGIN TRANSACTION

                  EXEC rdt.rdt_UCCReceive_Confirm
                     @nFunc         = @nFunc,
                     @nMobile       = @nMobile,
                     @cLangCode     = @cLangCode,
                     @nErrNo        = @nErrNo OUTPUT,
                     @cErrMsg       = @cErrMsg OUTPUT,
                     @cStorerKey    = @cStorerKey,
                     @cFacility     = @cFacility,
                     @cReceiptKey   = @cReceiptKey,
                     @cPOKey        = @cPOKeyValue,
                     @cToLOC        = @cLoc,
                     @cToID         = @cToID,
                     @cSKUCode      = '',
                     @cSKUUOM       = '',
                     @nSKUQTY       = 0,
                     @cUCC          = @cUCC,
                     @cUCCSKU       = @cSKU,
                     @nUCCQTY       = @nQTY,
                     @cCreateUCC    = '1',
                     @cLottable01   = @cLott01,
                     @cLottable02   = @cLott02,
                     @cLottable03   = '',
                     @dLottable04   = NULL,
                     @dLottable05   = NULL,
                     @nNOPOFlag     = @nNOPOFlag,
                     @cConditionCode = 'OK',
                     @cSubreasonCode = ''

                  IF ISNULL(@nErrNo, 0) <> 0
                  BEGIN
                     ROLLBACK TRANSACTION
                     GOTO Quit
                  END

                  -- Update UCC with CFS specific fields
                  UPDATE dbo.UCC WITH(ROWLOCK)
                  SET ExternKey = @cExternReceiptKey,
                      SourceType = 'PO',
                      Userdefined01 = 'N'
                  WHERE StorerKey = @cStorerKey
                    AND UCCNo = @cUCC

                  COMMIT TRANSACTION
                  END TRY
                  BEGIN CATCH
                     IF @@TRANCOUNT > 0
                        ROLLBACK TRANSACTION
                     SET @nErrNo = 264819
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END CATCH

                  -- Increase carton count
                  SET @nCurrentCnt = ISNULL(TRY_CAST(@cCartonCnt AS INT), 0) + 1
                  SET @nTotalCnt = ISNULL(TRY_CAST(@cTotalCarton AS INT), 0)

                  UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
                  SET V_String48 = CAST(@nCurrentCnt AS NVARCHAR(4))
                  WHERE Mobile = @nMobile

                  -- ============================================================
                  -- Navigation: Check count and decide where to go
                  -- ============================================================
                  IF @nTotalCnt > 0 AND @nCurrentCnt >= @nTotalCnt
                  BEGIN
                     -- UCC count matched, check if ASN fully received
                     SET @nASNFullyReceived = 0
                     IF NOT EXISTS (
                        SELECT 1 FROM dbo.ReceiptDetail RD WITH(NOLOCK)
                        WHERE RD.ReceiptKey = @cReceiptKey
                          AND RD.QtyExpected > RD.QtyReceived
                     )
                        SET @nASNFullyReceived = 1

                     IF @nASNFullyReceived = 1
                     BEGIN
                        -- ASN fully received, go to Screen 1
                        -- Clear stored SKU for next batch
                        UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
                        SET V_String50 = ''
                        WHERE Mobile = @nMobile

                        -- Clear output fields for Screen 1
                        SET @cOutField01 = ''
                        SET @cOutField02 = ''
                        SET @cOutField03 = ''
                        SET @cOutField04 = ''
                        SET @cOutField05 = ''
                        SET @cOutField11 = ''

                        SET @nAfterStep = @nStep_1
                        SET @nAfterScn = @nScn_1
                     END
                     ELSE
                     BEGIN
                        -- Go to TO ID screen (Screen 3)
                        -- Clear stored SKU for next batch
                        UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
                        SET V_String50 = ''
                        WHERE Mobile = @nMobile

                        -- Set correct field values for Screen 3 (use ISNULL to avoid NULL errors)
                        SET @cOutField01 = ISNULL(@cReceiptKey, '')                       -- ASN
                        SET @cOutField02 = ISNULL(@cPOKey, '')                       -- PO
                        SET @cOutField03 = ISNULL(@cLoc, '')                         -- TO LOC
                        SET @cOutField04 = ''                                        -- TO ID (empty for input)
                        SET @cOutField05 = ''
                        SET @cOutField11 = ''

                        SET @nAfterStep = @nStep_3
                        SET @nAfterScn = @nScn_3
                     END
                  END
                  ELSE
                  BEGIN
                     -- More UCCs to receive, stay on Screen 6
                     SET @cCountDisplay = CAST(@nCurrentCnt AS NVARCHAR(4)) + '/' + CAST(@nTotalCnt AS NVARCHAR(4))
                     SET @cOutField01 = ''
                     SET @cOutField11 = @cCountDisplay

                     SET @nAfterStep = @nStep_6
                     SET @nAfterScn = @nScn_6
                  END
                  GOTO Quit
               END
            END
            ELSE
            BEGIN
               -- NORMAL mode but UCC exists - update UCC fields and let main SP handle
               UPDATE dbo.UCC WITH(ROWLOCK)
               SET ExternKey = @cExternReceiptKey,
                   SourceType = 'PO',
                   Userdefined01 = 'N'
               WHERE StorerKey = @cStorerKey
                 AND UCCNo = @cUCC
            END
         END
      END

      -- ESC: Check if coming from Screen 8 (first UCC SKU entry)
      IF @nInputKey = 0
      BEGIN
         -- If there's a stored UCC, user pressed ESC on Screen 8 - stay on Screen 6
         IF @cStoredUCC <> '' AND @cStoredUCC IS NOT NULL
         BEGIN
            -- Clear stored UCC since user cancelled
            UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
            SET V_String49 = ''
            WHERE Mobile = @nMobile

            SET @cOutField01 = ''
            SET @cCountDisplay = ISNULL(@cCartonCnt, '0') + '/' + ISNULL(@cTotalCarton, '0')
            SET @cOutField11 = @cCountDisplay

            SET @nAfterStep = @nStep_6
            SET @nAfterScn = @nScn_6
            GOTO Quit
         END

         GOTO Quit
      END
   END

   /*==========================================================================
   STEP 3: Screen 7 (Create New UCC?) - SKIP for NORMAL, auto YES
   ==========================================================================*/
   IF @nStep = @nStep_7
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF UPPER(@cProcessType) = 'N'
         BEGIN
            -- Auto-YES, go to SKU screen
            SET @nAfterStep = @nStep_8
            SET @nAfterScn = @nScn_8
            GOTO Quit
         END

         IF UPPER(@cProcessType) = 'C'
         BEGIN
            SET @nErrNo = 264801
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')

            SET @nAfterStep = @nStep_6
            SET @nAfterScn = @nScn_6
            GOTO Quit
         END
      END

   END

   /*==========================================================================
   STEP 4: Screen 8 (SKU) - First UCC needs SKU input, then store it
   Subsequent UCCs will use stored SKU (handled in Screen 6)
   ==========================================================================*/
   IF @nStep = @nStep_8
   BEGIN
      IF @nInputKey = 1
      BEGIN
         SET @cSKU = ISNULL(RTRIM(SUBSTRING(@cMax, 1, 20)), '')
         -- Get UCC from stored value (V_String49), not from @cOutField01
         SET @cUCC = ISNULL(@cStoredUCC, '')

         -- If no stored UCC, try from field
         IF @cUCC = ''
            SET @cUCC = ISNULL(RTRIM(@cOutField01), ISNULL(RTRIM(@cInField01), ''))

         IF @cSKU <> '' AND @cUCC <> ''
         BEGIN
            -- Validate SKU
            IF NOT EXISTS (SELECT 1 FROM dbo.SKU WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU)
            BEGIN
               SET @nErrNo = 264806
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               SET @cOutField02 = ''

               SET @nAfterStep = @nStep_8
               SET @nAfterScn = @nScn_8
               GOTO Quit
            END

            -- Store SKU for subsequent UCCs
            UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
            SET V_String50 = @cSKU
            WHERE Mobile = @nMobile

            -- ============================================================
            -- Execute Step 9 logic (QTY = PACK.CaseCnt)
            -- ============================================================
            SET @nCaseCnt = 1
            SELECT @nCaseCnt = ISNULL(P.CaseCnt, 1),
                   @cPackKey = S.PackKey,
                   @cUOM = ISNULL(P.PackUOM3, '')
            FROM dbo.SKU S WITH(NOLOCK)
            INNER JOIN dbo.PACK P WITH(NOLOCK) ON P.PackKey = S.PackKey
            WHERE S.StorerKey = @cStorerKey
              AND S.SKU = @cSKU

            SET @nQTY = @nCaseCnt
            -- ============================================================
            -- Execute Step 10 logic (Call rdt_UCCReceive_Confirm)
            -- ============================================================
            SET @cPOKeyValue = CASE WHEN UPPER(@cPOKey) = 'NOPO' THEN '' ELSE @cPOKey END
            SET @nNOPOFlag = CASE WHEN UPPER(@cPOKey) = 'NOPO' THEN 1 ELSE 0 END

            -- Calculate Lottable values
            SET @cLott01 = ''
            SET @cLott02 = ''
            SET @cLott06 = @cExternReceiptKey
            SET @cLott07 = @cSignatory

            SELECT @nCube = ISNULL(RD.Cube, 0),
                   @nGrossWgt = ISNULL(RD.GrossWgt, 0),
                   @nQtyExpected = ISNULL(RD.QtyExpected, 0)
            FROM dbo.ReceiptDetail RD WITH(NOLOCK)
            WHERE RD.ReceiptKey = @cReceiptKey
              AND RD.SKU = @cSKU
              AND RD.StorerKey = @cStorerKey

            IF @nQtyExpected > 0
            BEGIN
               SET @cLott01 = CAST(CAST(ROUND(@nCube / @nQtyExpected, 3) AS DECIMAL(18,3)) AS NVARCHAR(18))
               SET @cLott02 = CAST(CAST(ROUND(@nGrossWgt / @nQtyExpected, 3) AS DECIMAL(18,3)) AS NVARCHAR(18))
            END

            -- Initialize error variables
            SET @nErrNo = 0
            SET @cErrMsg = ''

            BEGIN TRY
            BEGIN TRANSACTION

            EXEC rdt.rdt_UCCReceive_Confirm
               @nFunc         = @nFunc,
               @nMobile       = @nMobile,
               @cLangCode     = @cLangCode,
               @nErrNo        = @nErrNo OUTPUT,
               @cErrMsg       = @cErrMsg OUTPUT,
               @cStorerKey    = @cStorerKey,
               @cFacility     = @cFacility,
               @cReceiptKey   = @cReceiptKey,
               @cPOKey        = @cPOKeyValue,
               @cToLOC        = @cLoc,
               @cToID         = @cToID,
               @cSKUCode      = '',
               @cSKUUOM       = '',
               @nSKUQTY       = 0,
               @cUCC          = @cUCC,
               @cUCCSKU       = @cSKU,
               @nUCCQTY       = @nQTY,
               @cCreateUCC    = '1',
               @cLottable01   = @cLott01,
               @cLottable02   = @cLott02,
               @cLottable03   = '',
               @dLottable04   = NULL,
               @dLottable05   = NULL,
               @nNOPOFlag     = @nNOPOFlag,
               @cConditionCode = 'OK',
               @cSubreasonCode = ''

            IF ISNULL(@nErrNo, 0) <> 0
            BEGIN
               ROLLBACK TRANSACTION
               GOTO Quit
            END

            -- Update UCC with CFS specific fields
            UPDATE dbo.UCC WITH(ROWLOCK)
            SET ExternKey = @cExternReceiptKey,
                SourceType = 'PO',
                Userdefined01 = 'N'
            WHERE StorerKey = @cStorerKey
              AND UCCNo = @cUCC

            COMMIT TRANSACTION
            END TRY
            BEGIN CATCH
               IF @@TRANCOUNT > 0
                  ROLLBACK TRANSACTION
               SET @nErrNo = 264819
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END CATCH

            -- Increase carton count
            SET @nCurrentCnt = ISNULL(TRY_CAST(@cCartonCnt AS INT), 0) + 1
            SET @nTotalCnt = ISNULL(TRY_CAST(@cTotalCarton AS INT), 0)

            UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
            SET V_String48 = CAST(@nCurrentCnt AS NVARCHAR(4))
            WHERE Mobile = @nMobile

            -- ============================================================
            -- Navigation
            -- ============================================================
            IF @nTotalCnt > 0 AND @nCurrentCnt >= @nTotalCnt
            BEGIN
               SET @nASNFullyReceived = 0
               IF NOT EXISTS (
                  SELECT 1 FROM dbo.ReceiptDetail RD WITH(NOLOCK)
                  WHERE RD.ReceiptKey = @cReceiptKey
                    AND RD.QtyExpected > RD.QtyReceived
               )
                  SET @nASNFullyReceived = 1

               IF @nASNFullyReceived = 1
               BEGIN
                  -- Clear stored SKU for next batch
                  UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
                  SET V_String50 = ''
                  WHERE Mobile = @nMobile

                  -- Clear output fields for Screen 1
                  SET @cOutField01 = ''
                  SET @cOutField02 = ''
                  SET @cOutField03 = ''
                  SET @cOutField04 = ''
                  SET @cOutField05 = ''
                  SET @cOutField11 = ''

                  SET @nAfterStep = @nStep_1
                  SET @nAfterScn = @nScn_1
               END
               ELSE
               BEGIN
                  -- Clear stored SKU for next batch
                  UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
                  SET V_String50 = ''
                  WHERE Mobile = @nMobile

                  -- Set correct field values for Screen 3 (use ISNULL to avoid NULL errors)
                  SET @cOutField01 = ISNULL(@cReceiptKey, '')                  -- ASN
                  SET @cOutField02 = ISNULL(@cPOKey, '')                       -- PO
                  SET @cOutField03 = ISNULL(@cLoc, '')                         -- TO LOC
                  SET @cOutField04 = ''                                        -- TO ID (empty for input)
                  SET @cOutField05 = ''
                  SET @cOutField11 = ''

                  SET @nAfterStep = @nStep_3
                  SET @nAfterScn = @nScn_3
               END
            END
            ELSE
            BEGIN
               SET @cCountDisplay = CAST(@nCurrentCnt AS NVARCHAR(4)) + '/' + CAST(@nTotalCnt AS NVARCHAR(4))
               SET @cOutField01 = ''
               SET @cOutField11 = @cCountDisplay

               SET @nAfterStep = @nStep_6
               SET @nAfterScn = @nScn_6
            END
            GOTO Quit
         END
      END

   END

   /*==========================================================================
   STEP 5: Screen 9 (QTY) - Intercept after Screen 8 SKU entry
   When we reach here with a stored UCC, the main SP just validated SKU.
   We process the UCC receive here and skip the QTY screen.
   ==========================================================================*/
   IF @nStep = @nStep_9
   BEGIN
      -- Get SKU from @tExtScnData (main SP passes validated values here)
      SELECT @cSKU = Value FROM @tExtScnData WHERE Variable = '@cSKU'
      SELECT @cUCC = Value FROM @tExtScnData WHERE Variable = '@cUCC'

      -- If we have a stored UCC, this is our first UCC flow
      -- Process the UCC receive here
      IF @cStoredUCC <> '' AND UPPER(@cProcessType) = 'N'
      BEGIN
         SET @cUCC = @cStoredUCC

         -- Get SKU - prefer from ExtScnData, fallback to stored
         IF @cSKU = '' OR @cSKU IS NULL
         BEGIN
            -- Try to get from OutField02 (display field for SKU)
            SET @cSKU = ISNULL(RTRIM(@cOutField02), '')
         END

         IF @cSKU = ''
         BEGIN
            SET @nErrNo = 264806
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')

            GOTO Quit
         END

         -- Store SKU for subsequent UCCs
         UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
         SET V_String50 = @cSKU,
             V_String49 = ''  -- Clear stored UCC after processing
         WHERE Mobile = @nMobile

         -- Get QTY from PACK.CaseCnt
         SET @nCaseCnt = 1
         SELECT @nCaseCnt = ISNULL(P.CaseCnt, 1),
                @cPackKey = S.PackKey,
                @cUOM = ISNULL(P.PackUOM3, '')
         FROM dbo.SKU S WITH(NOLOCK)
         INNER JOIN dbo.PACK P WITH(NOLOCK) ON P.PackKey = S.PackKey
         WHERE S.StorerKey = @cStorerKey
           AND S.SKU = @cSKU

         SET @nQTY = @nCaseCnt

         -- Call rdt_UCCReceive_Confirm
         SET @cPOKeyValue = CASE WHEN UPPER(@cPOKey) = 'NOPO' THEN '' ELSE @cPOKey END
         SET @nNOPOFlag = CASE WHEN UPPER(@cPOKey) = 'NOPO' THEN 1 ELSE 0 END

         -- Calculate Lottable values
         SET @cLott01 = ''
         SET @cLott02 = ''
         SET @cLott06 = @cExternReceiptKey
         SET @cLott07 = @cSignatory

         SELECT @nCube = ISNULL(RD.Cube, 0),
                @nGrossWgt = ISNULL(RD.GrossWgt, 0),
                @nQtyExpected = ISNULL(RD.QtyExpected, 0)
         FROM dbo.ReceiptDetail RD WITH(NOLOCK)
         WHERE RD.ReceiptKey = @cReceiptKey
           AND RD.SKU = @cSKU
           AND RD.StorerKey = @cStorerKey

         IF @nQtyExpected > 0
         BEGIN
            SET @cLott01 = CAST(CAST(ROUND(@nCube / @nQtyExpected, 3) AS DECIMAL(18,3)) AS NVARCHAR(18))
            SET @cLott02 = CAST(CAST(ROUND(@nGrossWgt / @nQtyExpected, 3) AS DECIMAL(18,3)) AS NVARCHAR(18))
         END

         SET @nErrNo = 0
         SET @cErrMsg = ''

         BEGIN TRY
         BEGIN TRANSACTION

         EXEC rdt.rdt_UCCReceive_Confirm
            @nFunc         = @nFunc,
            @nMobile       = @nMobile,
            @cLangCode     = @cLangCode,
            @nErrNo        = @nErrNo OUTPUT,
            @cErrMsg       = @cErrMsg OUTPUT,
            @cStorerKey    = @cStorerKey,
            @cFacility     = @cFacility,
            @cReceiptKey   = @cReceiptKey,
            @cPOKey        = @cPOKeyValue,
            @cToLOC        = @cLoc,
            @cToID         = @cToID,
            @cSKUCode      = '',
            @cSKUUOM       = '',
            @nSKUQTY       = 0,
            @cUCC          = @cUCC,
            @cUCCSKU       = @cSKU,
            @nUCCQTY       = @nQTY,
            @cCreateUCC    = '1',
            @cLottable01   = @cLott01,
            @cLottable02   = @cLott02,
            @cLottable03   = '',
            @dLottable04   = NULL,
            @dLottable05   = NULL,
            @nNOPOFlag     = @nNOPOFlag,
            @cConditionCode = 'OK',
            @cSubreasonCode = ''

         IF ISNULL(@nErrNo, 0) <> 0
         BEGIN
            ROLLBACK TRANSACTION

            GOTO Quit
         END

         -- Update UCC with CFS specific fields
         UPDATE dbo.UCC WITH(ROWLOCK)
         SET ExternKey = @cExternReceiptKey,
             SourceType = 'PO',
             Userdefined01 = 'N'
         WHERE StorerKey = @cStorerKey
           AND UCCNo = @cUCC

         COMMIT TRANSACTION
         END TRY
         BEGIN CATCH
            IF @@TRANCOUNT > 0
               ROLLBACK TRANSACTION
            SET @nErrNo = 264819
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            GOTO Quit
         END CATCH

         -- Increase carton count
         SET @nCurrentCnt = ISNULL(TRY_CAST(@cCartonCnt AS INT), 0) + 1
         SET @nTotalCnt = ISNULL(TRY_CAST(@cTotalCarton AS INT), 0)

         UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
         SET V_String48 = CAST(@nCurrentCnt AS NVARCHAR(4))
         WHERE Mobile = @nMobile

         -- Navigation
         IF @nTotalCnt > 0 AND @nCurrentCnt >= @nTotalCnt
         BEGIN
            SET @nASNFullyReceived = 0
            IF NOT EXISTS (
               SELECT 1 FROM dbo.ReceiptDetail RD WITH(NOLOCK)
               WHERE RD.ReceiptKey = @cReceiptKey
                 AND RD.QtyExpected > RD.QtyReceived
            )
               SET @nASNFullyReceived = 1

            IF @nASNFullyReceived = 1
            BEGIN
               -- Clear stored SKU for next batch
               UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
               SET V_String50 = ''
               WHERE Mobile = @nMobile

               -- Clear output fields for Screen 1
               SET @cOutField01 = ''
               SET @cOutField02 = ''
               SET @cOutField03 = ''
               SET @cOutField04 = ''
               SET @cOutField05 = ''
               SET @cOutField11 = ''

               SET @nAfterStep = @nStep_1
               SET @nAfterScn = @nScn_1
            END
            ELSE
            BEGIN
               -- Clear stored SKU for next batch
               UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
               SET V_String50 = ''
               WHERE Mobile = @nMobile

               -- Set correct field values for Screen 3 (use ISNULL to avoid NULL errors)
               SET @cOutField01 = ISNULL(@cReceiptKey, '')                  -- ASN
               SET @cOutField02 = ISNULL(@cPOKey, '')                       -- PO
               SET @cOutField03 = ISNULL(@cLoc, '')                         -- TO LOC
               SET @cOutField04 = ''                                        -- TO ID (empty for input)
               SET @cOutField05 = ''
               SET @cOutField11 = ''

               SET @nAfterStep = @nStep_3
               SET @nAfterScn = @nScn_3
            END
         END
         ELSE
         BEGIN
            SET @cCountDisplay = CAST(@nCurrentCnt AS NVARCHAR(4)) + '/' + CAST(@nTotalCnt AS NVARCHAR(4))
            SET @cOutField01 = ''
            SET @cOutField11 = @cCountDisplay

            SET @nAfterStep = @nStep_6
            SET @nAfterScn = @nScn_6
         END
         GOTO Quit
      END

      -- ESC: Go back to Screen 6 (UCC screen)
      IF @nInputKey = 0
      BEGIN
         -- Clear stored UCC since user cancelled
         UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
         SET V_String49 = ''
         WHERE Mobile = @nMobile

         SET @cOutField01 = ''
         SET @cOutField02 = ''
         SET @cCountDisplay = ISNULL(@cCartonCnt, '0') + '/' + ISNULL(@cTotalCarton, '0')
         SET @cOutField11 = @cCountDisplay

         SET @nAfterStep = @nStep_6
         SET @nAfterScn = @nScn_6
         GOTO Quit
      END

      SET @nAfterStep = @nStep_6
      SET @nAfterScn = @nScn_6
      GOTO Quit
   END

   Quit:
   IF @nErrNo IS NULL OR (@nErrNo <> 0 AND @cErrMsg = '')
      SET @nErrNo = 0
   IF @cErrMsg IS NULL
      SET @cErrMsg = ''

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_898ExtScn07 TO NSQL
GO
