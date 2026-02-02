SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*********************************************************************************/    
/* Stored Proc: isp_TPACK_GetExtendedPackInfo                                    */    
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get Extended PackInfo Summary                                */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-01   1.0  GCH225     Created                                          */
/* 2025-11-27   1.0  Sean01     Add Pack Type determination                      */
/*********************************************************************************/
CREATE OR ALTER PROC [API].[isp_TPACK_GetExtendedPackInfo] (
     @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @cLangCode            NVARCHAR(10)      = ''
   , @cExtPackInfoJson     NVARCHAR(MAX)     = ''  OUTPUT
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

   DECLARE @n_Continue     INT            = 1  
         , @n_StartCnt     INT            = @@TRANCOUNT  

         , @cfieldname     NVARCHAR(100)
         , @cfieldvalue    NVARCHAR(1000)
         , @cSQL           NVARCHAR(2000)
         , @cSQLParams     NVARCHAR(2000)
         , @cVasSP         NVARCHAR(50)
         , @cWorkIns       NVARCHAR(4000)
         , @cVasCol1Val    NVARCHAR(250)
   
   DECLARE @DynamicData TABLE (
        rowRef       INT IDENTITY(1,1) PRIMARY KEY
      , fieldName    NVARCHAR(100)
      , fieldValue   NVARCHAR(1000)
   )
   SET @b_Success        = 0  
   SET @n_ErrNo          = 0  
   SET @c_ErrMsg         = ''  
   SET @cExtPackInfoJson = ''

   IF NOT EXISTS (SELECT 1  
                  FROM STORERCONFIG (NOLOCK)  
                  WHERE StorerKey = @cStorerKey  
                  AND ConfigKey = 'TPS-DisplayCol'
   )  
   BEGIN  
      IF @bIsDiscrete = 1
      BEGIN
         INSERT INTO @DynamicData (fieldname, fieldvalue)
         SELECT   'Country Name'
               ,  UPPER(c.Long)    
         FROM CODELKUP c (NOLOCK)    
         WHERE c.StorerKey = @cStorerKey    
         AND c.ListName = 'ISOCOUNTRY'  
         AND EXISTS (SELECT 1 
                     FROM ORDERS o (NOLOCK)
                     WHERE o.StorerKey = @cStorerkey
                     AND o.OrderKey = @cOrderKey
                     AND o.C_ISOCntryCode = c.Code
                    )
      END
      ELSE
      BEGIN
         INSERT INTO @DynamicData (fieldname, fieldvalue)
         SELECT   'Country Name'
               ,  UPPER(c.Long)    
         FROM CODELKUP c (NOLOCK)    
         WHERE c.StorerKey = @cStorerKey    
         AND c.ListName = 'ISOCOUNTRY'  
         AND EXISTS (SELECT 1 
                     FROM ORDERS o (NOLOCK)
                     WHERE o.StorerKey = @cStorerkey
                     AND o.LoadKey = @cLoadkey
                     AND o.C_ISOCntryCode = c.Code
                    )
      END
   END  
   ELSE  
   BEGIN   
      SELECT @cfieldname  = Svalue
      FROM STORERCONFIG (NOLOCK)  
      WHERE StorerKey = @cStorerKey  
         AND ConfigKey = 'TPS-DisplayCol'  

      IF NOT EXISTS(SELECT   1  
               FROM INFORMATION_SCHEMA.COLUMNS (NOLOCK)
               WHERE TABLE_NAME = 'ORDERS'  
               AND COLUMN_NAME = @cfieldname
      )  
      BEGIN  
         SET @n_Continue = 3
         SET @n_ErrNo = 10901    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Invalid Column, Failed to Get the Column from Orders.'   
         GOTO EXIT_SP   
      END  

      SET @cSQL = ' SELECT @cfieldvalue = ' + @cfieldname + CHAR(13)    
                + ' FROM ORDERS (NOLOCK) ' + CHAR(13)    
                + ' WHERE StorerKey = @cStorerKey ' + CHAR(13)    
                + ' AND ' + IIF(@bIsDiscrete = 1, ' OrderKey = @cOrderKey ', ' LoadKey = @cLoadkey ') + CHAR(13)    
      
      SET @cSQLParams = ', @cStorerKey  NVARCHAR(20)          ' + CHAR(13)        
                      + '  @cOrderKey   NVARCHAR(20)          ' + CHAR(13)  
                      + ', @cLoadKey    NVARCHAR(20)          ' + CHAR(13)    
                      + ', @cfieldvalue NVARCHAR(1000) OUTPUT ' + CHAR(13)     

      EXEC sp_executesql @cSQL
                       , @cSQLParams
                       , @cStorerKey
                       , @cOrderKey
                       , @cLoadKey
                       , @cfieldvalue OUTPUT  

      INSERT INTO @DynamicData (fieldname, fieldvalue)
      VALUES (@cfieldname, @cfieldvalue)
   END  

   
   --SELECT TOP 1 @cVasSP = sValue 
   --FROM STORERCONFIG (NOLOCK) 
   --WHERE StorerKey = @cStorerKey 
   --AND ConfigKey ='TPS-ExtInfoVAS'
   --AND sValue <> ''

   --IF @@ROWCOUNT = 1 
   --AND @cVasSP <> '' 
   --AND EXISTS( SELECT 1 FROM dbo.sysobjects WHERE [Name] = @cVasSP AND [type] = 'P')    
   --BEGIN  
   --   SET @cSQL = 'EXEC API.' + @cVasSP 
   --             + ' @cStorerKey=@cStorerKey '
   --             + ', @cOrderKey=@cOrderKey '
   --             + ', @b_Success=@b_Success OUTPUT '
   --             + ', @n_Err=@n_ErrNo OUTPUT '
   --             + ', @c_ErrMsg=@c_ErrMsg OUTPUT '
   --             + ', @cNotes=@cWorkIns OUTPUT '
   --             + ', @cLong=@cVasCol1Val OUTPUT '    
   
   --   SET @cSQLParams = N'@cStorerKey NVARCHAR(15) '
   --                   + N', @cOrderKey NVARCHAR(15) '
   --                   + N', @b_Success INT OUTPUT '
   --                   + N', @n_ErrNo INT OUTPUT '
   --                   + N', @c_ErrMsg NVARCHAR(255) OUTPUT '
   --                   + N', @cWorkIns NVARCHAR(4000) OUTPUT '
   --                   + N', @cVasCol1Val NVARCHAR(250) OUTPUT '   
                      
   --   EXEC sp_executesql  @cSQL    
   --                     , @cSQLParams
   --                     , @cStorerKey    
   --                     , @cOrderKey    
   --                     , @b_Success      OUTPUT    
   --                     , @n_ErrNo        OUTPUT    
   --                     , @c_ErrMsg       OUTPUT    
   --                     , @cWorkIns       OUTPUT    
   --                     , @cVasCol1Val    OUTPUT    
   
   --   IF @b_Success = 0    
   --   BEGIN    
   --   SELECT @n_ErrNo,@c_ErrMsg
   --      SET @n_ErrNo = @n_ErrNo    
   --      SET @c_ErrMsg = @c_ErrMsg    
   --      GOTO EXIT_SP    
   --   END    

   --   INSERT INTO @DynamicData(fieldname, fieldvalue)
   --   VALUES (@cVasCol1Val, @cWorkIns)
   --END    

   -- sean01 start
   -- Pack Type Determination, Call new SP to determine Single/Multi/MPOC

   DECLARE @cPackType         NVARCHAR(10)  = ''
         , @b_PackType_Success INT           = 0
         , @n_PackType_ErrNo   INT           = 0
         , @c_PackType_ErrMsg  NVARCHAR(250) = ''

   EXEC [API].[isp_TPACK_GetPackType]
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
      , @cPackType         = @cPackType        OUTPUT
      , @b_Success         = @b_PackType_Success OUTPUT
      , @n_ErrNo           = @n_PackType_ErrNo   OUTPUT
      , @c_ErrMsg          = @c_PackType_ErrMsg  OUTPUT

   -- Handle Pack Type determination failure
   IF @b_PackType_Success = 0
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = @n_PackType_ErrNo
      SET @c_ErrMsg = @c_PackType_ErrMsg
      GOTO EXIT_SP
   END

   INSERT INTO @DynamicData (fieldname, fieldvalue)
   VALUES ('PackType', @cPackType)
   -- sean01 end


   IF NOT EXISTS (SELECT 1 FROM @DynamicData)
   BEGIN
      GOTO EXIT_SP
   END  

   SET @cExtPackInfoJson = ISNULL ((SELECT  rowRef
                                          , fieldName
                                          , fieldValue 
                                    FROM @DynamicData 
                                    FOR JSON PATH
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