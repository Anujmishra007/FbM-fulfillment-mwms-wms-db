SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_CheckMultiSKUSelection                             */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Check the AltSKU whether allow to SelectAll SKU or First Only*/
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-22   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_CheckMultiSKUSelection] (
     @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @cInputValue1         NVARCHAR(128)     = ''
   , @cInputValue2         NVARCHAR(MAX)     = ''
   , @cInputValue3         NVARCHAR(128)     = ''
   , @cScanType            NVARCHAR(20)      = ''
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
   , @bIsMultiSKU          BIT               = 0
   , @bClickAll            BIT               = 0   OUTPUT
   , @bClickFirstOnly      BIT               = 0   OUTPUT
   , @b_Success            INT               = 0   OUTPUT  
   , @n_ErrNo              INT               = 0   OUTPUT  
   , @c_ErrMsg             NVARCHAR(250)     = ''  OUTPUT  
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue           INT            = 1  
         , @n_StartCnt           INT            = @@TRANCOUNT  
         
         , @cConfigVal           NVARCHAR(30)
         , @cSQL                 NVARCHAR(MAX)
         , @cSQLParams           NVARCHAR(MAX)
         , @bConfigVal           BIT

   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''  

   SET @bClickAll             = 0
   SET @bClickFirstOnly       = 1
   SET @cConfigVal            = ''
   SET @cSQL                  = ''
   SET @cSQLParams            = ''
   SET @bConfigVal            = 1

   IF @cScanType = 'altsku' AND 
   @bIsMultiSKU = 1 AND
   EXISTS ( SELECT 1 
            FROM STORERCONFIG (NOLOCK) 
            WHERE StorerKey = @cStorerKey 
            AND Configkey = 'TPS-AltSkuSelection' 
            AND sValue = '1'
   )
   BEGIN
      SET @bClickAll             = 1
      SET @bClickFirstOnly       = 0
      GOTO EXIT_SP
   END
   
   SELECT @cConfigVal = ISNULL(RTRIM(sValue),'0')
   FROM STORERCONFIG (NOLOCK)  
   WHERE StorerKey = @cStorerKey  
   AND ConfigKey = 'TPS-GetKeyPadInput'

   IF @@ROWCOUNT = 0
   BEGIN  
      GOTO EXIT_SP
   END
      
   IF EXISTS(SELECT 1 
               FROM dbo.sysobjects (NOLOCK) 
               WHERE name = @cConfigVal 
               AND type = 'P'
   )    
   BEGIN 
      SET @cSQL = 'EXEC [API].[' + @cConfigVal + ']' + CHAR(13)
                + '  @cType               ' + CHAR(13)
                + ', @bIsDiscrete         ' + CHAR(13)
                + ', @bIsCustom           ' + CHAR(13)
                + ', @cPickSlipNo         ' + CHAR(13)
                + ', @cOrderKey           ' + CHAR(13)
                + ', @cLoadKey            ' + CHAR(13)
                + ', @cDropID             ' + CHAR(13)
                + ', @cStorerKey          ' + CHAR(13)
                + ', @cFacility           ' + CHAR(13)
                + ', @bConfigVal   OUTPUT ' + CHAR(13)                     
                + ', @b_Success    OUTPUT ' + CHAR(13)
                + ', @n_ErrNo      OUTPUT ' + CHAR(13)
                + ', @c_ErrMsg     OUTPUT ' + CHAR(13)

      SET @cSQLParams  = '  @cType        NVARCHAR(30)          ' + CHAR(13)
                       + ', @bIsDiscrete  BIT                   ' + CHAR(13)
                       + ', @bIsCustom    BIT                   ' + CHAR(13)
                       + ', @cPickSlipNo  NVARCHAR(10)          ' + CHAR(13)
                       + ', @cOrderKey    NVARCHAR(10)          ' + CHAR(13)
                       + ', @cLoadKey     NVARCHAR(10)          ' + CHAR(13)
                       + ', @cDropID      NVARCHAR(20)          ' + CHAR(13)
                       + ', @cStorerKey   NVARCHAR(15)          ' + CHAR(13)
                       + ', @cFacility    NVARCHAR(5)           ' + CHAR(13)
                       + ', @bConfigVal   BIT            OUTPUT ' + CHAR(13) 
                       + ', @b_Success    INT            OUTPUT ' + CHAR(13) 
                       + ', @n_ErrNo      INT            OUTPUT ' + CHAR(13) 
                       + ', @c_ErrMsg     NVARCHAR(20)   OUTPUT ' + CHAR(13)   

      EXEC sp_ExecuteSQL @cSQL
                       , @cSQLParams
                       , @cType
                       , @bIsDiscrete
                       , @bIsCustom
                       , @cPickSlipNo
                       , @cOrderKey
                       , @cLoadKey
                       , @cDropID
                       , @cStorerKey
                       , @cFacility
                       , @bConfigVal   OUTPUT    
                       , @b_Success    OUTPUT    
                       , @n_ErrNo      OUTPUT    
                       , @c_ErrMsg     OUTPUT    

      IF @b_Success = 0    
      BEGIN    
         SET @n_Continue = 3
         GOTO EXIT_SP    
      END    
   END
   ELSE
   BEGIN
      SET @bConfigVal = TRY_CAST(@cConfigVal AS BIT)
   END

   IF @bConfigVal = 0
   BEGIN
      SET @bClickAll             = 0
      SET @bClickFirstOnly       = 0
   END

EXIT_SP:
   IF @n_Continue= 3  -- Error Occured - Process And Return      
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