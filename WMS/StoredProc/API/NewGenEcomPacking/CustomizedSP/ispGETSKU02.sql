SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Stored Procedure: ispGETSKU02                                        */
/* Creation Date: 05-MAR-2026                                           */
/* Copyright: Maersk                                                    */
/* Written by: Sean                                                     */
/*                                                                      */
/* Purpose: CONVERSE Ecom Packing - RetailSku lookup + Gift/Selling     */
/*          Goods 69 prefix validation                                  */
/*          - Resolves scanned value to SKU via RetailSku field         */
/*            (Order or TaskBatch context)                              */
/*          - Gift Goods  (CodeLkup CONVGIFT): skip 69 prefix check     */
/*          - Selling Goods: enforce UPC must start with '69'           */
/*                                                                      */
/* Called By: isp_GetPackSku_Wrapper (StorerConfig: GetPackSku_SP)      */
/*                                                                      */
/* GitLab Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 05-MAR-2026 Sean     1.0   Initial - RetailSku Gift/Selling validation */
/************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[ispGETSKU02]
     @c_TaskBatchNo  NVARCHAR(10)  = ''
   , @c_PickslipNo   NVARCHAR(10)  = ''
   , @c_OrderKey     NVARCHAR(10)  = ''
   , @c_Storerkey    NVARCHAR(15)
   , @c_Sku          NVARCHAR(60)
   , @c_NewSku       NVARCHAR(60)  OUTPUT
   , @b_Success      INT           OUTPUT
   , @n_Err          INT           OUTPUT
   , @c_ErrMsg       NVARCHAR(250) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue     INT          = 1
         , @n_StartTcnt    INT          = @@TRANCOUNT
         , @c_OriginalUPC  NVARCHAR(60) = ''   -- Save original scanned value for 69 validation
         , @c_TempSku      NVARCHAR(60) = ''   -- Resolved SKU from RetailSku lookup
         , @n_NoofSku      INT          = 0
         , @b_IsGiftGoods  BIT          = 0

   SELECT @b_Success = 1, @n_Err = 0, @c_ErrMsg = ''

   -- Save original input before any transformation
   SET @c_OriginalUPC = LTRIM(RTRIM(@c_Sku))

   -- ========================================================================
   -- STEP 1: Resolve scanned value -> SKU via RetailSku field
   --         Order context or TaskBatch context
   -- ========================================================================

   IF ISNULL(@c_OrderKey, '') <> ''
   BEGIN
      SELECT @c_TempSku = MIN(s.Sku),
             @n_NoofSku = COUNT(DISTINCT s.Sku)
      FROM ORDERDETAIL OD WITH (NOLOCK)
      JOIN SKU s WITH (NOLOCK) ON s.StorerKey = OD.StorerKey AND s.Sku = OD.SKU
      WHERE OD.OrderKey    = @c_OrderKey
        AND s.StorerKey    = @c_Storerkey
        AND s.RetailSku    = @c_OriginalUPC
      GROUP BY s.RetailSku
   END
   ELSE IF ISNULL(@c_TaskBatchNo, '') <> ''
   BEGIN
      SELECT @c_TempSku = MIN(s.Sku),
             @n_NoofSku = COUNT(DISTINCT s.Sku)
      FROM PACKTASK PT WITH (NOLOCK)
      JOIN PACKTASKDETAIL PTD WITH (NOLOCK) ON PT.TaskBatchNo = PTD.TaskBatchNo
                                           AND PT.OrderKey    = PTD.OrderKey
      JOIN SKU s WITH (NOLOCK) ON s.StorerKey = PTD.StorerKey AND s.Sku = PTD.SKU
      WHERE PT.TaskBatchNo   = @c_TaskBatchNo
        AND s.RetailSku      = @c_OriginalUPC
      GROUP BY s.RetailSku
   END

   -- If no SKU resolved, popup error
   IF ISNULL(@c_TempSku, '') = ''
   BEGIN
      SELECT @n_continue = 3
      SELECT @n_err = 87010
      SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Cannot find SKU by UPC: ' + RTRIM(@c_OriginalUPC) + '. (ispGETSKU02)'
      GOTO QUIT_SP
   END

   -- Duplicate RetailSku mapping guard
   IF ISNULL(@n_NoofSku, 0) >= 2
   BEGIN
      SET @n_Continue = 3
      SET @n_Err = 87011
      SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                    + ': Found more than one SKU for RetailSku ' + RTRIM(ISNULL(@c_OriginalUPC, ''))
                    + ' (ispGETSKU02)'
      GOTO QUIT_SP
   END

   -- ========================================================================
   -- STEP 2: Check if resolved SKU is Gift Goods (CodeLkup CONVGIFT)
   -- ========================================================================

   IF EXISTS (
      SELECT 1
      FROM CodeLkup WITH (NOLOCK)
      WHERE StorerKey = @c_Storerkey
        AND ListName  = 'CONVGIFT'
        AND Code      = @c_TempSku
   )
   BEGIN
      SET @b_IsGiftGoods = 1
   END

   -- ========================================================================
   -- STEP 3: 69 prefix validation - Selling Goods only
   --         Gift Goods bypass this check
   -- ========================================================================

   IF @b_IsGiftGoods = 0
   BEGIN
      IF LEFT(@c_OriginalUPC, 2) <> '69'
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 87012
         SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                       + ': UPC not start with 69. (ispGETSKU02)'
         GOTO QUIT_SP
      END
   END

   -- ========================================================================
   -- STEP 4: Return resolved SKU
   -- ========================================================================

   SET @c_NewSku = @c_TempSku

QUIT_SP:

   IF @n_Continue = 3
   BEGIN
      SET @b_Success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTcnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE dbo.nsp_LogError @n_Err, @c_ErrMsg, 'ispGETSKU02'
      RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR
      RETURN
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END -- End Procedure
GO
GRANT EXECUTE ON [dbo].[ispGETSKU02] TO NSQL
GO