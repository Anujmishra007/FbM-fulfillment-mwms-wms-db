if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_1653DecodeSP02]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdt_1653DecodeSP02]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1653DecodeSP02                                  */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Called from: rdtfnc_TrackNo_SortToPallet                             */
/*                                                                      */
/* Purpose: Decode tracking no and return orderkey                      */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2021-08-24  1.0  James    WMS-17773. Created                         */
/* 2021-09-30  1.1  LZG      JSM-23695 - Initialize @nErrNo to avoid    */
/*                           misbehavior in parent script (ZG01)        */
/************************************************************************/

CREATE PROC [RDT].[rdt_1653DecodeSP02] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cBarcode       NVARCHAR( 60),
   @cTrackNo       NVARCHAR( 40)  OUTPUT,
   @cOrderKey      NVARCHAR( 10)  OUTPUT,
   @cLabelNo       NVARCHAR( 20)  OUTPUT,
   @nErrNo         INT            OUTPUT,
   @cErrMsg        NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cInTrackNo     NVARCHAR( 40)

   IF LEN( @cBarcode) > 20
      SET @cInTrackNo = RIGHT( RTRIM( @cBarcode), 23)
   ELSE
      SET @cInTrackNo = RTRIM( @cBarcode)

   SET @nErrNo = 0   -- ZG01
   SET @cOrderKey = ''

   SELECT @cLabelNo = LabelNo
   FROM dbo.CartonTrack WITH (NOLOCK)
   WHERE TrackingNo = @cInTrackNo
   AND   KeyName = @cStorerKey

   IF ISNULL( @cLabelNo, '') = ''
      GOTO Fail

   SELECT TOP 1 @cOrderKey = PH.OrderKey
   FROM dbo.PackDetail PD WITH (NOLOCK)
   JOIN dbo.PackHeader PH WITH (NOLOCK) ON ( PD.PickSlipNo = PH.PickSlipNo)
   WHERE PD.LabelNo = @cLabelNo
   AND   PH.StorerKey = @cStorerKey
   ORDER BY 1

   SET @cTrackNo = @cInTrackNo
Fail:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1653DecodeSP02 TO NSQL
GO