SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_GetPrintFlag                                       */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Check whether need to perform paper or label print           */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-29   1.0  GCH225     Created                                          */
/* 2025-12-24   1.1  YLI237     Updated for UWP-43950                            */                                                                              
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_GetPrintFlag] (
	  @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @nCartonNo            INT               = 0
   , @cCartonStatus        NVARCHAR(20)      = ''
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
   , @bWeightInterface     BIT               = 0
   , @bIsLastCarton        BIT               = 0
   , @bPrintPaperFlag      BIT               = 0   OUTPUT
   , @bPrintLabelFlag      BIT               = 0   OUTPUT
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
         , @c_FunID                NVARCHAR(50)   = ''
         , @nStep                  INT            = 0
   
   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 

   IF EXISTS(SELECT 1 
             FROM STORERCONFIG (NOLOCK)
             WHERE StorerKey = @cStorerKey
             AND ConfigKey = 'PrintCartonLabelByITF'
             AND sValue = '1'
   ) AND @bWeightInterface = 1
   BEGIN
      EXEC isp_PrintCartonLabel_Interface 
         @c_Pickslipno     = @cPickSlipNo
       , @n_CartonNo_Min   = @nCartonNo
       , @n_CartonNo_Max   = @nCartonNo
       , @b_Success        = @b_Success   OUTPUT
       , @n_ErrNo          = @n_ErrNo     OUTPUT
       , @c_ErrMsg         = @c_ErrMsg    OUTPUT

      IF @b_Success = 0
      BEGIN
         SET @n_Continue  = 3    
         GOTO EXIT_SP
      END
   END

   IF EXISTS(SELECT 1 
             FROM STORERCONFIG (NOLOCK)
             WHERE StorerKey = @cStorerKey
             AND ConfigKey = 'TPS-DisableLblPrint'
             AND sValue = '1'
   ) 
   OR ( @bIsLastCarton = 0
   AND EXISTS( SELECT 1
               FROM STORERCONFIG (NOLOCK)
               WHERE StorerKey = @cStorerKey
               AND ConfigKey = 'TPS-PrintAfterPacked'
               AND sValue = '1'
             ) 
   )
   BEGIN
      SET @bPrintLabelFlag = 0
   END

   IF EXISTS(SELECT 1 
             FROM STORERCONFIG (NOLOCK)
             WHERE StorerKey = @cStorerKey
             AND ConfigKey = 'TPS-DisablePLPrint'
             AND sValue = '1'
   )
   BEGIN
      SET @bPrintPaperFlag = 0
   END

   SELECT TOP 1 @bPrintPaperFlag = IIF(TRY_CAST(S.sValue AS BIT) = 1, 1, 0)
   FROM STORERCONFIG S (NOLOCK)
   WHERE S.StorerKey = @cStorerKey
   AND (S.Facility = @cFacility OR S.Facility = '')
   AND S.ConfigKey = 'TPS-SkipPackList'
   AND EXISTS (SELECT 1 
               FROM ORDERS O (NOLOCK)
               WHERE (O.OrderKey = @cOrderKey OR O.OrderKey = '')
               AND (O.LoadKey = @cLoadKey OR O.LoadKey = '')
               AND O.[Type] = S.Option1
               AND (O.ShipperKey = S.Option2 OR S.Option2 = '')
              )
   ORDER BY Facility

   IF @bIsLastCarton = 1
   BEGIN
      SELECT  @c_FunID = SHORT
      FROM CODELKUP (NOLOCK) 
      WHERE LISTNAME = 'MDWCARRIER'
      AND (Storerkey='ALL' or Storerkey=@cStorerKey) 

      IF ISNULL(@c_FunID,'')  <> ''
      BEGIN
         EXEC [dbo].[isp_Carrier_Middleware_Interface]            
            @c_OrderKey      = @cOrderKey         
            , @c_Mbolkey     = ''      
            , @c_FunctionID  = @c_FunID          
            , @n_CartonNo    = nCartonNo      
            , @n_Step        = @nStep      
            , @b_Success     = @b_Success OUTPUT            
            , @n_Err         = @n_ErrNo   OUTPUT            
            , @c_ErrMsg      = @c_ErrMsg  OUTPUT   
      END 
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
      SELECT @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END



