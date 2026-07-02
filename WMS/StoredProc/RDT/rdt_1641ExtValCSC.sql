GO
/****** Object:  StoredProcedure [RDT].[rdt_1641ExtValCSC]    Script Date: 7/2/2026 9:17:50 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***********************************************************************/
/* Store procedure: rdt_1641ExtValidSPCSC                              */
/* Purpose: CSCUK01 Pallet Build Step 3 validation                     */
/*          Do not allow scan of DropID if it is not yet packed        */
/*                                                                     */
/* Applies only to:                                                    */
/* - StorerKey = CSCUK01                                               */
/* - Orders.DocType = 'N'                                              */
/***********************************************************************/
CREATE OR ALTER   PROC [RDT].[rdt_1641ExtValCSC]
(
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR(3),
   @nStep        INT,
   @nInputKey    INT,
   @cStorerKey   NVARCHAR(15),
   @cDropID      NVARCHAR(20),
   @cUCCNo       NVARCHAR(20),
   @cPrevLoadKey NVARCHAR(10),
   @cParam1      NVARCHAR(20),
   @cParam2      NVARCHAR(20),
   @cParam3      NVARCHAR(20),
   @cParam4      NVARCHAR(20),
   @cParam5      NVARCHAR(20),
   @nErrNo       INT OUTPUT,
   @cErrMsg      NVARCHAR(20) OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

IF @nFunc = 1641
BEGIN
   IF @nStep = 3
   BEGIN
      IF @nInputKey = 1
      BEGIN
         DECLARE
              @cOrderKey NVARCHAR(10)
            , @cDocType  NVARCHAR(10)

         SET @nErrNo    = 0
         SET @cErrMsg   = ''
         SET @cOrderKey = ''
         SET @cDocType  = ''

         SELECT TOP 1
              @cOrderKey = PD.OrderKey
            , @cDocType  = O.DocType
         FROM dbo.PickDetail PD WITH (NOLOCK)
         INNER JOIN dbo.Orders O WITH (NOLOCK)
            ON O.OrderKey = PD.OrderKey
           AND O.StorerKey = PD.StorerKey
         WHERE PD.StorerKey = @cStorerKey
         AND   PD.DropID = @cUCCNo

         IF  @cDocType = 'N'
         BEGIN
            IF NOT EXISTS
            (
               SELECT 1
               FROM dbo.PackDetail PDK WITH (NOLOCK)
               WHERE PDK.StorerKey = @cStorerKey
               AND   PDK.DropID = @cUCCNo
               AND   PDK.Qty > 0
            )
            AND EXISTS
            (
               SELECT 1
               FROM dbo.PickDetail PD WITH (NOLOCK)
               WHERE PD.StorerKey = @cStorerKey
               AND   PD.DropID = @cUCCNo
            )
            BEGIN
               SET @nErrNo = 161001   --161001DropIDNotPack 
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               GOTO QUIT
            END
         END
      END
   END
END

QUIT:
RETURN
