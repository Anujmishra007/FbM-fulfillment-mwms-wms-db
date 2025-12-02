SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_598DecodeSN01                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Decode comma delimeted serial no                            */
/*                                                                      */
/* Date        Rev  Author       Purposes                               */
/* 09-07-2025  1.0  YeeKung      FCR-5719 Created                       */
/* 02-12-2025  1.1  YeeKung      FCR-9540 Add Dynamic delimeter(yeekung01)*/
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_598DecodeSN01]
   @nMobile     INT,
   @nFunc       INT,
   @cLangCode   NVARCHAR( 3),
   @nStep       INT,
   @nInputKey   INT,
   @cStorerKey  NVARCHAR( 15),
   @cFacility   NVARCHAR( 5),
   @cSKU        NVARCHAR( 20),
   @cBarcode    NVARCHAR( MAX),
   @cSerialNo   NVARCHAR( 30)  OUTPUT,
   @nSerialQTY  INT            OUTPUT,
   @nBulkSNO    INT            OUTPUT,
   @nErrNo      INT            OUTPUT,
   @cErrMsg     NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nReceiveSerialNoLogKey INT
   DECLARE @nRowCount INT
   DECLARE @cShort NVARCHAR(30)
   DECLARE @tCurTable  TABLE ( --yeekung01
      Delimiter NVARCHAR( 10)
   )
   DECLARE @curDelimeter CURSOR --yeekung01

   SELECT TOP 1
      @nReceiveSerialNoLogKey = ReceiveSerialNoLogKey
   FROM rdt.rdtReceiveSerialNoLog WITH (NOLOCK)
   WHERE Mobile = @nMobile
      AND Func = @nFunc

   WHILE @@ROWCOUNT > 0
   BEGIN
      DELETE rdt.rdtReceiveSerialNoLog
      WHERE ReceiveSerialNoLogKey = @nReceiveSerialNoLogKey

      SELECT TOP 1
         @nReceiveSerialNoLogKey = ReceiveSerialNoLogKey
      FROM rdt.rdtReceiveSerialNoLog WITH (NOLOCK)
      WHERE Mobile = @nMobile
         AND Func = @nFunc
   END

   -- Get SKU info
   DECLARE @cSKUGroup NVARCHAR( 10)
   SELECT @cSKUGroup = SKUGroup FROM dbo.SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU

   -- Get decode info
   DECLARE @cDelimiter NVARCHAR( 1) = ''
   DECLARE @cLength NVARCHAR( 250) = ''
   DECLARE @nLength INT
   SELECT
      @cShort = ISNULL( Short, ''), 
      @cLength = ISNULL( Long, '')
   FROM dbo.CodeLKUP WITH (NOLOCK)
   WHERE ListName = 'DecodeSN'
      AND StorerKey = @cStorerKey
      AND Code = @cSKUGroup


   IF @cDelimiter <> '' --yeekung01
   BEGIN
      INSERT INTO @tCurTable (Delimiter)
      SELECT ColValue
      FROM dbo.fnc_DelimSplit (',', @cShort)
      
      -- Open cursor

      SET @curDelimeter = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
      SELECT
         Delimiter
      FROM @tCurTable 
      OPEN @curDelimeter 

      FETCH NEXT FROM @curDelimeter INTO @cDelimiter
      WHILE @@FETCH_STATUS = 0
      BEGIN
         IF CHARINDEX(@cDelimiter, @cBarcode) <> 0
		   BEGIN
            IF @cDelimiter = ';'
            BEGIN
               INSERT INTO rdt.rdtReceiveSerialNoLog (Mobile, Func, StorerKey, SKU, SerialNo, QTY)
               SELECT TOP 1 @nMobile, @nFunc, @cStorerKey, @cSKU, ColValue, 1
               FROM dbo.fnc_DelimSplit (@cDelimiter, @cBarcode)
               WHERE ColValue <> ''
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 241601
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS Log Fail
                  GOTO Quit
               END
            end 
            ELSE
            BEGIN
               INSERT INTO rdt.rdtReceiveSerialNoLog (Mobile, Func, StorerKey, SKU, SerialNo, QTY)
               SELECT @nMobile, @nFunc, @cStorerKey, @cSKU, ColValue, 1
               FROM dbo.fnc_DelimSplit (@cDelimiter, @cBarcode)
               WHERE ColValue <> ''
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 241606
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS Log Fail
                  GOTO Quit
               END
            END
         END

         FETCH NEXT FROM @curDelimeter INTO @cDelimiter
      END
      CLOSE @curDelimeter
      DEALLOCATE @curDelimeter
   END
   ELSE IF ISNULL(@cLength,'') <> ''
   BEGIN
      SET @nLength = TRY_CAST( @cLength AS INT)

      -- Check length setup
      IF @nLength IS NULL
      BEGIN
         SET @nErrNo = 241602
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Bad SNO setup
         GOTO Quit
      END

      -- Check length
      IF @nLength NOT BETWEEN 1 AND 30
      BEGIN
         SET @nErrNo = 241603
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Bad SNO setup
         GOTO Quit
      END

      IF LEN(@cBarcode)% @nLength <> 0
      BEGIN
         SET @nErrNo = 241605
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LengthNotMat
         GOTO Quit
      END

      -- Loop 
      DECLARE @cSubString NVARCHAR( 30)
      WHILE @cBarcode <> ''
      BEGIN
         SET @cSubString = LEFT( @cBarcode, @nLength)
         SET @cBarcode = SUBSTRING( @cBarcode, @nLength + 1, LEN( @cBarcode))

         INSERT INTO rdt.rdtReceiveSerialNoLog (Mobile, Func, StorerKey, SKU, SerialNo, QTY)
         VALUES (@nMobile, @nFunc, @cStorerKey, @cSKU, @cSubString, 1)
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 241604
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS Log Fail
            GOTO Quit
         END
      END

      IF (SELECT COUNT(1)
         FROM rdt.rdtReceiveSerialNoLog WITH (NOLOCK)
         WHERE Mobile = @nMobile
            AND Func = @nFunc) > 1
      BEGIN
         SET @nBulkSNO = 1
      END
      ELSE 
      BEGIN
         SET @cSerialNo = @cBarcode
         
         SET @nBulkSNO = 0
      END
   END

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_598DecodeSN01] TO [NSQL]
GO