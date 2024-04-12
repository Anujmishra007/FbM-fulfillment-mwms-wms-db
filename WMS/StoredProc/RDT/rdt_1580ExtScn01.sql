SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1580ExtScn01                                     */
/* Copyright      :                                                     */
/*                                                                      */
/* Purpose:       For Unilever                                          */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2024-03-13 1.0  Dennis   Draft                                       */
/*                                                                      */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1580ExtScn01] (
	@nMobile      INT,           
	@nFunc        INT,           
	@cLangCode    NVARCHAR( 3),  
	@nStep INT,           
	@nScn  INT,           
	@nInputKey    INT,           
	@cFacility    NVARCHAR( 5),  
	@cStorerKey   NVARCHAR( 15), 

	@cSuggLOC     NVARCHAR( 10) OUTPUT, 
	@cLOC         NVARCHAR( 20) OUTPUT, 
	@cID          NVARCHAR( 20) OUTPUT, 
	@cSKU         NVARCHAR( 20) OUTPUT, 
   @cReceiptKey  NVARCHAR( 10), 
   @cPOKey       NVARCHAR( 10),
   @cReasonCode  NVARCHAR( 10),
   @cReceiptLineNumber  NVARCHAR( 5),
   @cPalletType  NVARCHAR( 10),  

   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  @cLottable01 NVARCHAR( 18) OUTPUT,  
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  @cLottable02 NVARCHAR( 18) OUTPUT,  
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  @cLottable03 NVARCHAR( 18) OUTPUT,  
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,  
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,   
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,   
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  
	@nAction      INT, --0 Jump Screen, 1 Validation(pass through all input fields), 2 Update, 3 Prepare output fields .....
	@nAfterScn    INT OUTPUT, @nAfterStep    INT OUTPUT, 
   @nErrNo             INT            OUTPUT, 
   @cErrMsg            NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   DECLARE @nShelfLife FLOAT
   DECLARE @cResultCode NVARCHAR( 60)
   DECLARE
   @nRowCount            INT,
   @cPalletTypeInUse     NVARCHAR( 5),
   @nCheckDigit          INT,
   @cActLoc              NVARCHAR( 20),
   @cPalletTypeSave      NVARCHAR( 10)

   IF @nAction = 1 --Validate fields
   BEGIN
	   IF @nFunc = 1580 
	   BEGIN
         IF @nInputKey = 1
         BEGIN
            IF( @nStep = 99 )
            BEGIN
               IF (ISNULL( rdt.RDTGetConfig( @nFunc, 'ValidatePalletType', @cStorerKey),'0') != '0')
               BEGIN
                  SELECT 
                  @cPalletTypeInUse = PalletTypeInUse
                  FROM dbo.PalletTypeMaster WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                     AND Facility = @cFacility
                     AND PalletType = @cPalletType

                  IF @@ROWCOUNT = 0
                  BEGIN
                     SET @nErrNo = 212601
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --212601Pallet Type Not Configured
                     GOTO Quit
                  END

                  IF @cPalletTypeInUse != 'Y'
                  BEGIN
                     SET @nErrNo = 212602
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --212602Pallet Type Not In Use
                     GOTO Quit
                  END

                  SET @cPalletTypeSave = @cPalletType
               END
            END
            IF ( @nStep = 2 )
            BEGIN

               IF ISNULL(rdt.RDTGetConfig( 0, 'ReceiveDefaultToLoc', @cStorerKey),'') = @cLOC
                  GOTO QUIT

               SELECT
                  @nCheckDigit = CheckDigitLengthForLocation
               FROM dbo.FACILITY WITH (NOLOCK)
               WHERE facility = @cFacility

               IF @nCheckDigit > 0
               BEGIN
                  SELECT @cActLoc = loc 
                  FROM dbo.LOC WITH (NOLOCK)
                  WHERE Facility = @cFacility AND CONCAT(LOC,LOCCHECKDIGIT) = @cLOC
                  SET @nRowCount = @@ROWCOUNT
                  IF @nRowCount > 1
                  BEGIN
                     SET @nErrNo = 212603
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --212603Unique location not identified
                     GOTO Quit
                  END
                  ELSE IF @nRowCount = 0
                  BEGIN
                     SET @nErrNo = 212604
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --212604Loc Not Found
                     GOTO Quit
                  END
                  SET @nAfterStep = 3
                  SET @cLOC = @cActLoc
                  GOTO QUIT
               END
            END
         END

		END
      GOTO Quit
	END
   IF @nAction = 2 --Update
   BEGIN
      IF @nFunc = 1580 
	   BEGIN
         IF @nInputKey = 1
         BEGIN
            IF( @nStep = 1 )
            BEGIN
               IF @cLOC != ''
               BEGIN
                  SELECT
                  @nCheckDigit = CheckDigitLengthForLocation
                  FROM dbo.FACILITY WITH (NOLOCK)
                  WHERE facility = @cFacility

                  IF @nCheckDigit > 0
                  BEGIN
                     SELECT @cActLoc = CONCAT(LOC,LOCCHECKDIGIT) 
                     FROM dbo.LOC WITH (NOLOCK)
                     WHERE Facility = @cFacility AND LOC = @cLOC

                     SET @nRowCount = @@ROWCOUNT
                     IF @nRowCount > 0
                     BEGIN
                        SET @cLOC = @cActLoc
                        GOTO QUIT
                     END
                  END
               END
            END
         END
         ELSE IF @nInputKey = 0
         BEGIN
            IF( @nStep = 3 )
            BEGIN
               IF @cLOC != ''
               BEGIN
                  SELECT
                  @nCheckDigit = CheckDigitLengthForLocation
                  FROM dbo.FACILITY WITH (NOLOCK)
                  WHERE facility = @cFacility

                  IF @nCheckDigit > 0
                  BEGIN
                     SELECT @cActLoc = CONCAT(LOC,LOCCHECKDIGIT) 
                     FROM dbo.LOC WITH (NOLOCK)
                     WHERE Facility = @cFacility AND LOC = @cLOC

                     SET @nRowCount = @@ROWCOUNT
                     IF @nRowCount > 0
                     BEGIN
                        SET @cLOC = @cActLoc
                        GOTO QUIT
                     END
                  END
               END
            END
         END
      END
   END
Exception:
   ROLLBACK TRANSACTION

Quit:
UPDATE RDT.RDTMOBREC SET
   C_String1 = @cPalletTypeSave
   WHERE Mobile = @nMobile

END; 

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON rdt.rdt_1580ExtScn01 TO NSQL 
GO