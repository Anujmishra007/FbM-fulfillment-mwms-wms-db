SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
	
/************************************************************************/
/* Store procedure: [rdt_1812ExtUpd08]                                  */
/*                                                                      */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: JCB US                                                      */
/*                                                                      */
/* Date        Author   Ver.     Purposes                               */
/* 2026-07-31  JCH507   1.0.0    FCR-14961 CREATED (From ExtUpd04)      */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1812ExtUpd08]
   @nMobile         INT,          
   @nFunc           INT,           
   @cLangCode       NVARCHAR( 3), 
   @nStep           INT,          
   @nInputKey       INT,          
   @cTaskdetailKey  NVARCHAR( 10),
   @cDropID         NVARCHAR( 20),
   @nQTY            INT,          
   @cToLOC          NVARCHAR( 10),
   @nErrNo          INT OUTPUT,   
   @cErrMsg         NVARCHAR( 20) OUTPUT,
   @nAfterStep      INT      
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  @nDebugFlag  INT = 0

   DECLARE  
      @cSQL        NVARCHAR(MAX),
      @cSQLParam   NVARCHAR(MAX)
   
   DECLARE  
      @nScn                INT,
      @nFromScn            INT,
      @nFromStep           INT,
      @cUserName           NVARCHAR(128),
      @cPickMethod         NVARCHAR(10),
      @cExtUpdPrintSP      NVARCHAR(20),
      @cStorerKey          NVARCHAR(15),
      @nRowCount           INT, 
      @cLabelPrinter       NVARCHAR(10),
      @cPaperPrinter       NVARCHAR(10),	
      @cFacility           NVARCHAR(5),
      @cOrderGroup         NVARCHAR(20),
      @cSuggFromLOC        NVARCHAR(10),
      @cSuggID             NVARCHAR(18),
      @nSKUCountOnID       INT,
      @tPalletLBLParam     AS VariableTable,
      
      @cReasonCode         NVARCHAR(10),
      @cTaskStatus         NVARCHAR(10),
      @cTaskReasonKey      NVARCHAR(10),
      @cTaskType           NVARCHAR(10),
      @cListKey            NVARCHAR(10),
      @cInField01          NVARCHAR(60),
      @cOption             NVARCHAR(1)

   SELECT
      @nScn          = Scn,
      @cUserName     = UserName,
      @cStorerKey    = StorerKey,
      @cFacility     = Facility, 
      @nFromStep     = V_FromStep,
      @nFromScn      = V_FromSCN,
      @cPaperPrinter = Printer_Paper,
      @cLabelPrinter = Printer,
      @cSuggFromLOC  = V_LOC,
      @cPickMethod   = V_String4,
      @cInField01   = I_Field01
   FROM RDT.RDTMOBREC WITH (NOLOCK) 
   WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_1812ExtUpd08'
   
   IF @nFunc = 1812 -- PickSKU
   BEGIN        
      IF @nStep = 99 AND @nScn = 4022 --New FROMID logic
      BEGIN	
         IF @nInputKey = 1
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Executing rdt_1812ExtUpd08 Step 99, Scn 4022, Enter'

            SELECT 
               @cPickMethod   = TD.PickMethod,
               @cSuggID       = TD.FromID,
               @cOrderGroup   = OrderGroup
            FROM dbo.PickDetail PD WITH (NOLOCK) 
            JOIN dbo.TASKDETAIL TD WITH (NOLOCK) ON PD.TaskDetailKey = TD.TaskDetailKey
            JOIN dbo.ORDERS O WITH (NOLOCK) ON PD.OrderKey = O.OrderKey 
            WHERE PD.TaskDetailKey = @cTaskdetailKey 
               AND PD.StorerKey = @cStorerKey

            IF ISNULL(@cPickMethod, '') = 'FP'
            BEGIN
               IF ISNULL(@cOrderGroup, '') = 'STANDARD'
               BEGIN
                  SELECT @nSKUCountOnID = COUNT(DISTINCT(lli.Sku)) 
                  FROM dbo.LOTxLOCxID lli WITH (NOLOCK)
                  WHERE lli.storerkey = @cStorerKey
                     AND lli.Qty > 0
                     AND lli.Loc = @cSuggFromLOC
                     AND lli.Id = @cSuggID
                  GROUP BY lli.Id

                  -- Common params (To check)
                  INSERT INTO @tPalletLBLParam (Variable, Value) VALUES
                     ( '@cStorerKey',     @cStorerKey),
                     ( '@cFacility',      @cFacility),
                     ( '@cDropID',        @cSuggID),
                     ( '@cTaskdetailKey', @cTaskdetailKey)	

                  IF @nSKUCountOnID = 1
                  BEGIN
                     IF @nDebugFlag = 1
                        SELECT 'Printing Standard Single SKU Label'

                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                        'PickMonSKU', -- Report type
                        @tPalletLBLParam, -- Report params
                        'rdt_1812ExtUpd08',
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT
                     IF @nErrNo <> 0
                        GOTO Quit
                  END
                  ELSE IF @nSKUCountOnID > 1
                  BEGIN
                     IF @nDebugFlag = 1
                        SELECT 'Printing Standard Multi SKU Label'

                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                        'PkMltSKUHd', -- Report type
                        @tPalletLBLParam, -- Report params
                        'rdt_1812ExtUpd08',
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT
                     IF @nErrNo <> 0
                        GOTO Quit

                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                        'PkMltSKULt', -- Report type
                        @tPalletLBLParam, -- Report params
                        'rdt_1812ExtUpd08',
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT
                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END -- Standard Order
               ELSE IF ISNULL(@cOrderGroup, '') = 'KITTING'
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT 'Printing Kitting Label'

                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                     'KitGenLbHd', -- Report type
                     @tPalletLBLParam, -- Report params
                     'rdt_1812ExtUpd08',
                     @nErrNo  OUTPUT,
                     @cErrMsg OUTPUT
                  IF @nErrNo <> 0
                     GOTO Quit

                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                     'KitGenLbLt', -- Report type
                     @tPalletLBLParam, -- Report params
                     'rdt_1812ExtUpd08',
                     @nErrNo  OUTPUT,
                     @cErrMsg OUTPUT
                  IF @nErrNo <> 0
                     GOTO Quit
               END--Kitting
            END --FP     
         END --INPUTKEY = 1

         GOTO Quit
      END -- new FromID logic

      IF @nStep = 9 -- reason screen
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Executing rdt_1812ExtUpd08 Step 9, Enter'

            SET @cReasonCode = LEFT(@cInField01, 10)

            SELECT 
               @cSuggID       = FromID,
               @cSuggFromLOC  = FromLoc,
               @cTaskType     = TaskType,
               @cTaskStatus   = Status
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE TaskDetailKey = @cTaskdetailKey

            DECLARE @tTaskKeys TABLE (TaskDetailKey NVARCHAR(10))

            INSERT INTO @tTaskKeys (TaskDetailKey)
            SELECT TaskDetailKey
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND FromLoc  = @cSuggFromLOC
               AND FromID   = @cSuggID
               AND TaskType = @cTaskType
               AND Status NOT IN ('3', '5', '9', 'X')

            SELECT @nRowCount = COUNT(*) FROM @tTaskKeys

            IF @nRowCount > 0  AND @nFromStep = 99 AND @nFromScn = 4022 AND @cTaskStatus NOT IN ('3', '5', '9') -- from FromID screen
            BEGIN
               BEGIN TRY
                  UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
                     Status    = @cTaskStatus,
                     ReasonKey = CASE WHEN @cTaskStatus = '0' THEN '' ELSE @cReasonCode END,
                     EditDate  = GETDATE(),
                     EditWho   = SUSER_SNAME()
                  WHERE TaskDetailKey IN (SELECT TaskDetailKey FROM @tTaskKeys)
               END TRY
               BEGIN CATCH
                  SET @nErrNo  = 276951
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END CATCH
            END
         END --INPUTKEY = 1

         GOTO Quit
      END -- Step 9

      IF @nStep = 6 -- toLoc screen
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Executing rdt_1812ExtUpd08 Step 6, Enter'

            SELECT 
               @cPickMethod   = TD.PickMethod,
               @cSuggID       = TD.FromID,
               @cOrderGroup   = OrderGroup,
               @cListKey      = TD.ListKey
            FROM dbo.PickDetail PD WITH (NOLOCK) 
            JOIN dbo.TASKDETAIL TD WITH (NOLOCK) ON PD.TaskDetailKey = TD.TaskDetailKey
            JOIN dbo.ORDERS O WITH (NOLOCK) ON PD.OrderKey = O.OrderKey 
            WHERE PD.TaskDetailKey = @cTaskdetailKey 
               AND PD.StorerKey = @cStorerKey

            IF ISNULL(@cPickMethod, '') = 'PP' AND ISNULL(@cDropID,'') <> ''
               AND EXISTS (SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) 
                           WHERE StorerKey = @cStorerKey 
                              AND TaskType = 'FCP'
                              AND [Status] = '9'
                              AND DropID = @cDropID) -- only print label after executing PP tasks
            BEGIN
               -- Common params (To check)
               INSERT INTO @tPalletLBLParam (Variable, Value) VALUES
                  ( '@cStorerKey',     @cStorerKey),
                  ( '@cFacility',      @cFacility),
                  ( '@cDropID',        @cDropID),
                  ( '@cTaskdetailKey', @cTaskdetailKey)

               IF ISNULL(@cOrderGroup, '') = 'STANDARD'
               BEGIN
                  SELECT @nSKUCountOnID = COUNT(DISTINCT(lli.Sku)) 
                  FROM dbo.LOTxLOCxID lli WITH (NOLOCK)
                  WHERE lli.storerkey = @cStorerKey
                     AND lli.Qty > 0
                     AND lli.Loc = @cToLoc
                     AND lli.Id = @cDropID
                  GROUP BY lli.Id

                  IF @nSKUCountOnID = 1
                  BEGIN
                     IF @nDebugFlag = 1
                        SELECT 'Printing Standard Single SKU Label'

                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                        'PickMonSKU', -- Report type
                        @tPalletLBLParam, -- Report params
                        'rdt_1812ExtUpd08',
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT
                     IF @nErrNo <> 0
                        GOTO Quit
                  END
                  ELSE IF @nSKUCountOnID > 1
                  BEGIN
                     IF @nDebugFlag = 1
                        SELECT 'Printing Standard Multi SKU Label'

                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                        'PkMltSKUHd', -- Report type
                        @tPalletLBLParam, -- Report params
                        'rdt_1812ExtUpd08',
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT
                     IF @nErrNo <> 0
                        GOTO Quit

                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                        'PkMltSKULt', -- Report type
                        @tPalletLBLParam, -- Report params
                        'rdt_1812ExtUpd08',
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT
                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END -- Standard Order
               ELSE IF ISNULL(@cOrderGroup, '') = 'KITTING'
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT 'Printing Kitting Label'

                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                     'KitGenLbHd', -- Report type
                     @tPalletLBLParam, -- Report params
                     'rdt_1812ExtUpd08',
                     @nErrNo  OUTPUT,
                     @cErrMsg OUTPUT
                  IF @nErrNo <> 0
                     GOTO Quit

                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                     'KitGenLbLt', -- Report type
                     @tPalletLBLParam, -- Report params
                     'rdt_1812ExtUpd08',
                     @nErrNo  OUTPUT,
                     @cErrMsg OUTPUT
                  IF @nErrNo <> 0
                     GOTO Quit
               END--Kitting
            END --PP  
         END

         GOTO Quit
      END
   
   END --1812

   Quit:
      IF @nDebugFlag = 1
         SELECT 'Exiting rdt_1812ExtUpd08', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
END-- sp

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [RDT].[rdt_1812ExtUpd08] TO [NSQL]
GO
