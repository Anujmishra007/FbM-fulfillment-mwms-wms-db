SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*********************************************************************************/
/* Store procedure: rdt_1764ExtValid08                                           */
/* Copyright      : Maersk                                                       */
/* Customer       : AEOMX MEXWMS                                                 */
/*                                                                               */
/* Modifications log:                                                            */
/*                                                                               */
/* Date         Author    Ver.    Purposes                                       */
/* 2025-07-31   NickT     1.0.0   FCR-14963 Create                               */
/*********************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1764ExtValid08
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @cTaskdetailKey  NVARCHAR( 10),
   @cToLoc          NVARCHAR( 10),
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT,
   @nAfterStep      INT = 0,
   @cDropID         NVARCHAR( 20) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cStorerKey          NVARCHAR(15),
      @nInputKey           INT,
      @cUserName           NVARCHAR(128),
      @cGroupKey           NVARCHAR(10),
      @cInField01          NVARCHAR(60)

   SELECT TOP 1
      @cInField01    = I_Field01,
      @cUserName = UserName,
      @cStorerKey = StorerKey,
      @nInputKey = InputKey
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   SET @cInField01 = ISNULL(@cInField01, '')

   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      IF @nStep = 5 -- CONT NEXT TASK or CLOSE PALLET?
      BEGIN
         IF @nInputKey = 1 --Enter
         BEGIN
            SELECT @cGroupKey = GroupKey
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE TaskDetailKey = @cTaskdetailKey
            SET @cGroupKey = ISNULL(@cGroupKey, '')

            IF @cInField01 <> '9'
               AND NOT EXISTS(SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) 
                           WHERE StorerKey = @cStorerKey 
                              AND TaskType = 'RPF'
                              AND Status = '0'
                              AND GroupKey = @cGroupKey
                              AND UserKey = @cUserName)
            BEGIN
               SET @nErrNo = 276301
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Only option 9 is valid
               GOTO Quit
            END
         END
      END
   END
Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1764ExtValid08 TO NSQL
GO
