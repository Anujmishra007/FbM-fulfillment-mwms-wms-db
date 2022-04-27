
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_838DataCap05                                    */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Date       Rev  Author      Purposes                                 */
/* 11-02-2022 1.0  Ung         WMS-19000 Created                        */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838DataCap05 (
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
   @cPackData1       NVARCHAR( 30)  OUTPUT, 
   @cPackData2       NVARCHAR( 30)  OUTPUT, 
   @cPackData3       NVARCHAR( 30)  OUTPUT,
   @cPackLabel1      NVARCHAR( 20)  OUTPUT,   
   @cPackLabel2      NVARCHAR( 20)  OUTPUT,   
   @cPackLabel3      NVARCHAR( 20)  OUTPUT,  
   @cPackAttr1       NVARCHAR( 1)   OUTPUT,   
   @cPackAttr2       NVARCHAR( 1)   OUTPUT,   
   @cPackAttr3       NVARCHAR( 1)   OUTPUT, 
   @cDataCapture     NVARCHAR( 1)   OUTPUT, 
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nL02_Count  INT
   DECLARE @nL04_Count  INT
   DECLARE @dLottable04 DATETIME
   DECLARE @cOrderKey   NVARCHAR( 10)
   DECLARE @cPickStatus NVARCHAR(1)
   DECLARE @cSKUDataCapture NVARCHAR(1)

   DECLARE @tPick TABLE
   (
      Lottable02 NVARCHAR( 18)   NOT NULL, 
      QTY        INT             NOT NULL, 
      PRIMARY KEY CLUSTERED (Lottable02)
   )
   
   DECLARE @tPack TABLE
   (
      Lottable02 NVARCHAR( 18)   NOT NULL, 
      QTY        INT             NOT NULL, 
      PRIMARY KEY CLUSTERED (Lottable02)
   )

   DECLARE @tBalance TABLE
   (
      Lottable02 NVARCHAR( 18)   NOT NULL, 
      QTY        INT             NOT NULL, 
      PRIMARY KEY CLUSTERED (Lottable02)
   )

   SET @cPackData1 = '' -- Batch no, L02
   SET @cPackData2 = '' -- L01
   SET @cPackData3 = ''

   -- Get SKU info
   SELECT @cSKUDataCapture = DataCapture
   FROM SKU WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND SKU = @cSKU

   -- Check need data capture
   IF @cSKUDataCapture NOT IN ('1', '3')
      GOTO Quit

   -- Storer config
   SET @cPickStatus = rdt.RDTGetConfig( @nFunc, 'PickStatus', @cStorerkey)

   -- Get PickHeader info
   SELECT TOP 1
      @cOrderKey = OrderKey
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   -- Get pick
   INSERT INTO @tPick (Lottable02, QTY)
   SELECT LA.Lottable02, ISNULL( SUM( PD.QTY), 0)
   FROM dbo.PickDetail PD WITH (NOLOCK)
      JOIN dbo.LOTAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT)
   WHERE PD.OrderKey = @cOrderKey
      AND PD.StorerKey = @cStorerKey
      AND PD.SKU = @cSKU
      AND PD.QTY > 0
      AND PD.Status = @cPickStatus
      AND PD.Status <> '4'
   GROUP BY LA.Lottable02

   -- Get pack
   INSERT INTO @tPack (Lottable02, QTY)
   SELECT 
      UserDefine01, 
      ISNULL( SUM( QTY), 0)
   FROM dbo.PackDetailInfo WITH (NOLOCK) 
   WHERE PickSlipNo = @cPickSlipNo
      AND StorerKey = @cStorerKey
      AND SKU = @cSKU
   GROUP BY UserDefine01

   -- Get balance
   INSERT INTO @tBalance (Lottable02, QTY)
   SELECT Pick.Lottable02, Pick.QTY - ISNULL( Pack.QTY, 0)
   FROM @tPick Pick
      LEFT JOIN @tPack Pack ON (Pick.Lottable02 = Pack.Lottable02)
   WHERE Pick.QTY - ISNULL( Pack.QTY, 0) > 0
   
   -- Get stat
   SELECT @nL02_Count = COUNT( DISTINCT Lottable02)
   FROM @tBalance
   
   -- Auto default L02
   IF @nL02_Count = 1
   BEGIN
      SELECT TOP 1 @cPackData1 = Lottable02 FROM @tBalance
   END
   ELSE IF @nL02_Count > 1
   BEGIN
      EXEC rdt.rdtSetFocusField @nMobile, 1 -- PackData1  
      SET @cPackData1 = '' -- force key-in
      SET @cPackAttr1 = ''
   END
   
   -- Get default L01 (1 SKU + Batch, only 1 L01)
   IF @cPackData1 <> ''
   BEGIN
      SELECT TOP 1 
         @cPackData2 = LA.Lottable01
      FROM dbo.PickDetail PD WITH (NOLOCK)
         JOIN dbo.LOTAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT)
      WHERE PD.OrderKey = @cOrderKey
         AND PD.StorerKey = @cStorerKey
         AND PD.SKU = @cSKU
         AND PD.QTY > 0
         AND PD.Status = @cPickStatus
         AND PD.Status <> '4'
         AND LA.Lottable02 = @cPackData1
   END

   IF @cPackData1 = ''
      SET @cDataCapture = '1' -- need to capture
   
Quit:
   
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838DataCap05 TO NSQL
GO
