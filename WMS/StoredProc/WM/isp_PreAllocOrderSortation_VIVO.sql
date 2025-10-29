SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*******************************************************************************************************************************/
/* Store procedure: isp_PreAllocOrderSortation_VIVO                                                                           */
/* Copyright      : Maersk                                                                                                     */
/* Customer       : DE003 facilty - VIVO Storer																				 */
/*                                                                                                                             */
/* Purpose: Performs sortation of orders prior to allocation to drive ordered allocation to shortest possible walk				*/
/*			by Loc.PAlogicalLoc. Lowest PAlogicalLoc identified to fulfil order qty updated to Orderdetail.UserDefine02			*/
/*																																*/
/*	Called by: Scheulded Job - BEJ - isp_PreAllocOrderSortation_VIVO (DE003 - VIVO)												*/
/*																																*/
/* Version: 1.0																													*/
/*                                                                                                                             */
/* Date       Ver    Author     Purposes                                                                                       */
/* 14/10/25   1.0   JRA432		Intitial Version																			*/
/*******************************************************************************************************************************/

CREATE OR ALTER         PROC [dbo].[isp_PreAllocOrderSortation_VIVO] (
		@b_Success  INT OUTPUT,
		@n_Err INT OUTPUT,
		@c_ErrMsg  NVARCHAR(250) OUTPUT)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
/*
BEGIN
DROP TABLE #TmpPaLogicalLocAssign;
END
*/
DECLARE   
	 @JobName nvarchar (128) = 'BEJ - isp_PreAllocOrderSortation_VIVO (DE003 - VIVO)'
	,@Facility		nvarchar (15) = 'DE003'
	,@StorerKey	nvarchar (30) = 'VIVO'
    ,@UpdOrderKey nvarchar (10)
	,@UpdOrderLineNum nvarchar(5)
	,@UpdPALogicalLoc nvarchar (10) 
;
BEGIN
SET @b_Success = 0;

