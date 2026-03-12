
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1868UnpackVal01                                 */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date         Rev   Author      Purposes                              */
/* 2026-02-19   1.0   NYE018      FCR-10102  validation using sku       */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_1868UnpackVal01 (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @cSerialNo        NVARCHAR( 100),
   @cPickSlipNo      NVARCHAR( 20),
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF


    DECLARE @cSKU  NVARCHAR( 60)

    IF @cSerialNo = ''
    BEGIN
        SET @nErrNo = 259401
        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')   --259401^SerialNo is not valid
        GOTO Quit
    END

    IF NOT EXISTS( SELECT 1 FROM dbo.PackSerialNo WITH(NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND SerialNo = @cSerialNo AND StorerKey = @cStorerKey )
    BEGIN
        SET @nErrNo = 259403
        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')   --259403^Serial number not yet packed
        GOTO Quit
    END

    IF EXISTS( SELECT 1 FROM dbo.SerialNo WITH(NOLOCK) WHERE SerialNo = @cSerialNo AND Storerkey=@cStorerkey AND Status NOT IN(1,6) )
    BEGIN
        SET @nErrNo = 259402
        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')   --259402^SerialNo is not valid
        GOTO Quit
    END  

    SELECT @cSKU = V_SKU 
    FROM rdt.rdtMobRec WITH (NOLOCK) 
    WHERE Mobile = @nMobile

    IF ISNULL(@cSKU, '') <> ''
    BEGIN
       -- Validate if the scanned serial number belongs to the scanned SKU
        IF NOT EXISTS (
           SELECT 1 
           FROM dbo.PackSerialNo WITH (NOLOCK)
           WHERE PickSlipNo = @cPickSlipNo
             AND SerialNo = @cSerialNo
             AND StorerKey = @cStorerKey
             AND SKU = @cSKU
       )
        BEGIN
           SET @nErrNo = 259404
           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  -- 259404^Serial No not for SKU
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

GRANT EXECUTE ON RDT.rdt_1868UnpackVal01 TO NSQL
GO
