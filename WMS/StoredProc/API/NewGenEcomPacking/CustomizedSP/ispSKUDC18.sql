/************************************************************************/
/* Stored Procedure: ispSKUDC18                                         */
/* Creation Date: 04/03/2026                                            */
/* Copyright: Maersk                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: FCR-10893 MODT - SCE Ecom Packing SKU Decode CR (RFID/EPC)  */
/*                                                                      */
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
/* Date         Author   Ver   Purposes                                 */
/* 04-Mar-2026  Sean     1.0   FCR-10893 - Initial (MODT RFID/EPC flow) */
/* 17-Mar-2026  Sean01   1.1   FCR-10893 - Configurable UPC+EPC         */
/*                             separator via StorerConfig.Option1       */
/* 19-Mar-2026  Sean02   1.2   FCR-10893 - Validate EPC length is 24    */
/************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[ispSKUDC18]
     @c_Storerkey        NVARCHAR(15)
   , @c_Sku              NVARCHAR(500)
   , @c_NewSku           NVARCHAR(60)      OUTPUT
   , @b_Success          INT          = 1  OUTPUT
   , @n_Err              INT          = 0  OUTPUT
   , @c_ErrMsg           NVARCHAR(250)= '' OUTPUT
   , @c_Pickslipno       NVARCHAR(10) = ''
   , @n_CartonNo         INT = 0
   , @c_UCCNo            NVARCHAR(20) = ''
AS
BEGIN
    SET NOCOUNT ON;
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE 
        @c_UPC       NVARCHAR(30),
        @c_EPC       NVARCHAR(60),
        @c_BUSR5     NVARCHAR(30),
        @c_Separator NVARCHAR(5),   -- UPC+EPC separator; read from StorerConfig.Option1 (required)
        @n_Pos       INT,
        @n_Continue  INT = 1,
        @n_StartTcnt INT = @@TRANCOUNT;

    SELECT @b_success = 1, @n_err = 0, @c_errmsg = ''

    SET @c_Sku  = ISNULL(RTRIM(@c_Sku), '')
    SET @c_NewSku = ''

    /*
    -- EPC barcode format (separator-delimited):
    --   M33110801B26160+10233110801B26160000594F   (example with '+' separator)
    --   Left  of separator => UPC
    --   Right of separator => EPC
    --
    -- Plain barcode (no separator):
    --   Treated as UPC only (standard Ecom packing flow, no EPC)
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
        SET @n_Err = 90020;
        SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': UPC+EPC separator not configured in StorerConfig.Option1 (ispSKUDC18)';
        GOTO QUIT_SP;
    END
    -- Sean01 E

     -- Check if barcode contains the separator (EPC combined barcode)
    SET @n_Pos = CHARINDEX(@c_Separator, @c_Sku);

    IF @n_Pos > 0
    BEGIN
         -- Split UPC and EPC on the configured separator
        SET @c_UPC = LEFT(@c_Sku, @n_Pos - 1);
        SET @c_EPC = SUBSTRING(@c_Sku, @n_Pos + LEN(@c_Separator), LEN(@c_Sku));

        -- Validate UPC and EPC parts are not empty
        IF ISNULL(RTRIM(@c_UPC), '') = ''
        BEGIN
            SET @n_Continue = 3;
            SET @n_Err = 90021;
            SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': UPC part is empty in EPC barcode (ispSKUDC18)';
            GOTO QUIT_SP;
        END

        IF ISNULL(RTRIM(@c_EPC), '') = ''
        BEGIN
            SET @n_Continue = 3;
            SET @n_Err = 90022;
            SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': EPC part is empty in EPC barcode (ispSKUDC18)';
            GOTO QUIT_SP;
        END

        -- Sean02 B
        -- Validate EPC length is exactly 24 characters
        IF LEN(@c_EPC) <> 24
        BEGIN
            SET @n_Continue = 3;
            SET @n_Err = 90029;
            SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': The EPC format is not valid (ispSKUDC18)';
            GOTO QUIT_SP;
        END
        -- Sean02 E

        -- Look up SKU from UPC table
        SELECT
            @c_NewSku = SKU
        FROM dbo.UPC WITH (NOLOCK)
        WHERE StorerKey = @c_StorerKey
          AND UPC = @c_UPC;

        IF @@ROWCOUNT <> 1
        BEGIN
            SET @c_NewSku = '';
            SET @n_Continue = 3;
            SET @n_Err = 90023;
            SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Cannot find SKU by UPC in EPC barcode (ispSKUDC18)';
            GOTO QUIT_SP;
        END

        -- Get BUSR5 from SKU table
        SELECT @c_BUSR5 = ISNULL(BUSR5, '')
        FROM dbo.SKU WITH (NOLOCK)
        WHERE StorerKey = @c_Storerkey
          AND SKU = @c_NewSku;

        IF @@ROWCOUNT = 0
        BEGIN
            SET @n_Continue = 3;
            SET @n_Err = 90024;
            SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Cannot find SKU record (ispSKUDC18)';
            GOTO QUIT_SP;
        END

        -- SKU does not require EPC but operator scanned EPC barcode
        IF @c_BUSR5 <> 'Y'
        BEGIN
            SET @n_Continue = 3;
            SET @n_Err = 90025;
            SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': SKU does not require EPC, must scan UPC only (ispSKUDC18)';
            GOTO QUIT_SP;
        END

    END
    ELSE
    BEGIN
        -- No '+': treat barcode as plain SKU (standard Ecom packing flow)
        SET @c_UPC = LEFT(@c_Sku, 30);

        -- Look up SKU from UPC table first (barcode may be a UPC)
        SELECT
            @c_NewSku = SKU
        FROM dbo.UPC WITH (NOLOCK)
        WHERE StorerKey = @c_StorerKey
          AND UPC = @c_UPC;

        IF @@ROWCOUNT = 0
        BEGIN
            SET @c_NewSku = '';
            SET @n_Continue = 3;
            SET @n_Err = 90026;
            SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Cannot find SKU by UPC (ispSKUDC18)';
            GOTO QUIT_SP;
        END

        -- Get BUSR5 from SKU table
        SELECT @c_BUSR5 = ISNULL(BUSR5, '')
        FROM dbo.SKU WITH (NOLOCK)
        WHERE StorerKey = @c_Storerkey
          AND SKU = @c_NewSku;

        IF @@ROWCOUNT = 0
        BEGIN
            SET @n_Continue = 3;
            SET @n_Err = 90027;
            SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Cannot find SKU record (ispSKUDC18)';
            GOTO QUIT_SP;
        END

        -- SKU requires EPC but operator scanned plain barcode without EPC
        IF @c_BUSR5 = 'Y'
        BEGIN
            SET @n_Continue = 3;
            SET @n_Err = 90028;
            SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Must scan EPC barcode (UPC+EPC format) (ispSKUDC18)';
            GOTO QUIT_SP;
        END
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
        EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'ispSKUDC18'
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