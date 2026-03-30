SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_API_GetVasInfo                                     */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get all the VAS info from standard workorder or other tables */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-11-25   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_API_GetVasInfo] (
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

   DECLARE @cLangCode      NVARCHAR(3)
         , @cType          NVARCHAR(30)
         , @bIsDiscrete    BIT
         , @bIsCustom      BIT
         , @cPickSlipNo    NVARCHAR(10)
         , @cOrderKey      NVARCHAR(10)
         , @cLoadKey       NVARCHAR(10)
         , @cDropID        NVARCHAR(20)
         , @cStorerKey     NVARCHAR(15)
         , @cFacility      NVARCHAR(5)
         , @nCartonNo      INT
         , @cSKU           NVARCHAR(20)
         , @cResponseJson  NVARCHAR(MAX)

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
         , @bIsDiscrete = bIsDiscrete
         , @bIsCustom   = bIsCustom
         , @cLangCode   = cLangCode
         , @cPickSlipNo = cPickSlipNo
         , @cOrderKey   = cOrderKey
         , @cLoadKey    = cLoadKey
         , @cDropID     = cDropID
         , @cStorerKey  = cStorerKey
         , @cFacility   = cFacility
         , @nCartonNo   = nCartonNo
         , @cSKU        = cSKU
   FROM OPENJSON(@c_RequestString)
   WITH (
         cType       NVARCHAR(30)
	    , bIsDiscrete BIT
	    , bIsCustom   BIT
       , cPickSlipNo NVARCHAR(10)
	    , cOrderKey   NVARCHAR(10)
       , cLoadKey    NVARCHAR(10)
       , cDropID     NVARCHAR(20)
       , cLangCode   NVARCHAR(3)
       , cStorerKey  NVARCHAR(15)
       , cFacility   NVARCHAR(5)
       , nCartonNo   INT
       , cSKU        NVARCHAR(20)
   )

   IF @cType = 'toteid' 
   BEGIN
      IF @cPickSlipNo = '' 
      AND @cOrderKey = '' 
      AND @cLoadKey = ''
      BEGIN
            IF @nCartonNo <> 0
            BEGIN
               SELECT @cPickSlipNo = PH.PickSlipNo
                  , @cOrderKey = PH.OrderKey
               FROM PACKHEADER PH (NOLOCK)
               WHERE EXISTS ( SELECT 1 
                              FROM PACKDETAIL PD (NOLOCK)
                              WHERE PD.PickSlipNo = PH.PickSlipNo
                              AND PD.DropID = @cDropID
                              AND PD.CartonNo = @nCartonNo
                              AND EXISTS (SELECT 1 
                                          FROM PACKINFO PIF (NOLOCK)
                                          WHERE PIF.PickSlipNo = PH.PickSlipNo
                                          AND PIF.CartonNo = PD.CartonNo
                                          AND PIF.EditWho = @c_UserID
                                          AND PIF.CartonStatus = 'INPROGRESS'
                                          )
                           )
         END
         ELSE
         BEGIN
            SELECT TOP 1 @cPickSlipNo = ISNULL(PH.PickHeaderKey, '')
                        , @cOrderKey = ISNULL(PH.OrderKey, '')
            FROM PICKHEADER PH (NOLOCK)
            WHERE EXISTS ( SELECT 1 
                           FROM PICKDETAIL PD (NOLOCK)
                           WHERE PD.OrderKey = PH.OrderKey
                           AND PD.DropID = @cDropID
                           AND PD.SKU = @cSKU
                           AND NOT (
                              (SELECT TOP 1 O.DocType FROM ORDERS O (NOLOCK) WHERE O.OrderKey = PD.OrderKey) = 'E'
                              AND PD.[Status] = '9'
                           )
                           AND NOT EXISTS (SELECT 1
                                       FROM PACKHEADER PH (NOLOCK)
                                       WHERE PH.OrderKey = PD.OrderKey
                                       AND PH.Status = '9'
                                    )
                        )
            ORDER BY PH.OrderKey ASC
         END
      END
   END
   
   EXEC [API].[isp_TPACK_GetVasInfo_Wrapper]
            @cType         = @cType            
          , @bIsDiscrete   = @bIsDiscrete      
          , @bIsCustom     = @bIsCustom        
          , @cPickSlipNo   = @cPickSlipNo       
          , @cOrderKey     = @cOrderKey
          , @cLoadKey      = @cLoadKey          
          , @cDropID       = @cDropID
          , @cStorerKey    = @cStorerKey        
          , @cFacility     = @cFacility   
          , @nCartonNo     = @nCartonNo
          , @cSKU          = @cSKU
          , @c_UserID      = @c_UserID
          , @cLangCode     = @cLangCode
          , @cResponseJson = @cResponseJson OUTPUT
          , @b_Success     = @b_Success     OUTPUT
          , @n_ErrNo       = @n_ErrNo       OUTPUT
          , @c_ErrMsg      = @c_ErrMsg      OUTPUT
   
   IF @b_Success = 0
   BEGIN    
      SET @n_Continue = 3     
      GOTO EXIT_SP
   END

   SET @c_ResponseString = ISNULL ((JSON_QUERY(CASE WHEN ISJSON(@cResponseJson) = 1
                                                      THEN @cResponseJson
                                                      ELSE '{"VASs":[]}'
                                                      END)
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