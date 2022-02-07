IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'rdt.rdt_1764ExtInfo02') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE rdt.rdt_1764ExtInfo02
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1764ExtInfo02                                   */
/* Purpose: Extended info                                               */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2017-04-06   Ung       1.0   WMS-1579 Created                        */
/************************************************************************/

CREATE PROCEDURE rdt.rdt_1764ExtInfo02
    @nMobile         INT 
   ,@nFunc           INT 
   ,@cLangCode       NVARCHAR( 3) 
   ,@nStep           INT 
   ,@cTaskdetailKey  NVARCHAR( 10) 
   ,@cExtendedInfo1  NVARCHAR( 20) OUTPUT
   ,@nErrNo          INT           OUTPUT 
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
   ,@nAfterStep      INT = 0
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nQTY   INT
   DECLARE @cUCCNo NVARCHAR(20)

   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      IF @nAfterStep = 4 -- SKU, QTY screen
      BEGIN
         -- Get UCC on task not yet pick
         SELECT 
            @nQTY = QTY, 
            @cUCCNo = CaseID
         FROM TaskDetail (NOLOCK)
         WHERE TaskDetailKey = @cTaskDetailKey

         IF @@ROWCOUNT = 1 
            SET @cExtendedInfo1 = RIGHT( RTRIM( @cUCCNo) + '--' + RTRIM(CAST( @nQTY AS NVARCHAR(5))), 20)
      END
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1764ExtInfo02 TO NSQL
GO
