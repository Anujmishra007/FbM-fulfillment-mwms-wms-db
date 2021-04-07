IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_RFID_Receiving_Confirm]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_RFID_Receiving_Confirm]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************/  
/* Stored Procedure: isp_RFID_Receiving_Confirm                          */  
/* Creation Date: 2020-09-21                                             */  
/* Copyright: LFL                                                        */  
/* Written by: Wan                                                       */  
/*                                                                       */  
/* Purpose: WMS-14739 - CN NIKE O2 WMS RFID Receiving Module             */
/*          ASN Header                                                   */  
/*                                                                       */  
/* Called By:                                                            */  
/*                                                                       */  
/* Version: 1.0                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date        Author   Ver   Purposes                                   */ 
/* 09-OCT-2020 Wan      1.0   Created                                    */
/* 2021-03-19  Wan01    1.1   WMS-16505 - [CN]NIKE_Phoenix_RFID_Receiving*/
/*                           _Overall_CR                                */
/*************************************************************************/   
CREATE PROCEDURE [dbo].[isp_RFID_Receiving_Confirm] 
   @n_SessionID         BIGINT         = 0   
,  @c_ReceiptKey        NVARCHAR(10)   = ''
,  @c_CarrierReference  NVARCHAR(18)   = ''
,  @n_TotalQtyReceived  INT            = 0   OUTPUT
,  @b_Success           INT            = 1   OUTPUT   
,  @n_Err               INT            = 0   OUTPUT
,  @c_Errmsg            NVARCHAR(255)  = ''  OUTPUT
AS  
BEGIN  
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue           INT = 1
         , @n_StartTCnt          INT = @@TRANCOUNT

         , @n_Cnt                INT          = 0 
         , @c_Facility           NVARCHAR(5)  = ''
         , @c_Storerkey          NVARCHAR(15) = ''
         , @c_CarrierRef         NVARCHAR(18) = ''
         , @c_ASNStatus          NVARCHAR(10) = '0'

         , @n_RowID              BIGINT       = 0
         , @n_Qty                INT          = 0
         , @c_ToLoc              NVARCHAR(10) = ''     
         , @c_ToId               NVARCHAR(18) = ''
         , @c_Sku                NVARCHAR(20) = ''
         , @c_Lottable01         NVARCHAR(18) = ''
         , @c_Lottable02         NVARCHAR(18) = ''
         , @c_Lottable03         NVARCHAR(18) = ''
         , @dt_Lottable04        DATETIME     = NULL
         , @c_Lottable06         NVARCHAR(30) = ''
         , @c_Lottable07         NVARCHAR(30) = ''
         , @c_Lottable08         NVARCHAR(30) = ''
         , @c_Lottable09         NVARCHAR(30) = ''
         , @c_Lottable10         NVARCHAR(30) = ''
         , @c_Lottable11         NVARCHAR(30) = ''
         , @c_Lottable12         NVARCHAR(30) = ''
         , @dt_Lottable13        DATETIME     = NULL
         , @dt_Lottable14        DATETIME     = NULL
         , @dt_Lottable15        DATETIME     = NULL
         
         , @c_TrackingNo         NVARCHAR(30) = ''

         , @CUR_CFMREC           CURSOR

   SELECT @n_Cnt = 1
         ,@c_Facility = RH.Facility
         ,@c_Storerkey= RH.Storerkey
         ,@c_CarrierRef = RH.CarrierReference
         ,@c_ASNStatus  = RH.ASNStatus
   FROM RECEIPT RH WITH (NOLOCK)
   WHERE RH.ReceiptKey = @c_ReceiptKey

   IF @n_Cnt = 0
   BEGIN
      SET @n_continue = 3      
      SET @n_err = 86010
      SET @c_errmsg = 'NSQL' +CONVERT(CHAR(5),@n_err) + ': ASN Not Found. (isp_RFID_Receiving_Confirm)'
      GOTO QUIT_SP
   END

   IF @c_ASNStatus = '9'
   BEGIN
      SET @n_continue = 3      
      SET @n_err = 86020
      SET @c_errmsg = 'NSQL' +CONVERT(CHAR(5),@n_err) + ': ASN Has Been Finalized. (isp_RFID_Receiving_Confirm)'
      GOTO QUIT_SP
   END

   IF @c_CarrierReference <> @c_CarrierRef
   BEGIN
      UPDATE RECEIPT
         SET CarrierReference = @c_CarrierReference 
         , Trafficcop = NULL
         , EditWho    = SUSER_NAME()
         , EditDate   = GETDATE()
      WHERE ReceiptKey = @c_ReceiptKey

      IF @@ERROR <> 0
      BEGIN
         SET @n_continue = 3      
         SET @n_err = 86030
         SET @c_errmsg = 'NSQL' +CONVERT(CHAR(5),@n_err) + ': Update RECEIPT Failed. (isp_RFID_Receiving_Confirm)'
         GOTO QUIT_SP
      END
   END
   
   SET @CUR_CFMREC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT   RD.RowID
      ,     RD.ToLoc
      ,     RD.ToId
      ,     RD.Sku
      ,     RD.Lottable01
      ,     RD.Lottable02
      ,     RD.Lottable03
      ,     RD.Lottable04
      ,     RD.Lottable06
      ,     RD.Lottable07
      ,     RD.Lottable08
      ,     RD.Lottable09
      ,     RD.Lottable10
      ,     RD.Lottable11
      ,     RD.Lottable12
      ,     RD.Lottable13
      ,     RD.Lottable14
      ,     RD.Lottable15
      ,     RD.Qty
      ,     RD.UserDefine02
      ,     RD.UserDefine04
   FROM RECEIPTDETAIL_WIP RD WITH (NOLOCK)
   WHERE RD.SessionID  = @n_SessionID
   AND   RD.ReceiptKey = @c_ReceiptKey
   AND   RD.LockDocKey  IN ('','N')

   OPEN @CUR_CFMREC

   FETCH NEXT FROM @CUR_CFMREC INTO
                                 @n_RowID 
                              ,  @c_ToLoc
                              ,  @c_ToId
                              ,  @c_Sku
                              ,  @c_Lottable01 
                              ,  @c_Lottable02 
                              ,  @c_Lottable03 
                              ,  @dt_Lottable04
                              ,  @c_Lottable06 
                              ,  @c_Lottable07 
                              ,  @c_Lottable08 
                              ,  @c_Lottable09 
                              ,  @c_Lottable10 
                              ,  @c_Lottable11 
                              ,  @c_Lottable12 
                              ,  @dt_Lottable13
                              ,  @dt_Lottable14
                              ,  @dt_Lottable15
                              ,  @n_Qty
                              ,  @c_CarrierReference
                              ,  @c_TrackingNo
 

   WHILE @@FETCH_STATUS <> -1
   BEGIN  
      --Confirm RFID Receiving
      EXEC dbo.isp_RFID_Receiving_ConfirmPost
           @c_StorerKey      = @c_StorerKey
         , @c_Facility       = @c_Facility
         , @c_ReceiptKey     = @c_ReceiptKey
         , @c_POKey          = '' 
         , @c_ToLOC          = @c_ToLoc
         , @c_ToID           = @c_ToID
         , @c_SKU            = @c_SKU
         , @c_UOM            = ''
         , @n_QTY            = @n_QTY
         , @c_Lottable01     = @c_Lottable01 
         , @c_Lottable02     = @c_Lottable02 
         , @c_Lottable03     = @c_Lottable03 
         , @dt_Lottable04    = @dt_Lottable04     
         , @dt_Lottable05    = NULL
         , @c_Lottable06     = @c_Lottable06 
         , @c_Lottable07     = @c_Lottable07 
         , @c_Lottable08     = @c_Lottable08 
         , @c_Lottable09     = @c_Lottable09 
         , @c_Lottable10     = @c_Lottable10 
         , @c_Lottable11     = @c_Lottable11 
         , @c_Lottable12     = @c_Lottable12 
         , @dt_Lottable13    = @dt_Lottable13 
         , @dt_Lottable14    = @dt_Lottable14
         , @dt_Lottable15    = @dt_Lottable15
         , @c_UserDefine02   = @c_CarrierReference
         , @c_UserDefine04   = @c_TrackingNo
         , @c_ConditionCode  = 'OK'
         , @c_SubreasonCode  = '' 
         , @b_Success        = @b_Success OUTPUT   
         , @n_Err            = @n_Err     OUTPUT
         , @c_Errmsg         = @c_Errmsg  OUTPUT

      IF @b_Success = 0
      BEGIN
         SET @n_continue = 3      
         SET @n_err = 86040
         SET @c_errmsg = 'NSQL' +CONVERT(CHAR(5),@n_err) + ': Error Executing isp_RFID_Receiving_ConfirmPost. (isp_RFID_Receiving_Confirm)'
                       + '(' + @c_Errmsg + ')'
         GOTO QUIT_SP
      END

      EXEC dbo.isp_Delete_ReceiptDetail_WIP
            @n_RowID   = @n_RowID   
         ,  @b_Success = @b_Success OUTPUT   
         ,  @n_Err     = @n_Err     OUTPUT
         ,  @c_Errmsg  = @c_Errmsg  OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_continue = 3      
         SET @n_err = 86050
         SET @c_errmsg = 'NSQL' +CONVERT(CHAR(5),@n_err) + ': Error Executing isp_Delete_ReceiptDetail_WIP. (isp_RFID_Receiving_Confirm)'
         GOTO QUIT_SP
      END

      FETCH NEXT FROM @CUR_CFMREC INTO 
                                    @n_RowID 
                                 ,  @c_ToLoc
                                 ,  @c_ToId
                                 ,  @c_Sku
                                 ,  @c_Lottable01 
                                 ,  @c_Lottable02 
                                 ,  @c_Lottable03 
                                 ,  @dt_Lottable04
                                 ,  @c_Lottable06 
                                 ,  @c_Lottable07 
                                 ,  @c_Lottable08 
                                 ,  @c_Lottable09 
                                 ,  @c_Lottable10 
                                 ,  @c_Lottable11 
                                 ,  @c_Lottable12 
                                 ,  @dt_Lottable13
                                 ,  @dt_Lottable14
                                 ,  @dt_Lottable15
                                 ,  @n_Qty
                                 ,  @c_CarrierReference
                                 ,  @c_TrackingNo
   END
   CLOSE @CUR_CFMREC
   DEALLOCATE @CUR_CFMREC

   SELECT @n_TotalQtyReceived = SUM(RD.BeforeReceivedQty)
   FROM RECEIPTDETAIL RD WITH (NOLOCK)
   WHERE RD.ReceiptKey = @c_Receiptkey
   GROUP BY RD.Receiptkey
   QUIT_SP:

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_RFID_Receiving_Confirm'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END  
GO
GRANT EXECUTE ON [dbo].[isp_RFID_Receiving_Confirm] TO nSQL 
GO