WITH ValidOrders AS(
	SELECT DISTINCT oh.facility,od.Storerkey,
		oh.OrderKey AS OrderKey
		,od.Status AS Status
		,oh.Type
		,oh.Ecom_Single_Flag
		,od.OrderLineNumber
		,od.Sku
		,od.OpenQty - od.QtyAllocated - od.QtyPicked LineOpenQty
		,oh.OpenQty OrdOpenQty
	FROM dbo.Orders oh WITH (NOLOCK)
	INNER JOIN dbo.OrderDetail od WITH (NOLOCK) ON od.Storerkey = oh.Storerkey AND od.OrderKey = oh.OrderKey
	WHERE oh.Storerkey = @StorerKey 
	AND oh.Facility = @Facility
	AND oh.DocType = 'E'
	--AND oh.[Status] = 0
	AND od.[Status] = 0
	/*Only return orders that have a PF set up meeting SkuxLoc/Loc requirements for all ordered Skus 
	i.e. if Sku is missing correctly setup PF or location then no order sortation occurs for any line*/
	AND (SELECT COUNT(DISTINCT Sku) FROM dbo.OrderDetail od2 WITH (NOLOCK)
		WHERE od2.Storerkey = oh.Storerkey 
		AND od2.OrderKey = oh.OrderKey
		AND od2.Sku NOT IN (SELECT SKU FROM dbo.SkuxLoc sxl2 WITH (NOLOCK)
							JOIN dbo.Loc loc2 WITH (NOLOCK) ON loc2.Facility = oh.Facility AND loc2.loc = sxl2.loc
							WHERE sxl2.Storerkey = od2.Storerkey 
							AND ISNULL(loc2.ABC,'') <> ''
							AND ISNULL(loc2.PALogicalLoc,'') <> ''
							AND loc2.locationtype IN ('PICK','DYNAMICPK'))) = 0
	--ORDER BY od.sku, oh.Orderkey
)
, PickFaceLocCalc AS (
	SELECT DISTINCT 
		sxl.storerkey,vo.orderkey,vo.OrdOpenQty,vo.OrderLineNumber,vo.Ecom_Single_Flag,vo.Sku,vo.LineOpenQty OrigOpenLineQty
		,COALESCE(LAG(vo.LineOpenQty - CASE WHEN vo.LineOpenQty <= sxl.Qty THEN vo.LineOpenQty ELSE sxl.Qty - sxl.QtyAllocated - sxl.QtyPicked END,1) OVER (PARTITION BY vo.OrderKey,vo.OrderLineNumber ORDER BY sxl.Sku ASC, Loc.PALogicalLoc ASC,vo.Ecom_Single_Flag DESC, vo.OrderKey ASC),vo.LineOpenQty) CalcLineOpenQty	
		,sxl.loc
		,loc.LocationType
		,loc.PALogicalLoc
		,loc.ABC
		,sxl.QtyAllocated
		,sxl.QtyPicked
		,sxl.Qty - sxl.QtyAllocated - sxl.QtyPicked  OrigAvailPFQty 
		,(sxl.Qty - sxl.QtyAllocated - sxl.QtyPicked) -  SUM(CASE WHEN vo.LineOpenQty <= (sxl.Qty - sxl.QtyAllocated - sxl.QtyPicked) THEN vo.LineOpenQty
			  ELSE (sxl.Qty - sxl.QtyAllocated - sxl.QtyPicked) END) OVER (partition by sxl.Sku,Loc.Loc order by sxl.Sku ASC, Loc.PALogicalLoc ASC,vo.Ecom_Single_Flag DESC, vo.OrderKey ASC) + CASE WHEN vo.LineOpenQty <= (sxl.Qty - sxl.QtyAllocated - sxl.QtyPicked) THEN vo.LineOpenQty
			  ELSE (sxl.Qty - sxl.QtyAllocated - sxl.QtyPicked) END  PFQtyBeforeRowAlloc
	FROM  dbo.Skuxloc sxl WITH (NOLOCK)
	INNER JOIN  ValidOrders vo ON sxl.StorerKey = vo.StorerKey and vo.Sku = sxl.sku --AND vo.Loc = sxl.loc
	INNER JOIN dbo.loc WITH (NOLOCK) ON loc.Facility = vo.Facility AND loc.loc = sxl.loc 
	WHERE sxl.Qty - sxl.QtyAllocated - sxl.QtyPicked > 0 
	AND loc.LocationType in ('PICK','DYNAMICPK')
	AND ISNULL(loc.ABC,'') <> ''
	AND ISNULL(loc.PALogicalLoc,'') <> ''
	--ORDER BY vo.Sku ASC, Loc.PALogicalLoc ASC,vo.Ecom_Single_Flag DESC, vo.OrderKey ASC
)
, PickFaceLoc AS (
	SELECT DISTINCT 
		sxl.storerkey,sxl.orderkey,sxl.OrdOpenQty	
		,SUM(CASE WHEN CalcLineOpenQty <= PFQtyBeforeRowAlloc THEN CalcLineOpenQty ELSE PFQtyBeforeRowAlloc END) OVER (PARTITION BY Orderkey) SumOrdAlloc
		,sxl.OrderLineNumber,sxl.Ecom_Single_Flag,sxl.Sku
		,sxl.OrigOpenLineQty
		,sxl.CalcLineOpenQty
		,sxl.loc
		,sxl.LocationType
		,sxl.PALogicalLoc
		,sxl.ABC
		,sxl.OrigAvailPFQty
		,PFQtyBeforeRowAlloc
		,CASE WHEN CalcLineOpenQty <= PFQtyBeforeRowAlloc THEN CalcLineOpenQty ELSE PFQtyBeforeRowAlloc END LineAllocatableQtyCalc
		,PFQtyBeforeRowAlloc - CASE WHEN CalcLineOpenQty <= PFQtyBeforeRowAlloc THEN CalcLineOpenQty ELSE PFQtyBeforeRowAlloc END  PFQtyAfterRowAlloc
		, CalcLineOpenQty - CASE WHEN CalcLineOpenQty <= PFQtyBeforeRowAlloc THEN CalcLineOpenQty ELSE PFQtyBeforeRowAlloc END LineQtyRemain
	FROM PickFaceLocCalc sxl
	WHERE 1=1
	--Exclude Order lines for location when no PF stock remains after previous allocation
	AND PFQtyBeforeRowAlloc > 0
	-- Exclude Order Lines for PFs with no inventory
	AND OrigAvailPFQty > 0 --sxl.Qty - sxl.QtyAllocated - sxl.QtyPicked > 0 
	--Exclude Order lines for location when no PF stock remains after previous allocation
	AND PFQtyBeforeRowAlloc > 0 
	-- Exclude order lines that have been fulfilled by lower PALogical location PF
	AND CalcLineOpenQty > 0
	--ORDER BY sxl.Sku ASC, sxl.PALogicalLoc ASC,sxl.Ecom_Single_Flag DESC, sxl.OrderKey ASC
)
, FullData AS(
	SELECT PFLoc.* FROM PickFaceLoc PFLoc
	WHERE 1=1
	--Exclude all lines from orders that cannot be assigned in full to PFs i.e. for each LineQtyRemaining > 0 (not fully allocated to single loc) the SUM of line allocated qty for order line must meet OrigLineOpenQty
	AND 1 = CASE WHEN LineQtyRemain > 0 AND (SELECT SUM(PFLoc2.LineAllocatableQtyCalc) FROM PickFaceLoc PFLoc2 
											WHERE PFLoc2.OrderKey = PFLoc.OrderKey 
											AND PFLoc2.OrderLineNumber = PFLoc.OrderLineNumber) < OrigOpenLineQty THEN 0 
											ELSE 1 END
	--Exclude order not able to allocate in full
	AND PFLoc.SumOrdAlloc >= PFLoc.OrdOpenQty
	--ORDER BY PFLoc.Sku ASC, PFLoc.PALogicalLoc ASC, PFLoc.Ecom_Single_Flag DESC, PFLoc.OrderKey ASC
)
SELECT OrderKey,OrderLineNumber,MIN(PALogicalLoc) PALogicalLoc
INTO #TmpPaLogicalLocAssign
FROM FullData
GROUP BY OrderKey,OrderLineNumber
ORDER BY PALogicalLoc

