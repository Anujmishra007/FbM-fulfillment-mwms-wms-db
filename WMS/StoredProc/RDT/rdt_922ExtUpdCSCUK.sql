
/************************************************************************/
/* Store procedure: rdt_922ExtUpdCSCUK                                  */
/* Purpose: Update PACKHEADER status                                    */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-03-11 1.0  AGA399     Created                                   */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_922ExtUpdCSCUK] (
 @nMobile     INT,
 @nFunc       INT,
 @cLangCode   NVARCHAR( 3),   
 @nStep       INT,
 @nInputKey   INT,
 @cStorerKey  NVARCHAR( 15),
 @cType       NVARCHAR( 1),
 @cMBOLKey    NVARCHAR( 10),
 @cLoadKey    NVARCHAR( 10),
 @cOrderKey   NVARCHAR( 10),
 @cLabelNo    NVARCHAR( 20),
 @cPackInfo   NVARCHAR( 3),
 @cWeight     NVARCHAR( 10),
 @cCube       NVARCHAR( 10),
 @cCartonType NVARCHAR( 10),
 @cDoor       NVARCHAR( 10),
 @cRefNo      NVARCHAR( 40),
 @nErrNo      INT           OUTPUT,
 @cErrMsg     NVARCHAR( 20) OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF

IF @nFunc = 922
BEGIN
 IF @nStep = 2 -- LabelNo/DropID
 BEGIN
    IF @nInputKey = 1 -- ENTER
    BEGIN
       DECLARE @cPackConfirm    NVARCHAR(1)
       DECLARE @npickedQty      INT = 0
       DECLARE @nPackedQty      INT = 0
       DECLARE @nCQty           INT = 0
       DECLARE @cPickSlipNo     NVARCHAR( 10)

       -- Check pack confirm already
          IF EXISTS( SELECT 1 FROM PackHeader WITH (NOLOCK) WHERE OrderKey = @cOrderKey AND storerkey = @cStorerkey AND Status = '9')
             GOTO Quit

          SELECT @npickedQty = SUM(qty) FROM PickDetail WITH(NOLOCK)
          WHERE orderkey = @cOrderKey
          AND Storerkey = @cStorerKey

          SELECT @nPackedQty = SUM(qty)
          FROM PackDetail pd WITH(NOLOCK)
          INNER JOIN PackHeader ph WITH(NOLOCK)
          ON pd.pickslipno = ph.pickslipno
          WHERE ph.orderkey = @cOrderKey AND ph.Storerkey = @cStorerKey

          SELECT @cPickSlipNo = PickSlipNo FROM PackHeader WITH(NOLOCK)
          WHERE orderkey = @cOrderKey
          AND Storerkey = @cStorerKey

          IF @npickedQty = @nPackedQty
          BEGIN
             -- Update PackHeader
             UPDATE PackHeader SET
                Status = '9'
             WHERE PickSlipNo = @cPickSlipNo
                AND Status <> '9'
             IF @@ERROR <> 0
             BEGIN
                SET @nErrNo = 221001
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- PackCfm Fail
             END
          END

    END
 END
END

Quit:
Fail:
