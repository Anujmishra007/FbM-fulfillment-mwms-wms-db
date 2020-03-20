IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_Ecom_GetPackTaskOrders_S]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_Ecom_GetPackTaskOrders_S]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Trigger: isp_Ecom_GetPackTaskOrders_S                                */
/* Creation Date: 19-APR-2016                                           */
/* Copyright: LF Logistics                                              */
/* Written by: YTWan                                                    */
/*                                                                      */
/* Purpose: SOS#361901 - New ECOM Packing                               */
/*        :                                                             */
/* Called By: d_dw_ecom_packtaskorders_s (Single Order Mode)            */
/*          :                                                           */
/* PVCS Version: 1.5                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 23-SEP-2016 Wan01    1.1   Performance Tune                          */
/* 13-OCT-2017 Wan02    1.2   Performance Tune                          */
/* 13-JUN-2018 Wan03    1.3   Prevent & Trace issue:Orderkey Pack twice */
/* 14-AUG-2018 Wan04    1.3   Performance Tune                          */
/* 04-Apr-2019 NJOW01   1.4   WMS-8741 Add DropId parameter and filter  */
/*                            order by dropid                           */
/* 24-JUN-2019 Wan05    1.5   Performance Tune                          */ 
/* 16-AUG-2019 Wan06    1.6   Performance Tune. Remove debug - Print    */ 
/************************************************************************/
CREATE PROC [dbo].[isp_Ecom_GetPackTaskOrders_S]
            @c_TaskBatchNo    NVARCHAR(10)
         ,  @c_PickSlipNo     NVARCHAR(10)
         ,  @c_Orderkey       NVARCHAR(10) OUTPUT
         ,  @b_packcomfirm    INT            = 0
         ,  @c_DropID         NVARCHAR(20)   = '' --NJOW01         
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT
         , @n_Continue        INT 

         , @c_InProgOrderkey  NVARCHAR(10)
         , @c_Storerkey       NVARCHAR(15)   
         , @c_NonEPackSOLabel NVARCHAR(150)
         
         , @b_AutoAssignOrder INT               --(Wan01)
         , @n_RowRef          BIGINT            --(Wan01)
         , @c_PH_Orderkey     NVARCHAR(10)      --(Wan01)

         , @c_Sku             NVARCHAR(20)      --(Wan01)

         , @n_TotalOrder      INT               --(Wan01)
         , @n_TotalPacked     INT               --(Wan01)
         , @n_TotalCanc       INT               --(Wan01)
         , @n_Retry           INT 
         , @n_Retry1          INT               --(Wan03)

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_TotalOrder = 0                        --(Wan02)
   SET @n_TotalPacked= 0                        --(Wan02)
   SET @n_TotalCanc  = 0                        --(Wan02)
   SET @c_InProgOrderkey  = ''                  --(Wan02)
   SET @c_NonEPackSOLabel = ''                  --(Wan02)

   --(Wan02) - START
   WHILE @@TRANCOUNT > 0
   BEGIN
      COMMIT TRAN
   END
   --(Wan02) - END

   IF RTRIM(@c_TaskBatchNo) = '' OR @c_TaskBatchNo IS NULL
   BEGIN
      --GOTO QUIT_SP 
      GOTO DISPLAY_SUMMARY                      --(Wan02)
   END

   SET @c_Orderkey = ISNULL(RTRIM(@c_Orderkey),'')
   SET @c_NonEPackSOLabel = ''


   EXECUTE isp_Ecom_GetPackTaskOrderStatus
         @c_TaskBatchNo = @c_TaskBatchNo 
      ,  @c_PickSlipNo  = @c_PickSlipNo 
      ,  @c_Orderkey    = @c_Orderkey           --(WAN05)

   SET @c_InProgOrderkey = ''

   --(Wan1) - START
   --12-OCT-2016 - START
   IF @c_Orderkey <> ''
   BEGIN
      SET @c_InProgOrderkey = @c_Orderkey
   END
   --12-OCT-2016 - END
   IF @c_PickSlipNo <> '' AND @c_InProgOrderkey = ''   --12-OCT-2016 - START
   BEGIN
      SET @c_PH_Orderkey = ''

      SELECT @c_PH_Orderkey = Orderkey
      FROM PACKHEADER WITH (NOLOCK)
      WHERE PickSlipNo = @c_PickSlipNo

      IF @c_PH_Orderkey = ''
      BEGIN
         SET @c_Storerkey = ''
         SET @c_sku = ''

         SELECT @c_Storerkey = Storerkey
               ,@c_sku = Sku
         FROM PACKDETAIL WITH(NOLOCK)
         WHERE PickSlipNo = @c_PickSlipNo

         SET @n_Retry = 0 
         SET @n_Retry1= 0 
      
         Get_NextOrderNo:
      
         SET @n_RowRef = 0
         
         IF ISNULL(@c_DropID,'') <> '' --NJOW01
         BEGIN
            SELECT TOP 1 
                   @n_RowRef  = PTD.RowRef
                  ,@c_InProgOrderkey = PTD.Orderkey
            FROM PACKTASKDETAIL PTD WITH (NOLOCK)
            JOIN PICKDETAIL PD WITH (NOLOCK) ON PTD.Orderkey = PD.Orderkey AND PTD.Storerkey = PD.Storerkey AND PTD.Sku = PD.Sku         
            WHERE PTD.TaskBatchNo = @c_TaskBatchNo
            AND   PTD.Storerkey = @c_Storerkey
            AND   PTD.Sku = @c_Sku
            AND   PTD.Status = '0' 
            AND   PD.DropID = @c_DropID
            ORDER BY PTD.RowRef
         END
         ELSE
         BEGIN
            SELECT TOP 1 
                   @n_RowRef  = RowRef
                  ,@c_InProgOrderkey = Orderkey
            FROM PACKTASKDETAIL WITH (NOLOCK)         
            WHERE TaskBatchNo = @c_TaskBatchNo
            AND   Storerkey = @c_Storerkey
            AND   Sku = @c_Sku
            AND   Status = '0' 
            ORDER BY RowRef
         END

         IF @c_InProgOrderkey <> ''
         BEGIN
            UPDATE PACKTASKDETAIL WITH (ROWLOCK)
            SET Status     = '3'
               ,PickSlipNo = @c_PickSlipNo  
               ,EditWho    = SUSER_NAME()
               ,EditDate   = GETDATE()
               ,TrafficCop = NULL
            WHERE RowRef = @n_RowRef 
            AND   Status = '0'  

            IF @@ROWCOUNT = 0   
            BEGIN  
               SET @n_Retry = ISNULL(@n_Retry, 0) + 1  
                     
               IF @n_Retry > 3   
                  SET @c_InProgOrderkey = ''   
               ELSE  
                  GOTO Get_NextOrderNo
            END
         END 

         --(Wan03) - START
         IF @c_InProgOrderkey <> ''
         BEGIN
            IF EXISTS ( SELECT 1 
                        FROM PACKHEADER WITH (NOLOCK)
                        WHERE Orderkey = @c_InProgOrderkey
                        AND   PickSlipNo <> @c_PickSlipNo
                      )
            BEGIN
               --INSERT INTO TRACEINFO (TraceName, TimeIn, TimeOut, Step1, Step2, Step3)
               --VALUES ('isp_Ecom_GetPackTaskOrders_S', GETDATE(), GETDATE(), @c_TaskBatchNo, @c_PickSlipNo, @c_InProgOrderkey)

               SET @n_Retry1 = ISNULL(@n_Retry1, 0) + 1 
               
               IF @n_Retry1 > 3
               BEGIN
                  SET @c_InProgOrderkey = ''
               END 
               ELSE
               BEGIN
                  GOTO Get_NextOrderNo
               END 
            END
         END
         --(Wan03) - END 
      END
      --12-OCT-2016 - START
      IF @b_packcomfirm = 1 AND @c_InProgOrderkey <> ''
      BEGIN
         SET @c_Orderkey = @c_InProgOrderkey
         GOTO QUIT_SP
      END
      --12-OCT-2016 - END
   END 
   --(Wan1) - END

   SET @c_NonEPackSOLabel = 'CANC/ HOLD/ '



   IF ISNULL(RTRIM(@c_Storerkey),'') = ''
   BEGIN
      SELECT TOP 1 @c_Storerkey = PTD.Storerkey
      FROM PACKTASKDETAIL PTD WITH (NOLOCK)
      WHERE PTD.TaskBatchNo = @c_TaskBatchNo
   END
