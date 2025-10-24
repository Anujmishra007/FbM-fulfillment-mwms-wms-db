SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*******************************************************************************************************************************/
/* Store procedure: isp_PostPickOrderUpd_VIVO                                                                           */
/* Copyright      : Maersk                                                                                                     */
/* Customer       : DE003 facilty - VIVO Storer																				 */
/*                                                                                                                             */
/* Purpose: Performs updates on orders/lines post picking (status >= 5)														*/
/*				- Clear OrderDetail.UD02 data (PALogicalLoc) assigned during pre-alloc order sortation by SP					*/
/*				  isp_PreAllocOrderSortation_VIVO																			 */
/*																																*/
/*	Called by: Scheulded Job = BEJ - isp_PostPickOrderUpd_VIVO (DE003 - VIVO)												*/
/*																																*/
/* Version: 1.0																													*/
/*                                                                                                                             */
/* Date       Ver    Author     Purposes                                                                                       */
/* 22/10/25   1.0   JRA432		Intitial Version																			*/
/*******************************************************************************************************************************/

CREATE OR ALTER           PROC [dbo].[isp_PostPickOrderUpd_VIVO] (
		@b_Success  INT OUTPUT,
		@n_Err INT OUTPUT,
		@c_ErrMsg  NVARCHAR(250) OUTPUT)
AS

DECLARE   
	@JobName nvarchar (128) = 'BEJ - isp_PostPickOrderUpd_VIVO (DE003 - VIVO)'
	,@Facility		nvarchar (15) = 'DE003'
	,@StorerKey	nvarchar (30) = 'VIVO'
    ,@UpdOrderKey nvarchar (10)
	,@UpdOrderLineNum nvarchar(5)
;
BEGIN
SET @b_Success = 0;

DECLARE @RowCount INT = (SELECT COUNT(*) FROM dbo.OrderDetail WITH (NOLOCK) WHERE OrderDetail.StorerKey = @StorerKey AND OrderDetail.Status >= 5 AND OrderDetail.UserDefine02 <> '');  
  
WHILE @RowCount > 0 
BEGIN  
	SELECT @UpdOrderKey = OrderDetail.OrderKey , @UpdOrderLineNum = OrderDetail.OrderLineNumber 
	FROM dbo.OrderDetail WITH (NOLOCK) 
	WHERE OrderDetail.StorerKey = @StorerKey 
	AND OrderDetail.Status >= '5' 
	AND OrderDetail.UserDefine02 <> ''
	ORDER BY OrderKey,OrderLineNumber ASC OFFSET @RowCount - 1 ROWS FETCH NEXT 1 ROWS ONLY;  

	BEGIN
		UPDATE dbo.OrderDetail WITH (ROWLOCK)
		SET OrderDetail.UserDefine02 = ''
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

END