SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: isp_CartonResidual                                 */
/* Creation Date: 25-Sep-2025                                           */
/* Copyright: Maersk                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: FCR - 8144 - PickMod To Case Reserve - Inventory Change     */
/*                                                                      */
/*                                                                      */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date                     Author    Ver.  Purposes                                */
/* 11-MAY-2026      SSA01     1.1    Added  ResidualQty > 0  validation */
/************************************************************************/

CREATE OR ALTER PROC [dbo]. [isp_CartonResidual]
           @c_DataStream         NVARCHAR(10)   = ''
         , @c_StorerKey          NVARCHAR(15)
         , @c_InboundCartonID    NVARCHAR(50)
         , @c_UPC                NVARCHAR(50)
         , @n_ResidualQty        INT
         , @b_Debug              INT
         , @b_Success            INT             = 0   OUTPUT
         , @n_Err                INT             = 0   OUTPUT
         , @c_ErrMsg             NVARCHAR(250)   = ''  OUTPUT
AS
BEGIN 
   SET NOCOUNT ON
   SET ANSI_DEFAULTS OFF  
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue int,
           @n_cnt int,
           @n_starttcnt int

    DECLARE @c_Lot           NVARCHAR(10) = ''
         , @c_CLK_Long       NVARCHAR(60) = ''
         , @c_CLK_Long2      NVARCHAR(60) = ''
         , @c_itrnkey        NVARCHAR(10) = ''
         , @n_Channel_ID     BIGINT = 0
         , @c_Sku            NVARCHAR(60) = ''
         , @n_Qty            INT = ''
         , @dt_Date          DATETIME = GETDATE()
         , @c_SourceType     NVARCHAR(30) = 'isp_CartonResidual'

   SELECT @n_Continue = 1, @b_Success = 1, @n_starttcnt=@@TRANCOUNT, @c_ErrMsg ='', @n_Err =0
  IF @@TRANCOUNT = 0
      BEGIN TRAN
	IF (@n_Continue = 1 OR @n_Continue = 2)
	BEGIN
	 SET @c_Lot = ''

       SELECT @c_Lot = ISNULL(RTRIM(Lot), '')
       FROM  UCC(NOLOCK)
       WHERE UCCNo = @c_InboundCartonID

       SELECT @c_Sku = sku
       FROM SKU(NOLOCK)
       WHERE StorerKey = @c_StorerKey AND retailsku = @c_UPC

       SET @c_CLK_Long = ''
       SET @c_CLK_Long2 = ''

       SELECT @c_CLK_Long = ISNULL(RTRIM(Long),'') -- FromLOC
       FROM CODELKUP
       WHERE LISTNAME = 'BBDEFLOC'
       AND StorerKey = @c_StorerKey
       AND code = '1'

       SELECT @c_CLK_Long2 = ISNULL(RTRIM(Long),'') --ToLOC
       FROM CODELKUP
       WHERE LISTNAME = 'BBDEFLOC'
       AND StorerKey = 'LVSUSA'
       AND code = '2'

       SELECT @n_Qty = L.Qty-L.QtyAllocated-L.QtyPicked-L.PendingMoveIN
       FROM LOTxLOCxID(NOLOCK) L
       WHERE L.StorerKey = @c_StorerKey and SKU= @c_Sku and L.Loc = @c_CLK_Long and Lot= @c_Lot

       IF @n_ResidualQty <= 0 OR @n_Qty < @n_ResidualQty
       BEGIN
          SELECT @n_continue = 3
          SELECT @c_ErrMsg = CONVERT(CHAR(250),@n_err), @n_Err = 30101
			    SELECT @c_ErrMsg='NSQL'+CONVERT(char(5),@n_Err)+': Invalid ResidualQty. (isp_CartonResidual)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_ErrMsg),'') + ' ) '
       END
       IF @n_continue IN (1, 2)
       BEGIN
       IF EXISTS(SELECT 1 FROM UCC WITH (NOLOCK)
               WHERE StorerKey = @c_StorerKey AND Status = '6' AND UCCNo = @c_InboundCartonID)
        BEGIN
             UPDATE UCC WITH (ROWLOCK)
             SET Status = '1', Loc = @c_CLK_Long2, WaveKey = '',OrderKey = '', OrderLineNumber = '', PickDetailKey = ''
                , SourceType= @c_SourceType, TrafficCop = NULL
                , qty = @n_ResidualQty
             WHERE UCCNo = @c_InboundCartonID
             AND StorerKey = @c_StorerKey
             AND Status = '6'

            SELECT @n_Err = @@ERROR
            IF @n_Err <> 0
            BEGIN
              SELECT @n_continue = 3
              SELECT @c_ErrMsg = CONVERT(CHAR(250),@n_Err), @n_Err = 30102
              SELECT @c_ErrMsg='NSQL'+CONVERT(char(5),@n_Err)+': Error Update UCC Table. (isp_CartonResidual)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_ErrMsg),'') + ' ) '
            END
        END
        ELSE
        BEGIN
              SELECT @n_continue = 3
              SELECT @c_ErrMsg = CONVERT(CHAR(250),@n_Err), @n_Err = 30103
              SELECT @c_ErrMsg='NSQL'+CONVERT(char(5),@n_Err)+': Unable to find UCC No with status 6. (isp_CartonResidual)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_ErrMsg),'') + ' ) '
        END
       END
       IF @n_continue IN (1, 2)
       BEGIN
		   EXEC nspItrnAddMove @n_ItrnSysId = 0,
                           @c_StorerKey = @c_StorerKey,
                           @c_Sku = @c_Sku,
                           @c_Lot = @c_Lot,
                           @c_FromLoc = @c_CLK_Long,
                           @c_FromID = N'',
                           @c_ToLoc = @c_CLK_Long2,
                           @c_ToID = @c_InboundCartonID,
                           @c_Status = N'',
                           @c_lottable01 = N'',
                           @c_lottable02 = N'',
                           @c_lottable03 = N'',
                           @d_lottable04 = null,
                           @d_lottable05 = null,
                           @c_lottable06 = N'',
                           @c_lottable07 = N'',
                           @c_lottable08 = N'',
                           @c_lottable09 = N'',
                           @c_lottable10 = N'',
                           @c_lottable11 = N'',
                           @c_lottable12 = N'',
                           @d_lottable13 = null,
                           @d_lottable14 = null,
                           @d_lottable15 = null,
                           @n_casecnt = 0,
                           @n_innerpack = 0,
                           @n_qty = @n_ResidualQty,
                           @n_pallet = 0,
                           @f_cube = 0.0,
                           @f_grosswgt = 0.0,
                           @f_netwgt = 0.0,
                           @f_otherunit1 = 0.0,
                           @f_otherunit2 = 0.0,
                           @c_SourceKey = N'',
                           @c_SourceType = N'',
                           @c_PackKey = N'',
                           @c_UOM = N'',
                           @b_UOMCalc = 0,
                           @d_EffectiveDate = @dt_Date, -- datetime
                           @c_itrnkey = @c_itrnkey OUTPUT,
                           @b_Success = @b_Success OUTPUT,
                           @n_err = @n_Err OUTPUT,
                           @c_errmsg = @c_ErrMsg OUTPUT,
                           @c_MoveRefKey = N'',
                           @c_Channel = N'',
                           @n_Channel_ID = @n_Channel_ID OUTPUT

            SELECT @n_Err = @@ERROR
            IF @n_Err <> 0
            BEGIN
              SELECT @n_continue = 3
              SELECT @c_ErrMsg = CONVERT(CHAR(250),@n_Err), @n_Err = 30104
              SELECT @c_ErrMsg='NSQL'+CONVERT(char(5),@n_Err)+': Error while executing nspItrnAddMove. (isp_CartonResidual)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_ErrMsg),'') + ' ) '
            END
       END
	END

   IF @n_Continue=3  -- Error Occured - Process And Return
	 BEGIN
	    SELECT @b_Success = 0
	    IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_starttcnt
	    BEGIN
	       ROLLBACK TRAN
	    END
	    ELSE
	    BEGIN
	       WHILE @@TRANCOUNT > @n_starttcnt
 	      BEGIN
	          COMMIT TRAN
	       END
	    END
  	  execute nsp_logerror @n_Err, @c_ErrMsg, 'isp_CartonResidual'
	    RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR    -- SQL2012
	    RETURN
	 END
	 ELSE
	    BEGIN
	       SELECT @b_Success = 1
	       WHILE @@TRANCOUNT > @n_starttcnt
	       BEGIN
	          COMMIT TRAN
	       END
	       RETURN
	    END	   
END -- End PROC
GO 

GRANT EXECUTE ON isp_CartonResidual TO NSQL
GO

