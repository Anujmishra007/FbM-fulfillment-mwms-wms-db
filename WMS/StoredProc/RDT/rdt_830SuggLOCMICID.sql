SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************************************/
/* Store procedure: rdt_830SuggLOCMICID                                          */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose: Suggest LOC, lock by pickzone and aisle                              */
/*                                                                               */
/* Date        Rev  Author      Purposes                                         */
/* 2025-11-28  1.0  PYU015      FCR-9333  Created                                */
/*********************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_830SuggLOCMICID]
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR(3),
   @nStep         INT,
   @nInputKey     INT,
   @cFacility     NVARCHAR(5),
   @cStorerKey    NVARCHAR(15),
   @cPickSlipNo   NVARCHAR(10),
   @cPickZone     NVARCHAR(10),
   @cLOC          NVARCHAR(10),
   @cSuggLOC      NVARCHAR(10) OUTPUT,
   @nErrNo        INT          OUTPUT,
   @cErrMsg       NVARCHAR(20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSQL               NVARCHAR(MAX)
   DECLARE @cSQLCommonFrom     NVARCHAR(MAX)
   DECLARE @cSQLCommonWhere    NVARCHAR(MAX)
   DECLARE @cSQLCommonParam    NVARCHAR(MAX)

   DECLARE @cOrderKey          NVARCHAR(10)
   DECLARE @cLoadKey           NVARCHAR(10)
   DECLARE @cZone              NVARCHAR(18)
   DECLARE @cPickConfirmStatus NVARCHAR(1)
   DECLARE @cPickFilter        NVARCHAR(MAX)  = ''

   -- Get storer config
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'

   -- Get PickHeader info
   SELECT TOP 1
          @cOrderKey = OrderKey,
          @cLoadKey = ExternOrderKey,
          @cZone = Zone
     FROM dbo.PickHeader WITH (NOLOCK)
    WHERE PickHeaderKey = @cPickSlipNo

   -- Get pick filter
   SELECT @cPickFilter = ISNULL( Long, '')
     FROM CodeLKUP WITH (NOLOCK) 
    WHERE ListName = 'PickFilter'
      AND Code = @nFunc 
      AND StorerKey = @cStorerKey
      AND Code2 = @cFacility


   /***********************************************************************************************
                                             Built common SQL
   ***********************************************************************************************/
   -- Cross dock PickSlip
   IF @cZone IN ('XD', 'LB', 'LP')
   BEGIN
      SET @cSQLCommonFrom =
         ' FROM dbo.RefKeyLookup RKL WITH (NOLOCK) ' +
         ' JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey) ' +
         ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) '
      SET @cSQLCommonWhere =
         ' WHERE RKL.PickSlipNo = @cPickSlipNo ' +
           ' AND PD.QTY > 0 ' +
           ' AND PD.Status <> ''4'' ' +
           ' AND PD.Status < @cPickConfirmStatus '
   END

   -- Discrete PickSlip
   ELSE IF @cOrderKey <> ''
   BEGIN
      SET @cSQLCommonFrom =
         ' FROM dbo.PickDetail PD WITH (NOLOCK) ' +
         ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) '
      SET @cSQLCommonWhere =
         ' WHERE PD.OrderKey = @cOrderKey ' +
           ' AND PD.QTY > 0 ' +
           ' AND PD.Status <> ''4'' ' +
           ' AND PD.Status < @cPickConfirmStatus '
   END

   -- Conso PickSlip
   ELSE IF @cLoadKey <> ''
   BEGIN
      SET @cSQLCommonFrom =
         ' FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) ' +
         ' JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey) ' +
         ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) '
      SET @cSQLCommonWhere =
         ' WHERE LPD.LoadKey = @cLoadKey ' +
           ' AND PD.QTY > 0 ' +
           ' AND PD.Status <> ''4'' ' +
           ' AND PD.Status < @cPickConfirmStatus '
   END

   -- Custom PickSlip
   ELSE
   BEGIN
      SET @cSQLCommonFrom =
         ' FROM dbo.PickDetail PD WITH (NOLOCK) ' +
         ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) '
      SET @cSQLCommonWhere =
         ' WHERE PD.PickSlipNo = @cPickSlipNo ' +
           ' AND PD.QTY > 0 ' +
           ' AND PD.Status <> ''4'' ' +
           ' AND PD.Status < @cPickConfirmStatus '
   END

   SET @cSQLCommonParam =
      '@cPickSlipNo        NVARCHAR(10), ' +
      '@cOrderKey          NVARCHAR(10), ' +
      '@cLoadKey           NVARCHAR(10), ' +
      '@cPickConfirmStatus NVARCHAR(1),  ' +
      '@cLOCAisle          NVARCHAR(10) = '''', ' +
      '@cLogicalLOC        NVARCHAR(18) = '''', ' +
      '@cLOC               NVARCHAR(10) = '''', ' +
      '@cNewSuggLOC        NVARCHAR(10) = '''' OUTPUT, ' +
      '@cNewSuggAisle      NVARCHAR(10) = '''' OUTPUT  '



   /***********************************************************************************************
                                             Get suggest LOC
   ***********************************************************************************************/
   DECLARE @cLOCAisle      NVARCHAR( 10) = ''
   DECLARE @cLogicalLOC    NVARCHAR( 18) = ''
   DECLARE @cPickSEQ       NVARCHAR(4000)  = ''
   DECLARE @cNewSuggLOC    NVARCHAR( 10) = ''
   DECLARE @cNewSuggAisle  NVARCHAR( 10) = ''

   -- Get loc info
   IF @cLOC <> ''
      SELECT
         @cLogicalLOC = ISNULL( LogicalLocation, ''),
         @cLOCAisle = ISNULL( LOCAisle, '')
      FROM LOC WITH (NOLOCK)
      WHERE LOC = @cLOC


   --Check if custom Sequence configured
   SET @cPickSEQ = ''

   IF @cOrderKey <> ''
   BEGIN

      SELECT TOP 1 @cPickSEQ = CL.NOTES
      FROM CODELKUP CL WITH (NOLOCK)
      JOIN ORDERS O WITH (NOLOCK) ON CL.CODE = O.BILLTOKEY
                                 AND CL.STORERKEY = O.STORERKEY
      WHERE CL.LISTNAME = 'CUST830SEQ'
      AND O.ORDERKEY = @cOrderKey

      IF ISNULL(@cPickSEQ,'') = ''
      BEGIN
         SET @cPickSEQ = ''
      END

   END


   -- Build get suggest LOC
   SET @cSQL =
         ' SELECT TOP 1 ' +
         ' @cNewSuggLOC = LOC.LOC,       ' +
         ' @cNewSuggAisle = LOC.LOCAisle ' +
         @cSQLCommonFrom +
         @cSQLCommonWhere +
         CASE WHEN @cPickZone = '' THEN '' ELSE ' AND LOC.PickZone = @cPickZone ' END +
         CASE WHEN @cPickFilter = '' THEN '' ELSE @cPickFilter END + 
         ' GROUP BY LOC.LOCAisle, LOC.LogicalLocation, LOC.LOC ' + CASE WHEN ISNULL(@cPickSEQ,'') = '' THEN '' ELSE ',' + @cPickSEQ  END +
         ' ORDER BY ' +
         CASE WHEN ISNULL(@cPickSEQ,'') = '' THEN '' ELSE @cPickSEQ + ',' END +
         ' LOC.LOCAisle, ' +
         ' LOC.LogicalLocation, ' +
         ' LOC.LOC '

   -- Get suggest LOC
   EXEC sp_executeSQL @cSQL, @cSQLCommonParam,
      @cPickSlipNo = @cPickSlipNo,
      @cOrderKey   = @cOrderKey,
      @cLoadKey    = @cLoadKey,
      @cLOCAisle   = @cLOCAisle,
      @cLogicalLOC = @cLogicalLOC,
      @cLOC        = @cLOC,
      @cNewSuggLOC = @cNewSuggLOC OUTPUT,
      @cNewSuggAisle = @cNewSuggAisle OUTPUT,
      @cPickConfirmStatus = @cPickConfirmStatus

   IF ISNULL(@cLOC,'') <> '' AND ISNULL(@cNewSuggLOC,'') <> ''
      SET @cNewSuggLOC = ''

   -- Found suggest LOC
   IF @cNewSuggLOC = ''
   BEGIN
      SET @nErrNo = 219986
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No more task
      SET @nErrNo = -1 -- No more task
   END

   IF @cNewSuggLOC <> ''
   BEGIN
      SET @cSuggLOC = @cNewSuggLOC
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_830SuggLOCMICID] TO NSQL
GO
