SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Store procedure: rdt_1837ExtScn01                                    */
/*                                                                      */
/* Purpose:       Extended Screen Logic for Post Pack Sort              */
/*                                                                      */
/* Date        Rev   Author     Purposes                                */
/* 2026-01-08  1.0   NYE018     FCR-9508                                */
/************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_1837ExtScn01] (
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,           
   @nScn         INT,           
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
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag      INT = 0

   --Standard ExtScn variables
   DECLARE
      @nTempScn      INT,
      @nTempStep     INT
   --Standard ExtScn variables end
   
   DECLARE @nOrignStep    INT
   DECLARE @nOrignScn     INT

   DECLARE @cOption              NVARCHAR(1)
   DECLARE @tClosePallet         VariableTable
   DECLARE @tPrintLabelParam     VariableTable
   DECLARE @cAutoCompASTMV       NVARCHAR(1)
   DECLARE @cTaskDetailKey       NVARCHAR(10)
   DECLARE @cToLoc               NVARCHAR(10)
   DECLARE @nTranCount           INT

   -- Extracted Variables
   DECLARE @cCartonID           NVARCHAR( 20)
   DECLARE @cPalletID           NVARCHAR( 20)
   DECLARE @cLoadKey            NVARCHAR( 10)
   DECLARE @cPPS_Loc            NVARCHAR( 10)
   DECLARE @cPickDetailCartonID NVARCHAR( 20)
   DECLARE @cLabelPrinter       NVARCHAR( 10)
   DECLARE @cPaperPrinter       NVARCHAR( 10)
   DECLARE @cUserName           NVARCHAR( 18)

   -- Initialize
   SET @nErrNo = 0
   SET @nAfterScn = 0
   SET @nAfterStep = 0

   -- Initialize variables from rdtMobRec (Matching logic in rdtfnc_PostPackSort)
   SELECT 
      @nOrignStep     = Step,
      @nOrignScn      = Scn,
      @cCartonID      = V_String4,
      @cPalletID      = V_String5,
      @cLoadKey       = V_LoadKey,
      @cPPS_Loc       = V_Loc,
      @cPickDetailCartonID = V_String6,
      @cLabelPrinter  = Printer,
      @cPaperPrinter  = Printer_Paper,
      @cUserName      = UserName
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile 

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_1837ExtScn01', @cCartonID, @cPalletID, @cPPS_Loc

   IF @nFunc = 1837
   BEGIN
      -- Handle Step 99 (Extended Screen Delegation)
      IF @nStep = 99
      BEGIN
         
         -- 1. Initialization: Arriving from Standard Screen 5592 (Close Pallet)
         -- The Main SP redirect logic sets @nStep=99, but @nScn remains 5592.
         IF @nScn = 5592 
         BEGIN
            -- Set up target screen 6776
            SET @nAfterScn = 6776
            SET @nAfterStep = 99
            
            -- Initialize Output Fields if necessary
            SET @cOutField01 = '' -- Clear option input
            
            GOTO Quit
         END
    --   END
    --   -- We are in Step 3 (Close Pallet)
    --   IF @nOrignStep = 3 
    --   BEGIN

         IF @nScn = 6776  -- Close Pallet Extended Screen
         /********************************************************************************
         Scn = 6776. 
         Close Pallet Option?
            1 = Yes
            2 = No
            3 = Yes + Print
            Option (field01)
         ********************************************************************************/
         BEGIN

            IF @nInputKey = 1 -- ENTER
            BEGIN

               -- Screen mapping (Standard Input Field)
               SET @cOption = @cInField01

               -- Validate blank
               IF @cOption = ''
               BEGIN
                  SET @nErrNo = 255901 -- Option Required
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO Scn_6776_Fail
               END

               -- Validate option
               IF @cOption NOT IN ('1', '2', '3')
               BEGIN
                  SET @nErrNo = 255902 -- Invalid Option
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO Scn_6776_Fail
               END

               -- NO (Option 2) - Return to previous screen
               IF @cOption = '2' 
               BEGIN
                  SET @nAfterScn = 5590
                  SET @nAfterStep = 1
                  SET @nErrNo = 0
                  SET @cErrMsg = ''
                  GOTO Quit
               END

               -- YES (1) or YES + PRINT (3)
               IF @cOption IN ('1', '3')
               BEGIN
                  SET @nTranCount = @@TRANCOUNT
                  BEGIN TRAN
                  SAVE TRAN rdt_1837ExtScn01_6776

                  -- 1. Close Pallet (Call existing SP)
                  EXEC rdt.rdt_PostPackSort_ClosePallet
                     @nMobile             = @nMobile,    
                     @nFunc               = @nFunc,    
                     @cLangCode           = @cLangCode,    
                     @cStorerKey          = @cStorerKey,    
                     @cFacility           = @cFacility,     
                     @cCartonID           = @cCartonID, 
                     @cPalletID           = @cPalletID, 
                     @cLoadKey            = @cLoadKey, 
                     @cLoc                = @cPPS_Loc, 
                     @cOption             = @cOption, 
                     @cPickDetailCartonID = @cPickDetailCartonID,    
                     @tClosePallet        = @tClosePallet,    
                     @nErrNo              = @nErrNo            OUTPUT,    
                     @cErrMsg             = @cErrMsg           OUTPUT    

                  IF @nErrNo <> 0 
                  BEGIN
                     ROLLBACK TRAN rdt_1837ExtScn01_6776
                     GOTO Scn_6776_Fail
                  END

                  -- 2. Auto Complete ASTMV Task
                  SET @cAutoCompASTMV = rdt.rdtGetConfig(@nFunc, 'AutoCompASTMV', @cStorerKey)
                  
                  IF @cAutoCompASTMV = '1'
                  BEGIN
                     -- Find the ASTMV task created by ClosePallet logic
                     SELECT TOP 1 @cTaskDetailKey = TaskDetailKey, @cToLoc = ToLoc
                     FROM TASKDETAIL (NOLOCK)
                     WHERE TaskType = 'ASTMV' 
                     AND FromID = @cPalletID 
                     AND StorerKey = @cStorerKey
                     AND Status = '0'
                     ORDER BY AddDate DESC

                     IF @cTaskDetailKey IS NOT NULL
                     BEGIN
                         -- Perform Move
                         EXEC rdt.rdt_Move
                            @nMobile     = @nMobile,
                            @cLangCode   = @cLangCode, 
                            @nErrNo      = @nErrNo  OUTPUT,
                            @cErrMsg     = @cErrMsg OUTPUT,
                            @cSourceType = 'rdt_1837ExtScn01', 
                            @cStorerKey  = @cStorerKey,
                            @cFacility   = @cFacility, 
                            @cFromLOC    = @cPPS_Loc, 
                            @cToLOC      = @cToLoc, 
                            @cFromID     = @cPalletID, 
                            @cToID       = NULL,
                            @nFunc       = @nFunc 

                         IF @nErrNo <> 0
                         BEGIN
                            ROLLBACK TRAN rdt_1837ExtScn01_6776
                            GOTO Scn_6776_Fail
                         END

                         -- Close task
                         UPDATE TASKDETAIL SET 
                            Status = '9',
                            EditDate = GETDATE(),
                            EditWho = SUSER_SNAME()
                         WHERE TaskDetailKey = @cTaskDetailKey
                     END
                  END

                  -- 3. Print Labels (Option 3)
                  IF @cOption = '3'
                  BEGIN
                      -- Print Pallet Label
                      DELETE @tPrintLabelParam
                      INSERT INTO @tPrintLabelParam (Variable, Value) VALUES ('@PalletID', @cPalletID)
                         
                      EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,   
                        'PPS_PALLET',   -- Configure this ReportType in WMS
                        @tPrintLabelParam,
                        'rdtfnc_PostPackSort',   
                        @nErrNo  OUTPUT,  
                        @cErrMsg  OUTPUT 

                      -- Print Carton Labels
                      DELETE @tPrintLabelParam
                      INSERT INTO @tPrintLabelParam (Variable, Value) VALUES ('@PalletID', @cPalletID)
                         
                      EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,   
                        'PPS_CARTON',   -- Configure this ReportType in WMS
                        @tPrintLabelParam,
                        'rdtfnc_PostPackSort',   
                        @nErrNo  OUTPUT,  
                        @cErrMsg  OUTPUT 
                      
                      -- Suppress print errors to avoid rollback of Pallet Close
                      SET @nErrNo = 0 
                      SET @cErrMsg = ''
                  END
                  
                  COMMIT TRAN rdt_1837ExtScn01_6776 -- Only commit change made here

                  -- Loop back to start (Scan Carton)
                  SET @nAfterScn = 5590
                  SET @nAfterStep = 1
                  SET @nErrNo = 0
                  SET @cErrMsg = ''
                  
               END -- Option 1 or 3
               
               GOTO Quit
               
               Scn_6776_Fail:
               BEGIN
                  -- Reset this screen var
                  -- SET @cOutField01 = '' --Option
                  GOTO Quit
               END

            END -- Enter
         END -- Scn = 6776 
      END -- OrignStep = 3
   END -- nFunc = 1837

   GOTO Quit

Quit:
   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Exiting rdt_1837ExtScn01'
      SELECT @nErrNo AS ErrNo, @cErrMsg AS ErrMsg, @nAfterScn AS AfterScn, @nAfterStep AS AfterStep
   END
   
   -- If UDF variables needed to satisfy ExtScnEntry output expectations (optional, based on 830 pattern)
   /*
   SET @cUDF01 = ...
   */

   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [RDT].[rdt_1837ExtScn01] TO NSQL
GO