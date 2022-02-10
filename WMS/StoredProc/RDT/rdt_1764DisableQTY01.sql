IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'rdt.rdt_1764DisableQTY01') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE rdt.rdt_1764DisableQTY01
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1764DisableQTY01                                */
/* Purpose: Extended info                                               */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2014-07-31   Ung       1.0   Created                                 */
/************************************************************************/

CREATE PROCEDURE rdt.rdt_1764DisableQTY01
    @nMobile            INT 
   ,@nFunc              INT 
   ,@cLangCode          NVARCHAR( 3) 
   ,@nStep              INT 
   ,@cTaskdetailKey     NVARCHAR( 10) 
   ,@cDisableQTYField   NVARCHAR( 1)  OUTPUT
   ,@nErrNo             INT           OUTPUT 
   ,@cErrMsg            NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cLoseUCC NVARCHAR(1)

   -- Get TaskDetail info
   SELECT 
      @cLoseUCC = LOC.LoseUCC
   FROM TaskDetail WITH (NOLOCK) 
      JOIN LOC WITH (NOLOCK) ON (LOC.LOC = TaskDetail.FromLOC)
   WHERE TaskDetailKey = @cTaskDetailKey

   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      -- Disable by default
      SET @cDisableQTYField = '1' -- Disable
      
      -- Enable if DPP
      IF @cLoseUCC = '1'
         SET @cDisableQTYField = '0' -- Enable
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1764DisableQTY01 TO NSQL
GO
