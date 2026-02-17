SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1813ExtValid06                                        */
/* Purpose: Validate Pallet DropID                                            */
/*                                                                            */
/* Created for the MICHELIN customer    IDN                                   */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev  Author   Purposes                                          */
/* 2025-12-19 1.0  NYE018   FCR-9253 Created                                  */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1813ExtValid06] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cStorerKey       NVARCHAR( 15),
   @cFromID          NVARCHAR( 20),
   @cOption          NVARCHAR( 1),
   @cSKU             NVARCHAR( 20),
   @nQty             INT,
   @cToID            NVARCHAR( 20),
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
) AS
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF

    IF @nFunc = 1813
    BEGIN

        DECLARE @cInField02     NVARCHAR(60)
        DECLARE @cMergePltOpt   NVARCHAR(1)

        SET @nErrNo = 0

        SELECT @cInField02 = I_Field02
        FROM RDT.RDTMOBREC WITH (NOLOCK)       
        WHERE Mobile = @nMobile      


        IF @nStep = 1 -- From  id
        BEGIN
            IF @nInputKey = 1 -- ENTER
            BEGIN
                SET @cMergePltOpt = @cInField02

                IF @cMergePltOpt NOT IN ('1')
                BEGIN
                    SET @nErrNo = 254452  -- Invalid Option
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                    GOTO Quit
                END
            END
        END


    END

Quit:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1813ExtValid06] TO NSQL
GO