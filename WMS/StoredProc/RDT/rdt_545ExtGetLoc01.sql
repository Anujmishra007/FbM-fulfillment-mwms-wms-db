if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_545ExtGetLoc01]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure rdt.rdt_545ExtGetLoc01
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_545ExtGetLoc01                                  */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Date       Rev Author      Purposes                                  */
/* 2018-10-25 1.0 James       WMS6789 Created                           */
/************************************************************************/

CREATE PROC rdt.rdt_545ExtGetLoc01 (
   @nMobile        INT,          
   @nFunc          INT,          
   @cLangCode      NVARCHAR( 3), 
   @nStep          INT,          
   @nAfterStep     INT,          
   @nInputKey      INT,          
   @cFacility      NVARCHAR( 5), 
   @cStorerKey     NVARCHAR( 15),
   @tVar           VariableTable READONLY,
   @cLOC           NVARCHAR( 10) OUTPUT,
   @cSuggID        NVARCHAR( 18) OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT 
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cOrderKey      NVARCHAR( 10),
           @cLane          NVARCHAR( 10)

   IF @nFunc = 545 -- Replen
   BEGIN
      IF @nAfterStep = 3 -- LABEL/ID/REFNO
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Variable mapping
            SELECT @cOrderKey = Value FROM @tVar WHERE Variable = '@cOrderKey'
            SELECT @cLane = Value FROM @tVar WHERE Variable = '@cLane'

            -- Get existing LOC, ID
            SELECT TOP 1 
               @cLOC = LOC, 
               @cSuggID = ID
            FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) 
            WHERE Lane = @cLane 
               AND OrderKey = @cOrderKey 
               AND Status = '1' -- In-use
         
            -- Get available empty LOC
            IF @cLOC = ''
            BEGIN
               -- Lock a LOC
               DECLARE @nRowCount INT
               UPDATE TOP (1) rdt.rdtSortLaneLocLog SET
                  OrderKey = @cOrderKey, 
                  LoadKey  = '', 
                  Status   = '1', -- In-use
                  @cLOC    = LOC  -- Retrieve LOC used
               WHERE Lane = @cLane 
                  AND Status = '0'
               SELECT @nRowCount = @@ROWCOUNT, @nErrNo = @@ERROR
            
               IF @nErrNo <> 0
               BEGIN
                  SET @nErrNo = 180041
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Lock LOC fail
                  GOTO Quit
               END
            
               -- Check LOC available
               IF @nRowCount <> 1
               BEGIN
                  SET @nErrNo = 180042
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- No avail LOC
                  GOTO Quit
               END
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

GRANT EXECUTE ON RDT.rdt_545ExtGetLoc01 TO NSQL
GO
