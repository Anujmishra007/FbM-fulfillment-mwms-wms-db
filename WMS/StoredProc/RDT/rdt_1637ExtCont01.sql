SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO    

/************************************************************************/  
/* Store procedure: rdt_1637ExtCont01                                   */  
/* Copyright      : MAERSK                                              */  
/*                                                                      */  
/* Purpose: Create Container record                                     */  
/*                                                                      */  
/* Modifications log:                                                   */            
/*                                                                      */            
/* Date       Rev  Author     Purposes                                  */            
/* 2024-05-28 1.1  James      WMS-25441 Created                         */      
/************************************************************************/            
            
CREATE OR ALTER PROC [RDT].[rdt_1637ExtCont01] (            
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

   DECLARE @c_NewKey    NVARCHAR( 10)
   DECLARE @b_success   INT
   DECLARE @nTranCount  INT
   DECLARE @n_ErrNo     INT
   DECLARE @c_ErrMsg    NVARCHAR( 20)
   DECLARE @cDefaultContainerType   NVARCHAR( 10)

   SET @nTranCount = @@TRANCOUNT  
   BEGIN TRAN  
   SAVE TRAN rdt_1637ExtCont01  

   SELECT TOP 1 @cContainerKey = ContainerKey
   FROM dbo.CONTAINER WITH (NOLOCK)
   WHERE BookingReference = @cContainerNo
   AND   [Status] = '0'
   ORDER BY 1

   IF ISNULL( @cContainerKey, '') = ''
   BEGIN
      SET @c_NewKey = ''  
      EXECUTE nspg_getkey  
      'ContainerKey'  
      , 10  
      , @c_NewKey          OUTPUT  
      , @b_Success         OUTPUT  
      , @n_ErrNo           OUTPUT  
      , @c_ErrMsg          OUTPUT  
  
      IF @b_Success <> 1  
      BEGIN  
         SET @nErrNo = 215601  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GETKEY FAILED  
         GOTO RollBackTran  
      END  
  
      SET @cContainerKey = @c_NewKey  
      
      SELECT @cDefaultContainerType = V_String11
      FROM RDT.RDTMOBREC WITH (NOLOCK)
      WHERE Mobile = @nMobile

      -- Insert new container  
      INSERT INTO dbo.Container  
      (ContainerKey, Status, ContainerType, BookingReference) VALUES 
      (@cContainerKey, '0', @cDefaultContainerType, @cContainerNo)  
  
      IF @@ERROR <> 0  
      BEGIN  
         SET @nErrNo = 215602  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS CONT FAIL  
         GOTO RollBackTran  
      END  
   END
            
   GOTO Quit
   
   RollBackTran:  
         ROLLBACK TRAN rdt_1637ExtCont01  
   Quit:  
      WHILE @@TRANCOUNT > @nTranCount  
         COMMIT TRAN   
GO
SET QUOTED_IDENTIFIER OFF  
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  rdt.rdt_1637ExtCont01 TO NSQL
GO