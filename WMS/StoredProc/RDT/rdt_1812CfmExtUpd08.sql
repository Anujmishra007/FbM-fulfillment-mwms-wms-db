
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1812CfmExtUpd08                                 */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: American Eagle Mexico                                       */
/*                                                                      */
/* Modifications log:                                                   */
/* Date         Author    Ver.  Purposes                                */
/* 2026-06-22   JackC     1.0   FCR-12989 Created                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1812CfmExtUpd08
    @nMobile            INT
   ,@nFunc              INT
   ,@cLangCode          NVARCHAR( 3)
   ,@cTaskdetailKey     NVARCHAR( 10)
   ,@cNewTaskdetailKey  NVARCHAR( 10)
   ,@nErrNo             INT           OUTPUT
   ,@cErrMsg            NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cStorerKey     NVARCHAR(15)
   DECLARE @nUCC_RowRef    INT
   DECLARE @cUCCNo         NVARCHAR(20) = ''
   DECLARE @curUpdUCC      CURSOR

   SELECT @cStorerKey = StorerKey FROM rdt.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile
   
   -- Get UCC (1 task 1 UCC)
   SELECT @cUCCNo = UCCNo
   FROM rdt.rdtFCPLog WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskDetailKey

   IF ISNULL(@cUCCNo, '') <> ''
   BEGIN 
      SET @curUpdUCC = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
      SELECT UCC_RowRef
      FROM dbo.UCC WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND   UCCNo = @cUCCNo
      AND   [Status] = '3'
      OPEN @curUpdUCC
      FETCH NEXT FROM @curUpdUCC INTO @nUCC_RowRef
      WHILE @@FETCH_STATUS = 0
      BEGIN
         BEGIN TRY
            UPDATE dbo.UCC WITH (ROWLOCK) SET
               [Status] = '5',
               EditWho = SUSER_SNAME(),
               EditDate = GETDATE()
            WHERE UCC_RowRef = @nUCC_RowRef
         END TRY
         BEGIN CATCH
            SET @nErrNo = 270851
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD UCC FAIL
            GOTO Fail
         END CATCH

         FETCH NEXT FROM @curUpdUCC INTO @nUCC_RowRef
      END
   END

   GOTO Quit

Fail:

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1812CfmExtUpd08] TO NSQL
GO
