
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1764ExtInfo16                                   */
/* Copyright      : Maersk                                              */
/* Customer       : AEOMX American Eagle                                */
/*                                                                      */
/* Date         Author     Ver.  Purposes                               */
/* 2026-06-24   NickT      1.0   FCR-12990 Show UCC Step4               */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1764ExtInfo16
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

   DECLARE @cStorerkey       NVARCHAR( 15)

   SELECT @cStorerKey = Storerkey
      FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      IF @nAfterStep = 4
      BEGIN
         -- Get TaskDetail info
         SELECT 
            @cExtendedInfo1 = CaseID 
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE TaskdetailKey = @cTaskdetailKey

        SELECT @cExtendedInfo1 = ISNULL(@cExtendedInfo1,'')
      END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1764ExtInfo16 TO NSQL
GO
