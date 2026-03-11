SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ExtUpd32                                     */
/* Copyright      : Maersk WMS                                          */
/* Customer       : LEVIS UAE                                           */
/*                                                                      */
/* Date       Rev    Author      Purposes                               */
/* 2026-02-18 1.0    SSR259      FCR-10629 Full UCC Pack Modification   */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ExtUpd32 (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @cPickSlipNo      NVARCHAR( 10),
   @cFromDropID      NVARCHAR( 20),
   @nCartonNo        INT,
   @cLabelNo         NVARCHAR( 20),
   @cSKU             NVARCHAR( 20),
   @nQTY             INT,
   @cUCCNo           NVARCHAR( 20),
   @cCartonType      NVARCHAR( 10),
   @cCube            NVARCHAR( 10),
   @cWeight          NVARCHAR( 10),
   @cRefNo           NVARCHAR( 20),
   @cSerialNo        NVARCHAR( 30),
   @nSerialQTY       INT,
   @cOption          NVARCHAR( 1),
   @cPackDtlRefNo    NVARCHAR( 20),
   @cPackDtlRefNo2   NVARCHAR( 20),
   @cPackDtlUPC      NVARCHAR( 30),
   @cPackDtlDropID   NVARCHAR( 20),
   @cPackData1       NVARCHAR( 30),
   @cPackData2       NVARCHAR( 30),
   @cPackData3       NVARCHAR( 30),
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE @cUsername NVARCHAR(30) = SUSER_SNAME()
    DECLARE @nLabelLine INT = 0

    IF @nFunc = 838
    BEGIN
        -- Step 8: Copy UCC to PackDetail.RefNo
        IF @nStep = 8 
        BEGIN
           IF @cUCCNo <> '' AND @nCartonNo > 0
           BEGIN
               UPDATE dbo.PACKDETAIL WITH (ROWLOCK)
               SET RefNo = @cUCCNo,
                   EditDate = GETDATE(),
                   EditWho = @cUsername
               WHERE PickSlipNo = @cPickSlipNo
                    AND CartonNo = @nCartonNo
                    AND StorerKey = @cStorerKey
                    AND LabelNo = @cLabelNo
                    AND LabelLine = @nLabelLine
           END
        END
    END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838ExtUpd32 TO NSQL
GO
