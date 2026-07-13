USE [GBRWMS]
GO
/****** Object:  StoredProcedure [RDT].[rdt_1641ExtValCSC]    Script Date: 7/13/2026 11:14:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************/
/* Store procedure: rdt_1641ExtValCSC                                  */
/* Purpose: CSCUK01 Pallet Build validation                            */
/*          Step 1: pallet ID must start with OUT                      */
/*          Step 3: scanned UCC must already be packed for DocType N   */
/*                  and pallet must not mix wavekeys                   */
/*                                                                     */
/* Applies only to:                                                    */
/* - StorerKey = CSCUK01                                               */
/* - Orders.DocType = 'N' for packed-carton validation                 */
/*                                                                     */
/* Modifications log:                                                  */
/* 2026-07-06 1.0  SKE140  CSCUK01 pallet build validation             */
/*                         Do not allow DropID if not yet packed       */
/* 2026-07-13 1.1  SKE140  WaveKey validation update                   */
/***********************************************************************/

ALTER   PROC [RDT].[rdt_1641ExtValCSC]
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
   IF @nStep = 1
   BEGIN
      IF UPPER(LTRIM(RTRIM(ISNULL(@cDropID, '')))) NOT LIKE 'OUT%'
      BEGIN
         SET @nErrNo = 218048
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO QUIT
      END
   END

   IF @nStep = 3
   BEGIN
      IF @nInputKey = 1
      BEGIN
         DECLARE
              @cOrderKey            NVARCHAR(10)
            , @cDocType             NVARCHAR(10)
            , @cUCCWaveKey          NVARCHAR(20)
            , @cExistingWaveKey     NVARCHAR(20)
            , @nExistingWaveKeyCnt  INT

         SET @nErrNo               = 0
         SET @cErrMsg              = ''
         SET @cOrderKey            = ''
         SET @cDocType             = ''
         SET @cUCCWaveKey          = ''
         SET @cExistingWaveKey     = ''
         SET @nExistingWaveKeyCnt  = 0

         SELECT TOP 1
              @cOrderKey = PD.OrderKey
            , @cDocType  = O.DocType
         FROM dbo.PickDetail PD WITH (NOLOCK)
         INNER JOIN dbo.Orders O WITH (NOLOCK)
            ON O.OrderKey = PD.OrderKey
           AND O.StorerKey = PD.StorerKey
         WHERE PD.StorerKey = @cStorerKey
         AND   PD.DropID = @cUCCNo

         IF @cDocType = 'N'
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
               SET @nErrNo = 161001
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               GOTO QUIT
            END
         END

         /**************************************************************/
         /* WaveKey validation - keep separate from existing logic     */
         /**************************************************************/

         SELECT TOP 1
              @cUCCWaveKey = LTRIM(RTRIM(ISNULL(PD.WaveKey, '')))
         FROM dbo.PickDetail PD WITH (NOLOCK)
         WHERE PD.StorerKey = @cStorerKey
         AND  (PD.CaseID = @cUCCNo OR PD.DropID = @cUCCNo)
         ORDER BY CASE WHEN PD.CaseID = @cUCCNo THEN 0 ELSE 1 END,
                  PD.PickDetailKey DESC

         SELECT
              @nExistingWaveKeyCnt = COUNT(DISTINCT LTRIM(RTRIM(ISNULL(PD.WaveKey, ''))))
            , @cExistingWaveKey    = MIN(LTRIM(RTRIM(ISNULL(PD.WaveKey, ''))))
         FROM dbo.DropIDDetail DID WITH (NOLOCK)
         INNER JOIN dbo.PickDetail PD WITH (NOLOCK)
            ON PD.CaseID = DID.ChildID
           AND PD.StorerKey = @cStorerKey
         WHERE DID.DropID = @cDropID
         AND   LTRIM(RTRIM(ISNULL(PD.WaveKey, ''))) <> ''

         IF @nExistingWaveKeyCnt > 1
         BEGIN
            SET @nErrNo = 229952   -- WaveKey does not match
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            GOTO QUIT
         END

         IF @nExistingWaveKeyCnt = 1
         AND LTRIM(RTRIM(ISNULL(@cUCCWaveKey, ''))) <> ''
         AND LTRIM(RTRIM(ISNULL(@cUCCWaveKey, ''))) <> LTRIM(RTRIM(ISNULL(@cExistingWaveKey, '')))
         BEGIN
            SET @nErrNo = 229952   -- WaveKey does not match
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            GOTO QUIT
         END
      END
   END
END

QUIT:
RETURN