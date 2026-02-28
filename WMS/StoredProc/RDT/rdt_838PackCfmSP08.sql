SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_838PackCfmSP08                                  */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2025-11-17 1.0  NickT       UWP-43907 Merge from V0 WMS-25533        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838PackCfmSP08] (
    @nMobile      INT
   ,@nFunc        INT
   ,@cLangCode    NVARCHAR( 3)
   ,@nStep        INT
   ,@nInputKey    INT
   ,@cFacility    NVARCHAR( 5)
   ,@cStorerKey   NVARCHAR( 15)
   ,@cPickSlipNo  NVARCHAR( 10)
   ,@cFromDropID  NVARCHAR( 20)
   ,@cPackDtlDropID NVARCHAR( 20)
   ,@cPrintPackList NVARCHAR( 1) OUTPUT
   ,@nErrNo       INT            OUTPUT
   ,@cErrMsg      NVARCHAR(250)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   -- Check any SKIP carton type
   IF EXISTS( SELECT 1 FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonType = 'SKIP')
      GOTO Quit
   
   -- Pack confirm
   EXEC rdt.rdt_Pack_PackConfirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
      ,@cPickSlipNo    = @cPickSlipNo   
      ,@cFromDropID    = @cFromDropID   
      ,@cPackDtlDropID = @cPackDtlDropID
      ,@cPrintPackList = @cPrintPackList OUTPUT
      ,@nErrNo         = @nErrNo         OUTPUT
      ,@cErrMsg        = @cErrMsg        OUTPUT
      ,@nUseStandard   = 1
   IF @nErrNo <> 0
      GOTO Quit
      
Quit:

END
GO

GRANT EXECUTE ON  [RDT].[rdt_838PackCfmSP08] TO [NSQL]
GO
