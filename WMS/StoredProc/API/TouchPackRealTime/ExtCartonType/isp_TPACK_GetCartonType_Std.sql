SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*********************************************************************************/    
/* Stored Proc: isp_TPACK_GetCartonType_Std                                      */    
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get standard carton type list                                */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-05-07   1.0  GCH225     UWP-55978: Migrated from API CartonType SP       */
/*********************************************************************************/
CREATE OR ALTER PROC [API].[isp_TPACK_GetCartonType_Std] (
     @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @c_UserID             NVARCHAR(256)     = ''
   , @cLangCode            NVARCHAR(10)      = ''
   , @nCartonNo            INT               = 0
   , @c_ResponseString     NVARCHAR(MAX)     = ''  OUTPUT
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

   DECLARE @n_Continue  INT            = 1  
         , @n_StartCnt  INT            = @@TRANCOUNT
         , @cConfigVal  NVARCHAR(30)
   
   DECLARE @storer TABLE (
      StorerKey     NVARCHAR( 15),
      catchWeight   INT,
      catchCube     INT
   )

   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''  
   SET @c_ResponseString      = ''
   SET @cConfigVal            = '' 

   SELECT TOP 1 @cConfigVal = ISNULL(sValue,'0')
   FROM STORERCONFIG (NOLOCK)  
   WHERE StorerKey = @cStorerKey
   AND ConfigKey = 'DefaultCartonType'
   
   IF @cType = 'toteid'
   BEGIN
      IF ( SELECT ISNULL(SUM(ExpQty), 0)
            FROM PACKDETAIL (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
         ) > 0
      AND ( SELECT ISNULL(COUNT(CartonNo), 0)
            FROM PACKINFO (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
            AND CartonStatus = 'INPROGRESS'
         ) = 1
      BEGIN
         SELECT TOP 1 @cConfigVal = CartonType
         FROM PACKINFO (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonStatus = 'INPROGRESS'
      END
      ELSE IF @nCartonNo > 0
      BEGIN
         SELECT @cConfigVal = CartonType
         FROM PACKINFO (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND CartonStatus = 'INPROGRESS'
      END
   END
   
   INSERT INTO @storer
   SELECT @cStorerKey
        , IIF(sValue LIKE '%W%', 1, 0)
        , IIF(sValue LIKE '%C%', 1, 0)
   FROM STORERCONFIG  WITH (NOLOCK)  
   WHERE StorerKey = @cStorerKey
   AND ConfigKey = 'TPS-captureWeight'

   IF NOT EXISTS (SELECT 1 FROM @storer)
   BEGIN
      INSERT INTO @storer (StorerKey, catchWeight, catchCube)
      VALUES (@cStorerKey, 0, 0)
   END
   
   SET @c_ResponseString = ISNULL((
                              SELECT  vs.StorerKey
                                    , vs.catchWeight
                                    , vs.catchCube 
                                    , Carton.cartonType
                                    , Carton.CartonDescription
                                    , Carton.Barcode
                                    , TRY_CAST(ISNULL(Carton.CartonLength,0) AS DECIMAL(18,3)) AS CartonLength
                                    , TRY_CAST(ISNULL(Carton.CartonWidth,0) AS DECIMAL(18,3)) AS CartonWidth
                                    , TRY_CAST(ISNULL(Carton.CartonHeight,0) AS DECIMAL(18,3)) AS CartonHeight
                                    , TRY_CAST(ISNULL(Carton.MaxWeight,0) AS DECIMAL(18,3)) AS MaxWeight
                                    , TRY_CAST(Carton.[CUBE] AS DECIMAL(18,3)) AS [Cube]
                                    , Carton.UseSequence AS UseSequence
                                    , CAST(IIF(RTRIM(Carton.cartonType) = RTRIM(@cConfigVal), 1, 0) AS BIT) AS Recommended
                              FROM @storer vs
                              JOIN STORER S WITH (NOLOCK)  
                              ON vs.StorerKey = s.StorerKey
                              JOIN CARTONIZATION Carton WITH (NOLOCK) 
                              ON S.cartonGroup = Carton.CartonizationGroup
                              WHERE S.StorerKey = @cStorerKey
                              AND Carton.cartonType <> ''
                              ORDER BY CASE 
                                          WHEN CAST(IIF(RTRIM(Carton.cartonType) = RTRIM(@cConfigVal), 1, 0) AS BIT) = 1 
                                          THEN 0 
                                          ELSE 1 END ASC
                                     , Carton.[Cube] ASC
                              FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
                           ), '') 

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