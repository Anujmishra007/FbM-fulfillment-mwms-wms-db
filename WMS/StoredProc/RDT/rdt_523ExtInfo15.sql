SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_523ExtInfo15                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Customer: DAIMLER TRUCK AG                                           */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2026-01-29 1.0  JackC    FCR-9756 created                            */
/************************************************************************/
    
CREATE OR ALTER PROCEDURE [RDT].[rdt_523ExtInfo15]    
   @nMobile         INT, 
   @nFunc           INT, 
   @cLangCode       NVARCHAR( 3),  
   @nStep           INT, 
   @nAfterStep      INT, 
   @nInputKey       INT,                
   @cStorerKey      NVARCHAR( 15), 
   @cFacility       NVARCHAR( 5),  
   @cLOC            NVARCHAR( 10), 
   @cID             NVARCHAR( 18), 
   @cSKU            NVARCHAR( 20), 
   @nQTY            INT,  
   @cSuggestedLOC   NVARCHAR( 10),  
   @cFinalLOC       NVARCHAR( 10), 
   @cOption         NVARCHAR( 1), 
   @cExtendedInfo1  NVARCHAR( 20) OUTPUT
AS    
BEGIN    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
   
   IF @nFunc = 523 -- Putaway by SKU
   BEGIN
      IF @nAfterStep = 5 AND @nInputKey = 1--message screen
      BEGIN
         SET @cExtendedInfo1 = 'PALoc: ' + @cFinalLOC
      END--st5

      IF @nAfterStep = 6 AND @nInputKey = 1--Loc diff screen
      BEGIN
         SET @cExtendedInfo1 = 'SCANNED: ' + @cFinalLOC
      END--st5
   END

Quit:

END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_523ExtInfo15 to nSQL
GO 
