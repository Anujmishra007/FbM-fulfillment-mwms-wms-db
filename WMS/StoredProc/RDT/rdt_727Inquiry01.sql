SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdt_727Inquiry01                                       */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date       Rev  Author   Purposes                                       */
/* 2016-09-21 1.0  ChewKP   WMS-338 Created                                */
/* 2019-09-20 1.1  YeeKung  WMS-10536 Change the parameter                 */  
/* 2023-10-03 1.2  Yeekung  WMS-23791 Extended Params (yeekung01)          */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_727Inquiry01] (
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
          ,@cLoadKey       NVARCHAR(10)
          ,@cPrintFlag     NVARCHAR(10)
          ,@cSOStatus      NVARCHAR(10)
          ,@cDropID        NVARCHAR(20)
          ,@cPreOrderKey   NVARCHAR(10)
          ,@cOrderKey      NVARCHAR(10)
          ,@nPDQty         INT
          ,@cToLoc         NVARCHAR(10)
          ,@cPutawayZone   NVARCHAR(10)
          ,@cStatus        NVARCHAR(5)
          ,@cDropIDType    NVARCHAR(10)
          ,@nOrderCount    INT
          ,@nSOStatusCount INT


SET @nErrNo = 0
SET @cPreOrderKey = ''

IF @cOption = '1'
BEGIN
   --IF @nStep = 2 OR @nStep = 3 OR @nStep = 4
   --BEGIN

      IF @nStep = 2
      BEGIN
         SET @cDropID = @cParam1

         IF @cDropID = ''
         BEGIN
            SET @nErrNo = 104352
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropIDReq
            GOTO QUIT
         END
      END

      IF @nStep = 3 OR @nStep = 4
      BEGIN
         SET @cDropID = @c_oFieled02

         IF ISNULL(@c_oFieled05,'' ) <> ''
         BEGIN
            SET @cPreOrderKey = RIGHT(@c_oFieled05,10 )
         END
      END

      SELECT @cLoadKey = LoadKey
            ,@cDropIDType = DropIDType
      FROM dbo.DropID WITH (NOLOCK)
      WHERE DropID = @cDropID


      SELECT TOP 1 @cOrderKey = PD.OrderKey
            ,@cToLoc    = PD.ToLoc
      FROM dbo.PickDetail PD WITH (NOLOCK)
      INNER JOIN dbo.Orders O WITH (NOLOCK) ON O.OrderKey = PD.OrderKey
      WHERE PD.DropID = @cDropID
      AND O.LoadKey = @cLoadKey
      AND PD.OrderKey > @cPreOrderKey
      ORDER BY O.OrderKey

      IF @@ROWCOUNT > 0
      BEGIN



         SELECT @cPutawayZone = PutawayZone
         FROM dbo.Loc WITH (NOLOCK)
         WHERE Loc = @cToLoc

         SELECT
             @cWaveKey = UserDefine09
            --,@cLoadKey = LoadKey
            --,@cPrintFlag = PrintFlag
            ,@cSOStatus  = SOStatus
            ,@cStatus    = Status
         FROM dbo.Orders WITH (NOLOCK)
         WHERE OrderKey = @cOrderKey

         SELECT @nPDQty = SUM(PD.Qty)
         FROM dbo.PickDetail PD WITH (NOLOCK)
         INNER JOIN dbo.Orders O WITH (NOLOCK) ON O.OrderKey = PD.OrderKey
         WHERE PD.DropID = @cDropID
         --AND @cOrderKey = @cOrderKey
         AND O.UserDefine09 = @cWaveKey
         AND PD.Status = '5'

         SELECT @nOrderCount = Count(Distinct O.OrderKey )
         FROM dbo.PickDetail PD WITH (NOLOCK)
         INNER JOIN dbo.Orders O WITH (NOLOCK) ON O.OrderKey = PD.OrderKey
         WHERE PD.DropID = @cDropID
         --AND @cOrderKey = @cOrderKey
         AND O.UserDefine09 = @cWaveKey
         AND PD.Status = '5'

         SELECT @nSOStatusCount = Count(Distinct O.SOStatus )
         FROM dbo.PickDetail PD WITH (NOLOCK)
         INNER JOIN dbo.Orders O WITH (NOLOCK) ON O.OrderKey = PD.OrderKey
         WHERE PD.DropID = @cDropID
         --AND @cOrderKey = @cOrderKey
         AND O.UserDefine09 = @cWaveKey
         AND PD.Status = '5'


         --INSERT INTO TracEInfo (TraceName , Timein , Col1, Col2, Col3 )
         --VALUES ( 'rdt_727Inquiry01' , getdate() , @cDropID , @cWaveKey , @nOrderCount )

         SELECT TOP 1 @cPrintFlag = O.PrintFlag
         FROM dbo.PickDetail PD WITH (NOLOCK)
         INNER JOIN dbo.Orders O WITH (NOLOCK) ON O.OrderKey = PD.OrderKey
         WHERE PD.DropID = @cDropID
         AND PD.StorerKey = @cStorerKey
         AND O.UserDefine09 = @cWaveKey
         ORDER BY O.PrintFlag




         SET @c_oFieled01 = 'DropID:'
         SET @c_oFieled02 = @cDropID
         SET @c_oFieled03 = 'Wave     :' + @cWaveKey
         SET @c_oFieled04 = 'LoadKey  :' + @cLoadKey
         SET @c_oFieled05 = 'OrderKey :' + CASE WHEN @nOrderCount = 1 THEN @cOrderKey ELSE @cDropIDType END
         SET @c_oFieled06 = 'PrintFlag:' + @cPrintFlag
         SET @c_oFieled07 = 'TotalQty :' + CAST(@nPDQty AS NVARCHAR(5))
         SET @c_oFieled08 = 'SOStatus :' + CASE WHEN @nSOStatusCount = 1 THEN @cSOStatus ELSE '' END
         SET @c_oFieled09 = 'Status   :' + @cStatus
         SET @c_oFieled10 = 'PZone    :' + @cPutawayZone

         SET @nNextPage = 0

      END
      ELSE
      BEGIN

         SET @nErrNo = 104351
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoMoreRecord
         GOTO QUIT
      END
   --END
END
QUIT:

GO
GRANT EXECUTE ON  [RDT].[rdt_727Inquiry01] TO [NSQL]
GO
