SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************/  
/* Store procedure: rdt_861Decodedrpid01                                      */ 
/* Copyright: Maersk                                                          */  
/*                                                                            */  
/* Purpose: PMI Outbound                                                      */  
/*                                                                            */  
/* Date        Author    Ver.  Purposes                                       */  
/* 2026-06-15  Navitha    1.0   Decoding                                      */
/******************************************************************************/  

CREATE OR ALTER PROC [RDT].[rdt_861Decodedrpid01] (  
   @nMobile         INT,      
   @nFunc           INT,      
   @cLangCode       NVARCHAR( 3), 
   @nStep           INT,         
   @nInputKey       INT,         
   @cStorerKey      NVARCHAR( 15),
   @cPickSlipNo     NVARCHAR( 10),
   @cDropID         NVARCHAR(60)   OUTPUT, 
   @cLOC            NVARCHAR(10)   OUTPUT, 
   @cID             NVARCHAR(18)   OUTPUT, 
   @cSKU            NVARCHAR(20)   OUTPUT,   
   @nQty            INT            OUTPUT,  
   @cLottable01     NVARCHAR( 18)  OUTPUT,   
   @cLottable02     NVARCHAR( 18)  OUTPUT,   
   @cLottable03     NVARCHAR( 18)  OUTPUT,   
   @dLottable04     DATETIME       OUTPUT,   
   @dLottable05     DATETIME       OUTPUT,   
   @cLottable06     NVARCHAR( 30)  OUTPUT,   
   @cLottable07     NVARCHAR( 30)  OUTPUT,   
   @cLottable08     NVARCHAR( 30)  OUTPUT,   
   @cLottable09     NVARCHAR( 30)  OUTPUT,   
   @cLottable10     NVARCHAR( 30)  OUTPUT,   
   @cLottable11     NVARCHAR( 30)  OUTPUT,   
   @cLottable12     NVARCHAR( 30)  OUTPUT,   
   @dLottable13     DATETIME       OUTPUT,   
   @dLottable14     DATETIME       OUTPUT,   
   @dLottable15     DATETIME       OUTPUT,   
   @nErrNo          INT OUTPUT,             
   @cErrMsg         NVARCHAR( 20) OUTPUT 
) AS  
BEGIN  
    SET NOCOUNT ON  
    SET ANSI_NULLS OFF  
    SET QUOTED_IDENTIFIER OFF  
    SET CONCAT_NULL_YIELDS_NULL OFF 

    DECLARE @nDebugFlag  INT
    DECLARE @cFacility   NVARCHAR( 5)

    SELECT @cFacility = Facility 
    FROM RDT.RDTMOBREC WITH (NOLOCK) 
    WHERE Mobile = @nMobile

    IF @nFunc = 861 -- UCC Pick 
    BEGIN  
        IF @nStep = 2  -- DropID/ToDropID
        BEGIN
            IF @nInputKey = 1
            BEGIN
                IF @cDropID <> ''
                BEGIN
                    SET @cDropID = LTRIM(RTRIM(@cDropID))
                    IF LEN(@cDropID) = 25
                    BEGIN
                        SET @cDropID = RIGHT(@cDropID, 18)
                    END
                    ELSE
                    BEGIN
                        SET @cDropID = @cDropID
                    END
                    IF @nErrNo <> 0
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

GRANT EXEC ON [RDT].[rdt_861Decodedrpid01] TO NSQL
GO