SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

    
/******************************************************************************/      
/* Store procedure: isp_TPS_ExtGenLBL02                                       */      
/* Copyright      : LFLogistics                                               */      
/*                                                                            */ 
/* Purpose        : Generate the labelNo by Trackingno                        */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */      
/* 2024-02-21   1.0  YeeKung  TPS-970 Created                                 */
/* 2025-05-19   1.1  GhChan   UWP-34530 Fix LabelNo return value issue        */
/******************************************************************************/      
      
CREATE OR ALTER PROC [API].[isp_TPS_ExtGenLBL02] (      
 @cStorerKey      NVARCHAR( 15),   
 @cFacility       NVARCHAR( 5),    
 @nFunc           INT,            
 @cLangCode       NVARCHAR( 3),   
 @cPickSlipNo     NVARCHAR( 30),  
 @cCartonNo       NVARCHAR(5),
 @cLabelNo        NVARCHAR( 20)  OUTPUT,  
 @b_Success       INT            OUTPUT,
 @n_Err           INT            OUTPUT,
 @c_ErrMsg        NVARCHAR( 255)  OUTPUT
)      
AS      
BEGIN      
   SET NOCOUNT ON      
   SET QUOTED_IDENTIFIER OFF      
   SET ANSI_NULLS OFF      
   SET CONCAT_NULL_YIELDS_NULL OFF  
   
   DECLARE  @cOrderkey      NVARCHAR(20)
   DECLARE  @cKeyname       NVARCHAR(20)
   DECLARE  @cShipperkey    NVARCHAR(20)
   DECLARE  @cTrackingNo    NVARCHAR(20)
   DECLARE  @nRowRef        INT
   DECLARE  @nTranCount     INT
   DECLARE  @c_authority      NVARCHAR(30),
            @c_Option1        NVARCHAR(50),  
            @c_Option2        NVARCHAR(50),
            @c_Identifier     NVARCHAR(2)    = '',
            @c_Packtype       NVARCHAR(1)    = '',
            @c_VAT            NVARCHAR(18)   = '',
            @c_nCounter       NVARCHAR(25)   = '',
            @c_Keyname        NVARCHAR(30)   = '',
            @c_PackNo_Long    NVARCHAR(250)  = '',
            @n_CheckDigit     INT = 0,
            @n_TotalCnt       INT = 0,
            @n_TotalOddCnt    INT = 0,
            @n_TotalEvenCnt   INT = 0,
            @n_Add            INT = 0,
            @n_Divide         INT = 0,
            @n_Remain         INT = 0,
            @n_OddCnt         INT = 0,
            @n_EvenCntt       INT = 0,
            @n_Odd            INT = 0,
            @n_Even           INT = 0,
            @c_CTNTrackNo     NVARCHAR(40)   = '',
            @cOldUCCLabelNo   NVARCHAR( 20)

   SET @nTranCount = @@TRANCOUNT  
   BEGIN TRAN  
   SAVE TRAN isp_TPS_ExtGenLBL02 

   SELECT TOP 1 @cOrderkey = Orderkey
   FROM PickHeader (NOLOCK)
   WHERE PickHeaderkey = @cPickSlipNo
   
   IF EXISTS ( SELECT 1
               FROM Orders (NOLOCK) 
               WHERE Orderkey = @cOrderkey
                  AND Storerkey = @cStorerKey
                  AND ISNULL(Shipperkey,'') <>''
                  AND ISNULL(ecom_platform,'')<> 'JIT')
   BEGIN
      IF @cCartonNo = '1'
      BEGIN
         SELECT @cLabelNo = trackingno
         FROM Orders (nolock)
         WHERE Orderkey = @cOrderkey
            AND Storerkey = @cStorerkey
      END
      ELSE
      BEGIN
         SELECT TOP 1 @cShipperkey = Shipperkey
         FROM Orders (NOLOCK) 
         WHERE Orderkey = @cOrderkey
            AND Storerkey = @cStorerKey
            AND ISNULL(Shipperkey,'') <>''

         SELECT @cKeyname = UDF05
         FROM Codelkup (NOLOCK) 
         WHERE Storerkey = @cStorerKey
            AND Listname = 'Asgntno'
            AND Short = @cShipperkey
            AND Notes = @cFacility
         

         SELECT TOP 1 @cTrackingNo = TrackingNo, 
                        @nRowRef = RowRef
         FROM Cartontrack_pool (nolock)
         WHERE keyname = @cKeyname
            AND CarrierName = @cShipperkey

         IF ISNULL( @cTrackingNo, '') = ''
         BEGIN
            SET @n_Err = 1001551
            SET @c_ErrMsg = api.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --'NO TRACKING #|isp_TPS_ExtGenLBL02'
            SET @b_Success = 0
            GOTO RollBackTran
         END

         INSERT INTO cartontrack  (Trackingno,CarrierName,KeyName,CarrierRef1,CarrierRef2,labelno)
         SELECT  TrackingNo, CarrierName,keyname,CarrierRef1,CarrierRef2,@cOrderkey
         FROM Cartontrack_pool (nolock)
         WHERE RowRef = @nRowRef

         IF @@ERROR <> 0
         BEGIN
            SET @n_Err = 1001552
            SET @c_ErrMsg = api.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --'Insert CartonTrack table fail :isp_TPS_ExtGenLBL02'
            SET @b_Success = 0
            GOTO RollBackTran
         END

         DELETE Cartontrack_pool WHERE RowRef = @nRowRef

         IF @@ERROR <> 0
         BEGIN
            SET @n_Err = 1001553
            SET @c_ErrMsg = api.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --'DEL TRACK# Err:isp_TPS_ExtGenLBL02'
            SET @b_Success = 0
            GOTO RollBackTran
         END
         
         SET @cLabelNo = @cTrackingNo
         
      END
   END
   ELSE
   BEGIN
               
      -- Config to allow user to key in Label no
      IF @cLabelNo = ''
      BEGIN
         --SELECT 'PackCaptureNewLabelno'
         EXECUTE nspGetRight null,
         @cStorerKey,       -- Storerkey
         '',               -- Sku
         'PackCaptureNewLabelno', -- Configkey
         @b_success      OUTPUT,
         @c_authority   OUTPUT,
         @n_err         OUTPUT,
         @c_errmsg      OUTPUT,
         @c_Option1     OUTPUT,  --(cc01)
         @c_Option2     OUTPUT   --(cc01)

         IF @c_authority = '1' AND @c_Option2 <> 'N' --(cc01)
         BEGIN
            --SET @cCaptureLabelNo = '1'
            SET @b_Success = 0
            SET @n_Err = 1001554
            SET @c_ErrMsg = api.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Need LabelNo. Function : isp_TPS_ExtGenLBL02'
            SET @b_Success = 0
            GOTO RollbackTran
         END
      END

      --config = GenLabelNo_SP
      IF @cLabelNo = ''
      BEGIN
         --SELECT 'GenLabelNo_SP'

         EXECUTE nspGetRight null,
         @cStorerKey,       -- Storerkey
         '',               -- Sku
         'GenLabelNo_SP',    -- Configkey
         @b_success      OUTPUT,
         @c_authority   OUTPUT,
         @n_err         OUTPUT,
         @c_errmsg      OUTPUT

         IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = RTRIM(@c_authority) AND type = 'P')
         BEGIN
            --Gen Label
            EXECUTE api.isp_TP_GenLabelNo_Wrapper
            @c_PickSlipNo = @cPickSlipno,
            @n_CartonNo   = @cCartonNo,  --(cc02)
            @c_LabelNo    = @cLabelNo   OUTPUT

            IF @cLabelNo <> ''
            BEGIN
               GOTO RollbackTran
            END
         END
      END

      --config = GenSSCCLabel
      IF @cLabelNo = ''
      BEGIN
         --SELECT 'GenSSCCLabel'
         EXECUTE nspGetRight null,
         @cStorerKey,       -- Storerkey
         '',               -- Sku
         'GenSSCCLabel',    -- Configkey
         @b_success      OUTPUT,
         @c_authority   OUTPUT,
         @n_err         OUTPUT,
         @c_errmsg      OUTPUT

         IF @c_authority IN ('1','2')
         BEGIN
             --Gen Label
            EXECUTE isp_TP_GenSSCCLabel_Wrapper
            @c_PickSlipNo = @cPickSlipno,
            @n_CartonNo   = 0,
            @c_SSCC_LabelNo    = @cLabelNo   OUTPUT

            IF @cLabelNo <> ''
            BEGIN
               GOTO RollbackTran
            END
         END
      END

      --config = GenUCCLabelNoConfig
      IF @cLabelNo = ''
      BEGIN
         --SELECT 'GenUCCLabelNoConfig'

         EXECUTE nspGetRight null,
         @cStorerKey,       -- Storerkey
         '',               -- Sku
         'GenUCCLabelNoConfig',    -- Configkey
         @b_success      OUTPUT,
         @c_authority   OUTPUT,
         @n_err         OUTPUT,
         @c_errmsg      OUTPUT

         IF @c_authority = '1'
         BEGIN
            SET @c_Identifier = '00'
            SET @c_Packtype = '0'
            SET @cLabelNo = ''

            SELECT @c_VAT = ISNULL(Vat,'')
            FROM Storer WITH (NOLOCK)
            WHERE Storerkey = @cStorerKey


            SELECT @cOldUCCLabelNo = sValue 
            FROM dbo.StorerConfig WITH (NOLOCK) 
            WHERE StorerKey = @cStorerKey 
               AND configKey = 'TPS-OldUCCLabelNoCfg'  


            IF ISNULL(@c_VAT,'') = ''
               SET @c_VAT = '000000000'

            IF @cOldUCCLabelNo <>'1'
            BEGIN
               IF LEN(@c_VAT) <> 9
                  SET @c_VAT = RIGHT('000000000' + RTRIM(LTRIM(@c_VAT)), 9)

               --(Wan01) - Fixed if not numeric
               IF ISNUMERIC(@c_VAT) = 0
               BEGIN
                  SET @n_Err = 1001555
                  SET @c_errmsg = api.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Execution Error : Vat is not a numeric value. Function : isp_TPS_ExtGenLBL02'
                  SET @b_Success = 0
                  GOTO RollbackTran
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
            @n_err          = @n_err output,
            @c_errmsg       = @c_errmsg output,
            @b_resultset    = 0,
            @n_batch        = 1

            SET @cLabelNo = @c_Identifier + @c_Packtype + RTRIM(@c_VAT) + RTRIM(@c_nCounter) --+ @n_CheckDigit

            SET @n_Odd = 1
            SET @n_OddCnt = 0
            SET @n_TotalOddCnt = 0
            SET @n_TotalCnt = 0

            WHILE @n_Odd <= 20
            BEGIN
               IF ISNUMERIC(SUBSTRING(@cLabelNo, @n_Odd, 1)) = 1
               BEGIN
                  SET @n_OddCnt = CAST(SUBSTRING(@cLabelNo, @n_Odd, 1) AS INT)
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
               IF ISNUMERIC(SUBSTRING(@cLabelNo, @n_Even, 1)) = 1
               BEGIN
                  SET @n_EvenCntt = CAST(SUBSTRING(@cLabelNo, @n_Odd, 1) AS INT)
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

            SET @cLabelNo = ISNULL(RTRIM(@cLabelNo), '') + CAST(@n_CheckDigit AS NVARCHAR( 1))
         END   -- GenUCCLabelNoConfig
         ELSE
         BEGIN
            --SELECT 'PACKNO'
            EXECUTE nspg_GetKey
               'PACKNO',
               10 ,
               @cLabelNo  OUTPUT,
               @b_success  OUTPUT,
               @n_err      OUTPUT,
               @c_errmsg   OUTPUT
         END
      END
   END
   
   GOTO QUIT

   RollBackTran:
      ROLLBACK TRAN isp_TPS_ExtGenLBL02  
  
   Quit:  
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
         COMMIT TRAN isp_TPS_ExtGenLBL02  
      
END      
GO
  
SET QUOTED_IDENTIFIER OFF  

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_ExtGenLBL02 TO NSQL
GO


