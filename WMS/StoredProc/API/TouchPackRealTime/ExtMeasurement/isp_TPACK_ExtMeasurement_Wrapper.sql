SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtMeasurement_Wrapper                             */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Extended Measurement Wrapper.                                */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-03-12   1.0  GCH225     FCR-11552 Created                                */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtMeasurement_Wrapper] (
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
   , @cCartonType          NVARCHAR(10)      = ''
   , @fWeight              FLOAT             = 0
   , @fCube                FLOAT             = 0
   , @cLabelNo             NVARCHAR(20)      = ''
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
   , @fTtlWeight           FLOAT             = 0   OUTPUT
   , @fTtlCube             FLOAT             = 0   OUTPUT
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
   
   DECLARE @cExtUpdateSP      NVARCHAR(256)
         , @cSQL              NVARCHAR(MAX)
         , @cSQLParam         NVARCHAR(3000)

         , @nPSN_Qty          INT
         , @nPDQty            INT
         , @cPSN_LabelNo      NVARCHAR(20)
         , @cPSN_SKU          NVARCHAR(20)
         , @cPickDetailKey    NVARCHAR(10)
         , @cExtMeasurementSP NVARCHAR(30)
   
   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 
   SET @cExtMeasurementSP  = ''

   SELECT @cExtMeasurementSP = ISNULL(sValue,'')
   FROM STORERCONFIG (NOLOCK)
   WHERE Storerkey = @cStorerKey
   AND ConfigKey = 'TPS-ExtMeasurement'
   AND sValue <> ''
   
   IF @@ROWCOUNT = 1
   BEGIN
      IF NOT EXISTS( SELECT 1 
                     FROM dbo.sysobjects 
                     WHERE [name] = @cExtMeasurementSP
                     AND [type] = 'P'
      )
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 15151    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --Invalid Extended Measurement SP Name in StorerConfig.
         GOTO EXIT_SP  
      END

      SET @cSQL = 'EXEC [API].[' + RTRIM(@cExtMeasurementSP) + ']' + CHAR(13)
                  + '  @cType               ' + CHAR(13)
                  + ', @bIsDiscrete         ' + CHAR(13)
                  + ', @bIsCustom           ' + CHAR(13)
                  + ', @cPickSlipNo         ' + CHAR(13)
                  + ', @cOrderKey           ' + CHAR(13)
                  + ', @cLoadKey            ' + CHAR(13)
                  + ', @cDropID             ' + CHAR(13)
                  + ', @cStorerKey          ' + CHAR(13)
                  + ', @cFacility           ' + CHAR(13)
                  + ', @nCartonNo           ' + CHAR(13)
                  + ', @cCartonStatus       ' + CHAR(13)
                  + ', @cCartonType         ' + CHAR(13)
                  + ', @fWeight             ' + CHAR(13)
                  + ', @fCube               ' + CHAR(13)
                  + ', @cLabelNo            ' + CHAR(13)
                  + ', @c_UserID            ' + CHAR(13)
                  + ', @cLangCode           ' + CHAR(13)
                  + ', @fTtlWeight   OUTPUT ' + CHAR(13)
                  + ', @fTtlCube     OUTPUT ' + CHAR(13)
                  + ', @b_Success    OUTPUT ' + CHAR(13)
                  + ', @n_ErrNo      OUTPUT ' + CHAR(13)
                  + ', @c_ErrMsg     OUTPUT ' + CHAR(13)

      SET @cSQLParam = '  @cType         NVARCHAR(30)         ' + CHAR(13)
                     + ', @bIsDiscrete   BIT                  ' + CHAR(13)
                     + ', @bIsCustom     BIT                  ' + CHAR(13)
                     + ', @cPickSlipNo   NVARCHAR(10)         ' + CHAR(13)
                     + ', @cOrderKey     NVARCHAR(10)         ' + CHAR(13)
                     + ', @cLoadKey      NVARCHAR(10)         ' + CHAR(13)
                     + ', @cDropID       NVARCHAR(20)         ' + CHAR(13)
                     + ', @cStorerKey    NVARCHAR(15)         ' + CHAR(13)
                     + ', @cFacility     NVARCHAR(5)          ' + CHAR(13)
                     + ', @nCartonNo     INT                  ' + CHAR(13)
                     + ', @cCartonStatus NVARCHAR(20)         ' + CHAR(13)
                     + ', @cCartonType   NVARCHAR(10)         ' + CHAR(13)
                     + ', @fWeight       FLOAT                ' + CHAR(13)
                     + ', @fCube         FLOAT                ' + CHAR(13)
                     + ', @cLabelNo      NVARCHAR(20)         ' + CHAR(13)
                     + ', @c_UserID      NVARCHAR(256)        ' + CHAR(13)
                     + ', @cLangCode     NVARCHAR(3)          ' + CHAR(13)
                     + ', @fTtlWeight    FLOAT         OUTPUT ' + CHAR(13)
                     + ', @fTtlCube      FLOAT         OUTPUT ' + CHAR(13)
                     + ', @b_Success     INT           OUTPUT ' + CHAR(13)
                     + ', @n_ErrNo       INT           OUTPUT ' + CHAR(13)
                     + ', @c_ErrMsg      NVARCHAR(250) OUTPUT ' + CHAR(13)
   
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
                        , @cCartonStatus
                        , @cCartonType
                        , @fWeight
                        , @fCube
                        , @cLabelNo     
                        , @c_UserID         
                        , @cLangCode  
                        , @fTtlWeight   OUTPUT
                        , @fTtlCube     OUTPUT
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
      SELECT  @fTtlWeight = IIF((ISNULL(S.[Weight], 0) = 0), 0, ROUND((S.[Weight] * T.TtlQty), 4))
            , @fTtlCube = IIF((ISNULL(S.[Cube], 0) = 0), 0, ROUND((S.[Cube] * T.TtlQty), 4))
      FROM SKU S (NOLOCK)
      INNER JOIN (
      SELECT PD.SKU AS SKU, SUM(PD.Qty) AS TtlQty
      FROM PACKDETAIL PD (NOLOCK)
      WHERE PD.PickSlipNo = @cPickSlipNo
      AND PD.CartonNo = @nCartonNo
      GROUP BY PD.SKU
      ) T
      ON T.SKU = S.SKU
      WHERE S.StorerKey = @cStorerKey
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
