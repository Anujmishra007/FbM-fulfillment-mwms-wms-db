SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_593TMSVALBL                                     */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Called by RDT Report TMSLBLAEOMX to pass ZPL to print job   */
/*                                                                      */
/* Called from: TMSLBLAEOMX                                             */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2026-07-27  1.0  ELB012   UWP-63386 AEOMX Created                   */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_593TMSVALBL] (
   @nMobile    INT,
   @nFunc      INT,
   @cLangCode  NVARCHAR(  3),
   @cStorerKey NVARCHAR( 15),
   @cValue01   NVARCHAR( 20),
   @cValue02   NVARCHAR( 20),
   @cValue03   NVARCHAR( 20),
   @cValue04   NVARCHAR( 20),
   @cValue05   NVARCHAR( 20),
   @cValue06   NVARCHAR( 20),
   @cValue07   NVARCHAR( 20),
   @cValue08   NVARCHAR( 20),
   @cValue09   NVARCHAR( 20),
   @cValue10   NVARCHAR( 20),
   @cTemplate  NVARCHAR(MAX),
   @cPrintData NVARCHAR(MAX) OUTPUT,
   @nErrNo     INT           OUTPUT,
   @cErrMsg    NVARCHAR( 250) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON

   SET @nErrNo     = 0
   SET @cErrMsg    = ''
   SET @cPrintData = ''

   DECLARE @cTrackingNo NVARCHAR( 30)

   SELECT TOP 1
      @cTrackingNo = PINFO.TrackingNo
   FROM dbo.PackDetail AS PD WITH (NOLOCK)
   JOIN dbo.PackInfo   AS PINFO WITH (NOLOCK)
      ON PINFO.PickSlipNo = PD.PickSlipNo
   WHERE PD.LabelNo   = @cValue01
   AND   PD.StorerKey = @cStorerKey

   SELECT TOP 1
      @cPrintData = PrintData
   FROM dbo.CartonTrack WITH (NOLOCK)
   WHERE KeyName = @cStorerKey
   AND ( LabelNo    = @cValue01
      OR TrackingNo = @cTrackingNo)
   ORDER BY AddDate DESC

   IF ISNULL(@cPrintData, '') = ''
   BEGIN
      SET @nErrNo  = 253583
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_593TMSVALBL] TO [NSQL]
GO
