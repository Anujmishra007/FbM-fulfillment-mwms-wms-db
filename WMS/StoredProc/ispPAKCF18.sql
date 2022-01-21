IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[ispPAKCF18]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[ispPAKCF18]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: ispPAKCF18                                            */
/* Creation Date: 03-Nov-2021                                              */
/* Copyright: LFL                                                          */
/* Written by: WLChooi                                                     */
/*                                                                         */
/* Purpose: WMS-18248 - SG Adidas Update Packdetail & Packinfo upon Pack   */ 
/*                      Confirm                                            */
/*                                                                         */
/* Called By: PostPackConfirmSP                                            */
/*                                                                         */
/* GitLab Version: 1.0                                                     */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 03-Nov-2021  WLChooi 1.0   DevOps Combine Script                        */
/***************************************************************************/  
CREATE PROC [dbo].[ispPAKCF18]  
(     @c_PickSlipNo  NVARCHAR(10)   
  ,   @c_Storerkey   NVARCHAR(15)
  ,   @b_Success     INT           OUTPUT
  ,   @n_Err         INT           OUTPUT
  ,   @c_ErrMsg      NVARCHAR(255) OUTPUT   
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @b_Debug           INT = 0
         , @n_Continue        INT 
         , @n_StartTCnt       INT 
 
   DECLARE @c_ECOM_S_Flag     NVARCHAR(1)
         , @c_OrderType       NVARCHAR(20)
         , @c_DocType         NVARCHAR(20)
         , @c_Orderkey        NVARCHAR(10)
         , @n_CartonNo        INT
         , @c_TrackingNo      NVARCHAR(50)
         , @c_UDF05           NVARCHAR(50)
   
   IF @n_Err > 0
   BEGIN
      SET @b_Debug  = @n_Err
   END

   SET @b_Success= 1 
   SET @n_Err    = 0  
   SET @c_ErrMsg = ''
   SET @n_Continue = 1  
   SET @n_StartTCnt = @@TRANCOUNT  

   IF @@TRANCOUNT = 0
      BEGIN TRAN 

   SELECT @c_ECOM_S_Flag = MAX(OH.ECOM_SINGLE_Flag)
        , @c_OrderType   = MAX(OH.[Type]) 
        , @c_DocType     = MAX(OH.DocType)
        , @c_Orderkey    = MAX(OH.OrderKey)
        , @c_TrackingNo  = MAX(OH.TrackingNo)
   FROM ORDERS OH (NOLOCK)
   JOIN PACKHEADER PH (NOLOCK) ON OH.OrderKey = PH.Orderkey
   WHERE PH.PickSlipNo = @c_Pickslipno
        
   IF @c_DocType = 'E'
   BEGIN
      SELECT @c_UDF05 = ISNULL(CL.UDF05,'') 
      FROM ORDERS OH (NOLOCK)
      JOIN CODELKUP CL (NOLOCK) ON CL.Listname = 'COURIERLBL'
                               AND CL.Storerkey  = OH.Storerkey
                               AND CL.Code = OH.Salesman
      WHERE OH.Orderkey = @c_Orderkey

      IF @c_UDF05 <> 'Y'
      BEGIN
         DECLARE CUR_LOOP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT DISTINCT CAST(PD.CartonNo AS INT)
         FROM PACKDETAIL PD (NOLOCK)
         WHERE PD.PickSlipNo = @c_PickSlipNo
         ORDER BY CAST(PD.CartonNo AS INT)

         OPEN CUR_LOOP

         FETCH NEXT FROM CUR_LOOP INTO @n_CartonNo

         WHILE @@FETCH_STATUS <> -1
         BEGIN
            UPDATE PACKDETAIL 
            SET RefNo = @c_TrackingNo
            WHERE PickSlipNo = @c_PickSlipNo
            AND CartonNo = @n_CartonNo

            IF @@ERROR <> 0  
            BEGIN  
               SET @n_continue = 3    
               SET @n_err = 65025     
               SET @c_errmsg = 'NSQL'+CONVERT(char(5),@n_err)+': Update PACKDETAIL table FAILED. (ispPAKCF18)'     
                             + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '     
               GOTO QUIT_SP    
            END  

            UPDATE PACKINFO 
            SET TrackingNo = @c_TrackingNo
            WHERE PickSlipNo = @c_PickSlipNo
            AND CartonNo = @n_CartonNo

            IF @@ERROR <> 0  
            BEGIN  
               SET @n_continue = 3    
               SET @n_err = 65030     
               SET @c_errmsg = 'NSQL'+CONVERT(char(5),@n_err)+': Update PACKINFO table FAILED. (ispPAKCF18)'     
                             + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '     
               GOTO QUIT_SP    
            END 

            FETCH NEXT FROM CUR_LOOP INTO @n_CartonNo
         END
         CLOSE CUR_LOOP
         DEALLOCATE CUR_LOOP
      END
   END

QUIT_SP:
   IF CURSOR_STATUS('LOCAL', 'CUR_LOOP') IN (0 , 1)
   BEGIN
      CLOSE CUR_LOOP
      DEALLOCATE CUR_LOOP   
   END
   
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispPAKCF18'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
        COMMIT TRAN
      END 
      RETURN
   END 
END
GO

GRANT EXECUTE ON [dbo].[ispPAKCF18] TO nSQL 
GO
