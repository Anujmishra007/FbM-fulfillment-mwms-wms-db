SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*********************************************************************************/
/* Store procedure: rdt_830SuggestLOC07                                          */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose: Suggest pick LOC - sort by ProductModel, LogicalLocation (JOI_DOLLAR)*/
/*                                                                               */
/* Called from: rdt_PickSKU_SuggestLOC                                           */
/*                                                                               */
/* Date        Rev  Author      Purposes                                         */
/* 2026-08-11  1.0  JACKC       FCR-14582 Created                                */
/*********************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_830SuggestLOC07]
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @cPickSlipNo      NVARCHAR( 10),
   @cPickZone        NVARCHAR( 10),
   @cLOC             NVARCHAR( 10),
   @cSuggLOC         NVARCHAR( 10) OUTPUT,
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag         INT = 0

   DECLARE @cOrderKey          NVARCHAR( 10)
   DECLARE @cLoadKey           NVARCHAR( 10)
   DECLARE @cZone              NVARCHAR( 18)
   DECLARE @cLogicalLOC        NVARCHAR( 18)
   DECLARE @cNewSuggLOC        NVARCHAR( 18)
   DECLARE @cPickConfirmStatus NVARCHAR( 1)
   DECLARE @cCurrentProductModel NVARCHAR( 30)
   DECLARE @cCursorPM            NVARCHAR( 30)   -- sentinel: empty PM maps to REPLICATE('Z',30) to sort last

   SET @cOrderKey   = ''
   SET @cLoadKey    = ''
   SET @cZone       = ''
   SET @cNewSuggLOC = ''
   SET @cCurrentProductModel = ''
   SET @cCursorPM            = ''

   -- Get storer config
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'

   -- Get loc info
   SET @cLogicalLOC = ''
   SELECT @cLogicalLOC = LogicalLocation FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cLOC

   IF @nDebugFlag = 1
      SELECT 'Start 830SuggLoc07', @cPickSlipNo AS PSNO, @cPickZone AS PickZone, @cLOC AS LOC, @cLogicalLOC AS LogicalLOC

   -- Get PickHeader info (must be before cursor derivation)
   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cLoadKey  = ExternOrderKey,
      @cZone     = Zone
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   IF @nDebugFlag = 1
      SELECT 'PickHeader Info', @cOrderKey AS OrderKey, @cLoadKey AS LoadKey, @cZone AS Zone

   -- Derive current ProductModel cursor from pending tasks at @cLOC
   -- Same join logic as main SuggestLOC queries (PickDetail.PickSlipNo is normally null)
   IF @cLOC <> ''
   BEGIN
      IF @cZone IN ('XD', 'LB', 'LP')
         SELECT @cCurrentProductModel = ISNULL( MIN( NULLIF( SKU.ProductModel, '')), '')
         FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON ( PD.PickDetailKey = RKL.PickDetailKey)
            JOIN dbo.SKU SKU WITH (NOLOCK) ON ( SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
         WHERE RKL.PickSlipNo = @cPickSlipNo
            AND PD.LOC = @cLOC
            AND PD.QTY > 0
            AND PD.Status <> '4'
            AND PD.Status < @cPickConfirmStatus
      ELSE IF @cOrderKey <> ''
         SELECT @cCurrentProductModel = ISNULL( MIN( NULLIF( SKU.ProductModel, '')), '')
         FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.SKU SKU WITH (NOLOCK) ON ( SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
         WHERE PD.OrderKey = @cOrderKey
            AND PD.LOC = @cLOC
            AND PD.QTY > 0
            AND PD.Status <> '4'
            AND PD.Status < @cPickConfirmStatus
      ELSE IF @cLoadKey <> ''
         SELECT @cCurrentProductModel = ISNULL( MIN( NULLIF( SKU.ProductModel, '')), '')
         FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON ( PD.OrderKey = LPD.OrderKey)
            JOIN dbo.SKU SKU WITH (NOLOCK) ON ( SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
         WHERE LPD.LoadKey = @cLoadKey
            AND PD.LOC = @cLOC
            AND PD.QTY > 0
            AND PD.Status <> '4'
            AND PD.Status < @cPickConfirmStatus
      ELSE
         SELECT @cCurrentProductModel = ISNULL( MIN( NULLIF( SKU.ProductModel, '')), '')
         FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.SKU SKU WITH (NOLOCK) ON ( SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
         WHERE PD.PickSlipNo = @cPickSlipNo
            AND PD.LOC = @cLOC
            AND PD.QTY > 0
            AND PD.Status <> '4'
            AND PD.Status < @cPickConfirmStatus
   END

   -- Map empty ProductModel to high sentinel so it sorts LAST.
   -- Only apply sentinel when @cLOC <> '' (i.e. we have a real cursor position).
   -- When @cLOC = '' (first entry or wrap-around reset), keep @cCursorPM = ''
   -- so T.MinPM > '' matches ALL LOCs and ORDER BY picks the smallest MinPM first.
   IF @cLOC <> ''
      SET @cCursorPM = CASE WHEN @cCurrentProductModel = '' THEN REPLICATE( 'Z', 30) ELSE @cCurrentProductModel END

   IF @nDebugFlag = 1
      SELECT 'After Derive CurrentPM', @cCurrentProductModel AS CurrentPM, @cCursorPM AS CursorPM

   WHILE (1=1)
   BEGIN
      -- Cross dock PickSlip
      IF @cZone IN ('XD', 'LB', 'LP')
         IF @cPickZone <> ''
            SELECT TOP 1 @cNewSuggLOC = T.LOC
            FROM (
               SELECT LOC.LOC, LOC.LogicalLocation, ISNULL( MIN( NULLIF( SKU.ProductModel, '')), REPLICATE( 'Z', 30)) AS MinPM
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON ( PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON ( LOC.LOC = PD.LOC)
                  JOIN dbo.SKU SKU WITH (NOLOCK) ON ( SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.PickZone = @cPickZone
               GROUP BY LOC.LOC, LOC.LogicalLocation
            ) AS T
            WHERE (
               T.MinPM > @cCursorPM
               OR ( T.MinPM = @cCursorPM AND T.LogicalLocation > @cLogicalLOC)
               OR ( T.MinPM = @cCursorPM AND T.LogicalLocation = @cLogicalLOC AND T.LOC > @cLOC)
            )
            ORDER BY T.MinPM, T.LogicalLocation, T.LOC
         ELSE
            SELECT TOP 1 @cNewSuggLOC = T.LOC
            FROM (
               SELECT LOC.LOC, LOC.LogicalLocation, ISNULL( MIN( NULLIF( SKU.ProductModel, '')), REPLICATE( 'Z', 30)) AS MinPM
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON ( PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON ( LOC.LOC = PD.LOC)
                  JOIN dbo.SKU SKU WITH (NOLOCK) ON ( SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
               GROUP BY LOC.LOC, LOC.LogicalLocation
            ) AS T
            WHERE (
               T.MinPM > @cCursorPM
               OR ( T.MinPM = @cCursorPM AND T.LogicalLocation > @cLogicalLOC)
               OR ( T.MinPM = @cCursorPM AND T.LogicalLocation = @cLogicalLOC AND T.LOC > @cLOC)
            )
            ORDER BY T.MinPM, T.LogicalLocation, T.LOC

      -- Discrete PickSlip
      ELSE IF @cOrderKey <> ''
         IF @cPickZone <> ''
            SELECT TOP 1 @cNewSuggLOC = T.LOC
            FROM (
               SELECT LOC.LOC, LOC.LogicalLocation, ISNULL( MIN( NULLIF( SKU.ProductModel, '')), REPLICATE( 'Z', 30)) AS MinPM
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON ( LOC.LOC = PD.LOC)
                  JOIN dbo.SKU SKU WITH (NOLOCK) ON ( SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
               WHERE PD.OrderKey = @cOrderKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.PickZone = @cPickZone
               GROUP BY LOC.LOC, LOC.LogicalLocation
            ) AS T
            WHERE (
               T.MinPM > @cCursorPM
               OR ( T.MinPM = @cCursorPM AND T.LogicalLocation > @cLogicalLOC)
               OR ( T.MinPM = @cCursorPM AND T.LogicalLocation = @cLogicalLOC AND T.LOC > @cLOC)
            )
            ORDER BY T.MinPM, T.LogicalLocation, T.LOC
         ELSE
            SELECT TOP 1 @cNewSuggLOC = T.LOC
            FROM (
               SELECT LOC.LOC, LOC.LogicalLocation, ISNULL( MIN( NULLIF( SKU.ProductModel, '')), REPLICATE( 'Z', 30)) AS MinPM
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON ( LOC.LOC = PD.LOC)
                  JOIN dbo.SKU SKU WITH (NOLOCK) ON ( SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
               WHERE PD.OrderKey = @cOrderKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
               GROUP BY LOC.LOC, LOC.LogicalLocation
            ) AS T
            WHERE (
               T.MinPM > @cCursorPM
               OR ( T.MinPM = @cCursorPM AND T.LogicalLocation > @cLogicalLOC)
               OR ( T.MinPM = @cCursorPM AND T.LogicalLocation = @cLogicalLOC AND T.LOC > @cLOC)
            )
            ORDER BY T.MinPM, T.LogicalLocation, T.LOC

      -- Conso PickSlip
      ELSE IF @cLoadKey <> ''
         IF @cPickZone <> ''
            SELECT TOP 1 @cNewSuggLOC = T.LOC
            FROM (
               SELECT LOC.LOC, LOC.LogicalLocation, ISNULL( MIN( NULLIF( SKU.ProductModel, '')), REPLICATE( 'Z', 30)) AS MinPM
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON ( PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON ( LOC.LOC = PD.LOC)
                  JOIN dbo.SKU SKU WITH (NOLOCK) ON ( SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
               WHERE LPD.LoadKey = @cLoadKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.PickZone = @cPickZone
               GROUP BY LOC.LOC, LOC.LogicalLocation
            ) AS T
            WHERE (
               T.MinPM > @cCursorPM
               OR ( T.MinPM = @cCursorPM AND T.LogicalLocation > @cLogicalLOC)
               OR ( T.MinPM = @cCursorPM AND T.LogicalLocation = @cLogicalLOC AND T.LOC > @cLOC)
            )
            ORDER BY T.MinPM, T.LogicalLocation, T.LOC
         ELSE
            SELECT TOP 1 @cNewSuggLOC = T.LOC
            FROM (
               SELECT LOC.LOC, LOC.LogicalLocation, ISNULL( MIN( NULLIF( SKU.ProductModel, '')), REPLICATE( 'Z', 30)) AS MinPM
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON ( PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON ( LOC.LOC = PD.LOC)
                  JOIN dbo.SKU SKU WITH (NOLOCK) ON ( SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
               WHERE LPD.LoadKey = @cLoadKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
               GROUP BY LOC.LOC, LOC.LogicalLocation
            ) AS T
            WHERE (
               T.MinPM > @cCursorPM
               OR ( T.MinPM = @cCursorPM AND T.LogicalLocation > @cLogicalLOC)
               OR ( T.MinPM = @cCursorPM AND T.LogicalLocation = @cLogicalLOC AND T.LOC > @cLOC)
            )
            ORDER BY T.MinPM, T.LogicalLocation, T.LOC

      -- Custom PickSlip
      ELSE
         IF @cPickZone <> ''
            SELECT TOP 1 @cNewSuggLOC = T.LOC
            FROM (
               SELECT LOC.LOC, LOC.LogicalLocation, ISNULL( MIN( NULLIF( SKU.ProductModel, '')), REPLICATE( 'Z', 30)) AS MinPM
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON ( LOC.LOC = PD.LOC)
                  JOIN dbo.SKU SKU WITH (NOLOCK) ON ( SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.PickZone = @cPickZone
               GROUP BY LOC.LOC, LOC.LogicalLocation
            ) AS T
            WHERE (
               T.MinPM > @cCursorPM
               OR ( T.MinPM = @cCursorPM AND T.LogicalLocation > @cLogicalLOC)
               OR ( T.MinPM = @cCursorPM AND T.LogicalLocation = @cLogicalLOC AND T.LOC > @cLOC)
            )
            ORDER BY T.MinPM, T.LogicalLocation, T.LOC
         ELSE
            SELECT TOP 1 @cNewSuggLOC = T.LOC
            FROM (
               SELECT LOC.LOC, LOC.LogicalLocation, ISNULL( MIN( NULLIF( SKU.ProductModel, '')), REPLICATE( 'Z', 30)) AS MinPM
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON ( LOC.LOC = PD.LOC)
                  JOIN dbo.SKU SKU WITH (NOLOCK) ON ( SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
               GROUP BY LOC.LOC, LOC.LogicalLocation
            ) AS T
            WHERE (
               T.MinPM > @cCursorPM
               OR ( T.MinPM = @cCursorPM AND T.LogicalLocation > @cLogicalLOC)
               OR ( T.MinPM = @cCursorPM AND T.LogicalLocation = @cLogicalLOC AND T.LOC > @cLOC)
            )
            ORDER BY T.MinPM, T.LogicalLocation, T.LOC

      -- Found suggest LOC
      IF @cNewSuggLOC <> ''
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Found NewSuggLOC', @cNewSuggLOC AS NewSuggLOC
         BREAK
      END
      ELSE
      BEGIN
         -- Search from beginning again
         IF @cLOC <> ''
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'No more task, search from beginning again'
            SET @cLOC = ''
            SET @cLogicalLOC = ''
            SET @cCurrentProductModel = ''
            SET @cCursorPM = ''
            CONTINUE
         END
         ELSE
         BEGIN
            SET @nErrNo = 277451
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No more task
            SET @nErrNo = -1
            BREAK
         END
      END
   END

   IF @cNewSuggLOC <> ''
      SET @cSuggLOC = @cNewSuggLOC

   GOTO Quit

   Quit:
      IF @nDebugFlag = 1
         SELECT 'End 830SuggLoc07', @cNewSuggLOC AS NewSuggLOC
END
GO

GRANT EXECUTE ON rdt.rdt_830SuggestLOC07 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
