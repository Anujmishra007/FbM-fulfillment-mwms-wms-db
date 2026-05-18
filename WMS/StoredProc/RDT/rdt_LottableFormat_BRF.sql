
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_LottableFormat_BRF                              */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-04-01 1.0  Cuize      FCR-11068 Created                         */
/* 2026-04-14 1.1  Amruta     FCR-11068 Add new validation              */
/************************************************************************/
CREATE OR ALTER PROCEDURE rdt.rdt_LottableFormat_BRF(
    @nMobile          INT
   ,@nFunc            INT
   ,@cLangCode        NVARCHAR( 3)
   ,@nInputKey        INT
   ,@cStorerKey       NVARCHAR( 15)
   ,@cSKU             NVARCHAR( 20)
   ,@cLottableCode    NVARCHAR( 30)
   ,@nLottableNo      INT
   ,@cFormatSP        NVARCHAR( 20)
   ,@cLottableValue   NVARCHAR( 20)
   ,@cLottable        NVARCHAR( 30) OUTPUT
   ,@nErrNo           INT           OUTPUT
   ,@cErrMsg          NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF


   IF @nLottableNo = 3
   BEGIN
      IF NOT EXISTS(
         SELECT 1 FROM dbo.CodeLkUp WITH (NOLOCK)
            WHERE storerkey = @cStorerKey
            AND listname = 'BRFSIF' -- For lottable3
            AND Code = @cLottableValue)
      BEGIN -- 263401
         SET @nErrNo = 263401
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Inv SIF'
         GOTO Quit
      END
   END

   IF @nLottableNo = 1
   BEGIN
      IF NOT EXISTS(
         SELECT 1 FROM dbo.CodeLkUp WITH (NOLOCK)
         WHERE storerkey = @cStorerKey
           AND listname = 'BRFSLCODE' -- For lottable1
           AND Code = @cLottableValue)
      BEGIN
         SET @nErrNo = 263402
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Inv SL'
         GOTO Quit
      END
   END

    IF @nLottableNo = 12 AND @cLottableValue ='' AND EXISTS (
           SELECT 1
           FROM RDT.RDTMOBREC RM WITH (NOLOCK)
           WHERE RM.MOBILE = @nMobile
             AND RM.FUNC = @nFunc
             AND RM.V_LOTTABLE01 = '198F'
    )

    BEGIN
       SET @nErrNo = 263404
       SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
       GOTO Quit
    END

   IF @nLottableNo = 12 AND EXISTS (
        SELECT 1
        FROM RDT.RDTMOBREC RM WITH (NOLOCK)
        WHERE RM.MOBILE = @nMobile
          AND RM.FUNC = @nFunc
          AND RM.V_LOTTABLE01 = '198F'
   )
   AND NOT EXISTS (
        SELECT 1
        FROM dbo.CodeLkUp CLK WITH (NOLOCK)
        WHERE CLK.STORERKEY = @cStorerKey
          AND CLK.listname = 'ASNREASON'
          AND CLK.Code = @cLottableValue
		  AND CLK.Short = '198F'
   )
   BEGIN
       SET @nErrNo = 263403
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

GRANT EXECUTE ON [rdt].[rdt_LottableFormat_BRF] TO NSQL
GO
