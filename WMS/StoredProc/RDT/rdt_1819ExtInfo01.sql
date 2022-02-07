IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[rdt].[rdt_1819ExtInfo01]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [rdt].[rdt_1819ExtInfo01]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1819ExtInfo01                                   */
/* Copyright      : LFLogistics                                         */
/*                                                                      */
/* Purpose: Display final location                                      */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2015-07-13 1.0  Ung      SOS346283 Created                           */
/************************************************************************/

CREATE PROCEDURE [RDT].[rdt_1819ExtInfo01] (
   @nMobile         INT,          
   @nFunc           INT,          
   @cLangCode       NVARCHAR( 3), 
   @nStep           INT,          
   @nAfterStep      INT, 
   @nInputKey       INT,          
   @cFromID         NVARCHAR( 18),
   @cSuggLOC        NVARCHAR( 10),
   @cPickAndDropLOC NVARCHAR( 10),
   @cToLOC          NVARCHAR( 10),
   @cExtendedInfo   NVARCHAR( 20) OUTPUT,
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
) AS

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nAfterStep = 2 -- Successful putaway
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         IF @cPickAndDropLOC <> ''
            SET @cExtendedInfo = 'FINAL LOC: ' + @cSuggLOC
      END
   END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1819ExtInfo01] TO NSQL
GO