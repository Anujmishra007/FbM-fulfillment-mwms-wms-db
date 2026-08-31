/************************************************************************/
/* Store procedure: [API].[isp_ECOMP_API_GetAllOrderList_S]             */
/* Creation Date: 29-Jun-2026                                           */
/* Copyright: Maersk                                                    */
/* Written by: Sean                                                     */
/*                                                                      */
/* Purpose: Returns all orders for a task batch regardless of           */
/*          PACKTASKDETAIL.Status. Used by Total Order, Packed Order,   */
/*          and Exceptional Order views in ECOMPack Single Mode.        */
/*          (Pending Order uses isp_ECOMP_API_GetOrderList_S which      */
/*          filters PTD.Status < '9'.)                                  */
/*                                                                      */
/* Called By: SCEAPI                                                    */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date           Author   Purposes                                     */
/* 29-Jun-2026    Sean     FCR-14533 Initial                            */
/************************************************************************/

CREATE OR ALTER PROC [API].[isp_ECOMP_API_GetAllOrderList_S](
     @b_Debug           INT            = 0
   , @c_Format          VARCHAR(10)    = ''
   , @c_UserID          NVARCHAR(256)  = ''
   , @c_OperationType   NVARCHAR(60)   = ''
   , @c_RequestString   NVARCHAR(MAX)  = ''
   , @b_Success         INT            = 0   OUTPUT
   , @n_ErrNo           INT            = 0   OUTPUT
   , @c_ErrMsg          NVARCHAR(250)  = ''  OUTPUT
   , @c_ResponseString  NVARCHAR(MAX)  = ''  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_DEFAULTS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue                    INT            = 1
         , @n_StartCnt                    INT            = @@TRANCOUNT

         , @c_TaskBatchNo                 NVARCHAR(10)   = ''
         , @c_OrderKey                    NVARCHAR(10)   = ''
         , @c_DropID                      NVARCHAR(10)   = ''
         , @c_Storerkey                   NVARCHAR(15)   = ''  -- FCR-12417 from request
         , @c_Facility                    NVARCHAR(5)    = ''  -- FCR-12417 from request
         , @c_sc_DisplayUPCMode           NVARCHAR(1)    = ''  -- FCR-12417

         , @b_sp_Success                  INT
         , @n_sp_err                      INT
         , @c_sp_errmsg                   NVARCHAR(250)= ''

   SET @b_Success                         = 0
   SET @n_ErrNo                           = 0
   SET @c_ErrMsg                          = ''
   SET @c_ResponseString                  = ''

   SELECT @c_TaskBatchNo   = ISNULL(RTRIM(TaskBatchID ), '')
         ,@c_OrderKey      = ISNULL(RTRIM(OrderKey    ), '')
         ,@c_DropID        = ISNULL(RTRIM(DropID      ), '')
         ,@c_Storerkey     = ISNULL(RTRIM(StorerKey   ), '')  -- FCR-12417
         ,@c_Facility      = ISNULL(RTRIM(Facility    ), '')  -- FCR-12417
   FROM OPENJSON (@c_RequestString)
   WITH (
      TaskBatchID          NVARCHAR(10)       '$.TaskBatchID',
      OrderKey             NVARCHAR(10)       '$.OrderKey',
      DropID               NVARCHAR(10)       '$.DropID',
      StorerKey            NVARCHAR(15)       '$.StorerKey',
      Facility             NVARCHAR(5)        '$.Facility'
   )

   IF @c_DropID <> ''
   BEGIN
      SELECT @c_TaskBatchNo = ISNULL(RTRIM(TaskBatchNo), '')
      FROM dbo.PACKTASKDETAIL PTD WITH (NOLOCK)
      WHERE EXISTS ( SELECT 1 FROM dbo.PickDetail PD WITH (NOLOCK)
         WHERE PD.DropID = @c_DropID AND PD.OrderKey = PTD.Orderkey)
   END
   ELSE IF @c_TaskBatchNo = '' AND @c_OrderKey <> ''
   BEGIN
      SELECT @c_TaskBatchNo = TaskBatchNo
      FROM [dbo].[PackTask] WITH (NOLOCK)
      WHERE OrderKey = @c_OrderKey
   END

   -- FCR-12417: StorerKey and Facility provided by caller, use directly
   SET @c_sc_DisplayUPCMode = ISNULL(dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'EPACKDisplayUPCMode'), '')

   SET @c_ResponseString = ISNULL((
                              SELECT PTD.TaskBatchNo
                                   , OH.Orderkey
                                   , OH.LoadKey
                                   , CASE WHEN @c_sc_DisplayUPCMode = '1'
                                          THEN ISNULL(UPC_LKP.UPC, PTD.Sku)
                                          ELSE PTD.Sku
                                     END AS Sku
                                   , PTD.QtyAllocated
                                   , ISNULL(PD.QtyPacked,0) AS QtyPacked
                                   , OH.[Status]
                                   , OH.SOStatus
                                   , PTD.[Status] AS TaskStatus
                              FROM PACKTASKDETAIL PTD WITH (NOLOCK)
                              JOIN ORDERS OH WITH (NOLOCK) ON OH.OrderKey = PTD.Orderkey
                              OUTER APPLY (SELECT SUM(Qty) AS QtyPacked
                                           FROM PACKDETAIL WITH (NOLOCK)
                                           WHERE PickSlipNo = PTD.PickSlipNo
                                           AND PickSlipNo <> '') AS PD
                              OUTER APPLY (SELECT TOP 1 U.UPC          -- FCR-12417
                                           FROM dbo.UPC U WITH (NOLOCK)
                                           INNER JOIN dbo.PACK P WITH (NOLOCK)
                                              ON P.PackKey = U.PackKey AND U.UOM = P.PackUOM3
                                           WHERE U.StorerKey = PTD.Storerkey AND U.SKU = PTD.Sku) AS UPC_LKP
                              WHERE PTD.TaskBatchNo = @c_TaskBatchNo
                              GROUP BY PTD.TaskBatchNo
                                     , OH.Orderkey
                                     , OH.LoadKey
                                     , CASE WHEN @c_sc_DisplayUPCMode = '1'
                                            THEN ISNULL(UPC_LKP.UPC, PTD.Sku)
                                            ELSE PTD.Sku
                                       END
                                     , PTD.QtyAllocated
                                     , ISNULL(PD.QtyPacked,0)
                                     , OH.[Status]
                                     , OH.SOStatus
                                     , PTD.[Status]
                              FOR JSON PATH
                           ), '')

   QUIT:

   IF @n_Continue= 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF @@TRANCOUNT > @n_StartCnt AND @@TRANCOUNT = 1
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartCnt
         BEGIN
            COMMIT TRAN
         END
      END
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END -- Procedure
