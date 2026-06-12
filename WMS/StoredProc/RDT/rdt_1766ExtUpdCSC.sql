
/************************************************************************/
/* Store procedure: rdt_1766ExtUpdCSC                                   */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-04-20 1.0  TTW017     Created                                   */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1766ExtUpdCSC] (
@nMobile     INT,
@nFunc       INT,
@cLangCode   NVARCHAR( 3),
@nStep       INT,
@nInputKey   INT,
@cFacility       NVARCHAR( 15),
@cStorerKey      NVARCHAR( 15),
@cTaskdetailkey  NVARCHAR( 20),
@cFromLoc        NVARCHAR( 20),
@cID             NVARCHAR( 20),
@cPickMethod     NVARCHAR( 20),
@nErrNo          INT           OUTPUT,
@cErrMsg         NVARCHAR( 20) OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE @nTranCount      INT,
       @cUCCNo          NVARCHAR( 20)


SET @nTranCount = @@TRANCOUNT
BEGIN TRAN  -- Begin our own transaction
SAVE TRAN rdt_1766ExtUpdCSC -- For rollback or commit only our own transaction

IF @nStep = 1
BEGIN
  IF @nInputKey = 1
  BEGIN
     UPDATE UCC
     SET Status = '3'
     FROM dbo.TaskDetail TD1 WITH (NOLOCK)
     LEFT JOIN dbo.TaskDetail TD2 WITH (NOLOCK) ON TD1.RefTaskKey = TD2.TaskDetailKey AND TD1.Storerkey = TD2.Storerkey
     LEFT JOIN dbo.UCC UCC WITH (NOLOCK) ON TD2.Storerkey = UCC.Storerkey AND TD2.Caseid = UCC.UCCNo
     WHERE TD1.TaskDetailKey = @cTaskdetailkey
      AND UCC.Status = 'H'

  END
END

IF @nStep = 6
BEGIN
UPDATE UCC
SET Status = 'H'
FROM dbo.TaskDetail TD1 WITH (NOLOCK)
LEFT JOIN dbo.TaskDetail TD2 WITH (NOLOCK) ON TD1.RefTaskKey = TD2.TaskDetailKey AND TD1.Storerkey = TD2.Storerkey
LEFT JOIN dbo.UCC UCC WITH (NOLOCK) ON TD2.Storerkey = UCC.Storerkey AND TD2.Caseid = UCC.UCCNo
WHERE TD1.TaskDetailKey = @cTaskdetailkey
 AND UCC.Status = '3'
END


GOTO CommitTrans

RollBackTran:
     ROLLBACK TRAN rdt_1766ExtUpdCSC

CommitTrans:
  WHILE @@TRANCOUNT > @nTranCount
     COMMIT TRAN
