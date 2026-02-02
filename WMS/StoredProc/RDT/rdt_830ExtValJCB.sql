
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************************************************************************/
/* Store procedure: [rdt_830ExtValJCB]                                  */
/* Copyright: Maersk                                                    */
/*                                                                      */
/*                                                                      */
/* Date         Rev   Author   Purposes                                 */
/* 21/03/2024   1.0   PPA374   Checks that DROP ID is blank	            */
/************************************************************************/

CREATE OR ALTER   PROC [RDT].[rdt_830ExtValJCB] (
@nMobile       INT,
@nFunc         INT,
@cLangCode     NVARCHAR( 3),
@nStep         INT,
@nInputKey     INT,
@cFacility     NVARCHAR( 5),
@cStorerKey    NVARCHAR( 15),
@cPickSlipNo   NVARCHAR( 10),
@cPickZone     NVARCHAR( 10),
@cSuggLOC      NVARCHAR( 10),
@cLOC          NVARCHAR( 10),
@cDropID       NVARCHAR( 20),
@cSKU          NVARCHAR( 20),
@cLottable01   NVARCHAR( 18),
@cLottable02   NVARCHAR( 18),
@cLottable03   NVARCHAR( 18),
@dLottable04   DATETIME,
@dLottable05   DATETIME,
@cLottable06   NVARCHAR( 30),
@cLottable07   NVARCHAR( 30),
@cLottable08   NVARCHAR( 30),
@cLottable09   NVARCHAR( 30),
@cLottable10   NVARCHAR( 30),
@cLottable11   NVARCHAR( 30),
@cLottable12   NVARCHAR( 30),
@dLottable13   DATETIME,
@dLottable14   DATETIME,
@dLottable15   DATETIME,
@nTaskQTY      INT,
@nQTY          INT,
@cToLOC        NVARCHAR( 10),
@cOption       NVARCHAR( 1),
@nErrNo        INT           OUTPUT,
@cErrMsg       NVARCHAR( 20) OUTPUT
) AS

BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nChkDgt    AS INT
   DECLARE @cChkDgt    AS NVARCHAR(5)
   DECLARE @cOrderKey  AS NVARCHAR(20)
   DECLARE @cLot       AS NVARCHAR(20)
   DECLARE @cCaseLot11 AS NVARCHAR(20)
   DECLARE @nEntQTY    AS INT

   IF @nFunc = 830
   BEGIN
      IF @nStep = 2 and @nInputKey = 1
      BEGIN
	     SELECT TOP 1 @cOrderKey = OrderKey 
		 FROM dbo.PICKHEADER PH WITH(NOLOCK) 
		 WHERE PickHeaderKey = @cPickSlipNo

		 SELECT TOP 1 @cLot = PD.LOT
         FROM dbo.PICKDETAIL PD WITH (NOLOCK)
            INNER JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK) 
            ON PD.LOT = LA.LOT
               AND ISNULL(LA.Lottable11, '') <> ''
         WHERE PD.OrderKey = @cOrderKey
            AND PD.LOC = @cSuggLOC
            AND PD.Status = '0'
            AND PD.Storerkey = @cStorerKey
         ORDER BY PD.PickDetailKey, PD.LOT

		 SELECT TOP 1 @cCaseLot11 = Lottable11
		 FROM dbo.LOTATTRIBUTE WITH(NOLOCK)
		 WHERE LOT = @cLot
		    AND StorerKey = @cStorerKey

		 IF @cCaseLot11 = ''
		 BEGIN
		    SET @nErrNo = 218150
			SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'218150^NonCase pick'
			GOTO QUIT
		 END

	     IF @cDropID <> @cCaseLot11
		 BEGIN
		    SET @nErrNo = 218151
			SET @cErrMsg = 'Scan '+@cCaseLot11
			GOTO QUIT
		 END
 	  END

	  IF @nStep = 4 and @nInputKey = 1
	  BEGIN
	     SELECT @nEntQTY = I_Field15 FROM RDT.RDTMOBREC WHERE Mobile = @nMobile

	     IF @nTaskQTY <> @nEntQTY
		 BEGIN
		    SET @nErrNo = 218152
			SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Confirm qty as shown'
			GOTO QUIT
		 END
      END
   END
Quit:
END
GO

GRANT EXECUTE ON rdt_830ExtValJCB TO NSQL
GO
