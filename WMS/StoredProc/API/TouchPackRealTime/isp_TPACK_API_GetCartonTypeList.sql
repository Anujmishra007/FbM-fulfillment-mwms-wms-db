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

   DECLARE @n_Continue                    INT            = 1  
         , @n_StartCnt                    INT            = @@TRANCOUNT  
         , @b_sp_Success                  INT  
         , @n_sp_err                      INT  
         , @c_sp_errmsg                   NVARCHAR(250)  = ''
         , @DBUserName                    NVARCHAR(100)
         , @b_sp_ExecuteAs                BIT

   DECLARE
      @cLangCode     NVARCHAR( 3),
      @cStorerKey    NVARCHAR( 15),
      @cFacility     NVARCHAR( 5),
      @nFunc         INT,
      @cStorerJson   NVARCHAR( 1048),
      @cConfigVal    NVARCHAR(30)

   DECLARE @errMsg TABLE (
      nErrNo    INT,
      cErrMsg   NVARCHAR( 1024)
   )

   DECLARE @storer TABLE (
      StorerKey     NVARCHAR( 15),
      catchWeight   INT,
      catchCube     INT
   )


   --Decode Json Format
   --DECLARE curMsg CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
   select @nFunc = Func,@cLangCode = LangCode, @cStorerJson=Storer
   FROM OPENJSON(@c_RequestString)
   WITH (
      Func       nvarchar( 5),
      LangCode   NVARCHAR( 1),
      Storer     nvarchar( max) as json
   )

   insert INTO @storer
   SELECT vs.storerKey
   , CASE WHEN SC.sValue LIKE '%W%' THEN 1 ELSE 0 END
   , CASE WHEN SC.sValue LIKE '%C%' THEN 1 ELSE 0 END
   FROM OPENJSON(@cStorerJson)
   WITH (
      StorerKey   NVARCHAR( 20)    '$.StorerKey'
   )vs
   LEFT JOIN ( SELECT storerKey, svalue 
               FROM dbo.StorerConfig  WITH (NOLOCK) 
               WHERE ConfigKey = 'TPS-captureWeight'
               ) SC
      ON (vs.StorerKey = SC.storerkey )

    IF NOT EXISTS (SELECT 1 FROM @storer)
    BEGIN
      SET @b_Success = 0
      SET @n_ErrNo = 10101
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No StorerKey Found.'
      GOTO EXIT_SP
    END


   SELECT TOP 1 @cConfigVal = ISNULL(sValue,'0')
   FROM STORERCONFIG (NOLOCK)  
   WHERE StorerKey IN ( SELECT StorerKey FROM @storer)
   AND ConfigKey = 'DefaultCartonType'

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
                                    , CASE WHEN Carton.cartonType = @cConfigVal THEN CAST(1 AS BIT)
                                           ELSE CAST(0 AS BIT)
                                           END AS Recommended
                              FROM @storer vs
                              JOIN STORER S WITH (NOLOCK)  ON vs.StorerKey = s.StorerKey
                              JOIN CARTONIZATION Carton WITH (NOLOCK) ON (S.cartonGroup=Carton.CartonizationGroup)
                              WHERE Carton.cartonType <> ''
                              ORDER BY Carton.[Cube] ASC
                              FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
                           ), '') 

   EXIT_SP:
      REVERT
END


