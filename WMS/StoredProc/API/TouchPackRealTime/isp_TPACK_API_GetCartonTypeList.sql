SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_API_GetCartonTypeList                              */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get the list of carton type for specific storer              */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-01   1.0  GCH225     Created                                          */
/* 2026-02-05   2.0  GCH225     UWP-48097: Recommended CartonType from PackInfo  */
/* 2026-05-07   3.0  GCH225     UWP-55973: Wrapper to support custom and standard*/
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_API_GetCartonTypeList] (
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

   DECLARE @cType       NVARCHAR(30)
         , @bIsDiscrete BIT
         , @bIsCustom   BIT
         , @cLangCode   NVARCHAR(3)
         , @cPickSlipNo NVARCHAR(10)
         , @cOrderKey   NVARCHAR(10)
         , @cLoadKey    NVARCHAR(10)
         , @cDropID     NVARCHAR(20)
         , @cStorerKey  NVARCHAR(15)
         , @cFacility   NVARCHAR(5)
         , @nCartonNo   INT
         , @cSQL        NVARCHAR(MAX)
         , @cSQLParam   NVARCHAR(MAX)
         , @c_authority NVARCHAR(100)
         , @c_Option1   NVARCHAR(100)
         , @c_Option2   NVARCHAR(100)
         , @c_Option3   NVARCHAR(100)
         , @c_Option4   NVARCHAR(100)
         , @c_Option5   NVARCHAR(100)

   SET @b_Success        = 0  
   SET @n_ErrNo          = 0  
   SET @c_ErrMsg         = ''  
   SET @c_ResponseString = '' 
   SET @bIsDiscrete      = 1
   SET @bIsCustom        = 0
   SET @cLangCode        = ''
   SET @cPickSlipNo      = ''
   SET @cOrderKey        = ''
   SET @cLoadKey         = ''
   SET @cDropID          = ''
   SET @cStorerKey       = ''
   SET @cFacility        = ''
   SET @nCartonNo        = 0
   SET @c_authority      = ''
   SET @c_Option1        = ''
   SET @c_Option2        = ''
   SET @c_Option3        = ''
   SET @c_Option4        = ''
   SET @c_Option5        = ''

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
         , @cPickSlipNo = cPickSlipNo
         , @cOrderKey   = cOrderKey
         , @cLoadKey    = cLoadKey
         , @cDropID     = cDropID
         , @cLangCode   = cLangCode
         , @cStorerKey  = cStorerKey
         , @cFacility   = cFacility
         , @nCartonNo   = nCartonNo
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
   )
   
   EXEC nspGetRight  -- (yeekung20)  
      @c_Facility   = @cFacility   
   ,  @c_StorerKey  = @cStorerKey   
   ,  @c_sku        = ''    
   ,  @c_ConfigKey  = 'TPS-RecartonBlocked'    
   ,  @b_Success    = @b_Success       OUTPUT    
   ,  @c_authority  = @c_authority     OUTPUT    
   ,  @n_err        = @n_ErrNo         OUTPUT    
   ,  @c_errmsg     = @c_ErrMsg        OUTPUT
   ,  @c_Option1    = @c_Option1       OUTPUT
   ,  @c_Option2    = @c_Option2       OUTPUT
   ,  @c_Option3    = @c_Option3       OUTPUT
   ,  @c_Option4    = @c_Option4       OUTPUT 
   ,  @c_Option5    = @c_Option5       OUTPUT
   
   IF @c_authority = '1' 
   AND @c_Option5 <> ''
   AND EXISTS (SELECT 1
               FROM dbo.sysobjects (NOLOCK)
               WHERE [name] = @c_Option5 
               AND type = 'P'
   )
   AND @nCartonNo > 0
   BEGIN
      SET @cSQL   = 'EXEC [API].[' + @c_Option5    + ']' + CHAR(13)
                  + '  @cType              ' + CHAR(13)
                  + ', @bIsDiscrete        ' + CHAR(13)
                  + ', @bIsCustom          ' + CHAR(13)
                  + ', @cPickSlipNo        ' + CHAR(13)
                  + ', @cOrderKey          ' + CHAR(13)
                  + ', @cLoadKey           ' + CHAR(13)
                  + ', @cDropID            ' + CHAR(13)
                  + ', @cStorerKey         ' + CHAR(13)
                  + ', @cFacility          ' + CHAR(13)
                  + ', @nCartonNo          ' + CHAR(13)
                  + ', @c_UserID           ' + CHAR(13)
                  + ', @cLangCode          ' + CHAR(13)
                  + ', @b_Success   OUTPUT ' + CHAR(13)
                  + ', @n_ErrNo     OUTPUT ' + CHAR(13)
                  + ', @c_ErrMsg    OUTPUT ' + CHAR(13)

      SET @cSQLParam = '  @cType        NVARCHAR(30)         ' + CHAR(13)
                     + ', @bIsDiscrete  BIT                  ' + CHAR(13)
                     + ', @bIsCustom    BIT                  ' + CHAR(13)
                     + ', @cPickSlipNo  NVARCHAR(10)         ' + CHAR(13)
                     + ', @cOrderKey    NVARCHAR(10)         ' + CHAR(13)
                     + ', @cLoadKey     NVARCHAR(10)         ' + CHAR(13)
                     + ', @cDropID      NVARCHAR(20)         ' + CHAR(13)
                     + ', @cStorerKey   NVARCHAR(15)         ' + CHAR(13)
                     + ', @cFacility    NVARCHAR(5)          ' + CHAR(13)
                     + ', @nCartonNo    INT                  ' + CHAR(13)
                     + ', @c_UserID     NVARCHAR(256)        ' + CHAR(13)
                     + ', @cLangCode    NVARCHAR(3)          ' + CHAR(13)
                     + ', @b_Success    INT           OUTPUT ' + CHAR(13)
                     + ', @n_ErrNo      INT           OUTPUT ' + CHAR(13)
                     + ', @c_ErrMsg     NVARCHAR(250) OUTPUT ' + CHAR(13)

      EXEC sp_ExecuteSQL  @cSQL
                        , @cSQLParam
                        , @cType            
                        , @bIsDiscrete     
                        , @bIsCustom        
                        , @cPickSlipNo      
                        , @cOrderKey        
                        , @cLoadKey         
                        , @cDropID          
                        , @cStorerKey       
                        , @cFacility          
                        , @nCartonNo        
                        , @c_UserID         
                        , @cLangCode  
                        , @b_Success   OUTPUT
                        , @n_ErrNo     OUTPUT
                        , @c_ErrMsg    OUTPUT
            
      IF @b_Success = 0
      BEGIN     
         SET @n_Continue = 3   
         GOTO EXIT_SP
      END
   END

   --Cartonization Entry Point
   IF EXISTS ( SELECT 1
               FROM STORERCONFIG (NOLOCK)
               WHERE Storerkey = @cStorerKey
               AND ConfigKey = 'TPS-CtnRec'
               AND SValue = '1'
   )
   AND @cType = 'toteid'
   AND EXISTS (SELECT 1
               FROM STORERCONFIG (NOLOCK)
               WHERE Storerkey = @cStorerKey
               AND ConfigKey = 'TPS-SinglePKStation'
               AND SValue = '1'
   ) 
   AND EXISTS (SELECT 1
               FROM CODELKUP (NOLOCK)
               WHERE Storerkey = @cStorerKey
               AND ListName = 'TPSCtnRec'
   )
   AND @nCartonNo > 0
   AND @cPickSlipNo = ''
   AND @cOrderKey = ''
   AND @cLoadKey = ''
   BEGIN

      SELECT  @cPickSlipNo = PH.PickSlipNo
            , @cOrderKey = PH.OrderKey
      FROM PACKHEADER PH (NOLOCK)
      WHERE EXISTS ( SELECT 1 
                     FROM PACKDETAIL PD (NOLOCK)
                     WHERE PD.PickSlipNo = PH.PickSlipNo
                     AND PD.DropID = @cDropID
                     AND PD.CartonNo = @nCartonNo
                     AND EXISTS (SELECT 1 
                                 FROM PACKINFO PIF (NOLOCK)
                                 WHERE PIF.PickSlipNo = PD.PickSlipNo
                                 AND PIF.CartonNo = PD.CartonNo
                                 AND PIF.EditWho = @c_UserID
                                 AND PIF.CartonStatus = 'INPROGRESS'
                     )
                  )

      IF @cPickSlipNo <> '' AND @cOrderKey <> ''
      BEGIN
         EXEC [API].[isp_TPACK_Cartonization_Wrapper]
            @cType          = @cType            
         , @bIsDiscrete    = @bIsDiscrete      
         , @bIsCustom      = @bIsCustom        
         , @cPickSlipNo    = @cPickSlipNo       
         , @cOrderKey      = @cOrderKey
         , @cLoadKey       = @cLoadKey          
         , @cDropID        = @cDropID
         , @cStorerKey     = @cStorerKey        
         , @cFacility      = @cFacility
         , @c_UserID       = @c_UserID
         , @cLangCode      = @cLangCode
         , @nCartonNo      = @nCartonNo
         , @nCartonizeStep = 2
         , @b_Success      = @b_Success      OUTPUT
         , @n_ErrNo        = @n_ErrNo        OUTPUT
         , @c_ErrMsg       = @c_ErrMsg       OUTPUT

         IF @b_Success = 0
         BEGIN
            SET @n_Continue = 3   
            GOTO EXIT_SP
         END
      END
   END

   EXEC [API].[isp_TPACK_GetCartonType_Wrapper]
     @cType             = @cType            
   , @bIsDiscrete       = @bIsDiscrete      
   , @bIsCustom         = @bIsCustom        
   , @cPickSlipNo       = @cPickSlipNo       
   , @cOrderKey         = @cOrderKey         
   , @cLoadKey          = @cLoadKey          
   , @cDropID           = @cDropID           
   , @cStorerKey        = @cStorerKey        
   , @cFacility         = @cFacility  
   , @c_UserID          = @c_UserID
   , @cLangCode         = @cLangCode
   , @nCartonNo         = @nCartonNo
   , @c_ResponseString  = @c_ResponseString  OUTPUT
   , @b_Success         = @b_Success         OUTPUT
   , @n_ErrNo           = @n_ErrNo           OUTPUT
   , @c_ErrMsg          = @c_ErrMsg          OUTPUT

   IF @b_Success = 0 OR ISNULL(@c_ResponseString, '') = ''
   BEGIN
      SET @n_Continue = 3  
      GOTO EXIT_SP
   END

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
      SET @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END
