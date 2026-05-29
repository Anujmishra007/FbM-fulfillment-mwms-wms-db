SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_API_UpdatePackInfo                                 */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Update the packinfo table                                    */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-21   1.0  GCH225     Created                                          */
/* 2026-05-12   1.1  JWF011     UWP-54223: Add Cartonization entry point         */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_API_UpdatePackInfo] (
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

   DECLARE @cType                NVARCHAR(30)
         , @bIsDiscrete          BIT
         , @bIsCustom            BIT
         , @cLangCode            NVARCHAR(3)
         , @cPickSlipNo          NVARCHAR(10)
         , @cOrderKey            NVARCHAR(10)
         , @cLoadKey             NVARCHAR(10)
         , @cDropID              NVARCHAR(20)
         , @cStorerKey           NVARCHAR(15)
         , @cFacility            NVARCHAR(5)
         , @nCartonNo            INT
         , @cCartonType          NVARCHAR(10)
         , @cPackInfoJson        NVARCHAR(MAX)
         , @cCartonStatus        NVARCHAR(20)
         , @bPrintPaperFlag      BIT
         , @bPrintLabelFlag      BIT
         , @bWeightInterface     BIT
         , @bIsLastCarton        BIT
         , @fWeight              FLOAT
         , @fCube                FLOAT
         , @cLabelNo             NVARCHAR(20)
         , @nTempCartonNo        INT

   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''  
   SET @c_ResponseString      = '' 
   SET @bIsDiscrete           = 1
   SET @bIsCustom             = 0
   SET @cLangCode             = ''
   SET @cPickSlipNo           = ''
   SET @cOrderKey             = ''
   SET @cLoadKey              = ''
   SET @cDropID               = ''
   SET @cStorerKey            = ''
   SET @cFacility             = ''
   SET @nCartonNo             = 0
   SET @cCartonType           = ''
   SET @cPackInfoJson         = ''
   SET @cCartonStatus         = ''
   SET @bPrintPaperFlag       = 0
   SET @bPrintLabelFlag       = 1
   SET @bWeightInterface      = 0
   SET @bIsLastCarton         = 0
   SET @fWeight               = 0
   SET @fCube                 = 0
   SET @cLabelNo              = ''
   SET @nTempCartonNo         = 0

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
   SELECT  @cType                = cType
         , @bIsDiscrete          = bIsDiscrete
         , @bIsCustom            = bIsCustom
         , @cPickSlipNo          = cPickSlipNo
         , @cOrderKey            = cOrderKey
         , @cLoadKey             = cLoadKey
         , @cDropID              = cDropID
         , @cLangCode            = cLangCode
         , @cStorerKey           = cStorerKey
         , @cFacility            = cFacility
         , @nCartonNo            = nCartonNo
         , @cCartonStatus        = cCartonStatus
         , @cCartonType          = cCartonType
         , @fWeight              = fWeight
         , @fCube                = fCube
         , @cLabelNo             = cLabelNo
   FROM OPENJSON(@c_RequestString)
   WITH (
	      cType                NVARCHAR(30)
	    , bIsDiscrete          BIT
	    , bIsCustom            BIT
       , cPickSlipNo          NVARCHAR(10)      
       , cLoadKey             NVARCHAR(10)      
       , cOrderKey            NVARCHAR(10)
       , cDropID              NVARCHAR(20)
       , cLangCode            NVARCHAR(3)
       , cStorerKey           NVARCHAR(15)
       , cFacility            NVARCHAR(5)
       , nCartonNo            INT
       , cCartonStatus        NVARCHAR(20)
       , cCartonType          NVARCHAR(10)
       , fWeight              FLOAT
       , fCube                FLOAT
       , cLabelNo             NVARCHAR(20)
   )

   IF @nCartonNo = 0
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 11602
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'CartonNo cannot be empty.'
      GOTO EXIT_SP
   END

   IF @cType = 'toteid' 
   BEGIN
      IF @cPickSlipNo = '' 
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
         
         IF @@ROWCOUNT = 1
         BEGIN
            INSERT INTO API.TPACK_UserSessionActivityLog 
            (
               PickSlipNo
               , CartonNo
               , LabelNo
               , OrderKey
               , LoadKey
               , DropID
               , StorerKey
               , Facility
               , Workstation
               , LabelPrinter
               , PaperPrinter
               , AddWho
               , AddDate
               , EditWho
               , EditDate
            )
            SELECT TOP 1 @cPickSlipNo
               , @nCartonNo
               , PD.LabelNo
               , @cOrderKey
               , L.LoadKey
               , L.DropID
               , L.StorerKey
               , L.Facility 
               , L.Workstation
               , L.LabelPrinter
               , L.PaperPrinter
               , @c_UserID
               , dbo.fnc_GetDate()
               , @c_UserID
               , dbo.fnc_GetDate()
            FROM API.TPACK_UserSessionActivityLog L WITH (NOLOCK)
            LEFT JOIN PACKDETAIL PD WITH (NOLOCK)
            ON PD.DropID = L.DropID
            AND PD.StorerKey = L.StorerKey
            WHERE L.DropID = @cDropID
            AND PD.PickSlipNo = @cPickSlipNo
            AND PD.CartonNo = @nCartonNo
            AND L.StorerKey = @cStorerKey
            AND L.PickSlipNo = ''
            AND L.OrderKey = ''
            AND L.LoadKey = ''
            ORDER BY L.RowRefNo DESC
         END
      END
   END

   IF @cPickSlipNo = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 11601
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'PickSlipNo cannot be empty.'
      GOTO EXIT_SP
   END

   IF @cCartonStatus IN ('HOLD', 'INPROGRESS')
   BEGIN
      SET @bPrintLabelFlag = 0
   END

   --Check and Get all the storerconfig
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
   , @nCartonNo            = @nCartonNo
   , @cCartonStatus        = @cCartonStatus
   , @cCartonType          = @cCartonType
   , @fWeight              = @fWeight
   , @fCube                = @fCube
   , @cLabelNo             = @cLabelNo
   , @c_UserID             = @c_UserID
   , @cLangCode            = @cLangCode
   , @bWeightInterface     = @bWeightInterface  OUTPUT
   , @bPrintPaperFlag      = @bPrintPaperFlag   OUTPUT
   , @bPrintLabelFlag      = @bPrintLabelFlag   OUTPUT
   , @bIsLastCarton        = @bIsLastCarton     OUTPUT
   , @b_Success            = @b_Success         OUTPUT
   , @n_ErrNo              = @n_ErrNo           OUTPUT
   , @c_ErrMsg             = @c_ErrMsg          OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_Continue = 3
      GOTO EXIT_SP
   END

   --Check and Get all the storerconfig
   EXEC [API].[isp_TPACK_GetPrintFlag]
     @cType                = @cType            
   , @bIsDiscrete          = @bIsDiscrete      
   , @bIsCustom            = @bIsCustom        
   , @cPickSlipNo          = @cPickSlipNo       
   , @cOrderKey            = @cOrderKey         
   , @cLoadKey             = @cLoadKey          
   , @cDropID              = @cDropID           
   , @cStorerKey           = @cStorerKey        
   , @cFacility            = @cFacility         
   , @nCartonNo            = @nCartonNo
   , @cCartonStatus        = @cCartonStatus
   , @c_UserID             = @c_UserID
   , @cLangCode            = @cLangCode
   , @bWeightInterface     = @bWeightInterface
   , @bIsLastCarton        = @bIsLastCarton
   , @bPrintPaperFlag      = @bPrintPaperFlag   OUTPUT
   , @bPrintLabelFlag      = @bPrintLabelFlag   OUTPUT
   , @b_Success            = @b_Success         OUTPUT
   , @n_ErrNo              = @n_ErrNo           OUTPUT
   , @c_ErrMsg             = @c_ErrMsg          OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_Continue = 3  
      GOTO EXIT_SP
   END

   --Cartonization Entry Point
   IF @cCartonStatus IN ('HOLD', 'CLOSED')
   AND EXISTS (SELECT 1
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
   BEGIN
      IF @bIsLastCarton = 0
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
         , @nCartonNo      = 0
         , @nCartonizeStep = 1
         , @b_Success      = @b_Success      OUTPUT
         , @n_ErrNo        = @n_ErrNo        OUTPUT
         , @c_ErrMsg       = @c_ErrMsg       OUTPUT

         IF @b_Success = 0
         BEGIN
            SET @n_Continue = 3   
            GOTO EXIT_SP
         END
      END
      ELSE
      BEGIN
         SELECT @nTempCartonNo = ISNULL(CartonNo, 0)
         FROM PACKINFO (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonStatus IN('INPROGRESS', 'HOLD')
         AND CartonType <> ''
         AND Qty = 0
         AND [Weight] = 0
         AND [Cube] = 0
         
         IF @nTempCartonNo > 0
         BEGIN
            DELETE FROM PACKINFO
            WHERE PickSlipNo = @cPickSlipNo
            AND CartonNo = @nTempCartonNo
         END
      END
   END

   SET @c_ResponseString = ISNULL ((SELECT CAST(@b_Success AS BIT)   AS Success 
                                         , @bPrintPaperFlag          AS bPrintPaperFlag
                                         , @bPrintLabelFlag          AS bPrintLabelFlag
                                         , @bIsLastCarton            AS bIsLastCarton
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