IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'rdt.rdt_1764ExtInfo05') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE rdt.rdt_1764ExtInfo05
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1764ExtInfo05                                   */
/* Purpose: Extended info                                               */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2019-05-31   Ung       1.0   WMS-9195 Created                        */
/************************************************************************/

CREATE PROCEDURE rdt.rdt_1764ExtInfo05
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

   DECLARE @cToLOC    NVARCHAR( 10)
   DECLARE @cFinalLOC NVARCHAR( 10)

   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      IF @nAfterStep = 3 -- From ID
      BEGIN
         -- Get TaskDetail info
         SELECT 
            @cToLOC = ToLOC, 
            @cFinalLOC = FinalLOC
         FROM TaskDetail WITH (NOLOCK) 
         WHERE TaskdetailKey = @cTaskdetailKey
      
         IF @cFinalLOC <> ''
            SET @cToLOC = @cFinalLOC
         
         SET @cExtendedInfo1 = @cToLOC
      END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1764ExtInfo05 TO NSQL
GO
