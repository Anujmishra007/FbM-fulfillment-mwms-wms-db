SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_PutawayBySKU_Confirm                            */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author   Purposes                                   */
/* 07-12-2016  1.0  Ung      WMS-751 Created                            */
/* 28-06-2019  1.1  James    WMS-9392 Add ExtendedPABySKUCfmSP (james01)*/
/* 20-11-2023  1.2  Ung      WMS-23730 Add Final ID                     */
/* 16-10-2025  1.3  Ung      FCR-8112 Add serial no                     */
/*                           Add suggest alternate LOC                  */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_PutawayBySKU_Confirm] (
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @cUserName     NVARCHAR( 18),
   @cStorerKey    NVARCHAR( 15),
   @cFacility     NVARCHAR( 5),
   @cLOT          NVARCHAR( 10),
   @cLOC          NVARCHAR( 10),
   @cID           NVARCHAR( 18),
   @cSKU          NVARCHAR( 20),
   @nQTY          INT,
   @cFinalLOC     NVARCHAR( 10),
   @cSuggestedLOC NVARCHAR( 10),
   @cLabelType    NVARCHAR( 20),
   @cUCC          NVARCHAR( 20),
   @nPABookingKey INT           OUTPUT,
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT,
   @cFinalID      NVARCHAR( 18) = NULL, 
   @cSerialNo     NVARCHAR( 30) = '',   -- For move with SerialNoUpdateLotLocID
   @nSerialQTY    INT = 0,              -- Same as above
   @nBulkSNO      INT = 0,              -- Same as above. Use rdt.rdtMoveSerialNoLog table
   @nBulkSNOQTY   INT = 0               -- Same as above   
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSQL           NVARCHAR( MAX)
   DECLARE @cSQLParam      NVARCHAR( MAX)
   DECLARE @tPABySKU       VariableTable
   DECLARE @cExtendedPABySKUCfmSP NVARCHAR(20)

   -- Get extended ExtendedPltBuildCfmSP
   SET @cExtendedPABySKUCfmSP = rdt.rdtGetConfig( @nFunc, 'ExtendedPABySKUCfmSP', @cStorerKey)
   IF @cExtendedPABySKUCfmSP = '0'
      SET @cExtendedPABySKUCfmSP = ''

   -- Extended putaway
   IF @cExtendedPABySKUCfmSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedPABySKUCfmSP AND type = 'P')
      BEGIN
         INSERT INTO @tPABySKU (Variable, Value) VALUES
            ('@cUserName',       @cUserName),
            ('@cLOT',            @cLOT),
            ('@cLOC',            @cLOC),
            ('@cID',             @cID),
            ('@cSKU',            @cSKU),
            ('@cQty',            CAST( @nQty AS NVARCHAR( 5))),
            ('@cFinalLOC',       @cFinalLOC) ,
            ('@cSuggestedLOC',   @cSuggestedLOC),
            ('@cLabelType',      @cLabelType),
            ('@cUCC',            @cUCC), 
            ('@cFinalID',        @cFinalID), 
            ('@cSerialNo',       @cSerialNo), 
            ('@nSerialQTY',      CAST( @nSerialQTY AS NVARCHAR( 5))),
            ('@nBulkSNO',        CAST( @nBulkSNO AS NVARCHAR( 5))),
            ('@nBulkSNOQTY',     CAST( @nBulkSNOQTY AS NVARCHAR( 10)))

         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedPABySKUCfmSP) +
            ' @nMobile, @nFunc, @cLangCode, @cStorerKey, @cFacility, @tPABySKU, @nPABookingKey OUTPUT,' +
            ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
         SET @cSQLParam =
            '@nMobile         INT,                  ' +
            '@nFunc           INT,                  ' +
            '@cLangCode       NVARCHAR( 3),         ' +
            '@cStorerKey      NVARCHAR( 15),        ' +
            '@cFacility       NVARCHAR( 5),         ' +
            '@tPABySKU        VariableTable READONLY, ' +
            '@nPABookingKey   INT           OUTPUT, ' +
            '@nErrNo          INT           OUTPUT, ' +
            '@cErrMsg         NVARCHAR( 20) OUTPUT  '

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, @cStorerKey, @cFacility, @tPABySKU, @nPABookingKey OUTPUT,
            @nErrNo OUTPUT, @cErrMsg OUTPUT

         IF @nErrNo <> 0
            GOTO Fail
      END
   END
   ELSE
   BEGIN
      DECLARE @nRowRef INT 
      DECLARE @cAutoAssignPickLOC NVARCHAR( 1)
      DECLARE @cSerialNoCapture NVARCHAR( 1)

      -- RDT storer config
      SET @cAutoAssignPickLOC = rdt.RDTGetConfig( @nFunc, 'AutoAssignPickLOC', @cStorerKey)
      SET @cSerialNoCapture = rdt.RDTGetConfig( @nFunc, 'SerialNoCapture', @cStorerKey)
      
      /*
      -- Decide bulk serial no
      DECLARE @nBulkSNO INT = 0
      IF @cSerialNoCapture = '1'
         IF EXISTS( SELECT TOP 1 1 FROM rdt.rdtMoveSerialNoLog WITH (NOLOCK) WHERE Mobile = @nMobile)
            SET @nBulkSNO = 1
      */
      
      -- Handling transaction
      DECLARE @nTranCount INT
      SET @nTranCount = @@TRANCOUNT
      BEGIN TRAN  -- Begin our own transaction
      SAVE TRAN rdt_PutawayBySKU_Confirm -- For rollback or commit only our own transaction

      -- Auto assign pick location
      IF @cAutoAssignPickLOC = '1'
      BEGIN
         EXEC rdt.rdt_PutawayBySKU_AssignPickLOC @nMobile, @nFunc, @cLangCode, @cStorerKey, @cFacility,
            @cSKU,
            @cSuggestedLOC,
            @cFinalLOC,
            @nErrNo  OUTPUT,
            @cErrMsg OUTPUT
         IF @nErrNo <> 0
            GOTO RollBackTran
      END
      
      -- Execute putaway process
      EXEC rdt.rdt_Putaway @nMobile, @nFunc, @cLangCode, @cUserName, @cFacility,
         @cLOT,
         @cLOC,
         @cID,
         @cStorerKey,
         @cSKU,
         @nQTY,
         @cFinalLOC,
         @cLabelType,   -- optional
         @cUCC,         -- optional
         @nErrNo  OUTPUT,
         @cErrMsg OUTPUT, 
         @cFinalID    = @cFinalID, 
         @cSerialNo   = @cSerialNo, 
         @nSerialQTY  = @nSerialQTY, 
         @nBulkSNO    = @nBulkSNO, 
         @nBulkSNOQTY = @nBulkSNOQTY         
      IF @nErrNo <> 0
         GOTO RollBackTran
      
      -- Unlock current session suggested LOC
      IF @nPABookingKey <> 0
      BEGIN
         -- Unlock by QTY
         IF @cSerialNo <> ''
         BEGIN
            -- Booking is always with ID. But nspItrnAddMoveCheck will auto deduct PendingMoveIn in certain scenario (one side only at LOTxLOCxID)
            -- So RDT side need to manually deduct PendingMoveIn at RFPutaway (also one side only)
            /*
               There are 3 possible conditions: 
               @cFinalID = NULL, means ToID = FromID
               @cFinalID = '', clear the ToID. RDT will send 'CLEAR' to move trigger
                           In move trigger:
                              if 'CLEAR', ToID = blank. 
                              InitialID = ToID
                              If loseID, ToID = blank
                           
                              Reduce booking (one sided at LOTxLOCxID) on:
                                 matched LOT, ToLOC and (initial ID or ToID)
               @cFinalID = Diff
            */
            IF @cSuggestedLOC = @cFinalLOC AND        -- To LOC match
              (@cFinalID IS NULL OR @cID = @cFinalID) -- To ID match
            BEGIN
               DECLARE @nRFPutawayQTY INT
               SELECT TOP 1 
                  @nRowRef = RowRef, 
                  @nRFPutawayQTY = QTY 
               FROM dbo.RFPutaway WITH (NOLOCK) 
               WHERE PABookingKey = @nPABookingKey
               
               IF (@nRFPutawayQTY - @nQTY) <= 0  
               BEGIN  
                  DELETE dbo.RFPutaway WITH (ROWLOCK)  
                  WHERE  RowRef = @nRowRef  
                  IF @@ERROR <> 0  
                  BEGIN  
                     SET @nErrNo = 266601  
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- DEL RPA FAIL
                     GOTO RollBackTran  
                  END
                  SET @nPABookingKey = 0
               END  
               ELSE  
               BEGIN  
                  UPDATE dbo.RFPutaway SET   
                     QTY = QTY - @nQTY  
                  WHERE RowRef = @nRowRef  
                  IF @@ERROR <> 0  
                  BEGIN  
                     SET @nErrNo = 266602  
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD RPA FAIL
                     GOTO RollBackTran  
                  END  
               END
            END
            
            -- Deduct both side by QTY
            ELSE
            BEGIN
               EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
                  ,'' --FromLOC
                  ,'' --FromID
                  ,'' --SuggLOC
                  ,'' --Storer
                  ,@nErrNo  OUTPUT
                  ,@cErrMsg OUTPUT
                  ,@nPutawayQTY = @nQTY
                  ,@nPABookingKey = @nPABookingKey OUTPUT
               IF @nErrNo <> 0
                  GOTO RollBackTran
            END
         END
         
         -- Unlock all
         ELSE
         BEGIN
            EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
               ,'' --FromLOC
               ,'' --FromID
               ,'' --SuggLOC
               ,'' --Storer
               ,@nErrNo  OUTPUT
               ,@cErrMsg OUTPUT
               ,@nPABookingKey = @nPABookingKey OUTPUT
            IF @nErrNo <> 0
               GOTO RollBackTran

            SET @nPABookingKey = 0
         END
      END

      -- Check no more booking
      IF @nPABookingKey = 0
      BEGIN
         -- Unlock putaway skipped LOC
         IF EXISTS( SELECT TOP 1 1
            FROM rdt.rdtPutawaySkipLOCLog WITH (NOLOCK) 
            WHERE Mobile = @nMobile
               AND Func = @nFunc)
         BEGIN
            DECLARE @curSkipLOC CURSOR 
            SET @curSkipLOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT RowRef
               FROM rdt.rdtPutawaySkipLOCLog WITH (NOLOCK) 
               WHERE Mobile = @nMobile
                  AND Func = @nFunc
            OPEN @curSkipLOC
            FETCH NEXT FROM @curSkipLOC INTO @nRowRef
            WHILE @@FETCH_STATUS = 0
            BEGIN
               DELETE rdt.rdtPutawaySkipLOCLog WHERE RowRef = @nRowRef
               FETCH NEXT FROM @curSkipLOC INTO @nRowRef
            END
         END
      END

      COMMIT TRAN rdt_PutawayBySKU_Confirm -- Only commit change made here
      GOTO Quit

      RollBackTran:
         ROLLBACK TRAN rdt_PutawayBySKU_Confirm -- Only rollback change made here
      Quit:
         WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
            COMMIT TRAN
      Fail:
   END
END
GO
GRANT EXECUTE ON  [RDT].[rdt_PutawayBySKU_Confirm] TO [NSQL]
GO
