SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*********************************************************************************/    
/* Stored Proc: isp_TPACK_GetPackLabelNo                                         */    
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get New Pack Label No.                                       */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-05   1.0  GCH225     Created                                          */
/*********************************************************************************/
CREATE OR ALTER PROC [API].[isp_TPACK_GetPackLabelNo] (
     @cType             NVARCHAR(30)      = ''
   , @bIsDiscrete       BIT               = 0
   , @bIsCustom         BIT               = 0
   , @cPickSlipNo       NVARCHAR(10)      = ''
   , @cOrderKey         NVARCHAR(10)      = ''
   , @cLoadKey          NVARCHAR(10)      = ''
   , @cDropID           NVARCHAR(20)      = ''
   , @cStorerKey        NVARCHAR(15)      = ''
   , @cFacility         NVARCHAR(5)       = ''
   , @cLangCode         NVARCHAR(3)       = ''
   , @nCartonNo         INT               = 0
   , @c_LabelNo         NVARCHAR(20)      = ''  OUTPUT
   , @b_Success         INT               = 0   OUTPUT
   , @n_ErrNo           INT               = 0   OUTPUT
   , @c_ErrMsg          NVARCHAR(250)     = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue        INT            = 1  
         , @n_StartCnt        INT            = @@TRANCOUNT  

         , @cConfigKey        NVARCHAR(30)
         , @cConfigVal        NVARCHAR(30)
         , @cSQL              NVARCHAR(2000)
         , @cSQLParams        NVARCHAR(2000)
         , @c_Option1         NVARCHAR(50)
         , @c_Option2         NVARCHAR(50)
         , @c_Identifier      NVARCHAR(2)   
         , @c_Packtype        NVARCHAR(1)   
         , @c_VAT             NVARCHAR(18)  
         , @c_nCounter        NVARCHAR(25)  
         , @c_Keyname         NVARCHAR(30)  
         , @c_PackNo_Long     NVARCHAR(250) 
         , @n_CheckDigit      INT
         , @n_TotalCnt        INT
         , @n_TotalOddCnt     INT
         , @n_TotalEvenCnt    INT
         , @n_Add             INT
         , @n_Remain          INT
         , @n_OddCnt          INT
         , @n_EvenCntt        INT
         , @n_Odd             INT
         , @n_Even            INT  
         , @cOldUCCLabelNo    NVARCHAR( 20)
         , @cCartonNo         NVARCHAR(10)
         , @nFunc             INT

   
   SET @b_Success       = 0  
   SET @n_ErrNo         = 0  
   SET @c_ErrMsg        = ''  
   SET @nFunc           = 838

   SET @cConfigKey = 'TPS-ExtendedGenLBLSP'
   SET @cConfigVal = ''

   SELECT @cConfigVal = ISNULL(RTRIM(sValue), '')  
   FROM STORERCONFIG WITH (NOLOCK)
   WHERE Configkey = @cConfigKey
      AND Storerkey = @cStorerKey 
      AND (Facility = '' OR Facility = @cFacility)

   IF @@ROWCOUNT = 1
   BEGIN  
      IF NOT EXISTS( SELECT 1 FROM dbo.sysobjects (NOLOCK) WHERE name = @cConfigVal AND type = 'P')    
      BEGIN 
         SET @n_Continue  = 3
         SET @n_ErrNo = 11051
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'@cConfigVal is not a valid ExtGenLabelSP.'
         GOTO EXIT_SP
      END

      SET @cCartonNo = CAST(@nCartonNo AS NVARCHAR(20))

      SET @cSQL = 'EXEC API.' + @cConfigVal +  CHAR(13)
                + '  @cStorerKey        ' +  CHAR(13)
                + ', @cFacility         ' +  CHAR(13)
                + ', @nFunc             ' +  CHAR(13)
                + ', @cLangCode         ' +  CHAR(13)
                + ', @cPickSlipNo       ' +  CHAR(13)
                + ', @cCartonNo         ' +  CHAR(13)   
                + ', @cLabelNo   OUTPUT ' +  CHAR(13)
                + ', @b_Success  OUTPUT ' +  CHAR(13)
                + ', @n_ErrNo    OUTPUT ' +  CHAR(13)
                + ', @c_ErrMsg   OUTPUT ' +  CHAR(13)

      SET @cSQLParams = '  @cStorerKey   NVARCHAR(15)          ' + CHAR(13)
                      + ', @cFacility    NVARCHAR(5)           ' + CHAR(13) 
                      + ', @nFunc        INT                   ' + CHAR(13)
                      + ', @cLangCode    NVARCHAR(3)           ' + CHAR(13)
                      + ', @cPickSlipNo  NVARCHAR(30)          ' + CHAR(13)
                      + ', @cCartonNo    NVARCHAR(5)           ' + CHAR(13)
                      + ', @cLabelNo     NVARCHAR(20)   OUTPUT ' + CHAR(13)
                      + ', @b_Success    INT            OUTPUT ' + CHAR(13)
                      + ', @n_ErrNo      INT            OUTPUT ' + CHAR(13)
                      + ', @c_ErrMsg     NVARCHAR(255)  OUTPUT ' + CHAR(13)
  
      EXEC sp_ExecuteSQL  @cSQL
                        , @cSQLParams  
                        , @cStorerKey
                        , @cFacility
                        , @nFunc
                        , @cLangCode
                        , @cPickSlipNo
                        , @cCartonNo
                        , @c_LabelNo   OUTPUT
                        , @b_Success   OUTPUT
                        , @n_ErrNo     OUTPUT
                        , @c_ErrMsg    OUTPUT 

      IF @b_Success = 0    
      BEGIN    
         SET @n_Continue  = 3 
         GOTO EXIT_SP    
      END    
   END  
   ELSE
   BEGIN
      -- Config to allow user to key in Label no
      IF @c_LabelNo = ''
      BEGIN
         SET @cConfigKey = 'PackCaptureNewLabelno'
         SET @cConfigVal = ''
         --SELECT 'PackCaptureNewLabelno'
         EXEC nspGetRight ''
                        , @cStorerKey             
                        , ''           
                        , @cConfigKey                
                        , @b_Success  OUTPUT
                        , @cConfigVal OUTPUT
                        , @n_ErrNo    OUTPUT
                        , @c_ErrMsg   OUTPUT
                        , @c_Option1  OUTPUT 
                        , @c_Option2  OUTPUT   

         IF @cConfigVal = '1' AND @c_Option2 <> 'N'
         BEGIN
            SET @n_Continue  = 3
            SET @n_ErrNo = 11052
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No Label No Found, Required User to Manual KeyIn.'
            GOTO EXIT_SP
         END
      END

      --config = GenLabelNo_SP
      IF @c_LabelNo = ''
      BEGIN
         SET @cConfigKey = 'GenLabelNo_SP'
         SET @cConfigVal = ''
         --SELECT 'GenLabelNo_SP'
         EXEC nspGetRight ''
                        , @cStorerKey
                        , ''
                        , @cConfigKey
                        , @b_Success   OUTPUT
                        , @cConfigVal  OUTPUT
                        , @n_ErrNo     OUTPUT
                        , @c_ErrMsg    OUTPUT

         IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = RTRIM(@cConfigVal) AND type = 'P')
         BEGIN
            --Gen Label
            EXECUTE API.isp_TP_GenLabelNo_Wrapper
            @c_PickSlipNo = @cPickSlipno,
            @n_CartonNo   = @nCartonNo,
            @c_LabelNo    = @c_LabelNo   OUTPUT

            IF @c_LabelNo <> ''
            BEGIN
               GOTO EXIT_SP
            END
         END
      END

      --config = GenSSCCLabel
      --IF @c_LabelNo = ''
      --BEGIN
      --   SET @cConfigKey = 'GenSSCCLabel'
      --   SET @cConfigVal = ''
      --   --SELECT 'GenSSCCLabel'
      --   EXECUTE nspGetRight ''
      --                     , @cStorerKey
      --                     , ''
      --                     , @cConfigKey
      --                     , @b_Success     OUTPUT
      --                     , @cConfigVal    OUTPUT
      --                     , @n_ErrNo       OUTPUT
      --                     , @c_ErrMsg      OUTPUT

      --   IF @cConfigVal IN ('1','2')
      --   BEGIN
      --       --Gen Label
      --      EXECUTE isp_TP_GenSSCCLabel_Wrapper
      --      @c_PickSlipNo = @cPickSlipno,
      --      @n_CartonNo   = 0,
      --      @c_SSCC_LabelNo    = @c_LabelNo   OUTPUT

      --      IF @c_LabelNo <> ''
      --      BEGIN
      --         GOTO EXIT_SP
      --      END
      --   END
      --END

      --config = GenUCCLabelNoConfig
      IF @c_LabelNo = ''
      BEGIN
         SET @cConfigKey = 'GenUCCLabelNoConfig'
         SET @cConfigVal = ''

         --SELECT 'GenUCCLabelNoConfig'
         EXECUTE nspGetRight ''
                           , @cStorerKey
                           , ''
                           , @cConfigKey
                           , @b_Success     OUTPUT
                           , @cConfigVal    OUTPUT
                           , @n_ErrNo       OUTPUT
                           , @c_ErrMsg      OUTPUT

         IF @cConfigVal = '1'
         BEGIN
            SET @c_Identifier = '00'
            SET @c_Packtype = '0'
            SET @c_LabelNo = ''

            SELECT @c_VAT = ISNULL(Vat,'')
            FROM STORER (NOLOCK)
            WHERE Storerkey = @cStorerKey


            SELECT @cOldUCCLabelNo = sValue 
            FROM STORERCONFIG(NOLOCK) 
            WHERE StorerKey = @cStorerKey 
               AND ConfigKey = 'TPS-OldUCCLabelNoCfg'  


            IF ISNULL(@c_VAT,'') = ''
               SET @c_VAT = '000000000'

            IF @cOldUCCLabelNo <>'1'
            BEGIN
               IF LEN(@c_VAT) <> 9
                  SET @c_VAT = RIGHT('000000000' + RTRIM(LTRIM(@c_VAT)), 9)

               IF ISNUMERIC(@c_VAT) = 0
               BEGIN
                  SET @n_Continue  = 3
                  SET @n_ErrNo = 11053
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Vat is not a numeric value.'
                  GOTO EXIT_SP
               END
            END

            --Fixed if not numeric

            SELECT @c_PackNo_Long = Long
            FROM  CODELKUP (NOLOCK)
            WHERE ListName = 'PACKNO'
            AND Code = @cStorerKey

            IF ISNULL(@c_PackNo_Long,'') = ''
               SET @c_Keyname = 'TBLPackNo'
            ELSE
               SET @c_Keyname = 'PackNo' + LTRIM(RTRIM(@c_PackNo_Long))

            EXECUTE nspg_getkey
            @c_Keyname ,
            7,
            @c_nCounter     Output ,
            @b_success      = @b_success output,
            @n_err          = @n_ErrNo output,
            @c_errmsg       = @c_errmsg output,
            @b_resultset    = 0,
            @n_batch        = 1

            SET @c_LabelNo = @c_Identifier + @c_Packtype + RTRIM(@c_VAT) + RTRIM(@c_nCounter) --+ @n_CheckDigit

            SET @n_Odd = 1
            SET @n_OddCnt = 0
            SET @n_TotalOddCnt = 0
            SET @n_TotalCnt = 0

            WHILE @n_Odd <= 20
            BEGIN
               IF ISNUMERIC(SUBSTRING(@c_LabelNo, @n_Odd, 1)) = 1
               BEGIN
                  SET @n_OddCnt = CAST(SUBSTRING(@c_LabelNo, @n_Odd, 1) AS INT)
               END
               ELSE
                  SET @n_OddCnt = 0
               SET @n_TotalOddCnt = @n_TotalOddCnt + @n_OddCnt
               SET @n_Odd = @n_Odd + 2
            END

            SET @n_TotalCnt = (@n_TotalOddCnt * 3)

            SET @n_Even = 2
            SET @n_EvenCntt = 0
            SET @n_TotalEvenCnt = 0

            WHILE @n_Even <= 20
            BEGIN
               IF ISNUMERIC(SUBSTRING(@c_LabelNo, @n_Even, 1)) = 1
               BEGIN
                  SET @n_EvenCntt = CAST(SUBSTRING(@c_LabelNo, @n_Odd, 1) AS INT)
               END
               ELSE
                  SET @n_EvenCntt = 0

               SET @n_TotalEvenCnt = @n_TotalEvenCnt + @n_EvenCntt
               SET @n_Even = @n_Even + 2
            END

            SET @n_Add = 0
            SET @n_Remain = 0
            SET @n_CheckDigit = 0

            SET @n_Add = @n_TotalCnt + @n_TotalEvenCnt
            SET @n_Remain = @n_Add % 10
            SET @n_CheckDigit = 10 - @n_Remain

            IF @n_CheckDigit = 10
               SET @n_CheckDigit = 0

            SET @c_LabelNo = ISNULL(RTRIM(@c_LabelNo), '') + CAST(@n_CheckDigit AS NVARCHAR( 1))
         END   -- GenUCCLabelNoConfig
         ELSE
         BEGIN
               --SELECT 'PACKNO'
            EXECUTE nspg_GetKey
               'PACKNO',
               10 ,
               @c_LabelNo  OUTPUT,
               @b_Success  OUTPUT,
               @n_ErrNo    OUTPUT,
               @c_ErrMsg   OUTPUT
         END
      END
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
END -- procedure 