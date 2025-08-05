SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1721UpdateId01                                  */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Called from: rdtfnc_Pallet_Move                                      */
/*                                                                      */
/* Purpose: Check ID                                                    */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2024-07-16  1.0  CYU027   FCR-575                                    */
/* 2025-04-01  1.1  CYU027   FCR-3837                                   */
/* 2025-07-30  1.2.0 NLT013  UWP-38609 Performance tuning               */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1721UpdateId01] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cID            NVARCHAR( 40),
   @cToLOC         NVARCHAR( 40),
   @cLocationCategory VARCHAR( 10),
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN
   DECLARE    @cDropID_Status   NVARCHAR( 10)
   DECLARE    @nTranCount       INT
   DECLARE    @cFromLOC         NVARCHAR( 40)

   DECLARE @tPickDetail TABLE 
   (
      PickDetailKey NVARCHAR(18) PRIMARY KEY
   )

   -- Get DropID status from Codelkup table because
   -- user can move pallet anywhere. Location type determine
   -- DropID status
   SELECT @cDropID_Status = ISNULL(Code, '0')
   FROM dbo.CodeLkUp WITH (NOLOCK)
   WHERE ListName = 'SHIPSTATUS'
     AND   Short = @cLocationCategory

   SET @nTranCount = @@TRANCOUNT

   BEGIN TRAN
   SAVE TRAN UPD_DROPID

   SELECT TOP 1 @cFromLOC = Loc
          FROM PalletDetail
   WHERE PalletKey = @cID

   IF @@ROWCOUNT > 0
   BEGIN
      -- Update DropID
      -- If Codelkup is not setup then use existing DropID status
      UPDATE PalletDetail WITH (ROWLOCK) SET
        [Status] = CASE WHEN ISNULL(@cDropID_Status, '') = '' THEN '0' ELSE @cDropID_Status END,
        LOC = @cToLOC,
        EditWho = 'rdt.' + sUser_sName(),
        EditDate = GETDATE()
      WHERE PalletKey = @cID
   END


   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 219304
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Upd PalletDetail fail
      GOTO RBACK
   END

--    UPDATE LOTxLOCxID
   EXECUTE rdt.rdt_Move
           @nMobile     = @nMobile,
           @cLangCode   = @cLangCode,
           @nErrNo      = @nErrNo  OUTPUT,
           @cErrMsg     = @cErrMsg OUTPUT, -- screen limitation, 20 char max
           @cSourceType = 'rdt_1721UpdateId01',
           @cStorerKey  = @cStorerKey,
           @cFacility   = @cFacility,
           @cFromLOC    = @cFromLOC,
           @cToLOC      = @cToLOC,
           @cFromID     = @cID,
           @cToID       = NULL,  -- NULL means not changing ID
           @nFunc       = @nFunc

   IF @nErrNo <> 0
   BEGIN
      SET @nErrNo = 219305
      SET @cErrMsg = @cErrMsg -- Upd LOTxLOCxID fail
      GOTO RBACK
   END

   --UPDATE PICKDETAIL
   --RDT_MOVE will not update pickdetail
   INSERT INTO @tPickDetail (PickDetailKey)
   SELECT PD.PickDetailKey
   FROM dbo.PICKDETAIL PD WITH (NOLOCK) 
   INNER JOIN dbo.PALLETDETAIL PTD WITH(NOLOCK) 
      ON PTD.CaseID IS NOT NULL
      AND PTD.CaseID = PD.CaseID
   WHERE PTD.PalletKey = @cID
   
   UPDATE PD WITH (ROWLOCK) 
   SET PD.LOC = @cToLOC
   FROM dbo.PICKDETAIL PD WITH (ROWLOCK) 
   INNER JOIN @tPickDetail TPD
      ON PD.PickDetailKey = TPD.PickDetailKey

   IF @nErrNo <> 0
   BEGIN
      SET @nErrNo = 219305
      SET @cErrMsg = @cErrMsg -- Upd LOTxLOCxID fail
      GOTO RBACK
   END

   GOTO Quit

RBACK:
   ROLLBACK TRAN UPD_DROPID
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1721UpdateId01 TO NSQL
GO