--print '@c_Storerkey'     --(Wan06)
--print @c_Storerkey       --(Wan06)
   --(Wan04) - START
   IF EXISTS ( SELECT 1   
               FROM CODELKUP CL WITH (NOLOCK)  
               WHERE CL.ListName = 'NONEPACKSO'
               AND   CL.Storerkey= @c_Storerkey
               )
   BEGIN
      SET @c_NonEPackSOLabel = @c_NonEPackSOLabel
                             + RTRIM(ISNULL(CONVERT(VARCHAR(250),
                                            (  SELECT  RTRIM(Code) + '/ ' 
                                                FROM CODELKUP WITH (NOLOCK) 
						                              WHERE ListName = 'NONEPACKSO'
                                                AND Code NOT IN ('CANC', 'HOLD')
                                                AND Storerkey = @c_Storerkey
                                                FOR XML PATH(''), TYPE
                                             )
                                           )
                                       ,'')
                                    )
   END
   ELSE
   BEGIN
  SET @c_NonEPackSOLabel = @c_NonEPackSOLabel
                             + RTRIM(ISNULL(CONVERT(VARCHAR(250),
                                            (  SELECT  RTRIM(Code) + '/ ' 
                                                FROM CODELKUP WITH (NOLOCK) 
						                              WHERE ListName = 'NONEPACKSO'
                                                AND Code NOT IN ('CANC', 'HOLD')
                                                AND Storerkey = ''
                                                FOR XML PATH(''), TYPE
                                             )
                                           )
                                       ,'')
                                    )
   END
   --(Wan04) - END

   IF LEN(@c_NonEPackSOLabel) > 0 
   BEGIN
      SET @c_NonEPackSOLabel = LEFT(@c_NonEPackSOLabel, LEN(@c_NonEPackSOLabel) - 1) + ' Order: '
   END

   --(Wan01) - START
   SET @n_TotalOrder = 0
   SET @n_TotalPacked = 0
   SET @n_TotalCanc  = 0
   SELECT @n_TotalOrder  = COUNT(1)
         ,@n_TotalPacked = ISNULL(SUM(CASE WHEN Status = '9' THEN 1 ELSE 0 END),0)
         ,@n_TotalCanc   = ISNULL(SUM(CASE WHEN Status = 'X' THEN 1 ELSE 0 END),0)
   FROM PACKTASKDETAIL WITH (NOLOCK)
   WHERE TaskBatchNo = @c_TaskBatchNo   

DISPLAY_SUMMARY:
   SELECT  
         TaskBatchNo    = @c_TaskBatchNo
      ,  Orderkey       = '' 
      ,  TotalOrder     = @n_TotalOrder
      ,  PackedOrder    = @n_TotalPacked
      ,  PendingOrder   = @n_TotalOrder - @n_TotalPacked - @n_TotalCanc
      ,  CancelledOrder = @n_TotalCanc
      ,  InProgOrderkey = @c_InProgOrderkey
      ,  NonEPackSO     = @c_NonEPackSOLabel  
   --(Wan01) - END
QUIT_SP:
  
   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
   --(Wan02) - END
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_Ecom_GetPackTaskOrders_S] TO nSQL 
GO
