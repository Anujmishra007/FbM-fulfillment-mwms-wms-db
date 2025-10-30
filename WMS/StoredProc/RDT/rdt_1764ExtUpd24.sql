SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_1764ExtUpd24                                       */
/* Customer: SWE SKF                                                       */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date         Author   Ver.    Purposes                                  */
/* 2025-10-28   JackC    1.0.0   FCR-8648 Created                          */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1764ExtUpd24]
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@cTaskdetailKey  NVARCHAR( 10)
   ,@nErrNo          INT           OUTPUT
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
   ,@nAfterStep      INT = 0
   ,@cDropID         NVARCHAR( 20) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount  INT

   DECLARE @cStorerKey     NVARCHAR( 15)
   DECLARE @cToLOC         NVARCHAR( 10)
   DECLARE @cFinalLOC      NVARCHAR(10)
   DECLARE @cTaskStatus    NVARCHAR(10)
   DECLARE @cToLOCCat      NVARCHAR( 10)
   DECLARE @cFacilily      NVARCHAR( 5)
   DECLARE @nInputKey      INT
   DECLARE @cTaskType      NVARCHAR(10)
   DECLARE @cListKey       NVARCHAR(10)
   DECLARE @cPickDetailKey NVARCHAR(10)
   DECLARE @nRowCount      INT
   DECLARE @nLoopIndex     INT
   DECLARE @cErrMsg1       NVARCHAR(125)
   DECLARE @cErrMsg2       NVARCHAR(125)
   DECLARE @cErrMsg3       NVARCHAR(125)
   DECLARE @cErrMsg4       NVARCHAR(125)

   SET @nTranCount = @@TRANCOUNT

   DECLARE @tPKD TABLE
   (
      id            INT IDENTITY(1,1),
      PickDetailKey NVARCHAR(10) 
   )

   SELECT @cFacilily = Facility,
      @cStorerKey  = StorerKey,
      @nInputKey = InputKey
   FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      IF @nStep = 6 -- To loc
      BEGIN
         IF @nInputKey = 1
         BEGIN

            BEGIN TRAN
            SAVE TRAN rdt_1764ExtUpd24

            INSERT INTO @tPKD (PickDetailKey)
            SELECT PickDetailKey
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
            AND TaskDetailKey = @cTaskDetailKey
            AND Status = '0'

            SET @nLoopIndex = -1
            WHILE 1 = 1
            BEGIN
               SELECT TOP 1
                  @cPickDetailKey = PickDetailKey,
                  @nLoopIndex = id
               FROM @tPKD
               WHERE id > @nLoopIndex
               ORDER BY id

               SET @nRowCount = @@ROWCOUNT

               IF @nRowCount = 0
                  BREAK
               
               BEGIN TRY
                  UPDATE dbo.PickDetail WITH (ROWLOCK)
                  SET Status = '5'
                  WHERE PickDetailKey = @cPickDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 250201
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- failed to update PKD
                  GOTO RollbackTran
               END CATCH
            END -- end while

            COMMIT TRAN rdt_1764ExtUpd24
         END -- inputkey = 1
      END
   END

   GOTO Quit

   RollBackTran:
   IF @nTranCount > 0 AND XACT_STATE() <> -1
      ROLLBACK TRAN rdt_1764ExtUpd24
   ELSE
      ROLLBACK TRAN
   GOTO Quit

   Fail:
   
   Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN

END--SP
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1764ExtUpd24 TO NSQL
GO
