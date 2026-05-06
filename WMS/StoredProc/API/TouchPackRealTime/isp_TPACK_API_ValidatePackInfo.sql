SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_API_ValidatePackInfo                               */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : UWP-42803 Validate Tote                                      */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-11-03   1.0  Sean       Real-time UWP-42803                              */
/* 2025-12-17   1.1  Sean01     Calculate total Pack Qty from PACKDETAIL         */
/* 2026-02-05   1.2  Sean02     UWP-42468: ToteID for multi orders               */
/* 2026-03-19   1.3  Sean03     UWP-42468: ToteID for multi orders               */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_API_ValidatePackInfo] (
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

    DECLARE @n_Continue     INT            = 1  
         , @n_StartCnt     INT            = @@TRANCOUNT  
         , @b_sp_Success   INT  
         , @n_sp_err       INT  
         , @c_sp_errmsg    NVARCHAR(250)  = ''
         , @DBUserName     NVARCHAR(100)
         , @b_sp_ExecuteAs BIT
    
    DECLARE @cType                NVARCHAR(30)
        , @cLangCode            NVARCHAR(3)
        , @cStorerKey           NVARCHAR(15)
        , @cFacility            NVARCHAR(5)
        , @bIsDiscrete          BIT
        , @bIsCustom            BIT
        , @cOrderKey            NVARCHAR(10)
        , @cLoadKey             NVARCHAR(10)
        , @cDropID              NVARCHAR(20)
        , @nCartonNo            INT
        , @cPickSlipNo          NVARCHAR(10)
        , @nTtlPickQty          INT
        , @nTtlPackQty          INT
        , @nCntOrder            INT

    -- (0) Set User Session
    EXEC [API].[isp_ECOMP_ValidateAndSetUser]
        @c_UserID      = @c_UserID,
        @c_DBUserName  = @DBUserName OUTPUT,
        @b_ExecuteAs   = @b_sp_ExecuteAs OUTPUT,
        @b_Success     = @b_sp_Success OUTPUT,
        @n_ErrNo       = @n_sp_err OUTPUT,
        @c_ErrMsg      = @c_sp_errmsg OUTPUT;

    IF @b_sp_Success = 0
    BEGIN
       SET @b_Success = 0      
       SET @n_ErrNo = @n_sp_err      
       SET @c_ErrMsg = @c_sp_errmsg     
       GOTO EXIT_SP
    END

    IF @b_sp_ExecuteAs = 1 OR @DBUserName LIKE '%' + @c_UserID + '%'
    BEGIN
       EXECUTE AS LOGIN = @DBUserName
       SET @c_UserID = @DBUserName

       IF OBJECT_ID('dbo.fnc_GetUserName', 'FN') IS NOT NULL
       BEGIN
          IF dbo.fnc_GetUserName() NOT IN ('WMConnect', '')
          BEGIN
             SET @c_UserID = dbo.fnc_GetUserName()
          END
       END
    END

    -- (1) Parse JSON input parameters
    SELECT  
        @cType          = cType,
        @cLangCode      = cLangCode,
        @cStorerKey     = cStorerKey,
        @cFacility      = cFacility,
        @bIsDiscrete    = bIsDiscrete,
        @bIsCustom      = bIsCustom,
        @cPickSlipNo    = cPickSlipNo,
        @cOrderKey      = cOrderKey,
        @cLoadKey       = cLoadKey,
        @cDropID        = cDropID,
        @nCartonNo      = nCartonNo
    FROM OPENJSON(@c_RequestString)
    WITH (
        cDropID              NVARCHAR(20),
        cPickSlipNo          NVARCHAR(10),
        cOrderKey            NVARCHAR(10),
        cLoadKey             NVARCHAR(10),
        cStorerKey           NVARCHAR(15),
        cFacility            NVARCHAR(5),
        cLangCode            NVARCHAR(3),
        nCartonNo            INT,
        cType                NVARCHAR(30),
        bIsDiscrete          BIT,
        bIsCustom            BIT
    )

    -- (2) Validate request payload
    -- Use standard validation stored procedure
    EXEC [API].[isp_TPACK_ValidateReqPayload]
         @cType         = @cType
       , @bIsDiscrete   = @bIsDiscrete
       , @bIsCustom     = @bIsCustom
       , @cPickSlipNo   = @cPickSlipNo
       , @cOrderKey     = @cOrderKey
       , @cLoadKey      = @cLoadKey
       , @cDropID       = @cDropID
       , @cStorerKey    = @cStorerKey
       , @cFacility     = @cFacility
       , @cLangCode     = @cLangCode
       , @b_Success     = @b_sp_Success OUTPUT
       , @n_ErrNo       = @n_sp_err OUTPUT
       , @c_ErrMsg      = @c_sp_errmsg OUTPUT

    IF @b_sp_Success = 0
    BEGIN
        SET @n_Continue = 3;
        SET @n_ErrNo = @n_sp_err;
        SET @c_ErrMsg = @c_sp_errmsg;
        GOTO EXIT_SP;
    END

    IF @cStorerKey IS NULL OR LTRIM(RTRIM(@cStorerKey)) = ''
    BEGIN
        SET @n_Continue = 3;
        SET @n_ErrNo = 13301;
        SET @c_ErrMsg = 'StorerKey cannot be empty';
        GOTO EXIT_SP;
    END

    -- (3) Calculate total Pick Qty    
    DECLARE @PickQtyStatus TABLE(
        TtlPickedQty INT,
        Sku NVARCHAR(20),
        [Status] NVARCHAR(10)
    )

    IF @cType = 'pickslip' OR (@cType = 'order' AND @bIsCustom = 0)
    BEGIN
        IF @bIsDiscrete = 1
        BEGIN
            INSERT INTO @PickQtyStatus (TtlPickedQty, Sku, [Status])
            SELECT SUM(Qty), Sku, [Status] 
            FROM PICKDETAIL (NOLOCK)
            WHERE StorerKey = @cStorerKey
            AND OrderKey = @cOrderKey
            GROUP BY Sku, [Status]
        END
        ELSE
        BEGIN
            IF @bIsCustom = 0
            BEGIN
                -- Normal consolidate mode
                INSERT INTO @PickQtyStatus (TtlPickedQty, Sku, [Status])
                SELECT SUM(Qty), Sku, [Status] 
                FROM PICKDETAIL PD (NOLOCK)
                WHERE PD.StorerKey = @cStorerKey
                AND EXISTS (SELECT 1 
                            FROM LOADPLANDETAIL LPD (NOLOCK)
                            WHERE LPD.OrderKey = PD.OrderKey
                            AND LPD.LoadKey = @cLoadKey
                )
                GROUP BY Sku, [Status]
            END
            ELSE
            BEGIN
                -- Custom consolidate mode
                INSERT INTO @PickQtyStatus (TtlPickedQty, Sku, [Status])
                SELECT SUM(Qty), Sku, [Status] 
                FROM PICKDETAIL PD (NOLOCK)
                WHERE PD.StorerKey = @cStorerKey
                AND PD.PickSlipNo = @cPickSlipNo
                GROUP BY Sku, [Status]
            END
        END
    END
    ELSE IF @cType = 'toteid'
    BEGIN
        INSERT INTO @PickQtyStatus (TtlPickedQty, Sku, [Status])
        SELECT SUM(Qty), Sku, [Status] 
        FROM PICKDETAIL PD (NOLOCK)
        WHERE PD.StorerKey = @cStorerKey
        AND PD.DropID = @cDropID -- Sean03
        AND NOT (
            (SELECT TOP 1 O.DocType FROM ORDERS O (NOLOCK) WHERE O.OrderKey = PD.OrderKey) = 'E'
            AND PD.[Status] = '9'
        )
        GROUP BY Sku, [Status]
    END
    ELSE IF @cType = 'order'
    BEGIN
        INSERT INTO @PickQtyStatus (TtlPickedQty, Sku, [Status])
        SELECT SUM(Qty), Sku, [Status] 
        FROM PICKDETAIL (NOLOCK)
        WHERE StorerKey = @cStorerKey
        AND OrderKey = @cOrderKey
        GROUP BY Sku, [Status]
    END

    -- Apply config-based filtering for Status '4' (Short Picked)
    IF NOT EXISTS (SELECT 1
                   FROM STORERCONFIG (NOLOCK)
                   WHERE StorerKey = @cStorerKey
                   AND ConfigKey = 'TPS-ShowShortPickQty' 
                   AND sValue = '1'
    )
    BEGIN
        DELETE FROM @PickQtyStatus WHERE [Status] = '4'
    END

    -- Calculate total Pick Qty from filtered results
    SELECT @nTtlPickQty = SUM(TtlPickedQty)
    FROM @PickQtyStatus

    -- (4) Calculate total Pack Qty from PACKDETAIL 
    -- Reference: GetPackInfoSummary 
    SELECT @nTtlPackQty = ISNULL(SUM(ISNULL(Qty, 0)), 0)
        FROM PACKDETAIL (NOLOCK)
        WHERE (@cPickSlipNo = '' OR PickSlipNo = @cPickSlipNo)
        AND (@cDropID = '' OR DropID = @cDropID)

    -- (5) Compare results
    IF ISNULL(@nTtlPickQty,0) = ISNULL(@nTtlPackQty,0)
    BEGIN 
        SET @b_Success = 1;
        SET @c_ErrMsg = CONCAT(
            UPPER(@cType), ' [', 
            IIF(@cType='toteid', @cDropID, @cPickSlipNo),
            '] Pick=Pack (', @nTtlPickQty, '). '
        );

        SET @c_ResponseString = (
            SELECT 
                @b_Success AS Success,
                @c_ErrMsg AS Message,
                @cType AS ValidateType,
                @cDropID AS ToteID,
                @cPickSlipNo AS PickSlipNo,
                NULL AS DiffList              
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END
    ELSE
    BEGIN
        SET @b_Success = 0;
        SET @n_ErrNo = 13302;
        SET @c_ErrMsg = CONCAT(
            UPPER(@cType), ' [',
            IIF(@cType='toteid', @cDropID, @cPickSlipNo),
            '] Pick<>Pack. PickQty=', ISNULL(@nTtlPickQty,0), ', PackQty=', ISNULL(@nTtlPackQty,0)
        );

        ;WITH PickData AS (
            SELECT 
                Sku AS SKU,
                SUM(TtlPickedQty) AS PickQty
            FROM @PickQtyStatus
            GROUP BY Sku
        ),
        PackData AS (
            SELECT 
                PD.SKU,
                SUM(ISNULL(PD.Qty, 0)) AS PackQty
            FROM PACKDETAIL PD (NOLOCK)
            WHERE (@cPickSlipNo = '' OR PD.PickSlipNo = @cPickSlipNo)
            AND (@cDropID = '' OR PD.DropID = @cDropID)
            GROUP BY PD.SKU
        ),
        Diff AS (
            SELECT 
                p.SKU,
                p.PickQty,
                ISNULL(pk.PackQty, 0) AS PackQty,
                p.PickQty - ISNULL(pk.PackQty, 0) AS DiffQty
            FROM PickData p
            LEFT JOIN PackData pk ON p.SKU = pk.SKU
            WHERE p.PickQty <> ISNULL(pk.PackQty, 0)
        )
        SELECT 
            @c_ResponseString = (
                SELECT 
                    @b_Success AS Success,
                    @c_ErrMsg AS Message,
                    @cType AS ValidateType,
                    @cDropID AS ToteID,
                    @cPickSlipNo AS PickSlipNo,
                    (
                        SELECT SKU, PickQty, PackQty, DiffQty FROM Diff FOR JSON PATH
                    ) AS DiffList
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            );
    END

EXIT_SP:
   IF @b_sp_ExecuteAs = 1 REVERT
   EXEC [WM].[lsp_ResetUser]

    IF @n_Continue = 3  -- Error Occurred - Process And Return      
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
END
GO