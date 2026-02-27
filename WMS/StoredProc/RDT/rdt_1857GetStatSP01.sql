SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_1857GetStatSP01                                 */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Date       Rev  Author      Purposes                                 */
/* 28-07-2021 1.0  Chermaine   WMS-17446 Created                        */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_1857GetStatSP01 (
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nStep         INT,
   @nInputKey     INT,
   @cFacility     NVARCHAR( 5),
   @cStorerKey    NVARCHAR( 15),
   @cStation      NVARCHAR( 10),
   @cMethod       NVARCHAR( 1),
   @cSKU          NVARCHAR( 20),
   @cLoc          NVARCHAR( 10),
   @cLight        NVARCHAR( 1),
   @nCurrentPage  INT           ,
   @cOutField01   NVARCHAR( 60) OUTPUT,
   @cOutField02   NVARCHAR( 60) OUTPUT,
   @cOutField03   NVARCHAR( 60) OUTPUT,
   @cOutField04   NVARCHAR( 60) OUTPUT,
   @cOutField05   NVARCHAR( 60) OUTPUT,
   @cOutField06   NVARCHAR( 60) OUTPUT,
   @cOutField07   NVARCHAR( 60) OUTPUT,
   @cOutField08   NVARCHAR( 60) OUTPUT,
   @cOutField09   NVARCHAR( 60) OUTPUT,
   @cOutField10   NVARCHAR( 60) OUTPUT,
   @cOutField11   NVARCHAR( 60) OUTPUT,
   @cOutField12   NVARCHAR( 60) OUTPUT,
   @cOutField13   NVARCHAR( 60) OUTPUT,
   @cOutField14   NVARCHAR( 60) OUTPUT,
   @cOutField15   NVARCHAR( 60) OUTPUT,
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF


   DECLARE @curPTLAuditLight CURSOR
   --DECLARE @curPTLAuditList CURSOR
   DECLARE @tPtlAuditList TABLE
   (
      RowRef         INT IDENTITY( 1, 1),
      WaveKey        NVARCHAR( 10) NULL,
      BatchKey       NVARCHAR( 10) NOT NULL,
      OrderKey       NVARCHAR( 10) NULL,
      DPLoc          NVARCHAR( 10) NOT NULL,
      SKU            NVARCHAR( 20) NOT NULL,
      SKUDescr1      NVARCHAR( 20) NOT NULL,
      SKUDescr2      NVARCHAR( 20) NULL,
      SKUDescr3      NVARCHAR( 20) NULL,
      PTLPosition    NVARCHAR( 10) NOT NULL,
      PTLIPAddr      NVARCHAR( 40) NULL,
      TotalXsorted   INT,
      TotalQty       INT
   )

   DECLARE
   	@cWaveKey      NVARCHAR(10),
   	@cTaskBatchNo  NVARCHAR(10),
   	@cOrderKey     NVARCHAR(10),
   	@cDPLoc        NVARCHAR(10),
   	@cDisplaySKU   NVARCHAR(20),
   	@cSKUDesc1     NVARCHAR(20),
   	@cSKUDesc2     NVARCHAR(20),
   	@cSKUDesc3     NVARCHAR(20),
   	@cIPAddress    NVARCHAR(40),
      @cPosition     NVARCHAR(10),
      @cDisplay      NVARCHAR(50),
      @cLightMode    NVARCHAR(5),
      @nTotalPage    INT,
      @nTotalRecord  INT,
      @nTotalXSorted INT,
      @nTotalQty     INT,
      @nTotalSorted  INT,
      @bSuccess      INT

   SELECT @cOutField01 = '', @cOutField02 = '', @cOutField03 = '', @cOutField04 = '', @cOutField05 = ''
         ,@cOutField06 = '', @cOutField07 = '', @cOutField08 = '', @cOutField09 = '', @cOutField10 = ''
         ,@cOutField11 = '', @cOutField12 = '', @cOutField13 = '', @cOutField14 = '', @cOutField15 = ''

   SET @cDisplay = '1'


   IF NOT EXISTS (SELECT TOP 1 1 FROM rdt.rdtPTLPieceLog WITH (NOLOCK) WHERE station = @cStation AND (WaveKey <> '' OR batchKey <> ''))
   BEGIN
   	SET @nErrNo = 173701
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoTaskAssigned
      GOTO Quit
   END

   --Populate List
   IF @cMethod = '1'
   BEGIN
   	IF NOT EXISTS (SELECT TOP 1 1
                     FROM rdt.rdtPTLPieceLog PTL WITH (NOLOCK)
                     JOIN PickDetail PD WITH (NOLOCK) ON (PD.OrderKey = PTL.OrderKey)
                     JOIN PackTask PT WITH (NOLOCK) ON (PT.orderKey = PD.OrderKey AND PT.TaskBatchNo = PTL.BatchKey)
                     WHERE PTL.Station = @cStation
                     AND PD.SKU = @cSKU )
      BEGIN
      	SET @nErrNo = 173702
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoTaskAssigned
         GOTO Quit
      END


   	INSERT INTO @tPtlAuditList ( WaveKey, BatchKey, OrderKey, DPLoc, SKU, SKUDescr1, SKUDescr2, SKUDescr3
   		                        , PTLPosition, PTLIPAddr, TotalXsorted, TotalQty )
   	SELECT
   		PD.waveKey,PT.TaskBatchNo,PD.OrderKey,DP.Loc,PD.SKU,SUBSTRING(S.Descr,1,20),SUBSTRING(S.Descr,21,20),SUBSTRING(S.Descr,41,20),
   		PT.DevicePosition, DP.IPAddress
   		, (SELECT SUM(Qty) FROM pickDetail WITH (NOLOCK) WHERE storerKey = @cStorerKey AND OrderKey = PD.OrderKey AND SKU = PD.SKU AND caseID <> 'sorted')
   		, (SELECT SUM(Qty) FROM pickDetail WITH (NOLOCK) WHERE storerKey = @cStorerKey AND OrderKey = PD.OrderKey AND SKU = PD.SKU)
      FROM PackTask PT WITH (NOLOCK)
      JOIN PickDetail PD WITH (NOLOCK) ON (PT.OrderKey = PD.OrderKey)
      JOIN rdt.rdtPTLPieceLog PTL WITH (NOLOCK) ON (PTL.batchKey = PT.TaskBatchNo AND PTL.OrderKey = PD.OrderKey)
      JOIN DeviceProfile DP WITH (NOLOCK) ON (PTL.Station = DP.DeviceID AND DP.StorerKey = PD.StorerKey AND PTL.Position = DP.DevicePosition)
      JOIN SKU S WITH (NOLOCK) ON (S.SKU = PD.SKU AND S.StorerKey = PD.StorerKey)
      WHERE PD.StorerKey = @cStorerKey
      AND PD.SKU = @cSKU
      AND PTL.Station = @cStation
      --AND PD.CaseID <> 'SORTED'
   	GROUP BY PD.waveKey,PT.TaskBatchNo,PD.OrderKey,DP.Loc, PD.SKU, S.Descr,
   	PT.DevicePosition, DP.IPAddress,
   	DP.LogicalPOS, DP.LogicalName
   	ORDER BY DP.LogicalPOS, DP.LogicalName

      SET @nTotalPage = @@ROWCOUNT

      SET @cOutField01 = 'SORT SKU '

   END
   ELSE IF @cMethod = '2'
   BEGIN
   	INSERT INTO @tPtlAuditList ( WaveKey, BatchKey, OrderKey, DPLoc, SKU, SKUDescr1, SKUDescr2, SKUDescr3
   		                        , PTLPosition, PTLIPAddr,TotalXsorted, TotalQty  )
   	SELECT
   		PD.waveKey,PT.TaskBatchNo,PD.OrderKey,DP.Loc,PD.SKU,SUBSTRING(S.Descr,1,20),SUBSTRING(S.Descr,21,20),SUBSTRING(S.Descr,41,20)
   		, PTL.Position, PTL.IPAddress
   		, (SELECT SUM(Qty) FROM pickDetail WITH (NOLOCK) WHERE storerKey = @cStorerKey AND OrderKey = PD.OrderKey AND SKU = PD.SKU AND caseID <> 'sorted')
   		, (SELECT SUM(Qty) FROM pickDetail WITH (NOLOCK) WHERE storerKey = @cStorerKey AND OrderKey = PD.OrderKey)
      FROM PackTask PT WITH (NOLOCK)
      JOIN PickDetail PD WITH (NOLOCK) ON (PT.OrderKey = PD.OrderKey)
      JOIN rdt.rdtPTLPieceLog PTL WITH (NOLOCK) ON (PTL.batchKey = PT.TaskBatchNo AND PTL.OrderKey = PD.OrderKey)
      JOIN DeviceProfile DP WITH (NOLOCK) ON (PTL.Station = DP.DeviceID AND DP.StorerKey = PD.StorerKey AND PTL.Position = DP.DevicePosition)
      JOIN SKU S WITH (NOLOCK) ON (S.SKU = PD.SKU AND S.StorerKey = PD.StorerKey)
      WHERE PD.StorerKey = @cStorerKey
      AND DP.Loc = @cLoc
      AND PTL.Station = @cStation
      --AND PD.CaseID <> 'SORTED'
      GROUP BY PD.waveKey,PT.TaskBatchNo,PD.OrderKey,DP.Loc, PD.SKU, S.Descr,PTL.Position, PTL.IPAddress
   	ORDER BY PD.SKU

      SET @nTotalPage = @@ROWCOUNT

      SET @cOutField01 = 'SORT LOC: '
   END
   ELSE IF @cMethod = '3'
   BEGIN
   	INSERT INTO @tPtlAuditList ( WaveKey, BatchKey, OrderKey, DPLoc, SKU, SKUDescr1, SKUDescr2, SKUDescr3
   		                         ,PTLPosition, PTLIPAddr,TotalXsorted, TotalQty  )
   	SELECT
   		PD.waveKey,PT.TaskBatchNo,PD.OrderKey,DP.Loc,@cSKU,SUBSTRING(S.Descr,1,20),SUBSTRING(S.Descr,21,20),SUBSTRING(S.Descr,41,20)
   		, PTL.Position, PTL.IPAddress
   		, COUNT(PD.OrderKey), (SELECT SUM(Qty) FROM pickDetail WITH (NOLOCK) WHERE storerKey = @cStorerKey AND OrderKey = PD.OrderKey)
      FROM PackTask PT WITH (NOLOCK)
      JOIN PickDetail PD WITH (NOLOCK) ON (PT.OrderKey = PD.OrderKey)
      JOIN rdt.rdtPTLPieceLog PTL WITH (NOLOCK) ON (PTL.batchKey = PT.TaskBatchNo AND PTL.OrderKey = PD.OrderKey AND PD.DropID = PTL.DropID)
      JOIN DeviceProfile DP WITH (NOLOCK) ON (PTL.Station = DP.DeviceID AND DP.StorerKey = PD.StorerKey AND PTL.Loc = DP.Loc)
      JOIN SKU S WITH (NOLOCK) ON (S.SKU = PD.SKU AND S.StorerKey = PD.StorerKey)
      WHERE PD.StorerKey = @cStorerKey
      AND PTL.Station = @cStation
      AND PD.CaseID <> 'SORTED'
      GROUP BY PD.waveKey,PT.TaskBatchNo,PD.OrderKey,DP.Loc, PD.SKU, S.Descr,PTL.Position, PTL.IPAddress, DP.LogicalPOS, DP.LogicalName
   	ORDER BY DP.LogicalPOS, DP.LogicalName
   END

   IF @nTotalPage > 0
   BEGIN
      SET @nCurrentPage = @nCurrentPage + 1 -- 1 record 1 Page

      SELECT
         @cWaveKey = WaveKey,
         @cTaskBatchNo = BatchKey,
         @cOrderkey = OrderKey,
         @cDPLoc    = DPLoc,
         @cDisplaySKU = SKU,
         @cSKUDesc1 = SKUDescr1,
         @cSKUDesc2 = SKUDescr2,
         @cSKUDesc3 = SKUDescr3,
   		@nTotalXSorted = ISNULL(TotalXsorted,0),
   		@nTotalQty = TotalQty
      FROM @tPtlAuditList
      WHERE RowRef = @nCurrentPage
      ORDER BY RowRef

      --INSERT INTO traceInfo (traceName,Col1,Col2,TimeIn)
      --VALUES ('cc123',@nCurrentPage,@cOrderkey,GETDATE())

      SET @cOutField01 = @cOutField01 + CONVERT(NVARCHAR(5),@nCurrentPage) + '/' + CONVERT(NVARCHAR(5),@nTotalPage)
      SET @cOutField02 = ''
      SET @cOutField03 = 'WaveID: ' + @cWaveKey
      SET @cOutField04 = 'TskBatch#:' + @cTaskBatchNo
      SET @cOutField05 = 'OrderKey: ' + @cOrderkey
      SET @cOutField06 = 'SortLoc: ' + @cDPLoc
      SET @cOutField07 = 'SKU: ' + @cDisplaySKU
      SET @cOutField08 = @cSKUDesc1
      SET @cOutField09 = @cSKUDesc2
      SET @cOutField10 = @cSKUDesc3
      SET @cOutField11 = ''
      SET @cOutField12 = 'Sort/TtlQty: ' + CONVERT(NVARCHAR(5),@nTotalQty - @nTotalXSorted) + '/' + CONVERT(NVARCHAR(5),@nTotalQty)
   END

   IF @nCurrentPage = 1 OR @cLight = '1'
   BEGIN
   	--On Light Cursor
      SET @curPTLAuditLight = CURSOR FOR
      SELECT PTLIPAddr,PTLPosition, TotalQty, TotalXSorted
      FROM @tPtlAuditList

   	----Audit by SKU
    --  IF @cMethod  = '1'
    --  BEGIN
   	--   --On Light Cursor
    --     SET @curPTLAuditLight = CURSOR FOR
    --     SELECT PTL.IPAddress, PTL.DevicePosition
    --     FROM PackTask PT WITH (NOLOCK)
    --     JOIN PickDetail PD WITH (NOLOCK) ON (PT.OrderKey = PD.OrderKey)
    --     JOIN rdt.rdtPTLPieceLog PTL WITH (NOLOCK) ON (PTL.batchKey = PT.TaskBatchNo AND PTL.OrderKey = PD.OrderKey)
    --     WHERE PD.StorerKey = @cStorerKey
    --     AND PD.SKU = @cSKU
    --     AND PTL.Station = @cStation
    --     AND PD.CaseID <> 'SORTED'
    --  END
    --  ELSE IF @cMethod  = '2'
    --  BEGIN
   	--   --On Light Cursor
    --     SET @curPTLAuditLight = CURSOR FOR
    --     SELECT PTL.IPAddress, PTL.DevicePosition
    --     FROM PackTask PT WITH (NOLOCK)
    --     JOIN PickDetail PD WITH (NOLOCK) ON (PT.OrderKey = PD.OrderKey)
    --     JOIN rdt.rdtPTLPieceLog PTL WITH (NOLOCK) ON (PTL.batchKey = PT.TaskBatchNo AND PTL.OrderKey = PD.OrderKey)
    --     JOIN DeviceProfile DP WITH (NOLOCK) ON (PTL.Station = DP.DeviceID AND DP.StorerKey = PD.StorerKey)
    --     WHERE PD.StorerKey = @cStorerKey
    --     AND DP.Loc = @cLoc
    --     AND PTL.Station = @cStation
    --     AND PD.CaseID <> 'SORTED'
    --  END
    --  ELSE IF @cMethod  = '3'
    --  BEGIN
   	--   -- Loop light position
    --     SET @curPTLAuditLight = CURSOR FOR
    --     SELECT PTL.IPAddress, PTL.DevicePosition
    --     FROM PackTask PT WITH (NOLOCK)
    --     JOIN PickDetail PD WITH (NOLOCK) ON (PT.OrderKey = PD.OrderKey)
    --     JOIN rdt.rdtPTLPieceLog PTL WITH (NOLOCK) ON (PTL.batchKey = PT.TaskBatchNo AND PTL.OrderKey = PD.OrderKey)
    --     WHERE PD.StorerKey = @cStorerKey
    --     AND PTL.Station = @cStation
    --     AND PD.CaseID <> 'SORTED'
    --  END

      OPEN @curPTLAuditLight
      FETCH NEXT FROM @curPTLAuditLight INTO @cIPAddress, @cPosition, @nTotalQty, @nTotalXSorted
      WHILE @@FETCH_STATUS = 0
      BEGIN
      	-- Light up location
         IF @cLight = '1'
         BEGIN
         	--IF @nTotalXSorted = @nTotalQty --open order, not sorted at all
          --  BEGIN
          --  	SET @cLightMode = rdt.RDTGetConfig( @nFunc, 'LightModeEnd', @cStorerKey)
          --  END
          --  ELSE
          --  BEGIN
            	SET @cLightMode = rdt.RDTGetConfig( @nFunc, 'LightMode', @cStorerKey)
            --END
            --INSERT INTO traceInfo (TraceName,timein,col1,col2,col3,col4,col5)
            --VALUES ('cc',GETDATE(),@cLightMode,@cStation,@cPosition,@cIPAddress ,@cLightMode)

         	EXEC PTL.isp_PTL_LightUpLoc
               @n_Func           = @nFunc
              ,@n_PTLKey         = 0
              ,@c_DisplayValue   = @cDisplay
              ,@b_Success        = @bSuccess    OUTPUT
              ,@n_Err            = @nErrNo      OUTPUT
              ,@c_ErrMsg         = @cErrMsg     OUTPUT
              ,@c_DeviceID       = @cStation
              ,@c_DevicePos      = @cPosition
              ,@c_DeviceIP       = @cIPAddress
              ,@c_LModMode       = @cLightMode
            IF @nErrNo <> 0
               GOTO Quit
         END
      	FETCH NEXT FROM @curPTLAuditLight INTO @cIPAddress, @cPosition, @nTotalQty, @nTotalXSorted
      END
   END


Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1857GetStatSP01 TO NSQL
GO
