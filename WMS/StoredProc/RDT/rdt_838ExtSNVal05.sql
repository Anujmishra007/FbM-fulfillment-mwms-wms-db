SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****************************************************************************************************/
/* Store procedure: rdt_838ExtSNVal05                                                               */
/* Copyright      : Maersk                                                                          */
/*                                                                                                  */
/* Customer : MICHELIN IDN                                                                          */
/*                                                                                                  */
/* Date        Rev  Author          Purposes                                                        */
/* 06-03-2026  1.0  bruce.yuan      FCR-11432 Only allow to Pack SNO as per pickdetail.ID           */
/* 29-04-2026  1.1  bruce.yuan      UWP-55389 fix an issue                                          */
/****************************************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdt_838ExtSNVal05]
    @nMobile          INT,
    @nFunc            INT,
    @cLangCode        NVARCHAR( 3),
    @nStep            INT,
    @nInputKey        INT,
    @cFacility        NVARCHAR( 3),
    @cStorerKey       NVARCHAR( 15),
    @cSKU             NVARCHAR( 20),
    @nQTY             INT, 
    @cSerialNo        NVARCHAR( 30),
    @cType            NVARCHAR( 15), --CHECK/INSERT
    @cDocType         NVARCHAR( 10), 
    @cDocNo           NVARCHAR( 20), 
    @nErrNo           INT           OUTPUT,
    @cErrMsg          NVARCHAR( 20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE @nRowCount           INT
    DECLARE @cChkStatus          NVARCHAR(10)
    DECLARE @cChkExternStatus    NVARCHAR(10)
    DECLARE @cID                 NVARCHAR(18)

    IF @nFunc = 838 -- Pack
    BEGIN
        SELECT TOP 1 @cID = p.ID
            FROM dbo.PICKDETAIL p WITH(NOLOCK)
        INNER JOIN rdt.RDTMOBREC m WITH(NOLOCK) 
            ON p.PickSlipNo = m.V_PickSlipNo 
            AND p.DropID = m.V_String20
        WHERE p.Storerkey = @cStorerKey
            AND p.Sku = @cSKU
            AND m.Mobile = @nMobile
        
        IF @cID IS NULL
        BEGIN
            SET @nErrNo = 262101
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --No matching PickDetail
            GOTO Quit
        END

        -- Get serial no info
        SELECT 
            @cChkStatus = Status, 
            @cChkExternStatus = ExternStatus
        FROM dbo.SerialNo WITH (NOLOCK)
        WHERE StorerKey = @cStorerKey
            AND SKU = @cSKU
            AND SerialNo = @cSerialNo
        SET @nRowCount = @@ROWCOUNT

        -- Check SNO in ASN
        IF @nRowCount = 0
        BEGIN
            SET @nErrNo = 262102
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO not exists
            GOTO Quit
        END
            
        -- Check SNO multi line
        IF @nRowCount > 1
        BEGIN
            SET @nErrNo = 262103
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNOMultiRecord
            GOTO Quit
        END
            
        IF @cChkStatus <> '1'
        BEGIN
            -- Check SNO received
            IF @cChkStatus = '0'
            BEGIN
                SET @nErrNo = 262104
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO NotYet RCV
                GOTO Quit
            END
    
            -- Check SNO received
            ELSE IF @cChkStatus = '5'
            BEGIN
                SET @nErrNo = 262105
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO ady picked
                GOTO Quit
            END
            
            -- Check SNO received
            ELSE IF @cChkStatus = '6'
            BEGIN
                SET @nErrNo = 262106
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO ady packed
                GOTO Quit
            END

            -- Check SNO received
            ELSE IF @cChkStatus = '9'
            BEGIN
                SET @nErrNo = 262107
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO ady ship
                GOTO Quit
            END
            
            -- Check SNO received
            ELSE IF @cChkStatus = 'H'
            BEGIN
                SET @nErrNo = 262108
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO is HOLD
                GOTO Quit
            END
            
            -- Status unknown
            ELSE
            BEGIN
                SET @nErrNo = 262109
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Bad SNO status
                GOTO Quit
            END
        END
        
        IF @cChkExternStatus = 'H'
        BEGIN
            SET @nErrNo = 262110
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO is HOLD
            GOTO Quit
        END
        
        -- Check SNO already scanned
        IF EXISTS( SELECT 1 
            FROM dbo.PackSerialNo WITH (NOLOCK)
            WHERE PickSlipNo = @cDocNo
                AND StorerKey = @cStorerKey
                AND SKU = @cSKU
                AND SerialNo = @cSerialNo)
        BEGIN
            SET @nErrNo = 262111
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO ady scan
            GOTO Quit
        END

        IF NOT EXISTS(SELECT 1
                    FROM dbo.PICKDETAIL p WITH(NOLOCK)
                    INNER JOIN rdt.RDTMOBREC m WITH(NOLOCK) ON p.PickSlipNo = m.V_PickSlipNo AND p.DropID = m.V_String20
                    INNER JOIN dbo.SerialNo SN WITH(NOLOCK) ON SN.StorerKey = P.Storerkey AND SN.SKU = p.Sku AND SN.ID = p.ID
                    WHERE p.Storerkey = @cStorerKey
                        AND p.Sku = @cSKU
                        AND m.Mobile = @nMobile
                        AND SN.SerialNo = @cSerialNo)
        BEGIN
            SET @nErrNo = 262112
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO not ID
            GOTO Quit
        END
    END

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_838ExtSNVal05] TO [NSQL]
GO
