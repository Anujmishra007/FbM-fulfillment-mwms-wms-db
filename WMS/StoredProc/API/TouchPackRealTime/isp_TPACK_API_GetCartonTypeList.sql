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

   DECLARE @storer TABLE (
      StorerKey     NVARCHAR( 15),
      catchWeight   INT,
      catchCube     INT
   )

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
         , @cConfigVal  NVARCHAR(30)

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
   )

   SELECT TOP 1 @cConfigVal = ISNULL(sValue,'0')
   FROM STORERCONFIG (NOLOCK)  
   WHERE StorerKey = @cStorerKey
   AND ConfigKey = 'DefaultCartonType'
     
   IF @cType = 'toteid'
   AND ( SELECT ISNULL(SUM(ExpQty), 0)
         FROM PACKDETAIL (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
       ) > 0
   AND ( SELECT ISNULL(COUNT(CartonNo), 0)
         FROM PACKINFO (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
       ) = 1
   BEGIN
      SELECT TOP 1 @cConfigVal = CartonType
      FROM PACKINFO (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
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

   --Json Format Output
   SET @b_Success = 1
   SET @c_ResponseString = ISNULL((
                              SELECT  vs.StorerKey
                                    , vs.catchWeight
                                    , vs.catchCube 
                                    , Carton.cartonType
                                    , Carton.CartonDescription
                                    , Carton.Barcode
                                    , CAST(ISNULL(Carton.CartonLength,0) AS DECIMAL(10,3)) AS CartonLength
                                    , CAST(ISNULL(Carton.CartonWidth,0) AS DECIMAL(10,3)) AS CartonWidth
                                    , CAST(ISNULL(Carton.CartonHeight,0) AS DECIMAL(10,3)) AS CartonHeight
                                    , CAST(ISNULL(Carton.MaxWeight,0) AS DECIMAL(10,3)) AS MaxWeight
                                    , CAST(Carton.[CUBE] AS DECIMAL(10,3)) AS [Cube]
                                    , Carton.UseSequence AS UseSequence
                                    , CAST(IIF(RTRIM(Carton.cartonType) = RTRIM(@cConfigVal), 1, 0) AS BIT) AS Recommended
                              FROM @storer vs
                              JOIN STORER S WITH (NOLOCK)  ON vs.StorerKey = s.StorerKey
                              JOIN CARTONIZATION Carton WITH (NOLOCK) 
                              ON S.cartonGroup = Carton.CartonizationGroup
                              WHERE S.StorerKey = @cStorerKey
                              AND Carton.cartonType <> ''
                              ORDER BY Carton.[Cube] ASC
                              FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
                           ), '') 
   EXIT_SP:
      REVERT

END


