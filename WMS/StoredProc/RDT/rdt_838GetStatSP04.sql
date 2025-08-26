SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_838GetStatSP04                                     */
/* Copyright      : Maersk                                                 */
/*                                                                         */
/* Purpose: Scan FromID, Get status only for single order                  */
/*                                                                         */
/* Date       Rev    Author      Purposes                                  */
/* 2025-07-28 1.0    Cuize       FCR-4649 created                          */
/* 2025-08-26 1.0.1  Jackc       FCR-4649 Fix rowcount issue in Next type  */
/***************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838GetStatSP04(
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@nInputKey       INT
   ,@cFacility       NVARCHAR( 5)
   ,@cStorerKey      NVARCHAR( 15)
   ,@cType           NVARCHAR( 10)  -- CURRENT/NEXT
   ,@cPickSlipNo     NVARCHAR( 10)
   ,@cFromDropID     NVARCHAR( 20)
   ,@cPackDtlDropID  NVARCHAR( 20)
   ,@nCartonNo       INT            OUTPUT
   ,@cLabelNo        NVARCHAR( 20)  OUTPUT
   ,@cCustomNo       NVARCHAR( 5)   OUTPUT
   ,@cCustomID       NVARCHAR( 20)  OUTPUT
   ,@nCartonSKU      INT            OUTPUT
   ,@nCartonQTY      INT            OUTPUT
   ,@nTotalCarton    INT            OUTPUT
   ,@nTotalPick      INT            OUTPUT
   ,@nTotalPack      INT            OUTPUT
   ,@nTotalShort     INT            OUTPUT
   ,@nErrNo          INT            OUTPUT
   ,@cErrMsg         NVARCHAR(250)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSQL        NVARCHAR(MAX)
   DECLARE @cSQLParam   NVARCHAR(MAX)
   DECLARE @cGetStatSP  NVARCHAR(20)

   DECLARE @cPackFilter NVARCHAR( MAX) = ''
   DECLARE @cPickFilter NVARCHAR( MAX) = ''
   DECLARE @cOrderKey   NVARCHAR( 10)
   DECLARE @cLoadKey    NVARCHAR( 10)
   DECLARE @cZone       NVARCHAR( 18)
   DECLARE @cDropID     NVARCHAR( 20)
   DECLARE @cRefNo      NVARCHAR( 20)
   DECLARE @cRefNo2     NVARCHAR( 30)
   DECLARE @nRowCount   INT = 0

   SET @cOrderKey = ''

   SELECT TOP 1
      @cOrderKey = OrderKey
   FROM PickDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
     AND DropID = @cFromDropID
     AND Status <= '5'


/***********************************************************************************************
                                                PackDetail
                                       Packdetial.RefNo2 = Orderkey
   ***********************************************************************************************/

   SELECT @nTotalPack = ISNULL( SUM( PD.QTY), 0)
   FROM dbo.PackDetail PD WITH (NOLOCK)
   WHERE PD.RefNo2 = @cOrderKey


   SELECT @nTotalCarton = COUNT( DISTINCT PD.LabelNo)
   FROM dbo.PackDetail PD WITH (NOLOCK)
   WHERE PD.RefNo2 = @cOrderKey


   IF @cType = 'CURRENT'
   BEGIN
      SELECT TOP 1
         @nCartonNo = CartonNo,
         @cLabelNo = LabelNo,
         @cDropID = DropID,
         @cRefNo = RefNo,
         @cRefNo2 = RefNo2
      FROM dbo.PackDetail PD WITH (NOLOCK)
      WHERE PD.RefNo2 = @cOrderKey
         AND CartonNo = @nCartonNo
      ORDER BY CartonNo
   END

   IF @cType = 'NEXT'
   BEGIN

      SELECT TOP 1
         @nCartonNo = CartonNo,
         @cLabelNo = LabelNo,
         @cDropID = DropID,
         @cRefNo = RefNo,
         @cRefNo2 = RefNo2
      FROM dbo.PackDetail PD WITH (NOLOCK)
      WHERE PD.RefNo2 = @cOrderKey
         AND CartonNo > @nCartonNo
      ORDER BY CartonNo

      SET @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0
      BEGIN

         SELECT TOP 1
            @nCartonNo = CartonNo,
            @cLabelNo = LabelNo,
            @cDropID = DropID,
            @cRefNo = RefNo,
            @cRefNo2 = RefNo2
         FROM dbo.PackDetail PD WITH (NOLOCK)
         WHERE PD.RefNo2 = @cOrderKey
         ORDER BY CartonNo

         SET @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0
         SELECT
            @nCartonNo = 0,
            @cLabelNo = '',
            @cDropID = '',
            @cRefNo = '',
            @cRefNo2 = ''
      END
   END

   SELECT
      @nCartonSKU = COUNT( DISTINCT PD.SKU),
      @nCartonQTY = ISNULL( SUM( PD.QTY), 0)
   FROM dbo.PackDetail PD WITH (NOLOCK)
   WHERE PD.RefNo2 = @cOrderKey
     AND CartonNo = @nCartonNo
     AND LabelNo = @cLabelNo

   -- Storer configure
   DECLARE @cCustomCartonNo NVARCHAR(1)
   DECLARE @cCustomCartonID NVARCHAR(1)
   SET @cCustomCartonNo = rdt.rdtGetConfig( @nFunc, 'CustomCartonNo', @cStorerKey)
   SET @cCustomCartonID = rdt.rdtGetConfig( @nFunc, 'CustomCartonID', @cStorerKey)

   -- Get customm carton no / label no
   SELECT
      @cCustomNo =
      CASE @cCustomCartonNo
         WHEN '1' THEN LEFT( @cDropID, 5)
         WHEN '2' THEN LEFT( @cRefNo, 5)
         WHEN '3' THEN LEFT( @cRefNo2, 5)
         ELSE CAST( @nCartonNo AS NVARCHAR(5))
         END,
      @cCustomID =
      CASE @cCustomCartonID
         WHEN '1' THEN @cDropID
         WHEN '2' THEN @cRefNo
         WHEN '3' THEN LEFT( @cRefNo2, 20)
         ELSE @cLabelNo
         END

   IF @cCustomNo = ''
      SET @cCustomNo = '0'

   /***********************************************************************************************
                                                PickDetail
   ***********************************************************************************************/

   IF @cOrderKey <> ''
   BEGIN

      SELECT @nTotalPick = ISNULL( SUM( PD.QTY), 0)
      FROM dbo.PickDetail PD WITH (NOLOCK)
      WHERE PD.OrderKey = @cOrderKey
         AND PD.Status <= '5'
         AND PD.Status <> '4'

      SELECT @nTotalShort = ISNULL( SUM( PD.QTY), 0)
      FROM dbo.PickDetail PD WITH (NOLOCK)
      WHERE PD.OrderKey = @cOrderKey
         AND PD.Status = '4'

   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838GetStatSP04 TO NSQL
GO
