SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*****************************************************************************/
/* Store Procedure: rdt_729GetUCCInfo03                                      */
/*                                                                           */
/* Purpose: Fetch and return all required UCC Inquiry display information    */
/*         for FN729 (UCC Inquiry)                                           */
/* Customer: PageInd                                                         */
/*                                                                           */
/* Modifications log:                                                        */
/*                                                                           */
/* Date        Rev  Author   Purposes                                        */
/* 29-01-2026  1.0  SSR259   FCR-9907 - Fetch all display fields             */
/*****************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_729GetUCCInfo03] (
    @nMobile      INT,
    @nFunc        INT,
    @cLangCode    NVARCHAR(3),
    @nStep        INT,
    @nInputKey    INT,
    @cStorerKey   NVARCHAR(15),
    @cUCC         NVARCHAR(20),
    @cExtInfo01   NVARCHAR(20)  OUTPUT,
    @cExtInfo02   NVARCHAR(20)  OUTPUT,
    @cExtInfo03   NVARCHAR(20)  OUTPUT,
    @cExtInfo04   NVARCHAR(20)  OUTPUT,
    @cExtInfo05   NVARCHAR(20)  OUTPUT,
    @cExtInfo06   NVARCHAR(20)  OUTPUT,
    @cExtInfo07   NVARCHAR(20)  OUTPUT,
    @nErrNo       INT           OUTPUT,
    @cErrMsg      NVARCHAR(1024) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF

    -- Init outputs
    SELECT
        @cExtInfo01 = N'',
        @cExtInfo02 = N'',
        @cExtInfo03 = N'',
        @cExtInfo04 = N'',
        @cExtInfo05 = N'',
        @cExtInfo06 = N'',
        @cExtInfo07 = N'',
        @nErrNo     = 0,
        @cErrMsg    = N''

    IF ISNULL(@cUCC, N'') = N''
    BEGIN
        SET @nErrNo  = 257801 -- 'UCC REQUIRED'
        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
        GOTO Quit
    END

    ;WITH U AS (
    SELECT TOP (1) UCC.ID, UCC.Loc, UCC.ExternKey, UCC.OrderKey, UCC.Lot, UCC.SKU
    FROM dbo.UCC WITH (NOLOCK)
    WHERE UCC.StorerKey = @cStorerKey AND UCC.UCCNo = @cUCC
    )
    
    SELECT
        @cExtInfo01 = 'ID:    ' + CAST(U.ID AS NVARCHAR(15)),
        @cExtInfo02 = 'LOC:  ' + CAST(U.Loc AS NVARCHAR(15)),
        @cExtInfo03 = CAST(ISNULL(S.SUSR3, N'') AS NVARCHAR(20)),
        @cExtInfo04 = CAST(U.ExternKey AS NVARCHAR(20)),
        @cExtInfo05 = CAST(ISNULL(O.ExternOrderKey, N'') AS NVARCHAR(20)),
        @cExtInfo06 = CAST(ISNULL(LA.Lottable01, N'') AS NVARCHAR(20))
    FROM U
    LEFT JOIN dbo.SKU S WITH (NOLOCK) ON S.StorerKey = @cStorerKey AND S.SKU = U.SKU
    LEFT JOIN dbo.Orders O WITH (NOLOCK) ON O.OrderKey = U.OrderKey
    LEFT JOIN dbo.LotAttribute LA WITH (NOLOCK) ON LA.StorerKey = @cStorerKey AND LA.Lot = U.Lot

    IF @@ROWCOUNT = 0
    BEGIN
        SET @nErrNo  = 257802 -- 'UCC NOT FOUND'
        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
        GOTO Quit
    END

Quit:

END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_729GetUCCInfo03] TO [NSQL]
GO