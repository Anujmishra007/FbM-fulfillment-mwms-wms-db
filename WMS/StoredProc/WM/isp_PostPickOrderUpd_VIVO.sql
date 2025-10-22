
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
;
BEGIN
SET @b_Success = 0;

BEGIN
UPDATE dbo.OrderDetail 
SET OrderDetail.UserDefine02 = ''
	,OrderDetail.EditDate = [dbo].[fnc_ConvSFTimeZone](ORDERS.StorerKey, ORDERS.Facility, GETDATE())
	,OrderDetail.EditWho = @JobName
FROM dbo.OrderDetail
JOIN dbo.Orders ON OrderDetail.OrderKey = Orders.OrderKey AND OrderDetail.Storerkey = Orders.Storerkey
WHERE OrderDetail.StorerKey = @StorerKey
AND Orders.Facility = @Facility
AND OrderDetail.Status >= 5
AND OrderDetail.UserDefine02 <> ''
IF @@ERROR <> 0 
	BEGIN
    SET @n_Err = @@ERROR
    SET @c_ErrMsg = CONVERT(NCHAR(10),@@ERROR) + ': OrderDetail update failed! (isp_PostPickOrderUpd_VIVO)'
	GOTO EXITNOW
	END
END

SELECT @b_Success = 1

EXITNOW:

END