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
        SELECT TOP (1)
            UCC.ID,
            UCC.Loc,
            UCC.ExternKey,
            UCC.OrderKey,
            UCC.Lot,
            UCC.SKU
        FROM dbo.UCC WITH (NOLOCK)
        WHERE UCC.StorerKey = @cStorerKey
            AND UCC.UCCNo     = @cUCC
        ORDER BY UCC.ID -- deterministic pick
    )
    SELECT
        @cExtInfo01 = 'ID:    ' + CAST(U.ID AS NVARCHAR(15)),      -- UCC.ID with prefix
        @cExtInfo02 = 'LOC:  ' + CAST(U.Loc AS NVARCHAR(15)),    -- UCC.LOC with prefix
        @cExtInfo04 = CAST(U.ExternKey AS NVARCHAR(20)), -- UCC.ExternKey
        @cExtInfo03 = N'',
        @cExtInfo05 = N'',
        @cExtInfo06 = N''
    FROM U

    IF @@ROWCOUNT = 0
    BEGIN
        SET @nErrNo  = 257801 -- 'UCC NOT FOUND'
        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
        GOTO Quit
    END

    SELECT TOP (1)
        @cExtInfo03 = CAST(ISNULL(S.SUSR3, N'') AS NVARCHAR(20))
    FROM dbo.SKU S WITH (NOLOCK)
    JOIN dbo.UCC U2 WITH (NOLOCK)
        ON U2.StorerKey = @cStorerKey
        AND U2.UCCNo     = @cUCC
        AND U2.SKU       = S.SKU
        WHERE S.StorerKey = @cStorerKey

    SELECT TOP (1)
        @cExtInfo05 = CAST(ISNULL(O.ExternOrderKey, N'') AS NVARCHAR(20))
    FROM dbo.Orders O WITH (NOLOCK)
    JOIN dbo.UCC U3 WITH (NOLOCK)
        ON U3.StorerKey = @cStorerKey
        AND U3.UCCNo     = @cUCC
        AND U3.OrderKey  = O.OrderKey

    SELECT TOP (1)
        @cExtInfo06 = CAST(ISNULL(LA.Lottable01, N'') AS NVARCHAR(20))
    FROM dbo.LotAttribute LA WITH (NOLOCK)
    JOIN dbo.UCC U4 WITH (NOLOCK)
        ON U4.StorerKey = @cStorerKey
        AND U4.UCCNo     = @cUCC
        AND U4.Lot       = LA.Lot
        WHERE LA.StorerKey = @cStorerKey

Quit:
END
GO
GRANT EXECUTE ON [RDT].[rdt_729GetUCCInfo03] TO [NSQL]
GO