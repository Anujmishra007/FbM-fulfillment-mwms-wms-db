SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: rdt_838DecodeSP21                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: PMI Outbound                                                */  
/*                                                                      */  
/* Date        Author    Ver.  Purposes                                 */  
/* 2026-06-15  Navitha   1.0   Created                                  */
/************************************************************************/
CREATE OR ALTER PROCEDURE [RDT].[rdt_838DecodeSP21]
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT,
   @nInputKey           INT,
   @cFacility           NVARCHAR( 5),
   @cStorerKey          NVARCHAR( 15),
   @cPickSlipNo         NVARCHAR( 10),
   @cFromDropID         NVARCHAR( 20),
   @cBarcode            NVARCHAR( 60),
   @cBarcode2           NVARCHAR( 60),
   @cSKU                NVARCHAR( 20)  OUTPUT,
   @nQTY                INT            OUTPUT,
   @cPackDtlRefNo       NVARCHAR( 20)  OUTPUT,
   @cPackDtlRefNo2      NVARCHAR( 20)  OUTPUT,
   @cPackDtlUPC         NVARCHAR( 30)  OUTPUT,
   @cPackDtlDropID      NVARCHAR( 20)  OUTPUT,
   @cSerialNo           NVARCHAR( 30)  OUTPUT,
   @cFromDropIDDecode   NVARCHAR( 20)  OUTPUT,
   @cToDropIDDecode     NVARCHAR( 20)  OUTPUT,
   @cUCCNo              NVARCHAR( 20)  OUTPUT,
   @nErrNo              INT            OUTPUT,
   @cErrMsg             NVARCHAR( 20)  OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    SET @nErrNo = 0
    SET @cErrMsg = ''

    DECLARE @cUCC        NVARCHAR( 20)
    DECLARE @cUCCSKU     NVARCHAR( 20)
    DECLARE @cID         NVARCHAR( 18)
    IF @nFunc = 838
    BEGIN
        IF @nStep = 1  -- FromDropID/ToDropID
        BEGIN
            IF @nInputKey = 1
            BEGIN
                IF @cBarcode <> ''
                BEGIN
                    SET @cBarcode = LTRIM(RTRIM(@cBarcode))
                    IF LEN(@cBarcode) = 25
                    BEGIN
                        SET @cFromDropIDDecode = SUBSTRING(@cBarcode, 8, 18)
                    END
                    ELSE
                    BEGIN
                        SET @cFromDropIDDecode = @cBarcode
                    END
                    IF @nErrNo <> 0
                        GOTO Quit
                END
                IF @cBarcode2 <> ''
                BEGIN
                    SET @cBarcode2 = LTRIM(RTRIM(@cBarcode2))
                    IF LEN(@cBarcode2) = 25
                    BEGIN
                        SET @cToDropIDDecode = SUBSTRING(@cBarcode2, 8, 18)
                    END
                    ELSE
                    BEGIN
                        SET @cToDropIDDecode = @cBarcode2
                    END
                    IF @nErrNo <> 0
                        GOTO Quit
                END
                GOTO Quit
            END
        END
        IF @nStep = 8  -- UCC
        BEGIN
            IF @nInputKey = 1
            BEGIN
                IF @cBarcode <> ''
                BEGIN
                --V1.1 start
                SET @cBarcode = LTRIM(RTRIM(@cBarcode))
                IF LEN(@cBarCode) = 49 --Fertin label
                BEGIN
                    SET @cUCC = SUBSTRING(@cBarcode, 19, 17)
                    SET @cUCCSKU = SUBSTRING(@cBarcode, 39, 11)
                    IF LEFT(@cUCCSKU, 2) <> 'NP'
                    BEGIN
                        SET @nErrNo = 269851
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --269851^Invalid SKU prefix
                        GOTO Quit
                    END
                    IF NOT EXISTS (SELECT 1 FROM dbo.SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                    BEGIN
                        SET @nErrNo = 269852
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --269852^SKU not found
                        GOTO Quit
                    END
                END--Fertin label
                ELSE IF LEN(@cBarcode) = 40
                BEGIN
                    SET @cUCC = SUBSTRING(@cBarcode, 21, 20)
                    END
                ELSE IF LEN(@cBarcode) = 57 --Swedish label
                BEGIN
                    SET @cUCC = SUBSTRING(@cBarcode, 19, 17)
                    SET @cUCCSKU = SUBSTRING(@cBarcode, 39, 11)
                    IF LEFT(@cUCCSKU, 2) <> 'NP'
                    BEGIN
                        SET @nErrNo = 269853
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --269853^Invalid SKU prefix
                        GOTO Quit
                    END
                    IF NOT EXISTS (SELECT 1 FROM dbo.SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                    BEGIN
                        SET @nErrNo = 269854
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --269854^SKU not found
                        GOTO Quit
                    END
                END -- swedish label
                ELSE IF LEN(@cBarcode) = 58 --Swedish label58
                BEGIN
                    SET @cUCC = SUBSTRING(@cBarcode, 19, 18)
                    SET @cUCCSKU = SUBSTRING(@cBarcode, 40, 11)
                    IF LEFT(@cUCCSKU, 2) <> 'NP'
                    BEGIN
                        SET @nErrNo = 269855
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --269855^Invalid SKU prefix
                        GOTO Quit
                    END
                    IF NOT EXISTS (SELECT 1 FROM dbo.SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                    BEGIN
                        SET @nErrNo = 269856
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --269856^SKU not found
                        GOTO Quit
                    END
                END -- swedish label
                --V1.1 end
                ELSE --V1.0 existing logic
                BEGIN
                    SET @cUCC = ''
                    EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
                        @cUCCNo  = @cUCC        OUTPUT,
                        @nErrNo  = @nErrNo      OUTPUT,
                        @cErrMsg = @cErrMsg     OUTPUT,
                        @cType   = 'UCCNo'
                    IF @nErrNo <> 0
                        GOTO Quit
                END
                SET @cUCCNo = @cUCC
                END --UCC decoding
                GOTO Quit
            END
        END
    END
Quit:
END
GO

GRANT EXECUTE ON [RDT].[rdt_838DecodeSP21] TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO