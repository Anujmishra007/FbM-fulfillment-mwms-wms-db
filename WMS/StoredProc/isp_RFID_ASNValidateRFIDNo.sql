IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_RFID_ASNValidateRFIDNo]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_RFID_ASNValidateRFIDNo]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: isp_RFID_ASNValidateRFIDNo                              */
/* Creation Date: 2020-08-28                                            */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:  WMS-14739 - CN NIKE O2 WMS RFID Receiving Module           */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.2                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 09-OCT-2020 Wan      1.0   Created                                   */
/* 03-MAR-2021 Wan01    1.1   WMS-16467 - [CN]NIKE_O2_RFID_Receiving_ChangeField_CR*/
/* 08-APR-2021 Wan02    1.2   WMS-16505 - [CN]NIKE_Phoenix_RFID_Receiving*/
/*                           _Overall_CR                                */
/************************************************************************/
CREATE PROC isp_RFID_ASNValidateRFIDNo
           @c_ReceiptKey         NVARCHAR(10)
         , @c_RFIDNo1            NVARCHAR(100)= ''  
         , @c_TidNo1             NVARCHAR(100)= '' 
         , @c_RFIDNo2            NVARCHAR(100)= '' 
         , @c_TidNo2             NVARCHAR(100)= '' 
         , @c_Sku                NVARCHAR(20) = '' OUTPUT
         , @b_Success            INT          = 1  OUTPUT
         , @n_Err                INT          = 0  OUTPUT
         , @c_ErrMsg             NVARCHAR(255)= '' OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT = @@TRANCOUNT
         , @n_Continue        INT = 1

         , @n_MatchTidNo1     INT = 0
         , @n_MatchTidNo2     INT = 0

         , @c_Facility        NVARCHAR(5)  = ''
         , @c_Storerkey       NVARCHAR(15) = ''
         , @c_CarrierName     NVARCHAR(45) = ''    --Wan01

         , @c_Sku1            NVARCHAR(20) = ''
         , @c_Sku2            NVARCHAR(20) = ''

         , @c_RFIDValidateSku_SP NVARCHAR(30) = ''

         , @c_SQL                NVARCHAR(MAX)= ''
         , @c_SQLParms           NVARCHAR(MAX)= ''

   SET @n_err      = 0
   SET @c_errmsg   = ''
   
   SET @c_Sku = ISNULL(@c_Sku, '')           --2021-01-07
   
   SELECT   @c_Facility     = RH.Facility
         ,  @c_Storerkey    = RH.Storerkey
         ,  @c_CarrierName = ISNULL(RH.CarrierName,'')   --(Wan01)
   FROM RECEIPT RH WITH (NOLOCK)
   WHERE RH.ReceiptKey = @c_ReceiptKey
  

   SELECT @c_Sku1 = MAX(CASE WHEN EOD.RFIDNo = @c_RFIDNo1 THEN EOD.Sku ELSE '' END)
         ,@c_Sku2 = MAX(CASE WHEN EOD.RFIDNo = @c_RFIDNo2 THEN EOD.Sku ELSE '' END)
         ,@n_MatchTidNo1 = MAX(CASE WHEN EOD.RFIDNo = @c_RFIDNo1 AND EOD.TidNo = @c_TidNo1 THEN 1 ELSE 0 END)
         ,@n_MatchTidNo2 = MAX(CASE WHEN EOD.RFIDNo = @c_RFIDNo2 AND EOD.TidNo = @c_TidNo2 THEN 1 ELSE 0 END)
   FROM EXTERNORDERS EOH WITH (NOLOCK) 
   JOIN EXTERNORDERSDETAIL EOD WITH (NOLOCK) ON EOH.ExternOrderKey = EOD.ExternOrderKey
   WHERE EOD.RFIDNo IN ( @c_RFIDNo1, @c_RFIDNo2 )
   AND   EOD.Storerkey = @c_Storerkey
   AND   EOH.PlatFormorderNo = @c_CarrierName                   --Wan02--(Wan01)
   AND   EOH.[Status]  = '9'
   GROUP BY EOD.Storerkey
         ,  EOH.Externorderkey
         ,  EOH.[Status]

   IF @c_Sku1 = '' AND  @c_Sku2 = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_Err      = 84010
      SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Both Left and Right RFIDNo For Receive''s Sales Order: ' + @c_CarrierName   --(Wan01)
                        + ' not found. (isp_RFID_ASNValidateRFIDNo)'
      GOTO QUIT_SP
   END

   IF @c_Sku1 = '' OR @c_Sku2 = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_Err      = 84020
      SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Either Left or Right RFIDNo Does Not Found in Received Sales Order.'
                        + ' (isp_RFID_ASNValidateRFIDNo)'

      GOTO QUIT_SP
   END

   IF @c_Sku1 <> @c_Sku2 
   BEGIN
      SET @n_Continue = 3
      SET @n_Err      = 84030
      SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Both RFIDNo''s Sku are unmatch.'
                        + ' (isp_RFID_ASNValidateRFIDNo)'
      GOTO QUIT_SP
   END

   IF @n_MatchTidNo1 = 0 OR @n_MatchTidNo2 = 0 
   BEGIN
      SET @n_Continue = 3
      SET @n_Err      = 84040
      SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Unmatch RFIDNo and TidNo is/are found.'
                        + ' (isp_RFID_ASNValidateRFIDNo)'
      GOTO QUIT_SP
   END

   --2021-01-07 for Scanned Sku then scanned RFID
   IF @c_Sku <> @c_Sku1 AND @c_Sku <> ''
   BEGIN
      SET @n_Continue = 3
      SET @n_Err      = 84050
      SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Scanned Sku and RFID Sku are unmatch.'
                        + ' (isp_RFID_ASNValidateRFIDNo)'
      GOTO QUIT_SP
   END
   
   IF NOT EXISTS (SELECT 1
                  FROM RECEIPTDETAIL RD WITH (NOLOCK)
                  WHERE RD.ReceiptKey = @c_ReceiptKey
                  AND   RD.Storerkey  = @c_Storerkey
                  AND   RD.Sku        = @c_Sku1
                  AND   RD.BeforeReceivedQty = 0
                  )
   BEGIN
      SET @n_Continue = 3
      SET @n_Err      = 84060
      SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': RFID Sku not Found in Receipt or Sku is received.'
                        + ' (isp_RFID_ASNValidateRFIDNo)'
      GOTO QUIT_SP
   END

   SET @c_Sku = @c_Sku1
  
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_RFID_ASNValidateRFIDNo'
      --RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_RFID_ASNValidateRFIDNo] TO nSQL 
GO
