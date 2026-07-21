SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************************/
/* Trigger: isp_ECOMP_GetValidQtyPacked                                             */
/* Creation Date: 20-APR-2016                                                       */
/* Copyright: LF Logistics                                                          */
/* Written by: YTWan                                                                */
/*                                                                                  */
/* Purpose: SOS#361901 - New ECOM Packing                                           */
/*        :                                                                         */
/* Called By: nep_n_cst_packcarton_ecom                                             */
/*          : ue_sku_rule                                                           */
/* PVCS Version: 1.1                                                                */
/*                                                                                  */
/* Version: 7.0                                                                     */
/*                                                                                  */
/* Data Modifications:                                                              */
/*                                                                                  */
/* Updates:                                                                         */
/* Date        Author   Ver   Purposes                                              */
/* 21-SEP-2016 Wan01    1.1   Performance Tune                                      */
/* 20-OCT-2016 Wan03    1.2   Fixed invalid qty if no packdetail                    */
/* 06-OCT-2017 Wan04    1.3   Performance Tune                                      */
/* 07-Apr-2026 Sean01   1.4   FCR-11940 - clone from dbo.isp_Ecom_GetValidQtyPacked */
/* 23-Apr-2026 Sean02   1.5   FCR-11940 - add debug print log                       */
/************************************************************************************/
CREATE OR ALTER PROC [API].[isp_ECOMP_GetValidQtyPacked]
            @b_Debug          INT = 0 -- Sean02
         ,  @c_PickSlipNo     NVARCHAR(10)
         ,  @c_TaskBatchNo    NVARCHAR(10)
         ,  @c_Storerkey      NVARCHAR(15)
         ,  @c_Sku            NVARCHAR(20)
         ,  @n_Qty            INT = 1
         ,  @c_UserID         NVARCHAR(30)
         ,  @c_ComputerName   NVARCHAR(30)
         ,  @b_ValidQtyPacked INT         OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF


   DECLARE
           @n_StartTCnt    INT
         , @n_Continue     INT

         , @n_QtyPacked    INT
         , @n_SkuQtyPacked INT
         , @n_SkuQtyOrder  INT
         , @c_Orderkey     NVARCHAR(10)

         , @c_PTD_Status   NVARCHAR(10)   --(Wan02)
         , @c_PTD_ORderkey NVARCHAR(10)   --(Wan02)

         , @c_OrderMode    NVARCHAR(10)   --(Wan02)

         , @b_FirstSkuScan INT            --(Wan03)

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1

   SET @b_ValidQtyPacked = 1

   SET @c_PickSlipNo = ISNULL(RTRIM(@c_PickSlipNo),'')


   SET @n_QtyPacked = 0
   SET @c_Orderkey = ''
  --(Wan03) - START
   SET @b_FirstSkuScan = 0

   -- Sean02 B : print inputs
   IF @b_Debug = 1
   BEGIN
      PRINT '====== isp_ECOMP_GetValidQtyPacked : INPUTS ======'
      PRINT ' @c_PickSlipNo   = [' + @c_PickSlipNo + ']'
      PRINT ' @c_TaskBatchNo  = [' + ISNULL(@c_TaskBatchNo, '') + ']'
      PRINT ' @c_Storerkey    = [' + ISNULL(@c_Storerkey, '') + ']'
      PRINT ' @c_Sku          = [' + ISNULL(@c_Sku, '') + ']'
      PRINT ' @n_Qty          = ' + CONVERT(NVARCHAR(10), ISNULL(@n_Qty, 0))
      PRINT ' @c_UserID       = [' + ISNULL(@c_UserID, '') + ']'
      PRINT ' @c_ComputerName = [' + ISNULL(@c_ComputerName, '') + ']'
   END
   -- Sean02 E

   -- Blank pickslip #. Scan First Sku for a taskbatchno,
   IF @c_PickSlipNo = ''
   BEGIN
      SET @b_FirstSkuScan = 1
   END
   ELSE  -- With PickSlip #
   BEGIN
      SET @b_FirstSkuScan = 1

      SELECT @b_FirstSkuScan = 0
      FROM PACKDETAIL WITH (NOLOCK)
      WHERE PickSlipNo = @c_PickSlipNo

      -- With PickSlip #
      SELECT @c_Orderkey = Orderkey
      FROM PACKHEADER WITH (NOLOCK)
      WHERE PickSlipNo= @c_PickSlipNo

      IF @c_Orderkey <> ''
      BEGIN
         SET @b_FirstSkuScan = 0
      END
   END

   -- Sean02 B : print first-scan detection result
   IF @b_Debug = 1
   BEGIN
      PRINT '------ First-Scan Detection ------'
      PRINT ' @b_FirstSkuScan = ' + CONVERT(NVARCHAR(5), @b_FirstSkuScan)
      PRINT ' @c_Orderkey (from PackHeader) = [' + ISNULL(@c_Orderkey,'') + ']'
   END
   -- Sean02 E

   IF @b_FirstSkuScan = 1
   --(Wan03) - END
   BEGIN
      SET @n_QtyPacked = @n_Qty

      SET @b_ValidQtyPacked = 0

      SELECT TOP 1 @b_ValidQtyPacked = 1
      FROM PACKTASKDETAIL PTD WITH (NOLOCK)
      WHERE PTD.TaskBatchNo = @c_TaskBatchNo
      AND   PTD.Storerkey   = @c_Storerkey
      AND   PTD.Sku = @c_Sku
      AND   PTD.QtyAllocated >= @n_QtyPacked
      AND   PTD.Status = '0'

      GOTO QUIT_SP
   END

   --(Wan03) - START
   -- With PickSlip #
   --SELECT @c_Orderkey = Orderkey
   --FROM PACKHEADER WITH (NOLOCK)
   --WHERE PickSlipNo= @c_PickSlipNo
   --(Wan03) - END

   SELECT @n_QtyPacked = ISNULL(SUM(Qty),0)
   FROM PACKDETAIL WITH (NOLOCK)
   WHERE PickSlipNo= @c_PickSlipNo
   AND   Storerkey = @c_Storerkey
   AND   Sku = @c_Sku

   SET @n_QtyPacked = @n_QtyPacked + @n_Qty

   -- Sean02 B : print qty-packed calculation
   IF @b_Debug = 1
   BEGIN
      PRINT '------ Qty Already Packed (PackDetail) ------'
      PRINT ' SUM(PackDetail.Qty) + @n_Qty = @n_QtyPacked = ' + CONVERT(NVARCHAR(10), @n_QtyPacked)
   END
   -- Sean02 E

   -- With Orderkey and with pickslip #
   IF @c_Orderkey <> ''
   BEGIN
      SELECT TOP 1 @b_ValidQtyPacked = 0
      FROM PACKTASKDETAIL PTD WITH (NOLOCK)
      WHERE PTD.Orderkey = @c_Orderkey
      AND   PTD.Storerkey = @c_Storerkey
      AND   PTD.Sku = @c_Sku
      AND   PTD.QtyAllocated < @n_QtyPacked

      -- Sean02 B : print branch result
      IF @b_Debug = 1
      BEGIN
         PRINT '------ Branch: WITH ORDERKEY + PICKSLIP ------'
         PRINT ' @c_Orderkey           = [' + @c_Orderkey + ']'
         PRINT ' @n_QtyPacked          = ' + CONVERT(NVARCHAR(10), @n_QtyPacked)
         PRINT ' @b_ValidQtyPacked     = ' + CONVERT(NVARCHAR(5), @b_ValidQtyPacked)
         PRINT ' (valid=0 if any PTD row has QtyAllocated < @n_QtyPacked)'
      END
      -- Sean02 E

      GOTO QUIT_SP
   END

   -- Blank Orderkey with pickslip # for single packtask
   SET @c_OrderMode = ''
   SELECT TOP 1 @c_OrderMode = OrderMode
   FROM PACKTASK WITH (NOLOCK)
   WHERE TaskBatchNo = @c_TaskBatchNo

   -- Sean02 B : print order mode
   IF @b_Debug = 1
   BEGIN
      PRINT '------ OrderMode Lookup ------'
      PRINT ' @c_OrderMode = [' + ISNULL(@c_OrderMode,'') + ']'
   END
   -- Sean02 E

   IF  LEFT(@c_OrderMode,1) = 's'
   BEGIN
      SET @b_ValidQtyPacked = 0

      SELECT TOP 1 @b_ValidQtyPacked = 1
      FROM PACKTASKDETAIL PTD WITH (NOLOCK)
      WHERE PTD.TaskBatchNo = @c_TaskBatchNo
      AND   PTD.Storerkey   = @c_Storerkey
      AND   PTD.Sku = @c_Sku 
      AND   PTD.QtyAllocated >= @n_QtyPacked
      AND   PTD.Status = '0'

      -- Sean02 B : print branch result
      IF @b_Debug = 1
      BEGIN
         PRINT '------ Branch: SINGLE PACKTASK (OrderMode=s) ------'
         PRINT ' @n_QtyPacked      = ' + CONVERT(NVARCHAR(10), @n_QtyPacked)
         PRINT ' @b_ValidQtyPacked = ' + CONVERT(NVARCHAR(5), @b_ValidQtyPacked)
      END
      -- Sean02 E

      GOTO QUIT_SP
   END

   -- Blank Orderkey with pickslip # for multi packtask
   --(Wan04) - START
   SET @b_ValidQtyPacked = 0
   IF EXISTS (
               SELECT 1
               FROM PACKTASKDETAIL  PTD WITH (NOLOCK)
               WHERE PTD.TaskBatchNo = @c_TaskBatchNo
               AND   PTD.Status < '3'
               AND   ( dbo.fnc_ECOM_GetPackOrderStatus (@c_TaskBatchNo, @c_PickSlipNo, Orderkey) = '1')
               AND   PTD.Storerkey = @c_Storerkey
               AND   PTD.Sku = @c_Sku
               AND   PTD.QtyAllocated >= @n_QtyPacked
             )
   BEGIN
      SET @b_ValidQtyPacked = 1
   END

   -- Sean02 B : print branch result
   IF @b_Debug = 1
   BEGIN
      PRINT '------ Branch: MULTI PACKTASK ------'
      PRINT ' @n_QtyPacked      = ' + CONVERT(NVARCHAR(10), @n_QtyPacked)
      PRINT ' @b_ValidQtyPacked = ' + CONVERT(NVARCHAR(5), @b_ValidQtyPacked)
   END
   -- Sean02 E

QUIT_SP:

   -- Sean02 B : final result
   IF @b_Debug = 1
   BEGIN
      PRINT '====== isp_ECOMP_GetValidQtyPacked : FINAL ======'
      PRINT ' @b_ValidQtyPacked = ' + CONVERT(NVARCHAR(5), @b_ValidQtyPacked)
      PRINT ''
   END
   -- Sean02 E

END -- procedure