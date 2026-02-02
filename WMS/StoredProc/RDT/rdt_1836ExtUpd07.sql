/**************************************************************************/
/* Store procedure: rdt_1836ExtUpd07                                      */
/* Copyright      : Maersk                                                */    
/* Client         : ONBR                                                  */    
/*                                                                        */
/* Modifications log:                                                     */
/*                                                                        */
/* Date         Author    Ver.    Purposes                                */
/* 2025-12-10   Jackc     1.0.0   FCR-8535 set UCC status to 6            */
/*                                                                        */
/**************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1836ExtUpd07]
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cTaskdetailKey  NVARCHAR( 10),
   @cFinalLOC       NVARCHAR( 10),
   @nErrNo          INT             OUTPUT,
   @cErrMsg         NVARCHAR( 20)   OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cCaseID           NVARCHAR( 20)
   DECLARE @nUCC_RowRef       INT
   DECLARE @cErrMsg1         NVARCHAR( 125)
   DECLARE @cErrMsg2         NVARCHAR( 125)
   DECLARE @cErrMsg3         NVARCHAR( 125)
   DECLARE @cStorerKey        NVARCHAR( 15)

   DECLARE @cTaskKey          NVARCHAR( 10)
   DECLARE @cTaskType         NVARCHAR( 10)

   DECLARE @cPickDetailKey    NVARCHAR( 15)
   DECLARE @cWaveKey          NVARCHAR( 10)
   --DECLARE @cTDWaveKey        NVARCHAR( 10)
   DECLARE @cFacility         NVARCHAR( 5)
   --DECLARE @cOrderKey         NVARCHAR( 10)
   DECLARE @cLot              NVARCHAR( 10)
   DECLARE @cLoc              NVARCHAR( 10)
   --DECLARE @cId               NVARCHAR( 10)
   DECLARE @cSKU              NVARCHAR( 20)
   DECLARE @nQty              INT
   --DECLARE @nPDQty            INT
   --DECLARE @nBalQty           INT
   --DECLARE @curTask           CURSOR
   --DECLARE @curPD             CURSOR
   --DECLARE @curCPK            CURSOR
   DECLARE @cAreakey          NVARCHAR(20)
   DECLARE @cFromLOC          NVARCHAR( 10)
   DECLARE @cSuggToLOC        NVARCHAR( 10)
   DECLARE @cSuggFinalLoc     NVARCHAR( 10)
   --DECLARE @nQty              INT
   DECLARE @cRefTaskKey       NVARCHAR( 10)

   SELECT 
      @cFacility = FACILITY,
      @cStorerKey = Storerkey
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- TM Replen From
   IF @nFunc = 1836
   BEGIN
      IF @nStep = 1 -- Final Loc
      BEGIN
         IF @nInputKey = '1'
         BEGIN
            SELECT 
               @cCaseID = CaseID
            FROM TaskDetail WITH (NOLOCK)
            WHERE TaskDetailKey = @cTaskDetailKey

            SELECT @nUCC_RowRef = UCC_RowRef 
            FROM dbo.UCC WITH(NOLOCK) 
            WHERE StorerKey = @cStorerKey
               AND UCCNo = @cCaseID

            IF ISNULL(@nUCC_RowRef, 0) <> 0
            BEGIN
               BEGIN TRY
                  UPDATE dbo.UCC WITH (ROWLOCK)
                  SET Status = '6'
                  WHERE UCC_RowRef = @nUCC_RowRef
               END TRY
               BEGIN CATCH
                  SET @cErrMsg1 = '253301'
                  SET @cErrMsg2 = 'Update UCC failed'
                  SET @cErrMsg3 = 'UCC: ' + @cCaseID
                  EXEC rdt.rdtInsertMsgQueue @nMobile = @nMobile,
                     @nErrNo = @nErrNo,
                     @cErrMsg = @cErrMsg,
                     @cLine01 = @cErrMsg1,
                     @cLine02 = @cErrMsg2,
                     @cLine03 = @cErrMsg3,
                     @nDisplayMsg = 0

                     GOTO Quit
               END CATCH
            END

            GOTO Quit
         END --enter
      END --st1
   END --1836

   GOTO Quit

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1836ExtUpd07 TO NSQL
GO
