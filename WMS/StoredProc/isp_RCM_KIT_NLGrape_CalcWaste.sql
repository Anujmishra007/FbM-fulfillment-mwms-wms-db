SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Proc: isp_RCM_KIT_NLGrape_CalcWaste                            */
/* Creation Date: 19-MAY-2025                                            */
/* Copyright: MAERSK                                                     */
/* Written by:                                                           */
/*                                                                       */
/* Purpose: FCR-2937 - NL-GRAPE - Waste Weight and Percentage Calculation*/
/*                                                                       */
/* Called By: Custom RCM Menu                                            */
/*                                                                       */
/* PVCS Version: 1.0                                                     */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author   Ver   Purposes                                   */
/* 19-MAY-2025 Michael  1.0   DEVOPS combine script                      */
/* 12-NOV-2025 Michael  1.1   FCR-8632 Allow Multi To-Detail Sku (ML01)  */
/*************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_RCM_KIT_NLGrape_CalcWaste]
      @c_Kitkey      NVARCHAR(MAX)
   ,  @b_success     INT OUTPUT
   ,  @n_err         INT OUTPUT
   ,  @c_errmsg      NVARCHAR(225) OUTPUT
   ,  @c_code        NVARCHAR(30)=''
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt              INT
         , @n_Continue               INT
         , @c_PkgMaterialClass       NVARCHAR(10) = 'PKGM'
         , @c_Sku                    NVARCHAR(20) = ''
         , @n_TotalNetWgt_From       FLOAT        = 0
         , @n_TotalNetWgt_To         FLOAT        = 0
         , @n_WastePercentage        FLOAT        = 0

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1
   SET @n_err      = 0
   SET @c_errmsg   = ''


   IF @n_continue IN(1,2)
   BEGIN
      SELECT @c_Sku    = ''

      SELECT TOP 1 @c_Sku = KD.Sku
      FROM dbo.KIT       KH (NOLOCK)
      JOIN dbo.KITDETAIL KD (NOLOCK) ON KH.Kitkey = KD.Kitkey
      LEFT JOIN dbo.SKU  SKU(NOLOCK) ON KD.Storerkey = SKU.Storerkey AND KD.Sku = SKU.Sku
      WHERE KH.Kitkey = @c_Kitkey
        AND ISNULL(SKU.ItemClass,'') <> @c_PkgMaterialClass
        AND ISNULL(SKU.NetWgt,0) = 0

      IF ISNULL(@c_Sku, '') <> ''
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 63300
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': SKU (' + ISNULL(RTRIM(@c_Sku),'') + ') net weight is 0 (isp_RCM_KIT_NLGrape_CalcWaste)'
      END
   END

   IF @n_continue IN(1,2)
      AND 1=2  --ML01 Skip checking
   BEGIN
      IF (SELECT COUNT(DISTINCT KD.Sku)
          FROM dbo.KIT       KH (NOLOCK)
          JOIN dbo.KITDETAIL KD (NOLOCK) ON KH.Kitkey = KD.Kitkey
          WHERE KH.Kitkey = @c_Kitkey
            AND KD.Type = 'T') > 1
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 63301
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Multi SKUs in To Detail List is not allowed (isp_RCM_KIT_NLGrape_CalcWaste)'
      END
   END

   IF @n_continue IN(1,2)
   BEGIN
      SELECT @n_TotalNetWgt_From = ISNULL(SUM(KD.Qty * ISNULL(SKU.NetWgt, 0)), 0)
        FROM dbo.KIT       KH (NOLOCK)
        JOIN dbo.KITDETAIL KD (NOLOCK) ON KH.Kitkey = KD.Kitkey
        LEFT JOIN dbo.SKU  SKU(NOLOCK) ON KD.Storerkey = SKU.Storerkey AND KD.Sku = SKU.Sku
       WHERE KH.Kitkey = @c_Kitkey
         AND KD.Type = 'F'
         AND ISNULL(SKU.ItemClass,'') <> @c_PkgMaterialClass

      SELECT @n_TotalNetWgt_To = ISNULL(SUM(KD.Qty * ISNULL(SKU.NetWgt, 0)), 0)
        FROM dbo.KIT       KH (NOLOCK)
        JOIN dbo.KITDETAIL KD (NOLOCK) ON KH.Kitkey = KD.Kitkey
        LEFT JOIN dbo.SKU  SKU(NOLOCK) ON KD.Storerkey = SKU.Storerkey AND KD.Sku = SKU.Sku
       WHERE KH.Kitkey = @c_Kitkey
         AND KD.Type = 'T'

      IF @n_TotalNetWgt_From < @n_TotalNetWgt_To
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 63302
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Waste weight is negative, please check the data (isp_RCM_KIT_NLGrape_CalcWaste)'
      END
   END

   IF @n_continue IN(1,2) AND ISNULL(@n_TotalNetWgt_From,0) = 0
   BEGIN
      SELECT @n_continue = 3
      SELECT @n_err = 63305
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Divide by zero error encountered (isp_RCM_KIT_NLGrape_CalcWaste)'
   END

   IF @n_continue IN(1,2)
   BEGIN
      BEGIN TRY
         SET @n_WastePercentage = (@n_TotalNetWgt_From - @n_TotalNetWgt_To) / @n_TotalNetWgt_From
      END TRY
      BEGIN CATCH
         SELECT @n_continue = 3
         SELECT @n_err = 63303
         SELECT @c_errmsg = ERROR_MESSAGE()
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error when calculation. (isp_RCM_KIT_NLGrape_CalcWaste)' + ' ('
                         + 'SQLSvr MESSAGE=' + ISNULL(TRIM(@c_errmsg),'') + ') '
      END CATCH

      IF @n_continue IN(1,2) AND @n_WastePercentage < 0 OR @n_WastePercentage > 1
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 63304
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Waste weight percentage is negative or greater than 100%, please check the data (isp_RCM_KIT_NLGrape_CalcWaste)'
      END
   END

   IF @n_continue IN(1,2)
   BEGIN
      UPDATE KH WITH(ROWLOCK)
         SET USRDEF8 = ISNULL(FORMAT(@n_TotalNetWgt_From - @n_TotalNetWgt_To, '0.#####'), '')
           , USRDEF9 = ISNULL(FORMAT(@n_WastePercentage, '0.##%'), '')
        FROM dbo.KIT KH
       WHERE KH.Kitkey = @c_Kitkey
   END


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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_RCM_KIT_NLGrape_CalcWaste'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
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
GRANT EXECUTE ON [dbo].[isp_RCM_KIT_NLGrape_CalcWaste] TO [nSQL]
GO