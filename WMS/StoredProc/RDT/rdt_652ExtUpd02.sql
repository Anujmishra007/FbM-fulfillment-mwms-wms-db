
/***************************************************************************/
/* Store procedure: rdt_652ExtUpd02                                        */
/* Copyright      : Maersk                                                 */
/* Customer       : Cajamar                                                */
/*                                                                         */
/* Date        Rev  Author       Purposes                                  */
/* 2025-11-13  1.0  Jackc        FCR-8674 Created                          */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_652ExtUpd02](
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT,
   @nInputKey           INT,
   @cStorerKey          NVARCHAR( 15),
   @cFacility           NVARCHAR( 5),
   @cContainerNo        NVARCHAR( 20), 
   @cAppointmentNo      NVARCHAR( 20), --receiptkey
   @cMenuOption         NVARCHAR( 10),
   @cActionType         NVARCHAR( 10),
   @cRefNo1             NVARCHAR( 10),
   @cDefaultOption      NVARCHAR( 10),
   @cDefaultCursor      NVARCHAR( 10),
   @cActivityStatus     NVARCHAR( 20),
   @nErrNo              INT           OUTPUT,
   @cErrMsg             NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cReceiptKey    NVARCHAR(10)
   DECLARE @nTranCount     INT
   DECLARE @bSuccess       INT

   IF @nFunc = 652
   BEGIN
      IF @nStep = 2
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @cMenuOption = '1'
            BEGIN
               DECLARE @tReceiptList TABLE 
               (
                  ID          INT IDENTITY,
                  ReceiptKey  NVARCHAR(10) NOT NULL
               )

               DECLARE @nLoopIndex  INT

               IF ISNULL(@cContainerNo, '') <> ''
                  INSERT INTO @tReceiptList
                  SELECT ReceiptKey
                  FROM dbo.Receipt WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND ContainerKey = @cContainerNo
                  AND ASNStatus <> '9'
               ELSE IF ISNULL(@cAppointmentNo, '') <> ''
                  INSERT INTO @tReceiptList
                  SELECT ReceiptKey
                  FROM dbo.Receipt WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND ReceiptKey = @cAppointmentNo
                  AND ASNStatus <> '9'
               ELSE
                  GOTO Quit

               IF EXISTS (SELECT 1 FROM @tReceiptList)
               BEGIN

                  SET @nLoopIndex = -1

                  SET @nTranCount = @@TRANCOUNT
                  BEGIN TRAN  -- Begin our own transaction
                  SAVE TRAN rdt_652ExtUpd02 -- For rollback or commit only our own transaction

                  WHILE 1 = 1
                  BEGIN
                     SELECT TOP 1 
                        @cReceiptKey = ReceiptKey,
                        @nLoopIndex = id
                     FROM @tReceiptList
                        WHERE id > @nLoopIndex
                     ORDER BY id

                     IF @@ROWCOUNT = 0
                        BREAK

                     EXECUTE ispGenTransmitLog2 
                     @c_TableName      = 'WSASNRFID', 
                     @c_Key1           = @cReceiptKey, 
                     @c_Key2           = '', 
                     @c_Key3           = @cStorerkey, 
                     @c_TransmitBatch  = '', 
                     @b_Success        = @bSuccess   OUTPUT,    
                     @n_err            = @nErrNo     OUTPUT,    
                     @c_errmsg         = @cErrMsg    OUTPUT

                     IF @nErrNo <> 0 OR @bSuccess <> 1
                        GOTO RollbackTran
                  END -- end loop

                  COMMIT TRAN
               END

               GOTO Quit
            END --optin1
         END
      END --st2
   END --652

   RollBackTran:
      IF @nTranCount > 0 AND XACT_STATE() <> -1
         ROLLBACK TRAN rdt_652ExtUpd02
      ELSE
         ROLLBACK TRAN

   Quit:
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
         COMMIT TRAN

END
GO

GRANT EXECUTE ON rdt.rdt_652ExtUpd02 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

