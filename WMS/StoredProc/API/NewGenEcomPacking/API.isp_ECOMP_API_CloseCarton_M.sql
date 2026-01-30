
/************************************************************************/              
/* Store procedure: [API].[isp_ECOMP_API_CloseCarton_M]                 */              
/* Creation Date: 13-FEB-2023                                           */
/* Copyright: Maersk                                                    */
/* Written by: AlexKeoh                                                 */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By: SCEAPI                                                    */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date            Author     Purposes                                  */
/* 14-Jul-2023     Alex       #JIRA PAC-7 Initial                       */
/* 07-Aug-2024     Alex01     #JIRA PAC-352 Bug fixes                   */
/* 10-Sep-2024     Alex02     #PAC-353 - Bundle Packing validation      */
/* 23-Jul-2025     Sean       #UWP-38247 - Compatible with Login User   */
/************************************************************************/    
CREATE OR ALTER PROC [API].[isp_ECOMP_API_CloseCarton_M](
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
         
         , @n_IsExists                    INT            = 0

         , @c_OrderMode                   NVARCHAR(1)    = ''

         , @c_PickSlipNo                  NVARCHAR(10)   = ''
         , @c_ComputerName                NVARCHAR(30)   = ''
         , @n_CartonNo                    INT            = 0
         , @c_TrackingNumber              NVARCHAR(40)   = ''
         , @c_CartonType                  NVARCHAR(10)   = ''
         , @f_Weight                      FLOAT          = 0
         , @b_IsLastCarton                INT            = 0

         , @f_Cube                        FLOAT
         , @f_CartonLength                FLOAT
         , @f_CartonWeight                FLOAT          = 0
         , @f_CartonWidth                 FLOAT
         , @f_CartonHeight                FLOAT 

         , @n_SumQty                      INT            = 0
         , @c_CartonGroup                 NVARCHAR(10)   = ''

         , @c_StorerKey                   NVARCHAR(15)   = ''
         , @c_Facility                    NVARCHAR(15)   = ''
         , @c_OrderKey                    NVARCHAR(10)   = ''

         , @c_TaskBatchNo                 NVARCHAR(10)   = ''
         , @c_Top1OrderKey                NVARCHAR(10)   = ''
         , @c_PHOrderKey                  NVARCHAR(10)   = ''

         , @n_NextCtnNo                   INT            = 0
         , @c_CurrCtnTrackingNo           NVARCHAR(40)   = ''
         , @c_NextCtnTrackingNo           NVARCHAR(40)   = ''

         , @b_sp_Success                  INT
         , @n_sp_err                      INT
         , @c_sp_errmsg                   NVARCHAR(250)  = ''

   DECLARE @c_LottableValue               NVARCHAR(60)   = ''

   DECLARE @c_AutoCartonType              NVARCHAR(10)   = ''
         , @c_AutoCartonGroup             NVARCHAR(10)   = ''
         , @f_AutoCartonWeight            INT            = 0
         , @b_AutoCloseCarton             INT            = 0

   DECLARE @c_MultiPackResponse           NVARCHAR(MAX)  = ''

   DECLARE @n_EPD_CartonNo                INT            = 0
         , @c_EPD_LabelNo                 NVARCHAR(20)   = ''
         , @c_LabelLine                   NVARCHAR(5)    = ''
         , @n_PackSerialNoKey             BIGINT         = 0

   DECLARE @t_CartonTypes AS TABLE (
      CartonizationKey  NVARCHAR(10)   NULL,
      CartonType        NVARCHAR(10)   NULL,
      [Cube]            FLOAT          NULL,
      MaxWeight         FLOAT          NULL,    --Alex01 Change datatype from int to float.
      MaxCount          INT            NULL,
      CartonWeight      FLOAT          NULL,
      CartonLength      FLOAT          NULL, 
      CartonWidth       FLOAT          NULL,
      CartonHeight      FLOAT          NULL,
      Alert             NVARCHAR(255)  NULL
   )

   SET @b_Success                         = 0
   SET @n_ErrNo                           = 0
   SET @c_ErrMsg                          = ''
   SET @c_ResponseString                  = ''
  

   -- UWP-38247 - Compatible with Login User S

   DECLARE @DBUserName NVARCHAR(100),
        @b_sp_ExecuteAs BIT

   EXEC [API].[isp_ECOMP_ValidateAndSetUser]
        @c_UserID      = @c_UserID,
        @c_DBUserName  = @DBUserName OUTPUT,
        @b_ExecuteAs   = @b_sp_ExecuteAs OUTPUT,
        @b_Success     = @b_sp_Success OUTPUT,
        @n_ErrNo       = @n_sp_err OUTPUT,
        @c_ErrMsg      = @c_sp_errmsg OUTPUT;

   IF @b_sp_Success = 0
   BEGIN
      SET @b_Success = 0      
      SET @n_ErrNo = @n_sp_err      
      SET @c_ErrMsg = @c_sp_errmsg     
      GOTO QUIT
   END

   IF @b_sp_ExecuteAs = 1 OR @DBUserName LIKE '%' + @c_UserID + '%'
   BEGIN
      EXECUTE AS LOGIN = @DBUserName
      SET @c_UserID = @DBUserName
   END

   -- UWP-38247 - Compatible with Login User E


   SELECT @c_PickSlipNo       = ISNULL(RTRIM(PickSlipNo     ), '')
         ,@c_ComputerName     = ISNULL(RTRIM(ComputerName   ), '')
         ,@n_CartonNo         = ISNULL(CartonNo              , 1)
         ,@c_TrackingNumber   = ISNULL(RTRIM(TrackingNumber ), '')
         ,@c_CartonType       = ISNULL(RTRIM(CartonType     ), '')
         ,@f_Weight           = ISNULL([Weight]              , 0)
         ,@b_IsLastCarton     = ISNULL([IsLastCarton]        , 0)
   FROM OPENJSON (@c_RequestString)
   WITH ( 
       PickSlipNo          NVARCHAR(10)      '$.PickSlipNo'
      ,ComputerName        NVARCHAR(30)      '$.ComputerName'  
      ,CartonNo            INT               '$.CartonNo'
      ,TrackingNumber      NVARCHAR(40)      '$.TrackingNumber'
      ,CartonType          NVARCHAR(10)      '$.CartonType'
      ,[Weight]            FLOAT             '$.Weight'
      ,[IsLastCarton]      INT               '$.IsLastCarton'
   )

   IF @b_Debug = 1
   BEGIN
     PRINT ' @c_PickSlipNo: ' + @c_PickSlipNo
     PRINT ' @c_ComputerName: ' + @c_ComputerName
     PRINT ' @n_CartonNo: ' + CONVERT(NVARCHAR(10), @n_CartonNo)
     PRINT ' @c_TrackingNumber: ' + @c_TrackingNumber
     PRINT ' @c_CartonType: ' + @c_CartonType
     PRINT ' @f_Weight: ' + CONVERT(NVARCHAR(15), @f_Weight)
     PRINT ' @b_IsLastCarton: ' + CONVERT(NVARCHAR(1), @b_IsLastCarton)
   END

   SELECT TOP 1 @n_IsExists = (1)
               ,@c_OrderMode = Left(UPPER(OrderMode),1) 
               ,@c_OrderKey = ISNULL(RTRIM(PT.Orderkey), '')
               ,@c_TaskBatchNo = ISNULL(RTRIM(PT.TaskBatchNo), '')
   FROM [dbo].[PackTask] PT WITH (NOLOCK) 
   WHERE EXISTS (SELECT 1 FROM [dbo].[PackHeader] PH WITH (NOLOCK)
      WHERE PH.PickSlipNo = @c_PickSlipNo
      AND PH.TaskBatchNo = PT.TaskBatchNo
      AND PH.OrderKey = PT.Orderkey 
      AND PH.OrderKey <> '' AND PH.OrderKey IS NOT NULL)

   SELECT @n_IsExists = (1)
         ,@c_TaskBatchNo = ISNULL(RTRIM(TaskBatchNo), '')
         ,@c_PHOrderKey = ISNULL(RTRIM(Orderkey), '')
         ,@c_StorerKey = ISNULL(RTRIM([StorerKey]  ), '')
   FROM [dbo].[PackHeader] WITH (NOLOCK)
   WHERE PickSlipNo = @c_PickSlipNo

   IF @n_IsExists <> 1 
   BEGIN   
     SET @n_Continue = 3 
     SET @n_ErrNo = 51660
     SET @c_ErrMsg = CONVERT(CHAR(5),@n_ErrNo) 
                   + '. Invalid PickSlipNo (' + @c_PickSlipNo + ').'
     GOTO QUIT
   END

   --Alex02 S
   SET @b_sp_Success = 0
   EXEC [API].[isp_ECOMP_BundlePackingValidation_Wrapper]
         @b_Debug          = @b_Debug
      ,  @c_PickSlipNo     = @c_PickSlipNo
      ,  @n_CartonNo       = @n_CartonNo
      ,  @c_OrderKey       = @c_PHOrderKey
      ,  @c_Storerkey      = @c_Storerkey
      ,  @c_SKU            = ''
      ,  @c_Type           = 'CLOSECARTON'
      ,  @b_Success        = @b_sp_Success   OUTPUT  
      ,  @n_Err            = @n_sp_err       OUTPUT  
      ,  @c_ErrMsg         = @c_sp_errmsg    OUTPUT  

   IF @b_sp_Success = 0
   BEGIN
      SET @n_Continue = 3 
      SET @n_ErrNo = 51665
      SET @c_ErrMsg = CONVERT(CHAR(5),@n_sp_err) + ' : ' + @c_sp_errmsg
   END
   --Alex02 E

   SELECT TOP 1 @n_IsExists = (1)
               ,@c_OrderMode = Left(UPPER(OrderMode),1) 
               ,@c_Top1OrderKey = ISNULL(RTRIM(Orderkey), '')
   FROM [dbo].[PackTask] PT WITH (NOLOCK) 
   WHERE TaskBatchNo = @c_TaskBatchNo
   AND OrderKey = CASE WHEN @c_OrderKey = '' THEN OrderKey ELSE @c_OrderKey END

   IF @c_OrderMode <> 'M'
   BEGIN   
     SET @n_Continue = 3 
     SET @n_ErrNo = 51661
     SET @c_ErrMsg = CONVERT(CHAR(5),@n_ErrNo) 
                   + '. Invalid OrderMode(' + @c_OrderMode + ').'
     GOTO QUIT
   END
   
   SELECT @c_Facility = ISNULL(RTRIM(Facility      ), '')
   FROM [dbo].[ORDERS] WITH (NOLOCK) 
   WHERE OrderKey = @c_Top1OrderKey

   SELECT @n_SumQty = SUM(Qty) 
   FROM dbo.PackDetail (NOLOCK) 
   WHERE PickSlipNo = @c_PickSlipNo 
   AND CartonNo = @n_CartonNo

   IF @c_CartonType <> ''
   BEGIN
      --SELECT @c_CartonGroup = CartonGroup 
      --FROM dbo.STORER WITH (NOLOCK) 
      --WHERE StorerKey = @c_StorerKey

      INSERT INTO @t_CartonTypes
      EXEC [API].[isp_ECOMP_GetPackCartonType]
           @c_Facility     = @c_Facility
         , @c_Storerkey    = @c_Storerkey
         , @c_CartonType   = @c_CartonType
         , @c_CartonGroup  = ''
         , @c_PickSlipNo   = @c_PickSlipNo
         , @n_CartonNo     = @n_CartonNo
         , @c_SourceApp    = 'SCE'

      --SELECT @f_Cube = [Cube]
      --      ,@f_CartonLength = CartonLength
      --      ,@f_CartonWeight = CartonWeight
      --      ,@f_CartonWidth = CartonWidth
      --      ,@f_CartonHeight = CartonHeight
      --FROM [dbo].[Cartonization] ctn WITH (NOLOCK)
      --WHERE CartonizationGroup = @c_CartonGroup
      --AND CartonType = @c_CartonType

      SELECT @f_Cube = [Cube]
            ,@f_CartonLength = CartonLength
            ,@f_CartonWeight = CartonWeight
            ,@f_CartonWidth = CartonWidth
            ,@f_CartonHeight = CartonHeight
      FROM @t_CartonTypes
   END

   IF NOT EXISTS ( SELECT 1 FROM [dbo].[PackInfo] WITH (NOLOCK) WHERE PickSlipNo = @c_PickSlipNo AND CartonNo = @n_CartonNo)
   BEGIN
      INSERT INTO [dbo].[PackInfo] (PickSlipNo, CartonNo, Qty, TrackingNo, CartonType, [Cube], [Length], [Weight], Width, Height)
      VALUES (@c_PickSlipNo, @n_CartonNo, @n_SumQty, @c_TrackingNumber, @c_CartonType, @f_Cube, @f_CartonLength, @f_Weight, @f_CartonWidth, @f_CartonHeight)
   END
   ELSE
   BEGIN
      UPDATE [dbo].[PackInfo] WITH (ROWLOCK)
      SET [Qty] = @n_SumQty
         --,[TrackingNo] = @c_TrackingNumber
         ,CartonType = @c_CartonType
         --,[Cube] = @f_Cube
         --,[Length] = @f_CartonLength
         ,[Weight] = @f_Weight
      WHERE PickSlipNo = @c_PickSlipNo 
      AND CartonNo = @n_CartonNo
   END

   --Get Current Carton Tracking Number / assign new tracking number
   EXEC [API].[isp_ECOMP_GetTrackingNumber]
            @b_Debug                   = @b_Debug
          , @c_PickSlipNo              = @c_PickSlipNo
          , @n_CartonNo                = @n_CartonNo
          , @b_Success                 = @b_sp_Success         OUTPUT
          , @n_ErrNo                   = @n_sp_err             OUTPUT
          , @c_ErrMsg                  = @c_sp_errmsg          OUTPUT
          , @c_TrackingNo              = @c_CurrCtnTrackingNo  OUTPUT

   IF @b_sp_Success <> 1
   BEGIN
      SET @n_Continue = 3 
      SET @n_ErrNo = 51662
      SET @c_ErrMsg = CONVERT(CHAR(5),@n_sp_err) + ' : ' + CONVERT(CHAR(5),@n_ErrNo)
                    + '. Failed to get tracking number - ' + @c_sp_errmsg
      GOTO QUIT
   END

   EXEC [API].[isp_ECOMP_GenLabelNo] 
           @b_Debug                    = @b_Debug
         , @c_PickSlipNo               = @c_PickSlipNo
         , @c_NewPickSlipNo            = ''
         , @b_PackConfirm              = 0
         , @b_Success                  = @b_sp_Success  OUTPUT
         , @n_ErrNo                    = @n_sp_err      OUTPUT
         , @c_ErrMsg                   = @c_sp_errmsg   OUTPUT

   IF @b_sp_Success <> 1
   BEGIN
      SET @n_Continue = 3 
      SET @n_ErrNo = 51663
      SET @c_ErrMsg = CONVERT(CHAR(5),@n_sp_err) + ' : ' + CONVERT(CHAR(5),@n_ErrNo)
                    + '. Failed to generate label no - ' + @c_sp_errmsg
      GOTO QUIT
   END

   IF @b_IsLastCarton <> 1
   BEGIN
      SET @n_NextCtnNo = @n_CartonNo + 1
      SET @c_NextCtnTrackingNo = ''

      --Get Tracking Number For Next Carton If ANY
      EXEC [API].[isp_ECOMP_GetTrackingNumber]
            @b_Debug                   = @b_Debug
          , @c_PickSlipNo              = @c_PickSlipNo
          , @n_CartonNo                = @n_NextCtnNo
          , @b_Success                 = @b_sp_Success         OUTPUT
          , @n_ErrNo                   = @n_sp_err             OUTPUT
          , @c_ErrMsg                  = @c_sp_errmsg          OUTPUT
          , @c_TrackingNo              = @c_NextCtnTrackingNo  OUTPUT

      IF @b_sp_Success <> 1
      BEGIN
         SET @n_Continue = 3 
         SET @n_ErrNo = 51664
         SET @c_ErrMsg = CONVERT(CHAR(5),@n_sp_err) + ' : ' + CONVERT(CHAR(5),@n_ErrNo)
                       + '. Failed to get tracking number - ' + @c_sp_errmsg
         GOTO QUIT
      END
   END
   ELSE
   BEGIN
      SET @c_NextCtnTrackingNo = @c_CurrCtnTrackingNo
   END

   EXEC [API].[isp_ECOMP_GetMultiPackTaskResponse] 
        @c_PickSlipNo            = @c_PickSlipNo  
      , @c_TaskBatchID           = @c_TaskBatchNo
      , @c_OrderKey              = @c_OrderKey    
      , @c_DropID                = ''
      , @b_SkipOrderOutput       = 0
      , @c_MultiPackResponse     = @c_MultiPackResponse OUTPUT

   IF @b_Debug = 1
   BEGIN
      PRINT '@c_PickSlipNo: ' + @c_PickSlipNo
      PRINT '@c_StorerKey: ' + @c_StorerKey
      PRINT '@c_Facility: ' + @c_Facility
      PRINT '@n_NextCtnNo: ' + CONVERT(NVARCHAR(2), @n_NextCtnNo)
      PRINT '@c_NextCtnTrackingNo: ' + @c_NextCtnTrackingNo
   END
   

   SET @c_ResponseString = ISNULL(( 
                              SELECT (
                                       JSON_QUERY(
                                          (SELECT @c_NextCtnTrackingNo   As 'TrackingNumber'
                                                --,@c_CartonType          As 'CartonType'
                                                --,@f_CartonWeight        As 'CartonWeight'
                                       FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
                                     ) As 'NewCartonInfo'
                                    ,(
                                       JSON_QUERY(@c_MultiPackResponse)
                                     ) AS 'MultiPackTask'
                              FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                           ), '')

   QUIT:

   IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'lsp_RevertUser' AND type = 'P') AND SESSION_CONTEXT(N'mwms_user_name') IS NOT NULL
   BEGIN
      EXEC [WM].[lsp_RevertUser]
   END

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
END -- Procedure  
