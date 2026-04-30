SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************************************************************************/
/* Store procedure: rdt_839GetTaskSP17                                  */
/* Copyright      : Maersk                                              */
/* Customer       : India PAGEIND                                       */
/*                                                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-01-09 1.0  NickT      FCR-9040 Get SuggestID                    */
/************************************************************************/
      
CREATE OR ALTER PROC [RDT].[rdt_839GetTaskSP17] (
  @nMobile          INT,                
  @nFunc            INT,                
  @cLangCode        NVARCHAR( 3),       
  @nStep            INT,                
  @nInputKey        INT,                
  @cFacility        NVARCHAR( 5) ,      
  @cStorerKey       NVARCHAR( 15),      
  @cType            NVARCHAR( 10),      
  @cPickSlipNo      NVARCHAR( 10),      
  @cPickZone        NVARCHAR( 10),       
  @nLottableOnPage  INT,    
  @cLOC             NVARCHAR( 10) OUTPUT,       
  @cSKU             NVARCHAR( 20) OUTPUT,       
  @cSKUDescr        NVARCHAR( 60) OUTPUT,       
  @nQTY             INT           OUTPUT,       
  @cDisableQTYField NVARCHAR( 1)  OUTPUT,       
  @cLottableCode    NVARCHAR( 30) OUTPUT,       
  @cLottable01      NVARCHAR( 18) OUTPUT,        
  @cLottable02      NVARCHAR( 18) OUTPUT,        
  @cLottable03      NVARCHAR( 18) OUTPUT,        
  @dLottable04      DATETIME      OUTPUT,        
  @dLottable05      DATETIME      OUTPUT,        
  @cLottable06      NVARCHAR( 30) OUTPUT,       
  @cLottable07      NVARCHAR( 30) OUTPUT,       
  @cLottable08      NVARCHAR( 30) OUTPUT,       
  @cLottable09      NVARCHAR( 30) OUTPUT,       
  @cLottable10      NVARCHAR( 30) OUTPUT,       
  @cLottable11      NVARCHAR( 30) OUTPUT,       
  @cLottable12      NVARCHAR( 30) OUTPUT,       
  @dLottable13      DATETIME      OUTPUT,       
  @dLottable14      DATETIME      OUTPUT,       
  @dLottable15      DATETIME      OUTPUT,       
  @nErrNo           INT           OUTPUT,       
  @cErrMsg          NVARCHAR(250) OUTPUT,  
  @cSuggID          NVARCHAR(20)  OUTPUT,   
  @nTtlBalQty      INT            OUTPUT,   
  @nBalQty         INT            OUTPUT, 
  @cSKUSerialNoCapture NVARCHAR(1) OUTPUT 
)          
AS    
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSQL      NVARCHAR( MAX)
   DECLARE @cSQLParam NVARCHAR( MAX)
   DECLARE @cGetTaskSP NVARCHAR( 20)
   DECLARE @cTempLottable01 NVARCHAR( 18)
   DECLARE @cTempLottable02 NVARCHAR( 18)
   DECLARE @cTempLottable03 NVARCHAR( 18)
   DECLARE @dTempLottable04 DATETIME
   DECLARE @dTempLottable05 DATETIME
   DECLARE @cTempLottable06 NVARCHAR( 30)
   DECLARE @cTempLottable07 NVARCHAR( 30)
   DECLARE @cTempLottable08 NVARCHAR( 30)
   DECLARE @cTempLottable09 NVARCHAR( 30)
   DECLARE @cTempLottable10 NVARCHAR( 30)
   DECLARE @cTempLottable11 NVARCHAR( 30)
   DECLARE @cTempLottable12 NVARCHAR( 30)
   DECLARE @dTempLottable13 DATETIME
   DECLARE @dTempLottable14 DATETIME
   DECLARE @dTempLottable15 DATETIME
   DECLARE @cTempLottableCode NVARCHAR( 30)
   DECLARE @cGetNextSKU NVARCHAR( 1)
   DECLARE @cCheckNextZone NVARCHAR( 1)
   DECLARE @cSuggUCC NVARCHAR(20)
   DECLARE @nRowCount INT
   DECLARE @cUCCorPiecePick  NVARCHAR( 5)
   DECLARE @cLot  NVARCHAR( 10)
   

   SET @nErrNo = 0 -- Require if calling GetTask multiple times (NEXTSKU then NEXTLOC)
   SET @cErrMsg = ''

   /***********************************************************************************************
                                              Standard get task
   ***********************************************************************************************/
   DECLARE @cOrderKey   NVARCHAR( 10)
   DECLARE @cLoadKey    NVARCHAR( 10)
   DECLARE @cZone       NVARCHAR( 18)
   DECLARE @cSuggSKU    NVARCHAR( 20)
   DECLARE @cSuggLOC    NVARCHAR( 10)
   DECLARE @nSuggQTY    INT
   DECLARE @cCurrLogicalLOC    NVARCHAR( 18)
   DECLARE @cCurrLOC           NVARCHAR( 10)
   DECLARE @cCurrUCC           NVARCHAR( 20)
   DECLARE @cCurrLOT           NVARCHAR( 10)
   DECLARE @cPickConfirmStatus NVARCHAR( 1)

   DECLARE @cSelect  NVARCHAR( MAX)
   DECLARE @cFrom    NVARCHAR( MAX)
   DECLARE @cWhere1  NVARCHAR( MAX)
   DECLARE @cWhere2  NVARCHAR( MAX)
   DECLARE @cGroupBy NVARCHAR( MAX)
   DECLARE @cOrderBy NVARCHAR( MAX)
   DECLARE @cCurrSKU NVARCHAR( 20)
   DECLARE @cUserName NVARCHAR( 128)
   DECLARE @cSuggestedUCC NVARCHAR( 20)
   DECLARE @cSuggestedPieceLOT NVARCHAR( 10)
   DECLARE @cUOM  NVARCHAR( 5)

   SET @cOrderKey = ''
   SET @cLoadKey = ''
   SET @cZone = ''

   SELECT
      @cSuggestedUCC = C_String1,
      @cSuggestedPieceLOT = C_String2,
      @cUOM = C_String6,
      @cUserName = UserName
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   SET @cCurrLOC = @cLOC
   SET @cCurrSKU = CASE WHEN @cType = 'BALPICK' THEN @cSKU ELSE '' END

   SET @cCurrUCC = ''

   IF @cType = 'BALPICK'
   BEGIN
      IF @cUOM = '2'
      BEGIN
         SELECT @cCurrLOT = LOT
         FROM dbo.UCC WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND UCCNo = @cSuggestedUCC

         SET @cCurrUCC = @cSuggestedUCC
      END
      ELSE IF @cUOM = '6'
      BEGIN
         SET @cCurrLOT = @cSuggestedPieceLOT
      END
   END
   ELSE
      SET @cCurrLOT = ''

   SET @cCurrLOT = ISNULL(@cCurrLOT, '')

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

   -- Get logical LOC
   SET @cCurrLogicalLOC = ''
   SELECT @cCurrLogicalLOC = LogicalLocation FROM LOC WITH (NOLOCK) WHERE LOC = @cCurrLOC

   SET @cUCCorPiecePick = 'UCC'

   UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
   SET 
      C_String1 = '',
      C_String2 = ''
   WHERE Mobile = @nMobile

   DROP TABLE IF EXISTS #ExistingPickLogs

   CREATE TABLE #ExistingPickLogs (
      PickDetailKey     NVARCHAR(10) NOT NULL,
      PickMethod        NVARCHAR(10),
      Status            NVARCHAR(1),
      Mobile            INT,
      AddWho            NVARCHAR(128)
   )

   INSERT INTO #ExistingPickLogs
   SELECT PickDetailKey, PickMethod, Status, Mobile, AddWho
   FROM [RDT].[rdtPickLog] WITH(NOLOCK)
   WHERE PickSlipNo = @cPickSlipNo

   CREATE NONCLUSTERED INDEX IX_EPL_Search 
   ON #ExistingPickLogs (PickDetailKey, PickMethod) 
   INCLUDE (Status, Mobile, AddWho)

   /***********************************************************************************************
                                              Get next Zone
   ***********************************************************************************************/
   IF @cType = 'NEXTZONE' --AND @cCheckNextZone = '1'
   BEGIN
      -- Cross dock PickSlip
      IF @cZone IN ('XD', 'LB', 'LP')
      BEGIN
         IF @cPickZone = ''
         BEGIN
            -- UCC
            SELECT TOP 1
               @cSuggLOC = LOC.LOC, 
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND PD.Status < @cPickConfirmStatus
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND (LOC.LogicalLocation > @cCurrLogicalLOC
               OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
                  AND PD.Status < @cPickConfirmStatus
            END

            -- Piece in UCC
            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggLOC = LOC.LOC,
                  @cSuggSKU = PD.SKU,
                  @cLot = PD.LOT,
                  @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
               LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
               GROUP BY LOC.LogicalLocation, LOC.LOC, PD.Lot, PD.StorerKey, PD.SKU
               ORDER BY LOC.LogicalLocation, LOC.LOC, PD.Lot, PD.StorerKey, PD.SKU

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cSuggLOC = LOC.LOC, 
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone <> @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND (LOC.LogicalLocation > @cCurrLogicalLOC
               OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone <> @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            -- Piece in UCC
            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggLOC = LOC.LOC,
                  @cSuggSKU = PD.SKU,
                  @cLot = PD.LOT,
                  @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone <> @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
               GROUP BY LOC.LogicalLocation, LOC.LOC, PD.Lot, PD.StorerKey, PD.SKU
               ORDER BY LOC.LogicalLocation, LOC.LOC, PD.Lot, PD.StorerKey, PD.SKU

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone <> @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
      END

      -- Discrete PickSlip
      ELSE IF @cOrderKey <> ''
      BEGIN
         IF @cPickZone = ''
         BEGIN
            SELECT TOP 1
               @cSuggLOC = LOC.LOC, 
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE PD.OrderKey = @cOrderKey
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND (LOC.LogicalLocation > @cCurrLogicalLOC
               OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
               INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            -- Piece in UCC
            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggLOC = LOC.LOC,
                  @cSuggSKU = PD.SKU,
                  @cLot = PD.LOT,
                  @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
               GROUP BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU
               ORDER BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone <> @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cSuggLOC = LOC.LOC,
               @cSuggID  = PD.ID, 
               @cSuggUCC = UCC.UCCNo,
               @cSuggSKU = PD.SKU, 
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE PD.OrderKey = @cOrderKey
               AND LOC.PickZone <> @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND (LOC.LogicalLocation > @cCurrLogicalLOC
               OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
               INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND LOC.PickZone <> @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            -- Piece in UCC
            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggLOC = LOC.LOC,
                  @cSuggSKU = PD.SKU,
                  @cLot = PD.LOT,
                  @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND LOC.PickZone <> @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
               GROUP BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU
               ORDER BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND LOC.PickZone <> @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
      END

      -- Conso PickSlip
      ELSE IF @cLoadKey <> ''
      BEGIN
         IF @cPickZone = ''
         BEGIN
            SELECT TOP 1
               @cSuggLOC = LOC.LOC,
               @cSuggID  = PD.ID, 
               @cSuggSKU = PD.SKU, 
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
            INNER JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
            INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE LPD.LoadKey = @cLoadKey  
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND (LOC.LogicalLocation > @cCurrLogicalLOC
               OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
               INNER JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
               INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey  
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            -- Piece in UCC
            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggLOC = LOC.LOC,
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT,
                  @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
               GROUP BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU
               ORDER BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cSuggLOC = LOC.LOC, 
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU, 
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
            INNER JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
            INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE LPD.LoadKey = @cLoadKey  
               AND LOC.PickZone <> @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND (LOC.LogicalLocation > @cCurrLogicalLOC
               OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
               INNER JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
               INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey  
                  AND LOC.PickZone <> @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggLOC = LOC.LOC,
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT,
                  @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey
                  AND LOC.PickZone <> @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
               GROUP BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU
               ORDER BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey
                  AND LOC.PickZone <> @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
      END

      -- Custom PickSlip
      ELSE
      BEGIN
         IF @cPickZone = ''
         BEGIN
            SELECT TOP 1
               @cSuggLOC = LOC.LOC, 
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU, 
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND (LOC.LogicalLocation > @cCurrLogicalLOC
               OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
               INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggLOC = LOC.LOC,
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT,
                  @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
               GROUP BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU
               ORDER BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cSuggLOC = LOC.LOC, 
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU, 
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone <> @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND (LOC.LogicalLocation > @cCurrLogicalLOC
               OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
               INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone <> @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggLOC = LOC.LOC,
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT,
                  @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone <> @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
               GROUP BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU
               ORDER BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone <> @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
      END
   END

   /***********************************************************************************************
                                              Get next LOC
   ***********************************************************************************************/
   IF @cType = 'NEXTLOC'
   BEGIN
      -- Cross dock PickSlip
      IF @cZone IN ('XD', 'LB', 'LP')
      BEGIN
         IF @cPickZone = ''
         BEGIN
            SELECT TOP 1
               @cSuggLOC = LOC.LOC, 
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU, 
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND (LOC.LogicalLocation > @cCurrLogicalLOC
               OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggLOC = LOC.LOC,
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT,
                  @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
               GROUP BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU
               ORDER BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cSuggLOC = LOC.LOC, 
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU, 
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND (LOC.LogicalLocation > @cCurrLogicalLOC
               OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggLOC = LOC.LOC,
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT,
                  @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
               GROUP BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU
               ORDER BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
      END

      -- Discrete PickSlip
      ELSE IF @cOrderKey <> ''
      BEGIN
         IF @cPickZone = ''
         BEGIN
            SELECT TOP 1
               @cSuggLOC = LOC.LOC, 
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU, 
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE PD.OrderKey = @cOrderKey
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND (LOC.LogicalLocation > @cCurrLogicalLOC
               OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggLOC = LOC.LOC,
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT,
                  @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
               GROUP BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU
               ORDER BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cSuggLOC = LOC.LOC,
               @cSuggID  = PD.ID, 
               @cSuggSKU = PD.SKU, 
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE PD.OrderKey = @cOrderKey
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND (LOC.LogicalLocation > @cCurrLogicalLOC
               OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggLOC = LOC.LOC,
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT,
                  @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
               GROUP BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU
               ORDER BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
      END

      -- Conso PickSlip
      ELSE IF @cLoadKey <> ''
      BEGIN
         IF @cPickZone = ''
         BEGIN
            SELECT TOP 1
               @cSuggLOC = LOC.LOC,
               @cSuggID  = PD.ID, 
               @cSuggSKU = PD.SKU, 
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
            JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE LPD.LoadKey = @cLoadKey  
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND (LOC.LogicalLocation > @cCurrLogicalLOC
               OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
               JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey  
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggLOC = LOC.LOC,
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT,
                  @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Status IN ( '4', '9' ) AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.AddWho <> @cUserName AND EPL2.PickMethod = 'GetTask-U' AND EPL2.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL3 ON EPL3.AddWho <> @cUserName AND EPL3.PickMethod = 'Pick-P' AND EPL3.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL4 ON EPL4.Mobile = @nMobile AND EPL4.AddWho = @cUserName AND EPL4.PickMethod = 'Pick-P' AND EPL4.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND EPL3.PickDetailKey IS NULL
                  AND EPL4.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
               GROUP BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU
               ORDER BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cSuggLOC = LOC.LOC, 
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU, 
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
            JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE LPD.LoadKey = @cLoadKey  
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND (LOC.LogicalLocation > @cCurrLogicalLOC
               OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
               JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey  
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggLOC = LOC.LOC,
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT,
                  @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
               GROUP BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU
               ORDER BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
      END

      -- Custom PickSlip
      ELSE
      BEGIN
         IF @cPickZone = ''
         BEGIN
            SELECT TOP 1
               @cSuggLOC = LOC.LOC, 
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU, 
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND (LOC.LogicalLocation > @cCurrLogicalLOC
               OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggLOC = LOC.LOC,
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT,
                  @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
               GROUP BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU
               ORDER BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cSuggLOC = LOC.LOC, 
               @cSuggID  = PD.ID,
               @cSuggSKU = PD.SKU, 
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND (LOC.LogicalLocation > @cCurrLogicalLOC
               OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
            GROUP BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY LOC.LogicalLocation, LOC.LOC, PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggLOC = LOC.LOC,
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT,
                  @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND (LOC.LogicalLocation > @cCurrLogicalLOC
                  OR  (LOC.LogicalLocation = @cCurrLogicalLOC AND LOC.LOC > @cCurrLOC))
               GROUP BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU
               ORDER BY LOC.LogicalLocation, LOC.LOC, PD.LOT, PD.StorerKey, PD.SKU

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
      END
   END
   /***********************************************************************************************
                                              Get next SKU
   ***********************************************************************************************/
   ELSE IF @cType IN ( 'NEXTSKU', 'BALPICK')
   BEGIN
      SET @cSuggLOC = @cCurrLOC

      -- Cross dock PickSlip
      IF @cZone IN ('XD', 'LB', 'LP')
      BEGIN
         IF @cPickZone = ''
         BEGIN
            SELECT TOP 1
               @cSuggSKU = PD.SKU, 
               @cSuggID  = PD.ID,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND (( @cType = 'BALPICK' AND PD.DropID <> @cCurrUCC) OR
                     ( @cType = 'NEXTSKU' AND PD.DropID = PD.DropID))
               AND PD.Status < @cPickConfirmStatus
               AND LOC.LOC = @cCurrLOC
            GROUP BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END
         
            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT
                  --@nSuggQTY = ISNULL( SUM( PD.QTY), 0)      --INC0720911
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.LOC = @cCurrLOC
                  AND (( @cType = 'BALPICK' AND PD.LOT <> @cCurrLOT) OR
                     ( @cType = 'NEXTSKU' AND PD.SKU = PD.SKU))
               GROUP BY PD.StorerKey, PD.SKU, PD.LOT
               ORDER BY PD.StorerKey, PD.SKU, PD.LOT

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cSuggSKU = PD.SKU, 
               @cSuggID  = PD.ID,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND (( @cType = 'BALPICK' AND PD.DropID <> @cCurrUCC) OR
                     ( @cType = 'NEXTSKU' AND PD.DropID = PD.DropID))
               AND PD.Status < @cPickConfirmStatus
               AND LOC.LOC = @cCurrLOC
            GROUP BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT
                  --@nSuggQTY = ISNULL( SUM( PD.QTY), 0)    --INC0720911
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.LOC = @cCurrLOC
                  AND (( @cType = 'BALPICK' AND PD.LOT <> @cCurrLOT) OR
                     ( @cType = 'NEXTSKU' AND PD.SKU = PD.SKU))
               GROUP BY PD.StorerKey, PD.SKU, PD.LOT
               ORDER BY PD.StorerKey, PD.SKU, PD.LOT

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
      END

      -- Discrete PickSlip
      ELSE IF @cOrderKey <> ''
      BEGIN
         IF @cPickZone = ''
         BEGIN
            SELECT TOP 1
               @cSuggSKU = PD.SKU, 
               @cSuggID  = PD.ID,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE PD.OrderKey = @cOrderKey
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND (( @cType = 'BALPICK' AND PD.DropID <> @cCurrUCC) OR
                     ( @cType = 'NEXTSKU' AND PD.DropID = PD.DropID))
               AND LOC.LOC = @cCurrLOC
            GROUP BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT
                  --@nSuggQTY = ISNULL( SUM( PD.QTY), 0)    --INC0720911
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND PD.QTY > 0
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.LOC = @cCurrLOC
                  AND (( @cType = 'BALPICK' AND PD.LOT <> @cCurrLOT) OR
                     ( @cType = 'NEXTSKU' AND PD.SKU = PD.SKU))
               GROUP BY PD.StorerKey, PD.SKU, PD.LOT
               ORDER BY PD.StorerKey, PD.SKU, PD.LOT

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cSuggSKU = PD.SKU, 
               @cSuggID  = PD.ID,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE PD.OrderKey = @cOrderKey
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND (( @cType = 'BALPICK' AND PD.DropID <> @cCurrUCC) OR
                     ( @cType = 'NEXTSKU' AND PD.DropID = PD.DropID))
               AND PD.Status < @cPickConfirmStatus
               AND LOC.LOC = @cCurrLOC
            GROUP BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT
                  --@nSuggQTY = ISNULL( SUM( PD.QTY), 0)      --INC0720911
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.LOC = @cCurrLOC
                  AND (( @cType = 'BALPICK' AND PD.LOT <> @cCurrLOT) OR
                     ( @cType = 'NEXTSKU' AND PD.SKU = PD.SKU))
               GROUP BY PD.StorerKey, PD.SKU, PD.LOT
               ORDER BY PD.StorerKey, PD.SKU, PD.LOT

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
      END

      -- Conso PickSlip
      ELSE IF @cLoadKey <> ''
      BEGIN
         IF @cPickZone = ''
         BEGIN
            SELECT TOP 1
               @cSuggSKU = PD.SKU, 
               @cSuggID  = PD.ID,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
            JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE LPD.LoadKey = @cLoadKey  
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND (( @cType = 'BALPICK' AND PD.DropID <> @cCurrUCC) OR
                     ( @cType = 'NEXTSKU' AND PD.DropID = PD.DropID))
               AND PD.Status < @cPickConfirmStatus
               AND LOC.LOC = @cCurrLOC
            GROUP BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
               JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey  
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT
                  --@nSuggQTY = ISNULL( SUM( PD.QTY), 0)      --INC0720911
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.LOC = @cCurrLOC
                  AND (( @cType = 'BALPICK' AND PD.LOT <> @cCurrLOT) OR
                     ( @cType = 'NEXTSKU' AND PD.SKU = PD.SKU))
               GROUP BY PD.StorerKey, PD.SKU, PD.LOT
               ORDER BY PD.StorerKey, PD.SKU, PD.LOT

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cSuggSKU = PD.SKU, 
               @cSuggID  = PD.ID,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
            JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE LPD.LoadKey = @cLoadKey  
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND (( @cType = 'BALPICK' AND PD.DropID <> @cCurrUCC) OR
                     ( @cType = 'NEXTSKU' AND PD.DropID = PD.DropID))
               AND PD.Status < @cPickConfirmStatus
               AND LOC.LOC = @cCurrLOC
            GROUP BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
               JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey  
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT
                  --@nSuggQTY = ISNULL( SUM( PD.QTY), 0)      --INC0720911
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.LOC = @cCurrLOC
                  AND (( @cType = 'BALPICK' AND PD.LOT <> @cCurrLOT) OR
                     ( @cType = 'NEXTSKU' AND PD.SKU = PD.SKU))
               GROUP BY PD.StorerKey, PD.SKU, PD.LOT
               ORDER BY PD.StorerKey, PD.SKU, PD.LOT

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
      END

      -- Custom PickSlip
      ELSE
      BEGIN
         IF @cPickZone = ''
         BEGIN
            SELECT TOP 1
               @cSuggSKU = PD.SKU, 
               @cSuggID  = PD.ID,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND (( @cType = 'BALPICK' AND PD.DropID <> @cCurrUCC) OR
                     ( @cType = 'NEXTSKU' AND PD.DropID = PD.DropID))
               AND PD.Status < @cPickConfirmStatus
               AND LOC.LOC = @cCurrLOC
            GROUP BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT
                  --@nSuggQTY = ISNULL( SUM( PD.QTY), 0)  --INC0720911
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.LOC = @cCurrLOC
                  AND (( @cType = 'BALPICK' AND PD.LOT <> @cCurrLOT) OR
                     ( @cType = 'NEXTSKU' AND PD.SKU = PD.SKU))
               GROUP BY PD.StorerKey, PD.SKU, PD.LOT
               ORDER BY PD.StorerKey, PD.SKU, PD.LOT

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cSuggSKU = PD.SKU, 
               @cSuggID  = PD.ID,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND (( @cType = 'BALPICK' AND PD.DropID <> @cCurrUCC) OR
                     ( @cType = 'NEXTSKU' AND PD.DropID = PD.DropID))
               AND PD.Status < @cPickConfirmStatus
               AND LOC.LOC = @cCurrLOC
            GROUP BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT
                  --@nSuggQTY = ISNULL( SUM( PD.QTY), 0)  --INC0720911
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.LOC = @cCurrLOC
                  AND (( @cType = 'BALPICK' AND PD.LOT <> @cCurrLOT) OR
                     ( @cType = 'NEXTSKU' AND PD.SKU = PD.SKU))
               GROUP BY PD.StorerKey, PD.SKU, PD.LOT
               ORDER BY PD.StorerKey, PD.SKU, PD.LOT

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
      END
   END

   /***********************************************************************************************
                                              Get next SKU
   ***********************************************************************************************/
   ELSE IF @cType IN ('CLOSE')
   BEGIN
      SET @cSuggLOC = @cCurrLOC

      -- Cross dock PickSlip
      IF @cZone IN ('XD', 'LB', 'LP')
      BEGIN
         IF @cPickZone = ''
         BEGIN
            SELECT TOP 1
               @cSuggSKU = PD.SKU, 
               @cSuggID  = PD.ID,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND LOC.LOC = @cCurrLOC
            GROUP BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT
                  --@nSuggQTY = ISNULL( SUM( PD.QTY), 0)      --INC0720911
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.LOC = @cCurrLOC
                  AND PD.SKU = PD.SKU
               GROUP BY PD.StorerKey, PD.SKU, PD.LOT
               ORDER BY PD.StorerKey, PD.SKU, PD.LOT

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cSuggSKU = PD.SKU, 
               @cSuggID  = PD.ID,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND LOC.LOC = @cCurrLOC
            GROUP BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT
                  --@nSuggQTY = ISNULL( SUM( PD.QTY), 0)    --INC0720911
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.LOC = @cCurrLOC
                  AND PD.SKU = PD.SKU
               GROUP BY PD.StorerKey, PD.SKU, PD.LOT
               ORDER BY PD.StorerKey, PD.SKU, PD.LOT

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
      END

      -- Discrete PickSlip
      ELSE IF @cOrderKey <> ''
      BEGIN
         IF @cPickZone = ''
         BEGIN
            SELECT TOP 1
               @cSuggSKU = PD.SKU, 
               @cSuggID  = PD.ID,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE PD.OrderKey = @cOrderKey
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND LOC.LOC = @cCurrLOC
            GROUP BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT
                  --@nSuggQTY = ISNULL( SUM( PD.QTY), 0)    --INC0720911
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.LOC = @cCurrLOC
                  AND PD.SKU = PD.SKU
               GROUP BY PD.StorerKey, PD.SKU, PD.LOT
               ORDER BY PD.StorerKey, PD.SKU, PD.LOT

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cSuggSKU = PD.SKU, 
               @cSuggID  = PD.ID,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE PD.OrderKey = @cOrderKey
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND LOC.LOC = @cCurrLOC
            GROUP BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT
                  --@nSuggQTY = ISNULL( SUM( PD.QTY), 0)      --INC0720911
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.LOC = @cCurrLOC
                  AND PD.SKU = PD.SKU
               GROUP BY PD.StorerKey, PD.SKU, PD.LOT
               ORDER BY PD.StorerKey, PD.SKU, PD.LOT

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.OrderKey = @cOrderKey
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
      END

      -- Conso PickSlip
      ELSE IF @cLoadKey <> ''
      BEGIN
         IF @cPickZone = ''
         BEGIN
            SELECT TOP 1
               @cSuggSKU = PD.SKU, 
               @cSuggID  = PD.ID,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
            JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE LPD.LoadKey = @cLoadKey  
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND LOC.LOC = @cCurrLOC
            GROUP BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
               JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey  
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT
                  --@nSuggQTY = ISNULL( SUM( PD.QTY), 0)      --INC0720911
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.LOC = @cCurrLOC
                  AND PD.SKU = PD.SKU
               GROUP BY PD.StorerKey, PD.SKU, PD.LOT
               ORDER BY PD.StorerKey, PD.SKU, PD.LOT

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cSuggSKU = PD.SKU, 
               @cSuggID  = PD.ID,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
            JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE LPD.LoadKey = @cLoadKey  
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND LOC.LOC = @cCurrLOC
            GROUP BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
               JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey  
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT
                  --@nSuggQTY = ISNULL( SUM( PD.QTY), 0)      --INC0720911
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.LOC = @cCurrLOC
                  AND PD.SKU = PD.SKU
               GROUP BY PD.StorerKey, PD.SKU, PD.LOT
               ORDER BY PD.StorerKey, PD.SKU, PD.LOT

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE LPD.LoadKey = @cLoadKey
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
      END

      -- Custom PickSlip
      ELSE
      BEGIN
         IF @cPickZone = ''
         BEGIN
            SELECT TOP 1
               @cSuggSKU = PD.SKU, 
               @cSuggID  = PD.ID,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND LOC.LOC = @cCurrLOC
            GROUP BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT
                  --@nSuggQTY = ISNULL( SUM( PD.QTY), 0)  --INC0720911
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.LOC = @cCurrLOC
                  AND PD.SKU = PD.SKU
               GROUP BY PD.StorerKey, PD.SKU, PD.LOT
               ORDER BY PD.StorerKey, PD.SKU, PD.LOT

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cSuggSKU = PD.SKU, 
               @cSuggID  = PD.ID,
               @cSuggUCC = UCC.UCCNo,
               @nSuggQTY = ISNULL( SUM( PD.QTY), 0)
            FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
            LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickDetailKey = PD.PickDetailKey AND EPL1.PickMethod = 'GetTask-U' AND EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.Status IN ( '4', '9' )
            LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.PickDetailKey = PD.PickDetailKey AND EPL2.PickMethod = 'GetTask-U' AND EPL2.AddWho <> @cUserName
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status <> '4'
               AND PD.UOM = '2'
               AND EPL1.PickDetailKey IS NULL
               AND EPL2.PickDetailKey IS NULL
               AND PD.Status < @cPickConfirmStatus
               AND LOC.LOC = @cCurrLOC
            GROUP BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU
            ORDER BY PD.ID, UCC.UCCNo, PD.StorerKey, PD.SKU

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount > 0
            BEGIN
               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cSuggUCC, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-U', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON PD.StorerKey = UCC.StorerKey AND PD.DropID = UCC.UCCNo
               LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.PickMethod = 'GetTask-U' AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '2'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.ID = @cSuggID
                  AND PD.SKU = @cSuggSKU
                  AND PD.DropID = @cSuggUCC
            END

            IF @nRowCount = 0
            BEGIN
               SELECT TOP 1
                  @cSuggSKU = PD.SKU,
                  @cLOT = PD.LOT
                  --@nSuggQTY = ISNULL( SUM( PD.QTY), 0)  --INC0720911
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Status IN ( '4', '9' ) AND EPL1.PickMethod = 'GetTask-P' AND EPL1.PickDetailKey = PD.PickDetailKey
                  LEFT JOIN #ExistingPickLogs EPL2 ON EPL2.Mobile = @nMobile AND EPL2.PickMethod = 'Pick-P' AND EPL2.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND EPL2.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.LOC = @cCurrLOC
                  AND PD.SKU = PD.SKU
               GROUP BY PD.StorerKey, PD.SKU, PD.LOT
               ORDER BY PD.StorerKey, PD.SKU, PD.LOT

               SET @cUCCorPiecePick = 'Piece'

               INSERT INTO [RDT].[rdtPickLog] (OrderKey, PickZone, PickDetailKey, StorerKey, Descr, ActQty, Mobile, PickSlipNo, PickMethod, LOC, ID, LOT, SKU)
               SELECT DISTINCT PD.OrderKey, @cPickZone, PD.PickDetailKey, @cStorerKey, @cLOT, PD.Qty, @nMobile, @cPickSlipNo, 'GetTask-P', PD.LOC, PD.ID, PD.LOT, PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  LEFT JOIN #ExistingPickLogs EPL1 ON EPL1.Mobile = @nMobile AND EPL1.AddWho = @cUserName AND EPL1.PickMethod IN ('GetTask-P', 'Pick-P') AND EPL1.PickDetailKey = PD.PickDetailKey
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.UOM = '6'
                  AND EPL1.PickDetailKey IS NULL
                  AND PD.Status < @cPickConfirmStatus
                  AND PD.LOC = @cSuggLOC
                  AND PD.SKU = @cSuggSKU
                  AND PD.LOT = @cLot
            END
         END
      END
   END

  /***********************************************************************************************
                                              Get Balance task
   ***********************************************************************************************/
   IF @cUCCorPiecePick = 'Piece' 
   BEGIN
      /***********************************************************************************************
                                                Return task
      ***********************************************************************************************/
      IF ISNULL( @cSuggSKU, '') = ''
      BEGIN
         SET @nErrNo = 100151
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No more task
         SET @nErrNo = -1 -- No more task
      END
      ELSE
      BEGIN
         -- Assign to actual
         SET @cLottable01 = @cTempLottable01
         SET @cLottable02 = @cTempLottable02
         SET @cLottable03 = @cTempLottable03
         SET @dLottable04 = @dTempLottable04
         SET @dLottable05 = @dTempLottable05
         SET @cLottable06 = @cTempLottable06
         SET @cLottable07 = @cTempLottable07
         SET @cLottable08 = @cTempLottable08
         SET @cLottable09 = @cTempLottable09
         SET @cLottable10 = @cTempLottable10
         SET @cLottable11 = @cTempLottable11
         SET @cLottable12 = @cTempLottable12
         SET @dLottable13 = @dTempLottable13
         SET @dLottable14 = @dTempLottable14
         SET @dLottable15 = @dTempLottable15
         SET @cLottableCode = @cTempLottableCode

         SET @cLOC = @cSuggLOC
         SET @cSKU = @cSuggSKU

         -- Get SKU description
         DECLARE @cDispStyleColorSize  NVARCHAR( 20)
         SET @cDispStyleColorSize = rdt.RDTGetConfig( @nFunc, 'DispStyleColorSize', @cStorerKey)

         --yeekung05
         DECLARE @cDispExtValue  NVARCHAR( 20)
         SET @cDispExtValue = rdt.RDTGetConfig( @nFunc, 'DispExtValues', @cStorerKey)  --(yeekung03)

         IF @cDispStyleColorSize = '0'
            SELECT @cSKUDescr = Descr FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU

         ELSE IF @cDispStyleColorSize = '1'
            SELECT @cSKUDescr =
               CAST( Style AS NCHAR(20)) +
               CAST( Color AS NCHAR(10)) +
               CAST( Size  AS NCHAR(10))
            FROM SKU WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND SKU = @cSKU

         IF @cDispExtValue ='1' --(yeekung05)
         BEGIN
            DECLARE @cTable NVARCHAR(20)
            DECLARE @cNotes NVARCHAR(MAX)
            DECLARE @cColumnName NVARCHAR(20)

            SELECT @cTable=long,
                  @cNotes = notes,
                  @cColumnName=udf01
            FROM codelkup (NOLOCK)
            where storerkey=@cStorerKey
            AND LISTNAME='RefColLkup'

         SET @cSQL =
            '    SELECT @cSKUDescr = ' + @cNotes +
            '    FROM dbo.'+@cTable + ' WITH (NOLOCK)' +
            '    WHERE storerkey=@cStorerkey ' +
            '       AND ' + @cColumnName + '= @c' + @cColumnName

            SET @cSQLParam =
               '@cOrderKey   NVARCHAR( 10) , ' +
               '@cStorerkey  NVARCHAR( 20) , ' +
               '@cSKU        NVARCHAR( 20) , ' +
               '@cSKUDescr   NVARCHAR( 60)   '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @cStorerKey = @cStorerKey,
               @cOrderKey   = @cOrderKey,
               @cSKU        = @cSuggSKU,
               @cSKUDescr   = @cSKUDescr OUTPUT
         END

         UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
         SET C_String2 = @cLOT,
            C_String6 = '6'
         WHERE Mobile = @nMobile
      END
   END

   IF @cUCCorPiecePick = 'UCC' 
   BEGIN
      IF @cSuggSKU IS NULL
      BEGIN
         
         SET @nErrNo = 184701
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No more task
         SET @nErrNo = -1 -- No more task
      END
      ELSE
      BEGIN
         SET @nQTY = 1

         SELECT @cSuggID = ID 
         FROM dbo.UCC WITH(NOLOCK)
         WHERE UCCNo = @cSuggUCC

         SET @cLOC = @cSuggLOC
         SET @cSKU = @cSuggSKU

         UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
         SET C_String1 = @cSuggUCC,
            C_String6 = '2'
         WHERE Mobile = @nMobile
      END
      SET @cLottableCode = ''
   END

   EXEC rdt.rdt_839GetBalQty
      @nMobile         = @nMobile,
      @nFunc           = @nFunc,
      @cLangCode       = @cLangCode,
      @nStep           = @nStep,
      @nInputKey       = @nInputKey,
      @cFacility       = @cFacility,
      @cStorerKey      = @cStorerKey,
      @cType           = @cUCCorPiecePick,
      @cPickSlipNo     = @cPickSlipNo,
      @cPickZone       = @cPickZone,
      @cLot            = @cLOT,
      @cLOC            = @cLOC,
      @cSKU            = @cSKU,
      @cLottableCode   = @cLottableCode,
      @nLottableOnPage = @nLottableOnPage,
      @cLottable01     = @cLottable01,
      @cLottable02     = @cLottable02,
      @cLottable03     = @cLottable03,
      @dLottable04     = @dLottable04,
      @dLottable05     = @dLottable05,
      @cLottable06     = @cLottable06,
      @cLottable07     = @cLottable07,
      @cLottable08     = @cLottable08,
      @cLottable09     = @cLottable09,
      @cLottable10     = @cLottable10,
      @cLottable11     = @cLottable11,
      @cLottable12     = @cLottable12,
      @dLottable13     = @dLottable13,
      @dLottable14     = @dLottable14,
      @dLottable15     = @dLottable15,
      @nQTY            = @nQTY OUTPUT,
      @nTtlBalQty      = @nTtlBalQty OUTPUT,
      @nBalQty         = @nBalQty OUTPUT,
      @nErrNo          = @nErrNo OUTPUT,
      @cErrMsg         = @cErrMsg OUTPUT

   IF @nErrNo <> 0
      RETURN

   -- Get DisableQTYField
   DECLARE @cDisableQTYFieldSP NVARCHAR( 20)
   SET @cDisableQTYFieldSP = rdt.rdtGetConfig( @nFunc, 'DisableQTYFieldSP', @cStorerKey)

   IF @cDisableQTYFieldSP = '0'
      SET @cDisableQTYField = ''
   ELSE IF @cDisableQTYFieldSP = '1'
      SET @cDisableQTYField = '1'
   ELSE
   BEGIN
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDisableQTYFieldSP AND type = 'P')
      BEGIN
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cDisableQTYFieldSP) +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cPickZone, @cLOC, @cSKU, @nQTY, ' +
            ' @cDisableQTYField OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
         SET @cSQLParam =
            '@nMobile          INT,           ' +
            '@nFunc            INT,           ' +
            '@cLangCode        NVARCHAR( 3),  ' +
            '@nStep            INT,           ' +
            '@nInputKey        INT,           ' +
            '@cFacility        NVARCHAR( 5),  ' +
            '@cStorerKey       NVARCHAR( 15), ' +
            '@cPickSlipNo      NVARCHAR( 10), ' +
            '@cPickZone        NVARCHAR( 10), ' +
            '@cLOC             NVARCHAR( 10), ' +
            '@cSKU             NVARCHAR( 20), ' +
            '@nQTY             INT,           ' +
            '@cDisableQTYField NVARCHAR( 1)  OUTPUT, ' +
            '@nErrNo           INT           OUTPUT, ' +
            '@cErrMsg          NVARCHAR( 20) OUTPUT  '

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cPickZone, @cLOC, @cSKU, @nQTY,
            @cDisableQTYField OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT
      END
   END

Quit:
   -- Putting here to centralize control all GetTaskSP
   IF @cSuggSKU <> ''
   BEGIN
      -- Capture serial no
      IF rdt.RDTGetConfig( @nFunc, 'SerialNoCapture', @cStorerKey) = '1'
      BEGIN
         -- Get SKU info
         SELECT @cSKUSerialNoCapture = SerialNoCapture 
         FROM dbo.SKU WITH (NOLOCK) 
         WHERE StorerKey = @cStorerKey 
            AND SKU = @cSuggSKU 
         
         -- Disable QTY field, if need to capture
         IF @cSKUSerialNoCapture IN ('1', '3')
            SET @cDisableQTYField = '1'
      END
   END
END

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [RDT].[rdt_839GetTaskSP17] TO [NSQL]
GO

