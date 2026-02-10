
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

   DECLARE @cCaseID NVARCHAR( 20)

   IF @nFunc = 1764
   BEGIN
      IF @nAfterStep = 4 --SKU/Qty Screen
      BEGIN
         SELECT @cCaseID = CaseID
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE TaskDetailKey = @cTaskDetailKey

         SET @cExtendedInfo1 = 'Case: ' + @cCaseID
      END --st4
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


