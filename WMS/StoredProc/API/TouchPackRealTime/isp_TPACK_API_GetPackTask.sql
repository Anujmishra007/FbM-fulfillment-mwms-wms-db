SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_API_GetPackTask                                    */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get all the pack task info from pickdetail & packinfo        */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-01   1.0  GCH225     Created                                          */
/* 2025-11-17   1.1  JWF011     UWP-43858: VAS Tote PreCartonize check rule      */
/* 2026-02-05   2.0  GCH225     UWP-48237: Handle PenAudit status                */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_API_GetPackTask] (
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

   DECLARE @n_Continue           INT            = 1  
         , @n_StartCnt           INT            = @@TRANCOUNT  
         , @b_sp_Success         INT  
         , @n_sp_err             INT  
         , @c_sp_errmsg          NVARCHAR(250)  = ''
         , @DBUserName           NVARCHAR(100)
         , @b_sp_ExecuteAs       BIT

   DECLARE @cLangCode            NVARCHAR(3)
         , @cType                NVARCHAR(30)
         , @bIsDiscrete          BIT
         , @bIsCustom            BIT
         , @cPickSlipNo          NVARCHAR(10)
         , @cOrderKey            NVARCHAR(10)
         , @cLoadKey             NVARCHAR(10)
         , @cDropID              NVARCHAR(20)
         , @cStorerKey           NVARCHAR(15)
         , @cFacility            NVARCHAR(5)
         , @cScanNo              NVARCHAR(20)
         , @cExtPackInfoJson     NVARCHAR(MAX)
         , @cPackTaskConfigJson  NVARCHAR(MAX)

   DECLARE @cCartonType          NVARCHAR(20)   = ''
         , @fWeight              FLOAT          = 0
         , @fCube                FLOAT          = 0

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = ''  
   SET @c_ResponseString   = '' 
   SET @bIsDiscrete        = 1
   SET @bIsCustom          = 0
   SET @cDropID            = ''
   SET @cOrderKey          = ''
   SET @cLoadKey           = ''

   EXEC [API].[isp_ECOMP_ValidateAndSetUser]
        @c_UserID      = @c_UserID
      , @c_DBUserName  = @DBUserName OUTPUT
      , @b_ExecuteAs   = @b_sp_ExecuteAs OUTPUT
      , @b_Success     = @b_sp_Success OUTPUT
      , @n_ErrNo       = @n_sp_err OUTPUT
      , @c_ErrMsg      = @c_sp_errmsg OUTPUT

   IF @b_sp_Success = 0
   BEGIN    
      SET @n_Continue = 3
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

   --Decode Json Format
   SELECT  @cType       = cType
         , @cLangCode   = cLangCode
         , @cStorerKey  = cStorerKey
         , @cFacility   = cFacility
         , @cScanNo     = cScanNo
   FROM OPENJSON(@c_RequestString)
   WITH (
         cType        NVARCHAR(30)
       , cLangCode    NVARCHAR(3)
	    , cStorerKey   NVARCHAR(15)
	    , cFacility    NVARCHAR(5)
       , cScanNo      NVARCHAR(20)
   )

   --Data Validate  - Check ScanNo blank
   IF @cScanNo = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 10201
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'ScanNo cannot be empty.'
      GOTO EXIT_SP
   END

   IF @cStorerKey = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 10202
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Storerkey cannot be empty.'
      GOTO EXIT_SP
   END

   IF @cFacility = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 10203
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Facility cannot be empty.'
      GOTO EXIT_SP
   END

   --Verify cType whether is order,pickslip or toteid and determine whether is discrete or consolidate or custom
   IF EXISTS ( SELECT 1 
               FROM PICKHEADER (NOLOCK) 
               WHERE OrderKey = @cScanNo
   ) OR EXISTS(SELECT 1 
               FROM PICKDETAIL (NOLOCK)
               WHERE OrderKey = @cScanNo
   )
   BEGIN
      SET @cType = 'order'

      SELECT TOP 1
              @cPickSlipNo = PickHeaderKey
            , @cOrderKey   = OrderKey
            , @cLoadKey    = ExternOrderKey
      FROM PICKHEADER (NOLOCK)
      WHERE OrderKey = @cScanNo 
      
      IF @@ROWCOUNT = 0
      BEGIN
         SELECT TOP 1 
                 @cPickSlipNo = PH.PickHeaderKey
               , @cOrderKey   = @cScanNo
               , @cLoadKey    = PH.ExternOrderKey
         FROM PICKHEADER PH (NOLOCK)
         WHERE EXISTS ( SELECT 1 
                        FROM LOADPLANDETAIL LPD (NOLOCK)
                        WHERE LPD.OrderKey = @cScanNo 
                        AND LPD.LoadKey = PH.ExternOrderKey
                      )
         IF @@ROWCOUNT <> 0
         BEGIN
            SET @bIsCustom = 1
            IF (SELECT TOP 1 StorerKey FROM ORDERS (NOLOCK) WHERE LoadKey =  @cLoadKey ) <> @cStorerKey
            BEGIN
               SET @n_Continue = 3
               SET @n_ErrNo = 10219
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Scanned Consol PickSlip Order is from a different storer. Please use another valid Order No.
               GOTO EXIT_SP
            END

            IF (SELECT TOP 1 Facility FROM ORDERS (NOLOCK) WHERE LoadKey = @cLoadKey ) <> @cFacility
            BEGIN
               SET @n_Continue = 3
               SET @n_ErrNo = 10220
               SET @c_ErrMsg =API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Scanned Consol PickSlip Order is from a different facility. Please use another valid Order No.
               GOTO EXIT_SP
            END
         END
      END
      ELSE
      BEGIN
         IF (SELECT TOP 1 StorerKey FROM ORDERS (NOLOCK) WHERE OrderKey =  @cOrderKey ) <> @cStorerKey
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 10204
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Scanned Order No is from a different storer. Please use another valid Order No.
            GOTO EXIT_SP
         END

         IF (SELECT TOP 1 Facility FROM ORDERS (NOLOCK) WHERE OrderKey =  @cOrderKey ) <> @cFacility
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 10205
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Scanned Order No is from a different facility. Please use another valid Order No.
            GOTO EXIT_SP
         END
      END  
      IF NOT EXISTS (SELECT 1 
                     FROM PICKDETAIL PD (NOLOCK)
                     LEFT JOIN ORDERS O (NOLOCK)
                        ON PD.OrderKey = O.OrderKey
                     WHERE PD.OrderKey = @cOrderKey
                     AND PD.[Status] <= '9'
                     AND O.[Status] <= '9'
      )
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 10206
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No PickDetail found with the scanned Order No.'
         GOTO EXIT_SP
      END 
   END
   ELSE
   BEGIN
      IF @cType = 'pickslip'
      BEGIN
         IF NOT EXISTS (SELECT 1 
                        FROM PICKHEADER (NOLOCK)
                        WHERE PickHeaderKey = @cScanNo
         )
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 10207
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No PickHeader found with the scanned Pickslip No.'
            GOTO EXIT_SP
         END

         SELECT TOP 1
                 @cPickSlipNo = PickHeaderKey
               , @cOrderKey   = OrderKey
               , @cLoadKey    = ExternOrderKey
         FROM PICKHEADER (NOLOCK)
         WHERE PickHeaderKey = @cScanNo 

         IF @cOrderKey = '' 
         BEGIN
            SET @bIsDiscrete = 0
            IF  @cLoadKey = ''
            BEGIN
               SET @bIsCustom = 1

               IF NOT EXISTS (SELECT 1 
                              FROM PICKDETAIL (NOLOCK)
                              WHERE PickSlipNo = @cPickSlipNo
                              AND [Status] <= '9'
               )
               BEGIN
                  SET @n_Continue = 3
                  SET @n_ErrNo = 10208
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No PickDetail found with scanned custom Pickslip No.'
                  GOTO EXIT_SP
               END
            END
            ELSE
            BEGIN
               IF (SELECT TOP 1 StorerKey FROM ORDERS (NOLOCK) WHERE LoadKey =  @cLoadKey ) <> @cStorerKey
               BEGIN
                  SET @n_Continue = 3
                  SET @n_ErrNo = 10209
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Scanned Consol Pickslip No is from a different storer. Please use another valid Consol Pickslip No.'
                  GOTO EXIT_SP
               END

               IF (SELECT TOP 1 Facility FROM ORDERS (NOLOCK) WHERE LoadKey = @cLoadKey ) <> @cFacility
               BEGIN
                  SET @n_Continue = 3
                  SET @n_ErrNo = 10210
                  SET @c_ErrMsg =API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Scanned Consol Pickslip No is from a different facility. Please use another valid Consol Pickslip No.'
                  GOTO EXIT_SP
               END

               IF NOT EXISTS (SELECT 1 
                              FROM PICKDETAIL PD (NOLOCK)
                              WHERE EXISTS ( SELECT 1 
                                             FROM  LOADPLANDETAIL LPD (NOLOCK)
                                             WHERE LPD.OrderKey = PD.OrderKey
                                             AND LPD.LoadKey = @cLoadKey
                              )
                              AND PD.[Status] <= '9'
               )
               BEGIN
                  SET @n_Continue = 3
                  SET @n_ErrNo = 10211
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No PickDetail found with the scanned Consol Pickslip No.'
                  GOTO EXIT_SP
               END  
            END
         END
         ELSE
         BEGIN
            IF (SELECT TOP 1 StorerKey FROM ORDERS (NOLOCK) WHERE OrderKey =  @cOrderKey ) <> @cStorerKey
            BEGIN
               SET @n_Continue = 3
               SET @n_ErrNo = 10212
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Scanned Pickslip No is from a different storer. Please use another valid Pickslip No.'
               GOTO EXIT_SP
            END

            IF (SELECT TOP 1 Facility FROM ORDERS (NOLOCK) WHERE OrderKey =  @cOrderKey ) <> @cFacility
            BEGIN
               SET @n_Continue = 3
               SET @n_ErrNo = 10213
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Scanned Pickslip No is from a different facility. Please use another valid Pickslip No.'
               GOTO EXIT_SP
            END

            IF NOT EXISTS (SELECT 1 
                     FROM PICKDETAIL PD (NOLOCK)
                     LEFT JOIN ORDERS O (NOLOCK)
                        ON PD.OrderKey = O.OrderKey
                     WHERE PD.OrderKey = @cOrderKey
                     AND PD.[Status] <= '9'
                     AND O.[Status] <= '9'
            )
            BEGIN
               SET @n_Continue = 3
               SET @n_ErrNo = 10214
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No PickDetail found with the scanned Pickslip No.'
               GOTO EXIT_SP
            END 
         END
      END
      ELSE IF @cType = 'toteid'
      BEGIN
         IF NOT EXISTS (SELECT 1 
                        FROM PICKDETAIL (NOLOCK)
                        WHERE DropID = @cScanNo
                        AND [Status] <= '9'
         )
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 10215
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No PickDetail found with the scanned ToteID.'
            GOTO EXIT_SP
         END

         SELECT TOP 1
                 @cOrderKey   = OrderKey
                ,@cDropID     = DropID
         FROM PICKDETAIL (NOLOCK)
         WHERE DropID = @cScanNo
         AND [Status] <= '9'

         IF NOT EXISTS( SELECT 1
                        FROM PICKHEADER (NOLOCK)
                        WHERE OrderKey = @cOrderKey 
         )
         BEGIN
            IF NOT EXISTS( SELECT 1
                           FROM PICKHEADER PH (NOLOCK)
                           WHERE EXISTS(SELECT 1 
                                        FROM LOADPLANDETAIL LPD (NOLOCK)
                                        WHERE LPD.LoadKey = PH.ExternOrderKey
                                        AND LPD.OrderKey = @cOrderKey
                           )
            
            )
            BEGIN
               SET @n_Continue = 3
               SET @n_ErrNo = 10216
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No PickHeader found with the scanned ToteID.'
               GOTO EXIT_SP
            END
            ELSE
            BEGIN
               SET @bIsCustom = 1
               SELECT TOP 1
                       @cPickSlipNo = PH.PickHeaderKey
                     , @cLoadKey    = PH.ExternOrderKey
               FROM PICKHEADER PH (NOLOCK)
               WHERE EXISTS(SELECT 1 
                            FROM LOADPLANDETAIL LPD (NOLOCK)
                            WHERE LPD.LoadKey = PH.ExternOrderKey
                            AND LPD.OrderKey = @cOrderKey
               )
            END
         END
         ELSE
         BEGIN
            SELECT TOP 1
                    @cPickSlipNo = PickHeaderKey
                  , @cLoadKey    = ExternOrderKey
            FROM PICKHEADER (NOLOCK)
            WHERE OrderKey = @cOrderKey     
         END

         IF (SELECT TOP 1 StorerKey FROM ORDERS (NOLOCK) WHERE OrderKey = @cOrderKey ) <> @cStorerKey
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 10217
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Scanned ToteID is from a different storer. Please use another valid ToteID.'
            GOTO EXIT_SP
         END

         IF (SELECT TOP 1 Facility FROM ORDERS (NOLOCK) WHERE OrderKey = @cOrderKey ) <> @cFacility
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 10218
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Scanned ToteID is from a different facility. Please use another valid ToteID.'
            GOTO EXIT_SP
         END

         SELECT @cCartonType     = CartonType
              , @fWeight         = [Weight]
              , @fCube           = [Cube]
         FROM PACKINFO (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonStatus IN ('', 'PenAudit')

         -- VAS PreCartonize Check
         IF @@ROWCOUNT = 1
         AND (SELECT ISNULL(SUM(ExpQty), 0)
         FROM PACKDETAIL (NOLOCK) 
         WHERE DropID = @cDropID) > 0

         BEGIN
            EXEC [API].[isp_TPACK_UpdatePackInfo]
                 @cType                = @cType            
               , @bIsDiscrete          = @bIsDiscrete      
               , @bIsCustom            = @bIsCustom        
               , @cPickSlipNo          = @cPickSlipNo       
               , @cOrderKey            = @cOrderKey         
               , @cLoadKey             = @cLoadKey          
               , @cDropID              = @cDropID           
               , @cStorerKey           = @cStorerKey        
               , @cFacility            = @cFacility         
               , @nCartonNo            = 1
               , @cCartonStatus        = 'INPROGRESS'
               , @cCartonType          = @cCartonType
               , @fWeight              = @fWeight
               , @fCube                = @fCube
               , @cLabelNo             = ''
               , @c_UserID             = @c_UserID
               , @cLangCode            = @cLangCode
               , @b_Success            = @b_Success         OUTPUT
               , @n_ErrNo              = @n_ErrNo           OUTPUT
               , @c_ErrMsg             = @c_ErrMsg          OUTPUT
            
            IF @b_Success = 0
            BEGIN
               SET @n_Continue = 3
               GOTO EXIT_SP
            END
         END
         -- VAS PreCartonize Check (END)
      END
   END

   IF @bIsDiscrete = 1
   BEGIN
      --Check the PickingInfo for only discrete pickslip where 1 pickslip = 1 order
      EXEC [API].[isp_TPACK_CheckPickingInfo]
           @cType              = @cType            
         , @bIsDiscrete        = @bIsDiscrete      
         , @bIsCustom          = @bIsCustom        
         , @cPickSlipNo        = @cPickSlipNo       
         , @cLoadKey           = @cLoadKey          
         , @cOrderKey          = @cOrderKey         
         , @cDropID            = @cDropID  
         , @cStorerKey         = @cStorerKey
         , @cFacility          = @cFacility
         , @c_UserID           = @c_UserID
         , @cLangCode          = @cLangCode
         , @b_Success          = @b_Success  OUTPUT
         , @n_ErrNo            = @n_ErrNo    OUTPUT
         , @c_ErrMsg           = @c_ErrMsg   OUTPUT

      IF @b_Success = 0
      BEGIN
         SET @n_Continue = 3   
         GOTO EXIT_SP
      END
   END
   --Get the Extended Dynamic PackInfo
   EXEC [API].[isp_TPACK_GetExtendedPackInfo]
        @cType             = @cType            
      , @bIsDiscrete       = @bIsDiscrete      
      , @bIsCustom         = @bIsCustom        
      , @cPickSlipNo       = @cPickSlipNo       
      , @cOrderKey         = @cOrderKey         
      , @cLoadKey          = @cLoadKey          
      , @cDropID           = @cDropID           
      , @cStorerKey        = @cStorerKey        
      , @cFacility         = @cFacility    
      , @cLangCode         = @cLangCode
      , @cExtPackInfoJson  = @cExtPackInfoJson  OUTPUT
      , @b_Success         = @b_Success         OUTPUT
      , @n_ErrNo           = @n_ErrNo           OUTPUT
      , @c_ErrMsg          = @c_ErrMsg          OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_Continue = 3   
      GOTO EXIT_SP
   END

   --Check and Get all the storerconfig
    EXEC [API].[isp_TPACK_GetPackTaskConfig]
        @cType                = @cType            
      , @bIsDiscrete          = @bIsDiscrete      
      , @bIsCustom            = @bIsCustom        
      , @cPickSlipNo          = @cPickSlipNo       
      , @cOrderKey            = @cOrderKey         
      , @cLoadKey             = @cLoadKey          
      , @cDropID              = @cDropID           
      , @cStorerKey           = @cStorerKey        
      , @cFacility            = @cFacility  
      , @c_UserID             = @c_UserID
      , @cPackTaskConfigJson  = @cPackTaskConfigJson  OUTPUT
      , @b_Success            = @b_Success            OUTPUT
      , @n_ErrNo              = @n_ErrNo              OUTPUT
      , @c_ErrMsg             = @c_ErrMsg             OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_Continue = 3   
      GOTO EXIT_SP
   END

   SET @c_ResponseString = ISNULL ((SELECT  @cType                AS cType
                                          , @bIsDiscrete          AS bIsDiscrete
                                          , @bIsCustom            AS bIsCustom
                                          , @cPickSlipNo          AS cPickSlipNo
                                          , @cOrderKey            AS cOrderKey
                                          , @cLoadKey             AS cLoadKey
                                          , @cDropID              AS cDropID
                                          , JSON_QUERY(CASE WHEN ISJSON(@cExtPackInfoJson) = 1 
                                                               THEN @cExtPackInfoJson
                                                            ELSE '[]'
                                                            END) AS cExtPackInfoJson
                                          , JSON_QUERY(CASE WHEN ISJSON(@cPackTaskConfigJson) = 1 
                                                               THEN @cPackTaskConfigJson
                                                            ELSE '[]'
                                                            END) AS cPackTaskConfigJson
                                          FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                           ),'')

EXIT_SP:
   IF @n_Continue = 3  -- Error Occured - Process And Return      
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