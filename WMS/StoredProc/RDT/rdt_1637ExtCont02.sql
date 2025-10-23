SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/**************************************************************************/
/* Store procedure: rdt_1637ExtCont02                                     */
/* Copyright      : MAERSK                                                */
/* Customer       : HBDS                                                  */
/*                                                                        */
/* Purpose: Create Container record                                       */
/*                                                                        */
/* Modifications log:                                                     */
/*                                                                        */
/* Date       Rev    Author     Purposes                                  */
/* 2025-10-21 1.0.0  NickT      FCR-8619 Created                          */
/**************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1637ExtCont02] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @cFacility       NVARCHAR( 5),
   @cStorerKey      NVARCHAR( 15),
   @cContainerKey   NVARCHAR( 10) OUTPUT,
   @cMBOLKey        NVARCHAR( 10) OUTPUT,
   @cContainerNo    NVARCHAR( 20) OUTPUT,
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_NewKey    NVARCHAR( 10),
      @b_success   INT,
      @nTranCount  INT,
      @n_ErrNo     INT,
      @c_ErrMsg    NVARCHAR( 20),
      @cDefaultContainerType   NVARCHAR( 10),
      @cContainerKeyAllowBlank   NVARCHAR(10)

   SELECT @cContainerKeyAllowBlank = rdt.RDTGetConfig( @nFunc, 'ContainerKeyAllowBlank', @cStorerKey)

   IF @cContainerKeyAllowBlank <> '1' AND @cContainerKey = ''
   BEGIN
      SET @nErrNo = 249451
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ContainerKey is required
      GOTO Quit
   END

   IF @cContainerNo = ''
   BEGIN
      SET @nErrNo = 249452
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ContainerNo is required
      GOTO Quit
   END

   SET @nTranCount = @@TRANCOUNT

   BEGIN TRAN
   SAVE TRAN rdt_1637ExtCont02

   SET @c_NewKey = ''

   BEGIN TRY
      EXECUTE nspg_getkey
         'ContainerKey'  
         , 10  
         , @c_NewKey          OUTPUT
         , @b_Success         OUTPUT
         , @n_ErrNo           OUTPUT
         , @c_ErrMsg          OUTPUT
   END TRY
   BEGIN CATCH
      SET @nErrNo = 249453
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SQL Exception Occurred
      GOTO RollBackTran
   END CATCH

   IF @n_ErrNo <> 0 AND @c_ErrMsg <> ''
      GOTO RollBackTran

   IF @b_Success <> 1
   BEGIN
      SET @nErrNo = 249454
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Generate ContainerKey Failed
      GOTO RollBackTran
   END

   SET @cContainerKey = @c_NewKey
   
   SELECT @cDefaultContainerType = V_String11
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Insert new container
   BEGIN TRY
      INSERT INTO dbo.Container (ContainerKey, Status, ContainerType, BookingReference) 
      VALUES (@cContainerKey, '0', @cDefaultContainerType, @cContainerNo)
   END TRY
   BEGIN CATCH
      SET @nErrNo = 249455
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Insert Container Failed
      GOTO RollBackTran
   END CATCH


   GOTO Quit
   
   RollBackTran:
      ROLLBACK TRAN rdt_1637ExtCont02
   Quit:  
      WHILE @@TRANCOUNT > @nTranCount
         COMMIT TRAN
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  rdt.rdt_1637ExtCont02 TO NSQL
GO