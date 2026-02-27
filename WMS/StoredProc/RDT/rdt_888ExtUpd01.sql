SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdt_888ExtUpd01                                        */
/* Copyright      : Maersk WMS                                             */
/* Customer       : PAGE Inida                                             */
/*                                                                         */
/* Date       Rev    Author     Purposes                                   */
/* 2025-10-16 1.0    Jackc      FCR-8271 Created                           */
/***************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdt_888ExtUpd01]
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR(  3)
   ,@nStep           INT
   ,@nInputKey       INT
   ,@cFacility       NVARCHAR( 5) 
   ,@cStorerKey      NVARCHAR( 15)
   ,@cReceiptKey     NVARCHAR( 10)
   ,@cReceiptLineNo  NVARCHAR( 5)
   ,@cLOC            NVARCHAR( 10)
   ,@cID             NVARCHAR( 18)
   ,@cLottable01     NVARCHAR( 18)
   ,@cLottable02     NVARCHAR( 18)
   ,@cLottable03     NVARCHAR( 18)
   ,@dLottable04     DATETIME
   ,@dLottable05     DATETIME
   ,@cUCC            NVARCHAR( 20)
   ,@cSKU            NVARCHAR( 20)
   ,@nQTY            INT
   ,@cStatus         NVARCHAR( 10) 
   ,@cASNStatus      NVARCHAR( 10) 
   ,@cNewQty         NVARCHAR(  5)
   ,@cOption         NVARCHAR( 1)
   ,@nErrNo          INT            OUTPUT
   ,@cErrMsg         NVARCHAR( 20)  OUTPUT 
AS
BEGIN
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag     INT = 0

   DECLARE @nTranCount     INT
   DECLARE @cErrMsg1       NVARCHAR(125)
   DECLARE @cErrMsg2       NVARCHAR(125)
   DECLARE @cErrMsg3       NVARCHAR(125)
   DECLARE @cSerialNoKey   NVARCHAR( 10)
   DECLARE @cSourceKey     NVARCHAR( 20)
   DECLARE @cItrnKey       NVARCHAR( 10)
   DECLARE @nRowCount      INT  

   IF @nFunc = 888
   BEGIN
      IF @nStep = 7  -- Unreceiving UCC 
      BEGIN
         IF @nInputKey = 1 AND @cOption = '1'
         BEGIN
            IF EXISTS (SELECT 1 FROM dbo.ReceiptSerialNo WITH (NOLOCK) WHERE UCCNo = @cUCC)
            BEGIN

               DECLARE @curDel         CURSOR
               DECLARE @nRcptSNKey     BIGINT
               DECLARE @cSerialNo      NVARCHAR(50)

               SET @curDel = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
               SELECT 
                  ReceiptSerialNoKey,
                  SerialNo
               FROM dbo.ReceiptSerialNo WITH (NOLOCK)
               WHERE StorerKey = @cStorerkey
               AND   ReceiptKey = @cReceiptKey
               AND   UCCNo = @cUCC

               SET @nTranCount = @@TRANCOUNT

               IF @nTranCount = 0
                  BEGIN TRAN
               ELSE
                  SAVE TRAN rdt_888ExtUpd01

               OPEN @curDel
               FETCH NEXT FROM @curDel INTO @nRcptSNKey, @cSerialNo
               WHILE @@FETCH_STATUS = 0
               BEGIN
                  SET @nRowCount = 0

                  BEGIN TRY
                     DELETE FROM dbo.ReceiptSerialNo 
                     WHERE ReceiptSerialNoKey = @nRcptSNKey
                  END TRY
                  BEGIN CATCH
                     IF @nTranCount > 0 AND XACT_STATE() <> -1
                        ROLLBACK TRAN rdt_888ExtUpd01
                     ELSE
                        ROLLBACK TRAN

                     SET @cErrMsg1 = '249151 Failed to delete ReceiptSerialNo'
                     SET @cErrMsg2 = 'UCC: ' + @cUCC
                     SET @cErrMsg3 = 'Retry from the web'
                     EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3

                     GOTO Quit
                  END CATCH

                  SELECT @cSerialNoKey = SerialNoKey
                  FROM dbo.SerialNO WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND SerialNo = @cSerialNo

                  SET @nRowCount = @@ROWCOUNT

                  IF @nRowCount > 0
                  BEGIN
                     BEGIN TRY
                        DELETE dbo.SerialNo WHERE SerialNoKey = @cSerialNoKey
                     END TRY
                     BEGIN CATCH
                        IF @nTranCount > 0 AND XACT_STATE() <> -1
                           ROLLBACK TRAN rdt_888ExtUpd01
                        ELSE
                           ROLLBACK TRAN

                        SET @cErrMsg1 = '249152 Failed to delete SerialNo'
                        SET @cErrMsg2 = 'SerialNo: ' + @cUCC
                        SET @cErrMsg3 = 'Retry from the web'
                        EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                        GOTO Quit
                     END CATCH

                     SET @cSourceKey = @cReceiptKey + @cReceiptLineNo

                     SELECT @cItrnKey = ItrnKey FROM dbo.Itrn WITH (NOLOCK) 
                     WHERE SourceKey = @cSourceKey
                        AND TranType = 'AJ'

                     IF @nDebugFlag = 1
                        INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Col1, Col2, Col3, Col4, Col5)  
                        VALUES('888ExtUpd01', GETDATE(), @cSourceKey, @cSerialNo, @cItrnKey, '', 'GetItrnKey') 

                     IF ISNULL(@cItrnKey, '') <> ''
                     BEGIN
                        BEGIN TRY
                           INSERT INTO ITrnSerialNo (ITrnKey, TranType, StorerKey, SKU, SerialNo, QTY, SourceKey, SourceType
                                          ,Lot, Loc, ID
                                          ,Channel, Channel_ID, UCCNo
                                          )
                           SELECT @cItrnKey, 'AJ', StorerKey, SKU, SerialNo, -Qty, @cSourceKey, 'rdt_888ExtUpd01'
                                 ,Lot, Loc, ID
                                 ,'', '', @cUCC
                           FROM dbo.SerialNO WITH (NOLOCK)
                           WHERE SerialNoKey = @cSerialNoKey
                        END TRY
                        BEGIN CATCH
                           IF @nDebugFlag = 1
                              INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Col1, Col2, Col3, Col4, Col5)  
                              VALUES('888ExtUpd01', GETDATE(), @cSourceKey, @cSerialNo, '', '', 'InsItrnSNFail') 
                        END CATCH
                     END

                  END

                  FETCH NEXT FROM @curDel INTO @nRcptSNKey, @cSerialNo
               END               

               COMMIT TRAN

               GOTO Quit
            END
         END
      END --st1
   END

   GOTO Quit

   RollBackTran:
      IF @nTranCount > 0 AND XACT_STATE() <> -1
         ROLLBACK TRAN rdt_888ExtUpd01
      ELSE
         ROLLBACK TRAN

   Quit:
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
         COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_888ExtUpd01 TO NSQL
GO