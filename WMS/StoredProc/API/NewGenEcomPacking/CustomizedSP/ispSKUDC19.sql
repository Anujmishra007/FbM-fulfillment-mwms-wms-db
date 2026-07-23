/************************************************************************/
/* Stored Procedure: ispSKUDC19                                         */
/* Creation Date: 02/04/2026                                            */
/* Copyright: Maersk                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: FCR-11940 - SCE Ecom Packing SKU Decode CR                  */
/*                                                                      */
/* Called By: isp_SKUDecode_Wrapper                                     */
/*                                                                      */
/* GitLab Version: 1.0                                                  */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 02-Apr-2026  Sean    1.0   FCR-11940 - Initial                        */
/************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[ispSKUDC19]
     @c_Storerkey        NVARCHAR(15)
   , @c_Sku              NVARCHAR(500)
   , @c_NewSku           NVARCHAR(60)       OUTPUT
   , @c_Code01           NVARCHAR(60) = ''  OUTPUT   -- Resolved Qty multiplier
   , @c_Code02           NVARCHAR(60) = ''  OUTPUT
   , @c_Code03           NVARCHAR(60) = ''  OUTPUT
   , @b_Success          INT          = 1   OUTPUT
   , @n_Err              INT          = 0   OUTPUT
   , @c_ErrMsg           NVARCHAR(250)= ''  OUTPUT
   , @c_Pickslipno       NVARCHAR(10) = ''
   , @n_CartonNo         INT          = 0
   , @c_UCCNo            NVARCHAR(20) = ''
AS
BEGIN
    SET NOCOUNT ON;
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE
        @c_ScanValue  NVARCHAR(30),
        @n_UPCCount   INT,
        @n_ScanQty    INT,
        @n_Continue   INT = 1,
        @n_StartTcnt  INT = @@TRANCOUNT;

    SELECT @b_Success = 1, @n_Err = 0, @c_ErrMsg = ''
    SET @c_NewSku = ''
    SET @c_Code01 = ''
    SET @c_Code02 = ''
    SET @c_Code03 = ''

    SET @c_Sku = ISNULL(RTRIM(@c_Sku), '')

    SET @c_ScanValue = LEFT(@c_Sku, 30)

    IF ISNULL(RTRIM(@c_ScanValue), '') = ''
    BEGIN
        SET @n_Continue = 3;
        SET @n_Err      = 90040;
        SET @c_ErrMsg   = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                        + ': Error - SKU not found (ispSKUDC19)';
        GOTO QUIT_SP;
    END

    -- Check UPC match count
    SELECT @n_UPCCount = COUNT(1)
    FROM dbo.UPC WITH (NOLOCK)
    WHERE StorerKey = @c_StorerKey
      AND UPC       = @c_ScanValue;

    IF @n_UPCCount = 0
    BEGIN
        SET @n_Continue = 3;
        SET @n_Err      = 90041;
        SET @c_ErrMsg   = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                        + ': Error - SKU not found (ispSKUDC19)';
        GOTO QUIT_SP;
    END

    IF @n_UPCCount > 1
    BEGIN
        SET @n_Continue = 3;
        SET @n_Err      = 90042;
        SET @c_ErrMsg   = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                        + ': Duplicate SKU (ispSKUDC19)';
        GOTO QUIT_SP;
    END

    -- Exactly one UPC row: resolve SKU and Qty via Pack master UOM mapping
    SELECT
        @c_NewSku  = U.SKU,
        @n_ScanQty = CAST(
                         CASE U.UOM
                             WHEN P.PackUOM1 THEN P.CaseCnt
                             WHEN P.PackUOM2 THEN P.InnerPack
                             WHEN P.PackUOM3 THEN P.QTY
                             ELSE 1   
                         END
                     AS INT)
    FROM dbo.UPC U WITH (NOLOCK)
    INNER JOIN dbo.PACK P WITH (NOLOCK)
        ON P.PackKey = U.PackKey
    WHERE U.StorerKey = @c_StorerKey
      AND U.UPC       = @c_ScanValue;

    IF @@ROWCOUNT = 0 OR @n_ScanQty IS NULL
    BEGIN
        SET @n_Continue = 3;
        SET @n_Err      = 90043;
        SET @c_ErrMsg   = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                        + ': No Pack Master (ispSKUDC19)';
        GOTO QUIT_SP;
    END

    -- Pass resolved Qty to PostAction SP via Code01
    SET @c_Code01 = CONVERT(NVARCHAR(60), @n_ScanQty);

QUIT_SP:

    IF @n_Continue = 3
    BEGIN
        SET @b_Success = 0
        IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
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
        EXECUTE dbo.nsp_LogError @n_Err, @c_ErrMsg, 'ispSKUDC19'
        RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR
        RETURN
    END
    ELSE
    BEGIN
        SET @b_Success = 1
        WHILE @@TRANCOUNT > @n_StartTCnt
        BEGIN
            COMMIT TRAN
        END
        RETURN
    END
END -- End Procedure