SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1841ExtValidCSC                                       */
/* Copyright      : MAERSK                                                    */
/*                                                                            */
/* Called from    : rdtfnc_PrePalletizeSort                                   */
/* Purpose: Make sure when no pallet is suggested a new pallet is scanned     */
/*                                                                            */
/*                                                                            */
/* Date        Rev  Author       Purposes                                     */
/* 2026-03-27  1.0.0  MMA982       Created                                    */
/******************************************************************************/

ALTER   PROCEDURE [RDT].[rdt_1841ExtValidCSC]
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nAfterStep     INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cReceiptKey    NVARCHAR( 10),
   @cLane          NVARCHAR( 10),
   @cUCC           NVARCHAR( 20),
   @cToID          NVARCHAR( 18),
   @cSKU           NVARCHAR( 20),
   @nQty           INT,
   @cOption        NVARCHAR( 1),
   @cPosition      NVARCHAR( 20),
   @tExtValidVar   VariableTable READONLY,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
AS

BEGIN
	SET NOCOUNT ON
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS OFF
	SET CONCAT_NULL_YIELDS_NULL OFF

IF @nFunc = 1841
BEGIN
	IF @nStep = 2 -- UCC
	BEGIN
		IF @nInputKey = 1 -- ENTER
		BEGIN
			-- Check UserDefine10 in OriLine ASN
			IF NOT EXISTS (
					SELECT TOP 1 1
					FROM ReceiptDetail RD WITH (NOLOCK)
					JOIN UCC U WITH (NOLOCK) ON (
							RD.ExternReceiptKey = u.sourcekey
							AND RD.StorerKey = U.Storerkey
							)
                    JOIN RECEIPT R on (R.ReceiptKey = RD.ReceiptKey and R.StorerKey = RD.StorerKey)         
					WHERE U.UccNo = @cUCC
						AND RD.ReceiptKey = @cReceiptKey
						AND RD.StorerKey = @cStorerKey
                        AND R.ASNStatus <> '9'
					)
			BEGIN
				SET @nErrNo = 173501
				SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Invalid UCC

				GOTO Quit
			END
		END
	END

	IF @nStep = 3 -- ToID
	BEGIN
		IF @nInputKey = 1 -- ENTER
		BEGIN
			-- 1) Get the existing position for this TOID (if exists)
			--------------------------------------------------------------------
			DECLARE @cExistingPosition NVARCHAR(10);
			DECLARE @cPositionCode NVARCHAR(10);

			SELECT TOP 1 @cExistingPosition = Position
			FROM rdt.rdtPreReceiveSort WITH (NOLOCK)
			WHERE ID = @cToID
				AND STATUS = '1';

			--------------------------------------------------------------------
			-- 2) Decode position
			--------------------------------------------------------------------
			IF @cExistingPosition IS NOT NULL
			BEGIN
				SELECT @cPositionCode = ISNULL(Code, '')
				FROM dbo.CodeLkUp WITH (NOLOCK)
				WHERE ListName = 'PreRcvLane'
					AND StorerKey = @cStorerKey
					AND [Description] = @cPosition
			END

			--------------------------------------------------------------------
			-- 3) If TOID exists in a different position → Block
			--------------------------------------------------------------------
			IF @cExistingPosition IS NOT NULL
				AND @cExistingPosition <> @cPositionCode
			BEGIN
				SET @nErrNo = 147733
				SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --ToID is used          
			END
		END
	END
END

 Quit:  
   
END
GO
