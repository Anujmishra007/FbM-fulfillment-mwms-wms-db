/************************************************************************/
/* Stored Procedure: ispSKUDCPA03                                       */
/* Creation Date: 02/04/2026                                            */
/* Copyright: Maersk                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: FCR-11940 - SCE Ecom Packing SKU Decode PostAction CR       */
/*                                                                      */
/* Called By: isp_ECOMP_SKUDecode_PostAction_Wrapper                    */
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
/* 23-Jun-2026  Sean    1.1   FCR-11940 - Always insert PackUOM3 UPC     */
/************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[ispSKUDCPA03]
   @b_Debug          INT            = 0
,  @c_PickSlipNo     NVARCHAR(10)
,  @n_CartonNo       INT
,  @c_OrderKey       NVARCHAR(10)
,  @c_Storerkey      NVARCHAR(15)
,  @c_Sku            NVARCHAR(500)
,  @b_Success        INT            OUTPUT
,  @n_Err            INT            OUTPUT
,  @c_ErrMsg         NVARCHAR(255)  OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE
        @c_ScanValue    NVARCHAR(30),
        @c_PackDtlSKU   NVARCHAR(30),
        @c_PackDtlUPC   NVARCHAR(30),
        @c_PackKey      NVARCHAR(20),
        @c_PackUOM3     NVARCHAR(10),
        @n_ScanQty      INT,
        @n_LabelLineNo  INT = 0,
        @n_Continue     INT = 1,
        @n_StartTcnt    INT = @@TRANCOUNT;

    SELECT @b_Success = 1, @n_Err = 0, @c_ErrMsg = ''

    SET @c_Sku = ISNULL(RTRIM(@c_Sku), '')

    SET @c_ScanValue = LEFT(@c_Sku, 30)

    -- Use scanned UPC only to resolve SKU, PackKey, and quantity
    -- Guaranteed single row and valid UOM by ispSKUDC19
    SELECT
        @c_PackDtlSKU = U.SKU,
        @c_PackKey    = P.PackKey,
        @c_PackUOM3   = P.PackUOM3,
        @n_ScanQty    = CAST(
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

    -- Always store the base unit UPC (PackUOM3) in PackDetail regardless of which UPC was scanned,
    -- because multiple UPCs (case, inner pack) can map to the same SKU
    IF ISNULL(@c_PackUOM3, '') = ''
    BEGIN
        SET @n_Continue = 3
        SET @n_Err      = 51241
        SET @c_ErrMsg   = CONVERT(CHAR(5), @n_Err) + ': PackUOM3 is not configured for PackKey [' + ISNULL(@c_PackKey, '') + ']. Please set up PackUOM3 in Pack configuration.'
        GOTO QUIT_SP
    END

    SELECT TOP 1
        @c_PackDtlUPC = U.UPC
    FROM dbo.UPC U WITH (NOLOCK)
    INNER JOIN dbo.PACK P WITH (NOLOCK)
        ON P.PackKey = U.PackKey
       AND U.UOM     = P.PackUOM3
    WHERE U.PackKey   = @c_PackKey
      AND U.StorerKey = @c_StorerKey;

    IF ISNULL(@c_PackDtlUPC, '') = ''
    BEGIN
        SET @n_Continue = 3
        SET @n_Err      = 51242
        SET @c_ErrMsg   = CONVERT(CHAR(5), @n_Err) + ': No UPC found for PackUOM3 [' + @c_PackUOM3 + '] PackKey [' + ISNULL(@c_PackKey, '') + ']. Please add a UPC record with UOM = PackUOM3.'
        GOTO QUIT_SP
    END

    -- Guard: Qty must be at least 1
    IF ISNULL(@n_ScanQty, 0) < 1
        SET @n_ScanQty = 1;

    IF @b_Debug = 1
    BEGIN
        PRINT 'ispSKUDCPA03 @c_ScanValue='  + @c_ScanValue
        PRINT 'ispSKUDCPA03 @c_PackDtlSKU=' + @c_PackDtlSKU
        PRINT 'ispSKUDCPA03 @c_PackDtlUPC=' + @c_PackDtlUPC
        PRINT 'ispSKUDCPA03 @n_ScanQty='    + CONVERT(NVARCHAR(10), @n_ScanQty)
    END

    -- Insert or Update PackDetail
    IF NOT EXISTS (
        SELECT 1
        FROM [dbo].[PackDetail] WITH (NOLOCK)
        WHERE PickSlipNo = @c_PickSlipNo
          AND StorerKey  = @c_StorerKey
          AND SKU        = @c_PackDtlSKU
          AND CartonNo   = @n_CartonNo
    )
    BEGIN
        -- Calculate next LabelLine sequence for this carton
        SELECT @n_LabelLineNo = (COUNT(1) + 1)
        FROM [dbo].[PackDetail] WITH (NOLOCK)
        WHERE PickSlipNo = @c_PickSlipNo
          AND StorerKey  = @c_StorerKey
          AND CartonNo   = @n_CartonNo;

        -- First scan: INSERT with Qty = @n_ScanQty
        INSERT INTO [dbo].[PackDetail]
               (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, Qty, DropId, UPC)
        VALUES (
            @c_PickSlipNo,
            @n_CartonNo,
            '',
            RIGHT('0000' + CONVERT(NVARCHAR, @n_LabelLineNo), 5),
            @c_StorerKey,
            @c_PackDtlSKU,
            @n_ScanQty,
            '',
            @c_PackDtlUPC
        );
    END
    ELSE
    BEGIN
        -- Subsequent scan: Qty += @n_ScanQty
        UPDATE [dbo].[PackDetail] WITH (ROWLOCK)
        SET    Qty = (Qty + @n_ScanQty)
        WHERE  PickSlipNo = @c_PickSlipNo
          AND  StorerKey  = @c_StorerKey
          AND  SKU        = @c_PackDtlSKU
          AND  CartonNo   = @n_CartonNo;
    END

    -- No PackSerialNo insert: this flow does not track serial numbers

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
        EXECUTE dbo.nsp_LogError @n_Err, @c_ErrMsg, 'ispSKUDCPA03'
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