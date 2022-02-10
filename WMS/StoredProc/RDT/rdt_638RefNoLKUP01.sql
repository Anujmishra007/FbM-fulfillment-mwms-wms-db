IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[RDT].[rdt_638RefNoLKUP01]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_638RefNoLKUP01]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_638RefNoLKUP01                                        */
/* Copyright      : LF Logistics                                              */
/*                                                                            */
/* Purpose: Lookup RefNo by multiple fields                                   */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 12-03-2020   YeeKung   1.0   WMS-12465 Created                             */
/* 13-07-2020   Ung       1.1   WMS-13555 Change params                       */
/* 28-08-2020   Ung       1.2   WMS-14796 Add TrackingNo                      */
/******************************************************************************/

CREATE PROCEDURE rdt.rdt_638RefNoLKUP01
    @nMobile      INT
   ,@nFunc        INT
   ,@cLangCode    NVARCHAR( 3)
   ,@nStep        INT
   ,@nInputKey    INT
   ,@cFacility    NVARCHAR( 5)
   ,@cStorerKey   NVARCHAR( 15)
   ,@cSKU         NVARCHAR( 20)  -- Optional, lookup by RefNo + SKU
   ,@cRefNo       NVARCHAR( 20)  OUTPUT
   ,@cReceiptKey  NVARCHAR( 10)  OUTPUT
   ,@nBalQTY      INT            OUTPUT
   ,@nErrNo       INT            OUTPUT
   ,@cErrMsg      NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nRowCount INT

   IF @nFunc = 638 -- ECOM return
   BEGIN
      IF @cReceiptKey = ''
      BEGIN
         SELECT @cReceiptKey = ReceiptKey
         FROM dbo.Receipt WITH (NOLOCK)
         WHERE Facility = @cFacility
            AND StorerKey = @cStorerKey
            AND Status <> '9'
            AND ASNStatus <> 'CANC'
            AND ReceiptGroup = 'ECOM'
            AND TrackingNo = @cRefNo
         SELECT @nRowCount = @@ROWCOUNT
      END
      
      IF @cReceiptKey = ''
      BEGIN
         SELECT @cReceiptKey = ReceiptKey
         FROM dbo.Receipt WITH (NOLOCK)
         WHERE Facility = @cFacility
            AND StorerKey = @cStorerKey
            AND Status <> '9'
            AND ASNStatus <> 'CANC'
            AND  ReceiptGroup= 'ECOM'
            AND userdefine09 = @cRefNo
         SELECT @nRowCount = @@ROWCOUNT
      END
      
      IF @cReceiptKey = ''
      BEGIN
         SELECT @cReceiptKey = ReceiptKey
         FROM dbo.Receipt WITH (NOLOCK)
         WHERE Facility = @cFacility
            AND StorerKey = @cStorerKey
            AND Status <> '9'
            AND ASNStatus <> 'CANC'
            AND  ReceiptGroup= 'ECOM'
            AND userdefine02 = @cRefNo
         SELECT @nRowCount = @@ROWCOUNT
      END

      -- Check RefNo in ASN
      IF @nRowCount = 0
      BEGIN
         SET @nErrNo = 149551
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --RefNo NotInASN
         GOTO Quit
      END

      -- Check RefNo in ASN
      IF @nRowCount > 1
      BEGIN
         SET @nErrNo = 149552
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --RefNo MultiASN
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
GRANT EXEC ON RDT.rdt_638RefNoLKUP01 TO NSQL
GO