IF @@ERROR <> 0 
	BEGIN
    SET @n_Err = @@ERROR
    SET @c_ErrMsg = CONVERT(NCHAR(10),@@ERROR) + ': Failed to SELECT required data into #TmpPaLogicalLocAssign ! (isp_PreAllocOrderSortation_VIVO)'
	GOTO EXITNOW
	END
END

DECLARE @RowCount INT = (SELECT COUNT(*) FROM #TmpPaLogicalLocAssign);  
  
WHILE @RowCount > 0 
BEGIN  
	SELECT @UpdOrderKey = OrderKey, @UpdOrderLineNum =OrderLineNumber, @UpdPALogicalLoc = PALogicalLoc   
	FROM #TmpPaLogicalLocAssign   
	ORDER BY OrderKey,OrderLineNumber ASC OFFSET @RowCount - 1 ROWS FETCH NEXT 1 ROWS ONLY;  
	BEGIN
		UPDATE dbo.OrderDetail WITH (ROWLOCK)
		SET OrderDetail.UserDefine02 = @UpdPALogicalLoc
			,OrderDetail.EditDate = GETDATE()
			,OrderDetail.EditWho = @JobName
		WHERE OrderDetail.StorerKey = @StorerKey
		AND OrderDetail.OrderKey = @UpdOrderKey
		AND OrderDetail.OrderLineNumber = @UpdOrderLineNum     
	END
	SET @RowCount -= 1
END

SELECT @b_Success = 1

EXITNOW:

DROP TABLE #TmpPaLogicalLocAssign

END