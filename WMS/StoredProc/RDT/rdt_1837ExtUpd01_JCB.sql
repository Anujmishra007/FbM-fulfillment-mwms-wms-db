SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Store procedure: rdt_1837ExtUpd01_JCB                                */  
/*                                                                      */  
/* Purpose:       Merging DropIDs after picking                         */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2026-01-21 1.0  TPT001     Created                                   */  
/************************************************************************/  
CREATE OR ALTER PROC [RDT].[rdt_1837ExtUpd01_JCB] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cCartonID      NVARCHAR( 20), 
   @cPalletID      NVARCHAR( 20), 
   @cLoadKey       NVARCHAR( 10), 
   @cLoc           NVARCHAR( 10), 
   @cOption        NVARCHAR( 1), 
   @tExtUpdate     VariableTable READONLY,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cOrderKey      NVARCHAR( 10)
   --DECLARE @cPickSlipNo    NVARCHAR( 10)
   
   IF @nInputKey = 1 -- Enter
   BEGIN
      IF @nStep = 2 -- Enter New Pallet ID
      BEGIN
            UPDATE dbo.PICKDETAIL
            SET CaseID=Dropid
            WHERE Dropid=@cCartonID
            IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 1862024
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PickDetail update fail
                     GOTO Quit
                  END
             UPDATE dbo.PICKDETAIL
             SET DropID=ID
             WHERE Dropid=@cCartonID
             IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 1862024
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PickDetail update fail
                     GOTO Quit
                  END
      END
   END
   Quit:

END
GO
GRANT EXECUTE ON rdt_1837ExtUpd01_JCB TO NSQL

GO
