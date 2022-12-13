SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1654ExtUpd01                                    */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Called from: rdtfnc_TrackNo_SortToPallet_CloseLane                   */
/*                                                                      */
/* Purpose: Insert into Transmitlog2 table                              */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2022-10-04  1.0  James    WMS-20667. Created                         */
/* 2022-12-09  1.1  SYChua   JSM-116367 Fix to trigger at step 5 (SY01) */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1654ExtUpd01] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cLane          NVARCHAR( 20),
   @cOption        NVARCHAR( 1),
   @tExtUpdateVar  VariableTable READONLY,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @bSuccess    INT
   DECLARE @cMBOLKey    NVARCHAR( 10)

   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN
   SAVE TRAN rdt_1654ExtUpd01

   --IF @nStep = 2      --SY01
   IF @nStep IN (2, 5)  --SY01
   BEGIN
      IF @nInputKey = 1
      BEGIN
       IF @cOption = '1'
       BEGIN
        SELECT @cMBOLKey = MBOLKey
        FROM dbo.MBOL WITH (NOLOCK)
        WHERE ExternMbolKey= @cLane

            -- Insert transmitlog2 here
            EXECUTE ispGenTransmitLog2
               @c_TableName      = 'WSCRSOCLOSEILS',
               @c_Key1           = @cMBOLKey,
               @c_Key2           = '',
               @c_Key3           = @cStorerkey,
               @c_TransmitBatch  = '',
               @b_Success        = @bSuccess   OUTPUT,
               @n_err            = @nErrNo     OUTPUT,
               @c_errmsg         = @cErrMsg    OUTPUT

            IF @bSuccess <> 1
            BEGIN
               SET @nErrNo = 192501
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Insert TL2 Err
               GOTO RollBackTran
            END
       END
      END
   END

   GOTO Quit

   RollBackTran:
         ROLLBACK TRAN rdt_1654ExtUpd01
   Quit:
      WHILE @@TRANCOUNT > @nTranCount
         COMMIT TRAN

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1654ExtUpd01 TO NSQL
GO