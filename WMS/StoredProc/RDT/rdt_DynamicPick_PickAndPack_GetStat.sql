IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[RDT].[rdt_DynamicPick_PickAndPack_GetStat]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_DynamicPick_PickAndPack_GetStat]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_DynamicPick_PickAndPack_GetStat                 */
/* Copyright      : LFLogistics                                         */
/*                                                                      */
/* Purpose: Get statistics, total/balance of a pick slip                */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 01-Aug-2016 1.0  Ung         SOS375224 Created                       */
/************************************************************************/

CREATE PROC [RDT].[rdt_DynamicPick_PickAndPack_GetStat] (
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nStep         INT,
   @nInputKey     INT,
   @cFacility     NVARCHAR( 5),
   @cStorerKey    NVARCHAR( 15),
   @cPickSlipType NVARCHAR( 10),
   @cPickSlipNo   NVARCHAR( 10),
   @cPickZone     NVARCHAR( 10), 
   @cFromLOC      NVARCHAR( 10), 
   @cToLOC        NVARCHAR( 10), 
   @cType         NVARCHAR( 10),  -- Balance/Total
   @nQTY          INT           OUTPUT,
   @nErrNo        INT           OUTPUT, 
   @cErrMsg       NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSQL      NVARCHAR( MAX)
   DECLARE @cSQLParam NVARCHAR( MAX)

   DECLARE @cDynCheckUOM NVARCHAR(1)
   SET @cDynCheckUOM = rdt.RDTGetConfig( @nFunc, 'DynCheckUOM', @cStorerKey)

   -- Get statistic
   IF @cPickSlipType = 'X'
      SET @cSQL = @cSQL +
         ' SELECT @nQTY = ISNULL( SUM( PD.QTY), 0) ' + 
         ' FROM dbo.RefKeyLookup RKL WITH (NOLOCK) ' + 
         '    JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey) ' + 
         '    JOIN dbo.LOC WITH (NOLOCK) ON (PD.LOC = LOC.LOC) ' + 
         ' WHERE RKL.PickSlipNo = @cPickSlipNo ' + 
         '    AND PD.QTY > 0 ' 

   ELSE IF @cPickSlipType = 'D'
      SET @cSQL = @cSQL +
         ' SELECT @nQTY = ISNULL( SUM( PD.QTY), 0) ' + 
         ' FROM dbo.PickHeader PH WITH (NOLOCK) ' + 
         '    JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PH.OrderKey = PD.OrderKey) ' + 
         '    JOIN dbo.LOC WITH (NOLOCK) ON (PD.LOC = LOC.LOC) ' + 
         ' WHERE PH.PickHeaderKey = @cPickSlipNo ' + 
         '    AND PD.QTY > 0 ' 

   ELSE IF @cPickSlipType = 'C'
      SET @cSQL = @cSQL +
         ' SELECT @nQTY = ISNULL( SUM( PD.QTY), 0) ' + 
         ' FROM dbo.PickHeader PH WITH (NOLOCK) ' + 
         '    JOIN dbo.LoadPlanDetail LPD WITH (NOLOCK) ON (PH.ExternOrderKey = LPD.LoadKey) ' + 
         '    JOIN dbo.PickDetail PD WITH (NOLOCK) ON (LPD.OrderKey = PD.OrderKey) ' + 
         '    JOIN dbo.LOC WITH (NOLOCK) ON (PD.LOC = LOC.LOC) ' + 
         ' WHERE PH.PickHeaderKey = @cPickSlipNo ' + 
         '    AND PD.QTY > 0 ' 

   IF @cPickZone <> ''
      SET @cSQL = @cSQL + ' AND LOC.PickZone = @cPickZone '

   IF @cFromLOC <> ''
      SET @cSQL = @cSQL +
         ' AND LOC.LOC BETWEEN @cFromLoc AND @cToLoc ' + 
         ' AND PD.LOC BETWEEN  @cFromLoc AND @cToLoc '

   IF @cDynCheckUOM = '1'
      SET @cSQL = @cSQL + ' AND PD.UOM <> ''2'' '

   SET @cSQLParam = 
      '@cPickSlipNo NVARCHAR(10), ' + 
      '@cPickZone   NVARCHAR(10), ' + 
      '@cFromLOC    NVARCHAR(10), ' + 
      '@cToLOC      NVARCHAR(10), ' + 
      '@nQTY        INT OUTPUT    '
   
   IF @cType = 'BALANCE'
      SET @cSQL = @cSQL + ' AND PD.Status < ''3'' '

   IF @cType = 'TOTAL'
      SET @cSQL = @cSQL + ' AND PD.Status <= ''3'' '

   EXEC sp_ExecuteSQL @cSQL, @cSQLParam, 
      @cPickSlipNo = @cPickSlipNo, 
      @cPickZone     = @cPickZone, 
      @cFromLOC    = @cFromLOC, 
      @cToLOC      = @cToLOC, 
      @nQTY        = @nQTY OUTPUT

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_DynamicPick_PickAndPack_GetStat to nSQL
GO

