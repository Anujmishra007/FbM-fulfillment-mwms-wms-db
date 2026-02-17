
/************************************************************************/
/* Store procedure: rdt_1819ExtInfo08                                   */
/* Copyright      : LFLogistics                                         */
/*                                                                      */
/* Purpose: Display final location                                      */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2025-12-04 1.0  JRA432   Galaxy Specific Extended Info               */
/************************************************************************/

CREATE OR ALTER     PROCEDURE [RDT].[rdt_1819ExtInfo08] (
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
		 IF EXISTS(SELECT 1 FROM dbo.Loc (NOLOCK) WHERE loc = @cSuggLOC AND LocLevel > 0)
         SET @cExtendedInfo = 'Slave Pallet Req!'
		 
      END
   END
