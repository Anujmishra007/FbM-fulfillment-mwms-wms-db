SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_599ExtVal02                                     */
/* Copyright: Maersk                                                    */
/* Customer: PAGE IND                                                   */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2025-10-13 1.0  NickT      FCR-8280. Created                         */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_599ExtVal02] (
   @nMobile                   INT, 
   @nFunc                     INT, 
   @cLangCode                 NVARCHAR( 3), 
   @nStep                     INT, 
   @nInputKey                 INT, 
   @cStorerkey                NVARCHAR( 15), 
   @cReceiptKey               NVARCHAR( 10), 
   @cID                       NVARCHAR( 18), 
   @cSKU                      NVARCHAR( 20), 
   @nQty                      INT, 
   @cOption                   NVARCHAR( 1), 
   @nErrNo                    INT           OUTPUT,  
   @cErrMsg                   NVARCHAR( 20) OUTPUT  
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   DECLARE @nRowCount         INT

   IF @nFunc = 599
   BEGIN
      IF @nStep = 1
      BEGIN
         IF @nInputKey = 1
         BEGIN
            DECLARE @cReceiptGroup NVARCHAR(20)

            SELECT @cReceiptGroup = ReceiptGroup
            FROM dbo.RECEIPT WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND ReceiptKey = @cReceiptKey

            IF EXISTS(SELECT 1 
                     FROM dbo.CODELKUP WITH(NOLOCK)
                     WHERE ListName = 'RECEIPTGRP'
                        AND Code = @cReceiptGroup
                        AND Code2 = CAST(@nFunc AS NVARCHAR(10))
                     )
               GOTO Quit
            ELSE
            BEGIN
               SET @nErrNo = 248751
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Receipt Group not allowed
               GOTO Quit
            END
         END
      END
      ELSE IF @nStep = 2
      BEGIN
         IF @nInputKey = 1
         BEGIN
            DECLARE 
               @cToLoc                    NVARCHAR(10),
               @nQtyAllocated             INT,
               @nQtyPicked                INT,
               @nQtyReplen                INT,
               @cInvLoc                   NVARCHAR(10),
               @cStatus                   NVARCHAR(10)

            IF TRIM(ISNULL(@cID, '')) = ''
            BEGIN
               SET @nErrNo = 248752
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ID is needed
               GOTO Quit
            END

            SELECT 
               @cToLoc = ToLoc,
               @cStatus = Status
            FROM dbo.RECEIPTDETAIL WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND ReceiptKey = @cReceiptKey
               AND ToID = @cID
            
            SELECT @nRowCount = @@ROWCOUNT

            IF @nRowCount = 0
            BEGIN
               SET @nErrNo = 248753
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ID does not exists any more
               GOTO Quit
            END

            IF @cStatus = '9'
            BEGIN
               SELECT
                  @cInvLoc = Loc,
                  @nQtyAllocated = QtyAllocated,
                  @nQtyPicked =  QtyPicked,
                  @nQtyReplen = QtyReplen
               FROM dbo.LOTXLOCXID WITH(NOLOCK)
               WHERE Loc = @cToLoc
                  AND ID = @cID

               IF @cInvLoc <> @cToLoc
               BEGIN
                  SET @nErrNo = 248754
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ID is moved
                  GOTO Quit
               END

               IF @nQtyAllocated > 0
               BEGIN
                  SET @nErrNo = 248755
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ID is allocated
                  GOTO Quit
               END

               IF @nQtyPicked > 0
               BEGIN
                  SET @nErrNo = 248756
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ID is picked
                  GOTO Quit
               END

               IF @nQtyReplen > 0
               BEGIN
                  SET @nErrNo = 248757
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ID is allocated for replenishment
                  GOTO Quit
               END
            END
         END
      END
   END
   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_599ExtVal02] TO NSQL  
GO 
