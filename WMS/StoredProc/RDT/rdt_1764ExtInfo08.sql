IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'rdt.rdt_1764ExtInfo08') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE rdt.rdt_1764ExtInfo08
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1764ExtInfo08                                   */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Date         Author     Ver.  Purposes                               */
/* 2021-11-23   Chermaine  1.0   WMS-18419 Created                      */
/************************************************************************/

CREATE PROCEDURE rdt.rdt_1764ExtInfo08
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

   DECLARE @cTaskType   NVARCHAR( 10)
   DECLARE @cStorerKey  NVARCHAR( 15)
   DECLARE @cFromLOC    NVARCHAR( 10)
   DECLARE @cLoadKey    NVARCHAR( 10)
   DECLARE @cFacility   NVARCHAR( 5)
   DECLARE @nTotalTask  INT
   DECLARE @nFinishTask INT

   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      IF @nAfterStep = 4 
      BEGIN
         -- Get TaskDetail info
         SELECT 
            @cExtendedInfo1 = ISNULL(Notes,'')
         FROM Pickdetail WITH (NOLOCK) 
         WHERE TaskdetailKey = @cTaskdetailKey
      END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1764ExtInfo08 TO NSQL
GO
