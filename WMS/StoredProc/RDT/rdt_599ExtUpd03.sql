SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_599ExtUpd03                                     */
/* Copyright      : Maersk                                              */
/* Customer       : PAGE IND                                            */
/*                                                                      */
/* Purpose: Send picked interface to WCS                                */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2025-10-14   NickT     1.0   FCR-8280 Created                        */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_599ExtUpd03
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cReceiptKey    NVARCHAR( 10),
   @cID            NVARCHAR( 18),
   @cSKU           NVARCHAR( 20),
   @nQty           INT,
   @cLottable01    NVARCHAR( 18),
   @cLottable02    NVARCHAR( 18),
   @cLottable03    NVARCHAR( 18),
   @dLottable04    DATETIME,
   @dLottable05    DATETIME,
   @cLottable06    NVARCHAR( 30),
   @cLottable07    NVARCHAR( 30),
   @cLottable08    NVARCHAR( 30),
   @cLottable09    NVARCHAR( 30),
   @cLottable10    NVARCHAR( 30),
   @cLottable11    NVARCHAR( 30),
   @cLottable12    NVARCHAR( 30),
   @dLottable13    DATETIME,
   @dLottable14    DATETIME,
   @dLottable15    DATETIME,
   @cOption        NVARCHAR( 1),
   @tExtUpdate     VariableTable READONLY,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @tReceiptSerialNo TABLE
   (
      ReceiptSerialNoKey  BIGINT PRIMARY KEY
   )

   DECLARE @tSerialNo TABLE
   (
      SerialNoKey NVARCHAR(10) PRIMARY KEY
   )

   DECLARE @tReceiptDetail TABLE
   (
      ReceiptKey           NVARCHAR(10),
      ReceiptLineNumber    NVARCHAR(5),
      PRIMARY KEY CLUSTERED (ReceiptKey, ReceiptLineNumber)
   )

   DECLARE @nTranCount        INT
   SELECT @nTranCount = @@TRANCOUNT

   BEGIN TRAN
   SAVE TRAN rdt_599ExtUpd03

   IF @nFunc = 599
   BEGIN
      IF @nStep = 4
      BEGIN
         IF @nInputKey = 1
         BEGIN
            DELETE FROM @tReceiptDetail

            INSERT INTO @tReceiptDetail (ReceiptKey, ReceiptLineNumber)
            SELECT RD.ReceiptKey, RD.ReceiptLineNumber
            FROM dbo.ReceiptDetail RD WITH(NOLOCK)
            INNER JOIN dbo.Receipt R WITH(NOLOCK) ON RD.StorerKey = R.StorerKey AND RD.ReceiptKey = R.ReceiptKey
            WHERE RD.ReceiptKey = @cReceiptKey 
               AND RD.StorerKey = @cStorerKey
               AND RD.SKU = IIF( @cOption = '1', RD.SKU, @cSKU)
               AND RD.BeforeReceivedQty = 0
               AND RD.QtyReceived = 0
               AND RD.QtyAdjusted = 0
               AND RD.FinalizeFlag = 'N'
               AND R.Status = '0'
               AND R.ASNStatus = '0'

            BEGIN TRY
               UPDATE RD
                  SET ToId = '',
                  EditDate = GetDate(),
                  EditWho = SUSER_SNAME()
               FROM dbo.ReceiptDetail RD WITH(ROWLOCK)
               INNER JOIN @tReceiptDetail TRD ON TRD.ReceiptKey = RD.ReceiptKey AND TRD.ReceiptLineNumber = RD.ReceiptLineNumber
            END TRY
            BEGIN CATCH
               SET @nErrNo = 248953
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update  Receipt Detail Failed
               GOTO ROLLBACK_TRAN
            END CATCH
            
            DELETE FROM @tReceiptSerialNo

            INSERT INTO @tReceiptSerialNo (ReceiptSerialNoKey)
            SELECT DISTINCT RSN.ReceiptSerialNoKey
            FROM dbo.ReceiptSerialNo RSN WITH(NOLOCK)
            INNER JOIN dbo.ReceiptDetail RD WITH(NOLOCK) ON RSN.StorerKey = RD.StorerKey AND RSN.ReceiptKey = RD.ReceiptKey AND RSN.ReceiptLineNumber = RD.ReceiptLineNumber
            INNER JOIN dbo.Receipt R WITH(NOLOCK) ON RD.StorerKey = R.StorerKey AND RD.ReceiptKey = R.ReceiptKey
            WHERE RD.ReceiptKey = @cReceiptKey 
               AND RD.StorerKey = @cStorerKey
               AND RD.SKU = IIF( @cOption = '1', RD.SKU, @cSKU)
               AND RD.BeforeReceivedQty = 0
               AND RD.QtyReceived = 0
               AND RD.QtyAdjusted = 0
               AND RD.FinalizeFlag = 'N'
               AND R.Status = '0'
               AND R.ASNStatus = '0'

            BEGIN TRY
               DELETE RSN
               FROM dbo.ReceiptSerialNo RSN WITH(ROWLOCK)
               INNER JOIN @tReceiptSerialNo TRSN ON RSN.ReceiptSerialNoKey = TRSN.ReceiptSerialNoKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 248951
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Delete ReceiptSerialNo Failed
               GOTO ROLLBACK_TRAN
            END CATCH

            INSERT INTO @tSerialNo (SerialNoKey)
            SELECT DISTINCT SerialNoKey
            FROM dbo.SerialNo SN WITH(NOLOCK)
            INNER JOIN dbo.ReceiptDetail RD WITH(NOLOCK) ON SN.StorerKey = RD.StorerKey AND SN.ID = RD.ToID AND SN.SKU = RD.SKU
            INNER JOIN dbo.Receipt R WITH(NOLOCK) ON RD.StorerKey = R.StorerKey AND RD.ReceiptKey = R.ReceiptKey
            WHERE RD.ReceiptKey = @cReceiptKey 
               AND RD.StorerKey = @cStorerKey
               AND RD.SKU = IIF( @cOption = '1', RD.SKU, @cSKU)
               AND RD.BeforeReceivedQty = 0
               AND RD.QtyReceived = 0
               AND RD.QtyAdjusted = 0
               AND RD.FinalizeFlag = 'N'
               AND R.Status = '0'
               AND R.ASNStatus = '0'

            BEGIN TRY
               DELETE SN
               FROM dbo.SerialNo SN WITH(ROWLOCK)
               INNER JOIN @tSerialNo TSN ON SN.SerialNoKey = TSN.SerialNoKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 248952
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Delete SerialNo Failed
               GOTO ROLLBACK_TRAN
            END CATCH

         END
      END
   END

   GOTO Quit

   ROLLBACK_TRAN:
      ROLLBACK TRAN rdt_599ExtUpd03
   Quit:
      WHILE @@TRANCOUNT > @nTranCount
         COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_599ExtUpd03] TO NSQL
GO
