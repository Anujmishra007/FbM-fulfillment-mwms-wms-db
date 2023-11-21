SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO



/***************************************************************************/
/* Store procedure: rdt_727Inquiry06                                       */
/*                                                                         */
/* Purpose:                                                                */
/* 1. Inquiry Caseid and trackingNo                                        */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date       Rev  Author   Purposes                                       */
/* 2019-09-17 1.0  YeeKung   WMS-10536 Created                             */
/* 2023-10-03 1.1  Yeekung  WMS-23791 Extended Params (yeekung01)          */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_727Inquiry06] (
   @nMobile    INT,
   @nFunc      INT,
   @nStep      INT,
   @cLangCode  NVARCHAR( 3),
   @cStorerKey NVARCHAR( 15),
   @cOption    NVARCHAR( 1),
   @cParam1    NVARCHAR(60),
   @cParam2    NVARCHAR(60),
   @cParam3    NVARCHAR(60),
   @cParam4    NVARCHAR(60),
   @cParam5    NVARCHAR(60),
   @c_oFieled01  NVARCHAR(20) OUTPUT,
   @c_oFieled02  NVARCHAR(20) OUTPUT,
   @c_oFieled03  NVARCHAR(20) OUTPUT,
   @c_oFieled04  NVARCHAR(20) OUTPUT,
   @c_oFieled05  NVARCHAR(20) OUTPUT,
   @c_oFieled06  NVARCHAR(20) OUTPUT,
   @c_oFieled07  NVARCHAR(20) OUTPUT,
   @c_oFieled08  NVARCHAR(20) OUTPUT,
   @c_oFieled09  NVARCHAR(20) OUTPUT,
   @c_oFieled10  NVARCHAR(20) OUTPUT,
   @c_oFieled11  NVARCHAR(20) OUTPUT,
   @c_oFieled12  NVARCHAR(20) OUTPUT,
   @nNextPage    INT          OUTPUT,
   @nErrNo     INT OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

  DECLARE @cCaseID         NVARCHAR(20)
         ,@cTrackingNo     NVARCHAR(20)
         ,@cPickSlipNo     NVARCHAR(20)

SET @nErrNo = 0

IF @cOption = '1'
BEGIN
   IF @nStep = 2
   BEGIN
      SET @cCaseID = @cParam1
      SET @cTrackingNo = @cParam3

      IF ISNULL(@cCaseID,'')=''
      BEGIN
         SET @nErrNo = 143951
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --CaseID
         GOTO QUIT
      END

      IF ISNULL(@cTrackingNo,'')=''
      BEGIN
         SET @nErrNo = -1
         EXEC rdt.rdtSetFocusField @nMobile, 6 -- TrackingNO
         GOTO QUIT
      END

      SELECT TOP 1 @cPickSlipNo=pickslipno
      FROM PACKDETAIL (NOLOCK)
      WHERE DROPID=@cCaseID
      AND Storerkey=@cStorerkey

      IF NOT EXISTS (SELECT 1 FROM Packheader PH (NOLOCK) JOIN ORDERS O (NOLOCK)
                     ON PH.OrderKey=O.OrderKey
                     WHERE PH.pickslipno=@cPickSlipNo
                        AND O.TrackingNo=@cTrackingNo
                        AND O.Storerkey=@cStorerkey)
      BEGIN
         SET @nErrNo = 143953
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --CID&TKNoNotMatch
         EXEC rdt.rdtSetFocusField @nMobile, 2 -- TrackingNO
         SET @c_oFieled02 = ''
         SET @c_oFieled06 = ''
         GOTO QUIT
      END

      SET @c_oFieled01 = 'Case ID:'
      SET @c_oFieled02 = @cCaseID
      SET @c_oFieled03 = 'Tracking No:'
      SET @c_oFieled04 = @cTrackingNo
      SET @c_oFieled08 = 'CaseID&TrackNo Match'

      SET @nNextPage = 0
   END

END
QUIT:
GO
GRANT EXECUTE ON  [RDT].[rdt_727Inquiry06] TO [NSQL]
GO
