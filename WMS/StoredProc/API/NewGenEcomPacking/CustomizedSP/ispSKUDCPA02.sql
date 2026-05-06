/************************************************************************/
/* Stored Procedure: ispSKUDCPA02                                       */
/* Creation Date: 04/03/2026                                            */
/* Copyright: Maersk                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: FCR-10893 MODT - SCE Ecom Packing SKU Decode PostAction CR  */
/*          (RFID/EPC flow)                                             */
/*                                                                      */
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
/* 04-Mar-2026  Sean    1.0   FCR-10893 - Initial (MODT RFID/EPC flow)  */
/* 17-Mar-2026  Sean01  1.1   FCR-10893 - Configurable UPC+EPC          */
/*                            separator via StorerConfig.Option1        */
/************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[ispSKUDCPA02]
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
        @c_UPC          NVARCHAR(30),
        @c_EPC          NVARCHAR(60),
        @c_PackDtlSKU   NVARCHAR(30),
        @c_PackDtlUPC   NVARCHAR(30),
        @c_BUSR5        NVARCHAR(30),
        @c_Separator    NVARCHAR(5),   -- UPC+EPC separator; read from StorerConfig.Option1 (required)
        @n_LabelLineNo  INT = 0,
        @n_Position     INT,
        @n_Continue     INT = 1,
        @n_StartTcnt    INT = @@TRANCOUNT;

    SELECT @b_success = 1, @n_err = 0, @c_errmsg = ''

    SET @c_Sku = ISNULL(RTRIM(@c_Sku), '')

    /*
    -- EPC barcode format (separator-delimited):
    --   M33110801B26160+10233110801B26160000594F   (example with '+' separator)
    --   Left  of separator => UPC  (e.g. M33110801B26160)
    --   Right of separator => EPC  (e.g. 10233110801B26160000594F)
    --
    -- Plain barcode (no separator):
    --   Treated as UPC only (standard flow, no EPC)
    --
    -- Separator is read from StorerConfig.Option1 for this StorerKey.
    -- Option1 must be configured; an error is raised if it is missing or empty.
    */

    -- Sean01 B
    -- Read configurable separator from StorerConfig.Option1 (mandatory)
    SELECT @c_Separator = NULLIF(RTRIM(Option1), '')
    FROM dbo.StorerConfig WITH (NOLOCK)
    WHERE StorerKey = @c_Storerkey and ConfigKey = 'SKUDecode';
 
    IF @c_Separator IS NULL
    BEGIN
        SET @n_Continue = 3;
        SET @n_Err = 90032;
        SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': UPC+EPC separator not configured in StorerConfig.Option1 (ispSKUDCPA02)';
        GOTO QUIT_SP;
    END
    -- Sean01 E
 
    -- Detect EPC barcode by configured separator
    SET @n_Position = CHARINDEX(@c_Separator, @c_Sku);

    IF @n_Position > 0
    BEGIN
        -- EPC combined barcode: split UPC and EPC on the configured separator
        SET @c_UPC = LEFT(@c_Sku, @n_Position - 1);
        SET @c_EPC = SUBSTRING(@c_Sku, @n_Position + LEN(@c_Separator), LEN(@c_Sku));
    END
    ELSE
    BEGIN
        -- Standard barcode: no EPC
        SET @c_UPC = LEFT(@c_Sku, 30);
        SET @c_EPC = '';
    END

    -- Look up SKU from UPC table
    SELECT
        @c_PackDtlSKU = SKU,
        @c_PackDtlUPC = UPC
    FROM dbo.UPC WITH (NOLOCK)
    WHERE StorerKey = @c_StorerKey
      AND UPC = @c_UPC;

    IF @@ROWCOUNT <> 1
    BEGIN
        SET @c_PackDtlSKU = '';
        SET @c_PackDtlUPC = '';
        SET @n_Continue = 3;
        SET @n_Err = 90030;
        SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Cannot find SKU by UPC (ispSKUDCPA02)';
        GOTO QUIT_SP;
    END

    -- Check EPC is not duplicated for this PickSlipNo
    IF @n_Position > 0
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM PackSerialNo WITH (NOLOCK)
            WHERE PickSlipNo = @c_PickSlipNo
              AND StorerKey  = @c_StorerKey
              AND SerialNo   = @c_EPC
        )
        BEGIN
            SET @n_Continue = 3;
            SET @n_Err = 90031;
            SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': EPC already scanned (ispSKUDCPA02)';
            GOTO QUIT_SP;
        END
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

        INSERT INTO [dbo].[PackDetail] (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, Qty, DropId, UPC)
        VALUES (
            @c_PickSlipNo,
            @n_CartonNo,
            '',
            RIGHT('0000' + CONVERT(NVARCHAR, @n_LabelLineNo), 5),
            @c_StorerKey,
            @c_PackDtlSKU,
            1,
            '',
            @c_PackDtlUPC
        );
    END
    ELSE
    BEGIN
        UPDATE [dbo].[PackDetail] WITH (ROWLOCK)
        SET Qty = (Qty + 1)
        WHERE PickSlipNo = @c_PickSlipNo
          AND StorerKey  = @c_StorerKey
          AND SKU        = @c_PackDtlSKU
          AND CartonNo   = @n_CartonNo;
    END

    -- Insert PackSerialNo only when EPC barcode scanned (BUSR5='Y')
    -- Skip for standard flow (BUSR5='N', no '+' in barcode)
    IF @n_Position > 0
    BEGIN
        INSERT INTO [dbo].[PackSerialNo] (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, SerialNo, QTY, Barcode)
        SELECT TOP 1
            PickSlipNo,
            CartonNo,
            '',
            LabelLine,
            StorerKey,
            SKU,
            @c_EPC,     -- EPC value from barcode
            1,          -- Qty: 1 EPC = 1 piece
            @c_Sku      -- Store original EPC barcode
        FROM [dbo].[PackDetail] WITH (NOLOCK)
        WHERE PickSlipNo = @c_PickSlipNo
          AND CartonNo   = @n_CartonNo
          AND StorerKey  = @c_StorerKey
          AND SKU        = @c_PackDtlSKU;
    END

QUIT_SP:

    IF @n_Continue = 3  -- Error occurred
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
        EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'ispSKUDCPA02'
        RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR
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