
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Store procedure: rdt_922ExtScn01_UCC_GetStat                            */
/* Copyright      : Maersk                                                 */
/* Customer       : Columbia SW MY                                         */
/*                                                                         */
/* Purpose        : Get UCC scan statistics for ExtScn01                   */
/*                                                                         */
/* Date        Rev    Author     Purposes                                  */
/* 2026-04-22  1.0.0  Jackc      FCR-11588 created                         */
/* 2026-05-11  1.0.1  Jackc      FCR-11588 V1.4 FBR                        */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_922ExtScn01_UCC_GetStat] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @cStorerKey   NVARCHAR( 15),
   @cType        NVARCHAR( 1),
   @cMBOLKey     NVARCHAR( 10),
   @cLoadKey     NVARCHAR( 10),
   @cOrderKey    NVARCHAR( 10),
   @cDropID      NVARCHAR( 20),
   @nScanUCC     INT            OUTPUT,
   @nTotalUCC    INT            OUTPUT,
   @nErrNo       INT            OUTPUT,
   @cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @nErrNo = 0
   SET @cErrMsg = ''
   SET @nScanUCC = 0
   SET @nTotalUCC = 0

   -- Count scanned UCC (Status = '5' means confirmed)
   -- Count total UCC (exclude Status '0' = New, '6' = Cancelled)
   SELECT @nScanUCC = COUNT(DISTINCT UCCNo)
   FROM dbo.UCC WITH (NOLOCK)
   JOIN dbo.PickDetail PD WITH (NOLOCK) 
      ON (UCC.StorerKey = PD.StorerKey AND UCC.ID = PD.DropID)
   WHERE UCC.StorerKey = @cStorerKey
      AND UCC.ID = @cDropID
      AND UCC.Status = '5'
      AND PD.Status = '5' 

   -- Count total UCC (exclude Status '0' = New, '6' = Cancelled)
   SELECT @nTotalUCC = COUNT(DISTINCT UCCNo)
   FROM dbo.UCC WITH (NOLOCK)
   JOIN dbo.PickDetail PD WITH (NOLOCK) 
      ON (UCC.StorerKey = PD.StorerKey AND UCC.ID = PD.DropID)
   WHERE UCC.StorerKey = @cStorerKey
      AND UCC.ID = @cDropID
      AND UCC.Status NOT IN ('0', '6')
      AND PD.Status = '5'

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_922ExtScn01_UCC_GetStat] TO NSQL
GO

