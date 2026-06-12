/************************************************************************/
/* Store procedure: rdt_1837ExtUpd01_CSC                                */
/*                                                                      */
/* Purpose:       Merging DropIDs after picking                         */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-03-10 1.0  TTW017     Copied from rdt_1837ExtUpd01_JCB          */
/************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_1837ExtUpd01_CSC] (
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

   DECLARE @cDocType       NVARCHAR( 10)
         , @nMOBRECScn     INT

   SELECT @nMOBRECScn = Scn
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SELECT @cDocType = O.DocType
   FROM Pickdetail PD WITH (NOLOCK)
   JOIN ORDERS O WITH (NOLOCK) ON PD.Orderkey = O.Orderkey AND PD.Storerkey = O.Storerkey
   WHERE PD.Storerkey = @cStorerKey
      AND PD.DropID = @cCartonID

   IF @nInputKey = 1 -- Enter
   BEGIN
      IF @nMOBRECScn = 5591 AND @cDocType = 'E' -- Enter New Pallet ID
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
