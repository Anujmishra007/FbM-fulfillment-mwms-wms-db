SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_957GetTask03                                          */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date       Rev    Author     Purposes                                      */
/* 2025-04-07 1.0.0  NLT013     FCR-2704 Created                              */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_957GetTask03] (
    @nMobile          INT
   ,@nFunc            INT
   ,@cLangCode        NVARCHAR( 3)
   ,@nStep            INT
   ,@nInputKey        INT
   ,@cFacility        NVARCHAR( 5)
   ,@cStorerKey       NVARCHAR( 15)
   ,@cType            NVARCHAR( 10) -- NEXTSKU / NEXTLOC
   ,@cPickSlipNo      NVARCHAR( 10)
   ,@cPickZone        NVARCHAR( 10)
   ,@cLOC             NVARCHAR( 10) OUTPUT
   ,@cSKU             NVARCHAR( 20) OUTPUT
   ,@cSKUDescr        NVARCHAR( 60) OUTPUT
   ,@nQTY             INT           OUTPUT
   ,@cID              NVARCHAR( 18) OUTPUT
   ,@cBarCode         NVARCHAR( 60)
   ,@nTotalQty        INT           OUTPUT
   ,@nErrNo           INT           OUTPUT
   ,@cErrMsg          NVARCHAR(250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSQL      NVARCHAR( MAX)
   DECLARE @cSQLParam NVARCHAR( MAX)

   DECLARE @cOrderKey   NVARCHAR( 10)
   DECLARE @cLoadKey    NVARCHAR( 10)
   DECLARE @cZone       NVARCHAR( 18)
   
   DECLARE @cSuggLOC    NVARCHAR( 10)
   DECLARE @cSuggID     NVARCHAR( 18)
   DECLARE @cSuggSKU    NVARCHAR( 20)
   DECLARE @nSuggQTY    INT

   DECLARE @cCurrLOC    NVARCHAR( 10)
   DECLARE @cCurrID     NVARCHAR( 18)
   DECLARE @cCurrLogicalLOC   NVARCHAR( 18)

   SET @nErrNo = 0 -- Require if calling GetTask multiple times (NEXTSKU then NEXTLOC)
   SET @cErrMsg = ''

   SET @cOrderKey = ''
   SET @cLoadKey = ''
   SET @cZone = ''

   SET @cCurrLOC = @cLOC
   SET @cCurrID  = @cID

   -- Get PickHeader info
   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cLoadKey = ExternOrderKey,
      @cZone = Zone
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   -- Get logical LOC
   SET @cCurrLogicalLOC = ''
   SELECT @cCurrLogicalLOC = LogicalLocation FROM LOC WITH (NOLOCK) WHERE LOC = @cCurrLOC


   /***********************************************************************************************
                                              Get next LOC
   ***********************************************************************************************/
   IF @cType = 'NEXTLOC'
   BEGIN
      -- Cross dock PickSlip
      IF @cZone IN ('XD', 'LB', 'LP')
      BEGIN
         IF @cPickZone = ''
            SELECT TOP 1
               @cSuggLOC = LOC.LOC,
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               --AND (LOC.LogicalLocation > @cCurrLogicalLOC
               --OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, PD.StorerKey, PD.SKU
         ELSE
            SELECT TOP 1
               @cSuggLOC = LOC.LOC,
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               AND Loc.PickZone = @cPickZone
               -- AND (LOC.LogicalLocation > @cCurrLogicalLOC
               -- OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, PD.StorerKey, PD.SKU
      END

      -- Discrete PickSlip
      ELSE IF @cOrderKey <> ''
      BEGIN
         IF @cPickZone = ''
            SELECT TOP 1
               @cSuggLOC = LOC.LOC,
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.OrderKey = @cOrderKey
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               -- AND (LOC.LogicalLocation > @cCurrLogicalLOC
               -- OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, PD.StorerKey, PD.SKU
         ELSE
            SELECT TOP 1
               @cSuggLOC = LOC.LOC,
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.OrderKey = @cOrderKey
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               -- AND (LOC.LogicalLocation > @cCurrLogicalLOC
               -- OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, PD.StorerKey, PD.SKU
      END

      -- Conso PickSlip
      ELSE IF @cLoadKey <> ''
      BEGIN
         IF @cPickZone = ''
            SELECT TOP 1
               @cSuggLOC = LOC.LOC,
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
               JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE LPD.LoadKey = @cLoadKey
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               -- AND (LOC.LogicalLocation > @cCurrLogicalLOC
               -- OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, PD.StorerKey, PD.SKU
         ELSE
            SELECT TOP 1
               @cSuggLOC = LOC.LOC,
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
               JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE LPD.LoadKey = @cLoadKey
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               -- AND (LOC.LogicalLocation > @cCurrLogicalLOC
               -- OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, PD.StorerKey, PD.SKU
      END

      -- Custom PickSlip
      ELSE
      BEGIN
         IF @cPickZone = ''
            SELECT TOP 1
               @cSuggLOC = LOC.LOC,
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               -- AND (LOC.LogicalLocation > @cCurrLogicalLOC
               -- OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, PD.StorerKey, PD.SKU
         ELSE
            SELECT TOP 1
               @cSuggLOC = LOC.LOC,
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               -- AND (LOC.LogicalLocation > @cCurrLogicalLOC
               -- OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, PD.StorerKey, PD.SKU
      END
   END


   /***********************************************************************************************
                                              Get next SKU
   ***********************************************************************************************/
   ELSE IF @cType = 'NEXTUCC'
   BEGIN
      SET @cSuggLOC = @cCurrLOC

      -- Cross dock PickSlip
      IF @cZone IN ('XD', 'LB', 'LP')
      BEGIN
         IF @cPickZone = ''
            SELECT TOP 1
               @cSuggSKU = PD.SKU,
               @cSuggID  = PD.ID,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               AND LOC.LOC = @cCurrLOC
               AND PD.ID   = @cCurrID
            GROUP BY PD.ID, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, PD.StorerKey, PD.SKU
         ELSE
            SELECT TOP 1
               @cSuggSKU = PD.SKU,
               @cSuggID  = PD.ID,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               AND LOC.LOC = @cCurrLOC
               AND PD.ID   = @cCurrID
            GROUP BY PD.ID, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, PD.StorerKey, PD.SKU
      END

      -- Discrete PickSlip
      ELSE IF @cOrderKey <> ''
      BEGIN
         IF @cPickZone = ''
            SELECT TOP 1
               @cSuggSKU = PD.SKU,
               @cSuggID  = PD.ID,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.OrderKey = @cOrderKey
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               AND LOC.LOC = @cCurrLOC
               AND PD.ID   = @cCurrID
            GROUP BY PD.ID, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, PD.StorerKey, PD.SKU
         ELSE
            SELECT TOP 1
               @cSuggSKU = PD.SKU,
               @cSuggID  = PD.ID,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.OrderKey = @cOrderKey
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               AND LOC.LOC = @cCurrLOC
               AND PD.ID   = @cCurrID
            GROUP BY PD.ID, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, PD.StorerKey, PD.SKU
      END

      -- Conso PickSlip
      ELSE IF @cLoadKey <> ''
      BEGIN
         IF @cPickZone = ''
            SELECT TOP 1
               @cSuggSKU = PD.SKU,
               @cSuggID  = PD.ID,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
               JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE LPD.LoadKey = @cLoadKey
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               AND LOC.LOC = @cCurrLOC
               AND PD.ID   = @cCurrID
            GROUP BY PD.ID, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, PD.StorerKey, PD.SKU
         ELSE
            SELECT TOP 1
               @cSuggSKU = PD.SKU,
               @cSuggID  = PD.ID,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
               JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE LPD.LoadKey = @cLoadKey
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               AND LOC.LOC = @cCurrLOC
               AND PD.ID   = @cCurrID
            GROUP BY PD.ID, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, PD.StorerKey, PD.SKU
      END

      -- Custom PickSlip
      ELSE
      BEGIN
         IF @cPickZone = ''
            SELECT TOP 1
               @cSuggSKU = PD.SKU,
               @cSuggID  = PD.ID,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               AND LOC.LOC = @cCurrLOC
               AND PD.ID   = @cCurrID
               GROUP BY PD.ID, PD.StorerKey, PD.SKU
               ORDER BY PD.ID, PD.StorerKey, PD.SKU
         ELSE
            SELECT TOP 1
               @cSuggSKU = PD.SKU,
               @cSuggID  = PD.ID,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               AND LOC.LOC = @cCurrLOC
               AND PD.ID   = @cCurrID
               GROUP BY PD.ID, PD.StorerKey, PD.SKU
               ORDER BY PD.ID, PD.StorerKey, PD.SKU
      END


   END


   /***********************************************************************************************
                                              Get next ID
   ***********************************************************************************************/
   ELSE IF @cType = 'NEXTID'
   BEGIN
      SET @cSuggLOC = @cCurrLOC

      -- Cross dock PickSlip
      IF @cZone IN ('XD', 'LB', 'LP')
      BEGIN
         IF @cPickZone = ''
            SELECT TOP 1
               @cSuggSKU = PD.SKU,
               @cSuggID  = PD.ID,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               AND LOC.LOC = @cCurrLOC
               --AND PD.ID   > @cCurrID
            GROUP BY PD.ID, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, PD.StorerKey, PD.SKU
         ELSE
            SELECT TOP 1
               @cSuggSKU = PD.SKU,
               @cSuggID  = PD.ID,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               AND LOC.LOC = @cCurrLOC
               -- AND PD.ID   > @cCurrID
            GROUP BY PD.ID, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, PD.StorerKey, PD.SKU
      END

      -- Discrete PickSlip
      ELSE IF @cOrderKey <> ''
      BEGIN
         IF @cPickZone = ''
            SELECT TOP 1
               @cSuggSKU = PD.SKU,
               @cSuggID  = PD.ID,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.OrderKey = @cOrderKey
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               AND LOC.LOC = @cCurrLOC
               --AND PD.ID   > @cCurrID
            GROUP BY PD.ID, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, PD.StorerKey, PD.SKU
         ELSE
            SELECT TOP 1
               @cSuggSKU = PD.SKU,
               @cSuggID  = PD.ID,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.OrderKey = @cOrderKey
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               AND LOC.LOC = @cCurrLOC
               -- AND PD.ID   > @cCurrID
            GROUP BY PD.ID, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, PD.StorerKey, PD.SKU
      END

      -- Conso PickSlip
      ELSE IF @cLoadKey <> ''
      BEGIN
         IF @cPickZone = ''
            SELECT TOP 1
               @cSuggSKU = PD.SKU,
               @cSuggID  = PD.ID,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
               JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE LPD.LoadKey = @cLoadKey
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               AND LOC.LOC = @cCurrLOC
               --AND PD.ID   > @cCurrID
            GROUP BY PD.ID, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, PD.StorerKey, PD.SKU
         ELSE
            SELECT TOP 1
               @cSuggSKU = PD.SKU,
               @cSuggID  = PD.ID,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
               JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE LPD.LoadKey = @cLoadKey
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               AND LOC.LOC = @cCurrLOC
               -- AND PD.ID   > @cCurrID
            GROUP BY PD.ID, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, PD.StorerKey, PD.SKU
      END

      -- Custom PickSlip
      ELSE
      BEGIN
         IF @cPickZone = ''
            SELECT TOP 1
               @cSuggSKU = PD.SKU,
               @cSuggID  = PD.ID,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               AND LOC.LOC = @cCurrLOC
               --AND PD.ID   > @cCurrID
               GROUP BY PD.ID, PD.StorerKey, PD.SKU
               ORDER BY PD.ID, PD.StorerKey, PD.SKU
         ELSE
            SELECT TOP 1
               @cSuggSKU = PD.SKU,
               @cSuggID  = PD.ID,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.Status = '0'
               AND LOC.LOC = @cCurrLOC
               -- AND PD.ID   > @cCurrID
               GROUP BY PD.ID, PD.StorerKey, PD.SKU
               ORDER BY PD.ID, PD.StorerKey, PD.SKU
      END
   END


   /***********************************************************************************************
                                              Return task
   ***********************************************************************************************/
   IF @cSuggSKU IS NULL
   BEGIN
      SET @nErrNo = 209701
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No more task
      SET @nErrNo = -1 -- No more task
   END
   ELSE
   BEGIN
      SET @cLOC = @cSuggLOC
      SET @cID  = @cSuggID
      SET @cSKU = @cSuggSKU
      
      -- Cross dock PickSlip
      IF @cZone IN ('XD', 'LB', 'LP')
      BEGIN
         IF @cPickZone = ''
         BEGIN
            -- Total case (at loc level)
            SELECT @nQTY = COUNT( DISTINCT PD.DropID)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.LOC = @cSuggLOC
               
            -- Total scan (at loc level)
            SELECT @nTotalQTY = COUNT( DISTINCT PD.DropID)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               AND PD.Status IN ('3', '5')
               AND PD.LOC = @cSuggLOC
         END
         ELSE
         BEGIN
            -- Total case (at loc level)
            SELECT @nQTY = COUNT( DISTINCT PD.DropID)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.LOC = @cSuggLOC
            
            -- Total scan (at loc level)
            SELECT @nTotalQTY = COUNT( DISTINCT PD.DropID)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status IN ('3', '5')
               AND PD.LOC = @cSuggLOC
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

GRANT EXECUTE ON  [RDT].[rdt_957GetTask03] TO [NSQL]
GO
