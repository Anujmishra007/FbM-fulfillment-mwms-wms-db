
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_SerialNo_HP                                     */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: HP                                                          */
/*                                                                      */
/* Date        Rev  Author       Purposes                               */
/* 21-01-2026  1.0  yeekung      FCR-9675 Created                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_SerialNo_HP]
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 3),
   @cStorerKey       NVARCHAR( 15),
   @cSKU             NVARCHAR( 20),
   @cSKUDesc         NVARCHAR( 60),
   @nQTY             INT, 
   @cType            NVARCHAR( 15), --CHECK/UPDATE
   @cDocType         NVARCHAR( 10), --ASN/SO/PACK...
   @cDocNo           NVARCHAR( 20), --ReceiptKey/OrderKey/PickSlipNo...
   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,
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
   @nMoreSNO         INT           OUTPUT,  
   @cSerialNo        NVARCHAR( 60) OUTPUT,  
   @nSerialQTY       INT           OUTPUT,
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT, 
   @nScn             INT, 
   @nBulkSNO         INT           OUTPUT, 
   @nBulkSNOQTY      INT           OUTPUT,
   @cSerialCaptureType  NVARCHAR( 1), 
   @nScan            INT           OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cContainerKey NVARCHAR(20)
   DECLARE @cReceiptKey NVARCHAR(20)
   DECLARE @cReceiptLineNumber NVARCHAR(5)
   DECLARE @curReceipt CURSOR
   DECLARE @cID		NVARCHAR (20)

   -- Check serial no tally QTY
   IF @cType = 'CHECK'
   BEGIN

      SELECT   @cContainerKey = V_String1,
               @cReceiptKey = V_ReceiptKey,
               @cID         = V_ID
      FROM RDT.RDTMOBREC (NOLOCK)
      WHERE Mobile = @nMobile


      SET @nScan = 0

      SET @curReceipt = CURSOR FOR
      SELECT      ReceiptLineNumber,
                  ReceiptKey
      FROM ReceiptDetail (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND ReceiptKey IN (  SELECT ReceiptKey
                     FROM RECEIPT (NOLOCK)
                     WHERE ContainerKey = @cContainerKey
                        AND StorerKey = @cStorerKey)
         AND SKU = @cSKU
         AND TOID = @cID
      GROUP BY ReceiptLineNumber,ReceiptKey
      OPEN @curReceipt
      FETCH NEXT FROM @curReceipt INTO @cReceiptLineNumber,@cReceiptKey
      WHILE @@FETCH_STATUS = 0
      BEGIN

         SELECT @nScan = @nScan + COUNT( DISTINCT SerialNo)
         FROM ReceiptSerialNO (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND ReceiptKey = @cReceiptKey
            AND ReceiptLineNumber = @cReceiptLineNumber
            AND SKU = @cSKU

         FETCH NEXT FROM @curReceipt INTO @cReceiptLineNumber,@cReceiptKey

      END
      
		-- Prepare next screen var
		SET @cOutField01 = @cSKU
      SET @cOutField02 = rdt.rdtFormatString( @cSKUDesc, 1, 20)  -- SKU desc 1
      SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 21, 20) -- SKU desc 2
      SET @cOutField04 = '' -- SerialNo
      SET @cOutField05 = CAST( @nScan AS NVARCHAR(5)) + '/' + CAST( @nQTY AS NVARCHAR(5)) 
      
      EXEC rdt.rdtSetFocusField @nMobile, 3 -- SerialNo

      SET @cOutField15 = CAST( @nScan AS NVARCHAR(5)) -- Save scan to hidden field

      IF @nScan > @nQTY
      BEGIN
         SET @nErrNo = 261801
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Serial no qty over
         GOTO QUIT
      END

      IF @nScan = @nQTY
         SET @nMoreSNO = 0 -- No more serial no needed
      ELSE
         SET @nMoreSNO = 1 -- Need serial no
   END
   ELSE
   BEGIN

      -- Standard serial no
      EXEC rdt.rdt_SerialNo
         @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cSKU, @cSKUDesc, @nQTY, @cType, @cDocType, @cDocNo, 
         @cInField01 OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  
         @cInField02 OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  
         @cInField03 OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  
         @cInField04 OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  
         @cInField05 OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  
         @cInField06 OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  
         @cInField07 OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  
         @cInField08 OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  
         @cInField09 OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  
         @cInField10 OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  
         @cInField11 OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  
         @cInField12 OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  
         @cInField13 OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  
         @cInField14 OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  
         @cInField15 OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  
         @nMoreSNO   OUTPUT,  @cSerialNo   OUTPUT,  @nSerialQTY   OUTPUT,  
         @nErrNo     OUTPUT,  @cErrMsg     OUTPUT,  @nScn,                
         @nBulkSNO   OUTPUT,  @nBulkSNOQTY OUTPUT,  @cSerialCaptureType,   
         @nScan      OUTPUT,  
         @nUseStandard = 1  -- Force use back standard logic, otherwise infinite loop
   END
   QUIT:
END
GO

GRANT EXECUTE ON rdt.rdt_SerialNo_HP TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO