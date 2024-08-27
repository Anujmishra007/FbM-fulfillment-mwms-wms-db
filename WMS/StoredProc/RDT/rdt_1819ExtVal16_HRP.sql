GO
/****** Object:  StoredProcedure [RDT].[rdt_1819ExtVal16_HRP]    Script Date: 3/27/2024 12:00:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/************************************************************************/
/* Store procedure: [rdt_1819ExtVal16_HRP]                              */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Purpose: not allow to put pallet into location if maxpallet  <> 0    */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2024-03-21 1.0  WSE016        WMS-?                                  */
/************************************************************************/



CREATE OR ALTER     PROC [RDT].[rdt_1819ExtVal16_HRP] (
               @nMobile         INT,           
               @nFunc           INT,           
               @cLangCode       NVARCHAR( 3),  
               @nStep           INT,           
               @nInputKey       INT,            
               @cFromID         NVARCHAR( 18), 
               @cSuggLOC        NVARCHAR( 10), 
               @cPickAndDropLOC NVARCHAR( 10), 
               @cToLOC          NVARCHAR( 10), 
               @nErrNo          INT           OUTPUT, 
               @cErrMsg         NVARCHAR( 20) OUTPUT  
) AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF


DECLARE
	@LOCAvail int

	
IF @nStep = 2

BEGIN

select @LOCAvail = coalesce((select top 1 MaxPallet from LOC where loc = @cToLoc)
-
(select count(distinct id) from LOTxLOCxID where loc = @cToLoc and qty > 0),0)

	IF @LOCAvail < 1 or @LOCAvail is null
	BEGIN
            SET @nErrNo = 82151
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
	END
END

GO


GRANT EXECUTE ON  [RDT].[rdt_1819ExtVal16_HRP] TO [NSQL]
GO
