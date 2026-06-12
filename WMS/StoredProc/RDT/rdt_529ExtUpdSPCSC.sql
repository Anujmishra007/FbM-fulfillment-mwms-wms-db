
/************************************************************************/
/* Store procedure: rdt_529ExtUpdSPCSC                                  */
/* Copyright      : LF                                                  */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2026-03-31  1.0  TTW017   Created                                    */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_529ExtUpdSPCSC] (
@nMobile     INT,
@nFunc       INT,
@cLangCode  NVARCHAR( 3),
@cUserName   NVARCHAR( 15),
@cFacility   NVARCHAR( 5),
@cStorerKey  NVARCHAR( 15),
@cPickSlipNo NVARCHAR( 10),
@cFromDropID NVARCHAR( 20),
@cToDropID   NVARCHAR( 20),
@cSKU        NVARCHAR( 20),
@nQTY_Move   INT,
@nErrNo      INT          OUTPUT,
@cErrMsg     NVARCHAR( 20) OUTPUT  -- screen limitation, 20 char max
) AS
BEGIN
SET NOCOUNT ON
SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE @nMOBRECScn     INT
   , @nMOBRECStep    INT

SELECT @nMOBRECScn = Scn
, @nMOBRECStep = Step
FROM rdt.rdtMobRec WITH (NOLOCK)
WHERE Mobile = @nMobile

IF @nMOBRECScn = 2962 AND @nMOBRECStep = 3
BEGIN
  UPDATE PD
  SET PD.DropID = @cToDropID
    , PD.TrafficCop = NULL
  FROM PICKDETAIL PD WITH (ROWLOCK)
  LEFT JOIN PACKHEADER PaH WITH (NOLOCK) ON PD.Pickslipno = PaH.Pickslipno AND PD.Storerkey = PaH.Storerkey
  WHERE PD.DropID     = @cFromDropID
    AND PD.StorerKey  = @cStorerKey
    AND PD.SKU   = @cSKU
    AND PD.Status     = '5'
    AND (PaH.Status IS NULL
      OR PaH.Status <> '9')

END
Quit:

END
