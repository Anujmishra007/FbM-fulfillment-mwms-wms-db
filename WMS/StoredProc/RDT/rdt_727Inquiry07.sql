SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO



/***************************************************************************/
/* Store procedure: rdt_727Inquiry07                                       */
/*                                                                         */
/* Purpose:                                                                */
/* -Scan dropid to figure the zone,wave,sku and quantity                   */
/*                                                                         */
/* Modifications log:                                                      */
/* Date       Rev  Author   Purposes                                       */
/* 2019-09-30 1.0  YeeKung  WMS-100790 Created                             */
/* 2023-10-03 1.1  Yeekung  WMS-23791 Extended Params (yeekung01)          */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_727Inquiry07] (
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

   DECLARE @cWaveKey       NVARCHAR(10)
         ,@cDropID         NVARCHAR(20)
         ,@cPutawayZone    NVARCHAR(10)

   SET @nErrNo = 0


   IF @nStep = 2
   BEGIN
      SET @cDropID = @cParam1

      IF @cDropID = ''
      BEGIN
         SET @nErrNo = 145001
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropIDReq
         GOTO QUIT
      END
   END

   SELECT TOP 1
         @cWaveKey  = WaveKey
   FROM dbo.pickdetail WITH (NOLOCK)
   WHERE dropid = @cdropid
   AND  Status <= 5

   SELECT @cPutawayZone=userdefine02
   FROM wave WITH (NOLOCK)
   WHERE wavekey=@cWaveKey

   SET @c_oFieled01 = 'DropID:'
   SET @c_oFieled02 = @cDropID
   SET @c_oFieled03 = 'Wave     :' + @cWaveKey
   SET @c_oFieled04 = 'PZone    :' + @cPutawayZone

   SET @nNextPage = 0

QUIT:
GO
GRANT EXECUTE ON  [RDT].[rdt_727Inquiry07] TO [NSQL]
GO
