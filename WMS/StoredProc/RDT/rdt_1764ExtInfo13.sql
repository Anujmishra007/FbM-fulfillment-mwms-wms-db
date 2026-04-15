
/************************************************************************/
/* Store procedure: rdt_1764ExtInfo13                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: For JCB                                                     */
/*                                                                      */
/* Date        Rev     Author      Purposes                             */
/* 2025-06-09  1.0.0   Dennis      FCR-3959 Created                     */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1764ExtInfo13]
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

   DECLARE @nDebugFlag INT = 0

   DECLARE @cCaseID   NVARCHAR( 20)
   DECLARE @cFromLoc  NVARCHAR( 20)
   DECLARE @cToLoc    NVARCHAR( 20)
   DECLARE @cFromLoc2 NVARCHAR( 20)
   DECLARE @cToLoc2   NVARCHAR( 20)
   DECLARE @nScn      INT
   DECLARE @nIPK      INT

   SELECT TOP 1 @cFromLoc = FromLoc, @cToLoc = ToLoc FROM TaskDetail WITH(NOLOCK) WHERE TaskDetailKey = @cTaskdetailKey AND FromLoc = 'INTRANSIT'
   SELECT TOP 1 @cFromLoc2 = FromLoc, @cToLoc2 = ToLoc FROM TaskDetail TaskDetail WITH(NOLOCK) WHERE TaskDetailKey = @cTaskdetailKey
   SELECT TOP 1 @nScn = Scn, @nIPK = InputKey FROM RDT.RDTMOBREC WITH(NOLOCK) WHERE Mobile = @nMobile

   IF @nFunc = 1764
   BEGIN
      SET @cExtendedInfo1 = ''

      IF @cFromLoc = 'INTRANSIT'
      BEGIN
         SET @cExtendedInfo1 = 'To Loc: '+@cToLoc
      END

      IF @nAfterStep = 4 --SKU/Qty Screen
      BEGIN
         SELECT @cCaseID = CaseID
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE TaskDetailKey = @cTaskDetailKey

         SET @cExtendedInfo1 = 'Case: ' + @cCaseID
      END --st4

      IF (@nAfterStep = 5 AND @nIPK = 1) OR (@nStep = 5 AND @nScn = 2684 AND @nIPK = 0)
      BEGIN
         SET @cExtendedInfo1 = 'Source loc: ' + @cFromLoc2
      END
   END--1812

   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1764ExtInfo13 TO NSQL
GO


