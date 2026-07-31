SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1812ExtVal_PGPE                                 */
/* Copyright      : Maersk                                              */
/* Customer       : PGPE                                                */
/*                                                                      */
/* Purpose: Restrictions for Pallet Building During Picking process     */
/*          - Validate pallet volume does not exceed defined limit      */
/*          - Validate number of SKUs does not exceed limit             */
/*          - Validate DropID has not already been used                 */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2026-04-15   FRO014    1.0   RITM9021245/UWP-62599 Created           */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1812ExtVal_PGPE]
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cTaskDetailKey NVARCHAR( 10),
   @cDropID        NVARCHAR( 20),
   @nQTY           INT,
   @cToLOC         NVARCHAR( 10),
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cStorerKey           NVARCHAR( 20)
   DECLARE @cCustomer            NVARCHAR( 20)
   DECLARE @cWaveKey             NVARCHAR( 20)
   DECLARE @nDropIDCube          DECIMAL(10, 2)
   DECLARE @nCubeByDropID        DECIMAL(10, 2)
   DECLARE @nCubeByTaskSKU       DECIMAL(10, 2)
   DECLARE @nDropIDQSKU          INT
   DECLARE @nSkuQuantityByDropID INT

   SELECT
      @cStorerKey = StorerKey,
      @cWaveKey   = WaveKey
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskDetailKey

   IF @nFunc = 1812
   BEGIN
      IF @nStep = 1 -- DropID
      BEGIN
         -- Check duplicate DropID across different waves
         IF EXISTS (
            SELECT 1
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.WaveDetail WD WITH (NOLOCK)
               ON PD.OrderKey = WD.OrderKey
            WHERE PD.StorerKey = @cStorerKey
               AND PD.DropID   = @cDropID
               AND WD.WaveKey  <> @cWaveKey
         )
         BEGIN
            SET @nErrNo  = 275061
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- DropID used
            EXEC rdt.rdtSetFocusField @nMobile, 4
            GOTO Quit
         END
      END

      IF @nStep = 4 -- SKU
      BEGIN
         -- Get consignee for this task
         SELECT TOP 1 @cCustomer = O.ConsigneeKey
         FROM dbo.PickDetail PD WITH (NOLOCK)
         INNER JOIN dbo.ORDERS O WITH (NOLOCK)
            ON PD.OrderKey = O.OrderKey
         WHERE PD.StorerKey      = @cStorerKey
            AND PD.TaskDetailKey = @cTaskDetailKey

         -- Check cube limit if configured
         SELECT TOP 1 @nDropIDCube = TRY_CAST(COALESCE(NULLIF(UDF01, ''), '0') AS DECIMAL(10, 2))
         FROM dbo.CODELKUP WITH (NOLOCK)
         WHERE ListName = 'DROPIDCUBE'
            AND Code    = @cCustomer

         IF ISNULL(@nDropIDCube, 0) <> 0
         BEGIN
            SELECT @nCubeByDropID = SUM(PD.Qty * PACK.CubeUOM3)
            FROM dbo.WaveDetail WD WITH (NOLOCK)
            INNER JOIN dbo.PickDetail PD WITH (NOLOCK)
               ON PD.OrderKey = WD.OrderKey
            INNER JOIN dbo.SKU SKU WITH (NOLOCK)
               ON  PD.StorerKey = SKU.StorerKey
               AND PD.SKU       = SKU.SKU
            INNER JOIN dbo.PACK PACK WITH (NOLOCK)
               ON SKU.PackKey = PACK.PackKey
            WHERE WD.WaveKey  = @cWaveKey
               AND PD.DropID  = @cDropID
               AND PD.Status  = '5'

            SELECT TOP 1 @nCubeByTaskSKU = PACK.CubeUOM3 * @nQTY
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.SKU SKU WITH (NOLOCK)
               ON  PD.StorerKey = SKU.StorerKey
               AND PD.SKU       = SKU.SKU
            INNER JOIN dbo.PACK PACK WITH (NOLOCK)
               ON SKU.SKU = PACK.PackKey
            WHERE PD.StorerKey      = @cStorerKey
               AND PD.TaskDetailKey = @cTaskDetailKey

            SET @nCubeByDropID = ISNULL(@nCubeByDropID, 0) + ISNULL(@nCubeByTaskSKU, 0)

            IF @nCubeByDropID >= @nDropIDCube
            BEGIN
               SET @nErrNo  = 275062
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Exceed Cube limit
               GOTO Quit
            END
         END

         -- Check SKU count limit if configured
         SELECT TOP 1 @nDropIDQSKU = TRY_CAST(COALESCE(NULLIF(UDF01, ''), '0') AS INT)
         FROM dbo.CODELKUP WITH (NOLOCK)
         WHERE ListName = 'DROPIDQSKU'
            AND Code    = @cCustomer

         IF ISNULL(@nDropIDQSKU, 0) > 0
         BEGIN
            SELECT @nSkuQuantityByDropID = COUNT(DISTINCT PD.SKU)
            FROM dbo.WaveDetail WD WITH (NOLOCK)
            INNER JOIN dbo.PickDetail PD WITH (NOLOCK)
               ON PD.OrderKey = WD.OrderKey
            WHERE WD.WaveKey  = @cWaveKey
               AND PD.DropID  = @cDropID

            IF @nSkuQuantityByDropID >= @nDropIDQSKU
            BEGIN
               SET @nErrNo  = 275063
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Exceed SKU Qty limit
               GOTO Quit
            END
         END
      END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1812ExtVal_PGPE] TO [NSQL]
GO
