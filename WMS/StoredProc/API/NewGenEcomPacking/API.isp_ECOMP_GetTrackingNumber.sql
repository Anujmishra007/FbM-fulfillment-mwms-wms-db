
/************************************************************************/              
/* Store procedure: [API].[isp_ECOMP_GetTrackingNumber]                 */              
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
/* Date           Author   Purposes                                     */
/* 6-Jul-2023     Alex     #JIRA PAC-7 Initial                          */
/* 1-Apr-2024     Alex01   #JIRA PAC-328 Bug Fixes                      */
/* 10-Oct-2025    JWF011   #UWP-41761 - For EPACK CCTV Integration,     */
/*                         add rule for shipperkey JD                   */
/* 05-Dec-2025    Sean01   FCR-8269 - tracking no refresh in the UI     */
/* 06-Jan-2026    Sean02   FCR-8269 - fix duplicate get from            */
/*                                      transmitlog2 or ispAsgnTNo2     */
/* 12-Feb-2026    Sean03   FCR-8269 - fix not insert transmitlog2       */
/************************************************************************/    
CREATE OR ALTER PROC [API].[isp_ECOMP_GetTrackingNumber](
      @b_Debug                   INT            = 0
    , @c_PickSlipNo              NVARCHAR(10)   = ''
    , @c_OrderKey                NVARCHAR(10)   = ''
    , @n_CartonNo                INT            = 1
    , @b_CCTV_JD_Online          INT            = 0
    , @b_CCTVREFRESHTRACKNO      INT            = 0
    , @b_CloseCarton             INT            = 0
    , @b_FetchNextCarton         INT            = 0 -- Sean03
    , @b_Success                 INT            = 0   OUTPUT
    , @n_ErrNo                   INT            = 0   OUTPUT
    , @c_ErrMsg                  NVARCHAR(250)  = ''  OUTPUT
    , @c_TrackingNo              NVARCHAR(40)   = ''  OUTPUT
)

AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_DEFAULTS OFF 
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @n_Continue                    INT            = 1
         , @n_StartCnt                    INT            = @@TRANCOUNT
        
   DECLARE @c_SQLQuery                    NVARCHAR(MAX)  = ''
         , @c_SQLWhereClause              NVARCHAR(2000) = ''
         , @c_SQLParams                   NVARCHAR(2000) = ''

         , @c_PHOrderKey                  NVARCHAR(10)   = ''
         , @c_Facility                    NVARCHAR(15)   = ''
         , @c_StorerKey                   NVARCHAR(15)   = ''

         , @n_IsExists                    INT            = 0
         , @b_IsWhereClauseExists         INT            = 0

         , @c_ORDTrackingNo               NVARCHAR(40)   = ''
         , @c_CTNTrackNoSP                NVARCHAR(40)   = ''
         , @b_sp_Success                  INT            = 0
         , @n_sp_ErrNo                    INT            = 0
         , @c_sp_ErrMsg                   NVARCHAR(255)  = ''

         , @c_CurrentTrackingNo           NVARCHAR(40)   = ''
         , @c_FirstTrackingNo             NVARCHAR(40)   = ''


         , @c_ShipperKey                  NVARCHAR(15) = ''

   IF @b_Debug = 1
   BEGIN
      print 'gettrackingnumber - start - n_CartonNo: ' + CAST(@n_CartonNo AS NVARCHAR)
      print 'gettrackingnumber - start - b_CCTVREFRESHTRACKNO: ' + CAST(@b_CCTVREFRESHTRACKNO AS NVARCHAR)
   END

   SET @b_Success                         = 0
   SET @n_ErrNo                           = 0
   SET @c_ErrMsg                          = ''

   SET @n_IsExists = 0
   SET @b_IsWhereClauseExists = 0

   IF @c_PickSlipNo <> ''
   BEGIN
      SELECT @c_PHOrderKey = ISNULL(RTRIM(OrderKey), '')
      FROM [dbo].[PackHeader] WITH (NOLOCK)
      WHERE PickSlipNo = @c_PickSlipNo
   END
   ELSE IF @c_PickSlipNo = '' AND @c_OrderKey <> ''
   BEGIN
      SET @c_PHOrderKey = @c_OrderKey
   END

   IF @c_PHOrderKey  = '' GOTO QUIT

   SELECT @c_Facility = ISNULL(RTRIM(Facility), '')
         ,@c_StorerKey = ISNULL(RTRIM(StorerKey), '')
         ,@c_ShipperKey = ISNULL(RTRIM(ShipperKey), '')
   FROM [dbo].[ORDERS] WITH (NOLOCK) 
   WHERE OrderKey = @c_PHOrderKey

   EXEC [dbo].[nspGetRight]
         @c_Facility      = @c_Facility
      ,  @c_StorerKey     = @c_StorerKey
      ,  @c_sku           = ''
      ,  @c_ConfigKey     = 'EPACKCTNTrackNo_SP'
      ,  @b_Success       = @b_sp_Success          OUTPUT    
      ,  @c_authority     = @c_CTNTrackNoSP        OUTPUT  
      ,  @n_err           = @n_sp_ErrNo            OUTPUT  
      ,  @c_errmsg        = @c_sp_ErrMsg           OUTPUT
   
  SELECT 
      @c_ORDTrackingNo = CASE 
         WHEN EXISTS (
               SELECT 1 
               FROM [dbo].[StorerConfig] WITH (NOLOCK) 
               WHERE ConfigKey = 'EPACKGetTrackNoSkipUDF04' 
                  AND StorerKey = @c_StorerKey 
                  AND SValue = '1'
         ) 
         THEN ISNULL(RTRIM(TrackingNo), '') 
         ELSE 
               CASE 
                  WHEN ISNULL(RTRIM(TrackingNo), '') <> '' 
                  THEN TrackingNo 
                  ELSE ISNULL(RTRIM(UserDefine04), '') 
               END
      END
   FROM [dbo].[Orders] WITH (NOLOCK) 
   WHERE OrderKey = @c_PHOrderKey
   
   IF @n_CartonNo = 1 OR @c_CTNTrackNoSP = '' OR @c_CTNTrackNoSP = '0'
   BEGIN
      SET @c_TrackingNo = @c_ORDTrackingNo
      IF @b_CCTVREFRESHTRACKNO = 1 and @b_CloseCarton = 0 -- scan sku/scan lottable/scan qrf
      BEGIN
         GOTO QUIT
      END
   END
   ELSE IF @n_CartonNo >= 2
   BEGIN
      --UWP-41761 - JD Rule
      IF @b_CCTV_JD_Online = '1' AND @c_ShipperKey = 'JD'
      BEGIN
         IF @b_Debug = 1
            print 'gettrackingnumber - @b_CCTV_JD_Online = 1 AND @c_ShipperKey = JD '
         SET @c_TrackingNo = @c_ORDTrackingNo
         GOTO QUIT
      END
      --UWP-41761 - JD Rule (End)
      
      IF @b_CCTVREFRESHTRACKNO = 0
      BEGIN

         SELECT @c_FirstTrackingNo = ISNULL(RTRIM([TrackingNo]), '')
         FROM [dbo].[PackInfo] WITH (NOLOCK) 
         WHERE PickSlipNo = @c_PickSlipNo
         AND CartonNo = 1

         SELECT @n_IsExists = (1)
               ,@c_CurrentTrackingNo = ISNULL(RTRIM([TrackingNo]), '')
         FROM [dbo].[PackInfo] WITH (NOLOCK) 
         WHERE PickSlipNo = @c_PickSlipNo
         AND CartonNo = @n_CartonNo

         IF @b_Debug = 1
            print 'gettrackingnumber - b_CCTVREFRESHTRACKNO = 0 , @c_CurrentTrackingNo: ' + @c_CurrentTrackingNo

         IF @c_FirstTrackingNo <> @c_CurrentTrackingNo AND @c_CurrentTrackingNo <> ''
         BEGIN
            SET @c_TrackingNo = @c_CurrentTrackingNo
            IF @b_Debug = 1
               print 'gettrackingnumber - b_CCTVREFRESHTRACKNO = 0 , @c_FirstTrackingNo <> @c_CurrentTrackingNo QUIT '
            GOTO QUIT
         END

         IF @n_IsExists = 0
         BEGIN
            SET @c_TrackingNo = @c_ORDTrackingNo
            IF @b_Debug = 1
               print 'gettrackingnumber - b_CCTVREFRESHTRACKNO = 0 , PackInfo Not Exist QUIT '
            GOTO QUIT
         END

      END
      ELSE
      BEGIN -- @b_CCTVREFRESHTRACKNO = 1, @b_CloseCarton = 0, @b_FetchNextCarton = 0 only fetch from CATRONTRAK , not get from transmitlog2 or ispAsgnTNo2
         IF @b_CloseCarton = 0 AND @b_FetchNextCarton = 0
         BEGIN
            SET @c_TrackingNo = '#'
            SELECT TOP 1 @c_TrackingNo = CT.TrackingNo
               FROM CARTONTRACK CT (NOLOCK)
               WHERE CT.LabelNo = @c_PHOrderKey
               --AND CT.CarrierRef2 <> 'GET'
               AND CT.CarrierRef1 = @c_PHOrderKey + CAST(@n_CartonNo AS NVARCHAR)
            
            IF @@ROWCOUNT > 0
            Begin
               IF @b_Debug = 1
                  print 'gettrackingnumber - @b_CloseCarton = 0, @n_CartonNo >= 2  b_CCTVREFRESHTRACKNO = 1 - CARTONTRACK have value'
            END
            ELSE
            Begin
               IF @b_Debug = 1
                  print 'gettrackingnumber - @b_CloseCarton = 0, @n_CartonNo >= 2, b_CCTVREFRESHTRACKNO = 1 - CARTONTRACK have no value'
            END

            GOTO QUIT
         END
      END
   END
   --Assign Tracking Number (End)
   IF @b_Debug = 1
         print 'gettrackingnumber FetchTrackNo'
   FetchTrackNo:
   --Alex01 (Begin)
   IF (@c_PickSlipNo <> '' AND EXISTS ( SELECT 1 FROM [dbo].[PackInfo] WITH (NOLOCK) WHERE PickSlipNo = @c_PickSlipNo AND CartonNo = @n_CartonNo ))
      OR (@c_PickSlipNo <> '' and @b_CCTVREFRESHTRACKNO = 1  )
   BEGIN
      IF @b_Debug = 1
         print 'gettrackingnumber c_CTNTrackNoSP: ' + @c_CTNTrackNoSP
      BEGIN IF ISNULL(RTRIM(@c_CTNTrackNoSP), '') <> '' AND @c_CTNTrackNoSP <> '0'

         SET @c_SQLQuery = 'EXEC [dbo].[' + @c_CTNTrackNoSP + '] ' + CHAR(13) + 
                         + '      @c_PickSlipNo  = @c_PickSlipNo             ' + CHAR(13) +
                         + '   ,  @n_CartonNo    = @n_CartonNo               ' + CHAR(13) +
                         + '   ,  @c_CTNTrackNo  = @c_TrackingNo      OUTPUT ' + CHAR(13) +
                         + '   ,  @b_Success     = @b_sp_Success      OUTPUT ' + CHAR(13) +
                         + '   ,  @n_err         = @n_sp_ErrNo        OUTPUT ' + CHAR(13) +
                         + '   ,  @c_errmsg      = @c_sp_ErrMsg       OUTPUT ' + CHAR(13) 
   
         SET @c_SQLParams = '@c_PickSlipNo NVARCHAR(10)
                       ,@n_CartonNo INT
                       ,@c_TrackingNo NVARCHAR(40) OUTPUT
                       ,@b_sp_Success INT OUTPUT
                       ,@n_sp_ErrNo INT OUTPUT
                       ,@c_sp_ErrMsg NVARCHAR(255) OUTPUT';

         IF @b_CCTVREFRESHTRACKNO = 1
         BEGIN
            SET @c_SQLQuery = @c_SQLQuery +
                              '   ,  @b_CCTVREFRESHTRACKNO = @b_CCTVREFRESHTRACKNO ' + CHAR(13) +
                              '   ,  @b_CloseCarton = @b_CloseCarton ' + CHAR(13) +
                              '   ,  @b_FetchNextCarton = @b_FetchNextCarton ' + CHAR(13);
            SET @c_SQLParams = @c_SQLParams + ', @b_CCTVREFRESHTRACKNO INT' +
                                              ', @b_CloseCarton INT' +
                                              ', @b_FetchNextCarton INT'
         END
         
         BEGIN TRY
            IF @b_CCTVREFRESHTRACKNO = 1
            BEGIN
               EXECUTE sp_ExecuteSql 
                     @c_SQLQuery
                  ,@c_SQLParams
                  ,@c_PickSlipNo
                  ,@n_CartonNo
                  ,@c_TrackingNo           OUTPUT
                  ,@b_sp_Success           OUTPUT
                  ,@n_sp_ErrNo             OUTPUT
                  ,@c_sp_ErrMsg            OUTPUT
                  ,@b_CCTVREFRESHTRACKNO
                  ,@b_CloseCarton
                  ,@b_FetchNextCarton;
                  IF @b_Debug = 1
                     print 'gettrackingnumber - sp_ExecuteSql - b_CCTVREFRESHTRACKNO = 1'
            END
            ELSE
            BEGIN
               EXECUTE sp_ExecuteSql 
                     @c_SQLQuery
                  ,@c_SQLParams
                  ,@c_PickSlipNo
                  ,@n_CartonNo
                  ,@c_TrackingNo           OUTPUT
                  ,@b_sp_Success           OUTPUT
                  ,@n_sp_ErrNo             OUTPUT
                  ,@c_sp_ErrMsg            OUTPUT;
                  IF @b_Debug = 1
                     print 'gettrackingnumber - sp_ExecuteSql - b_CCTVREFRESHTRACKNO = 0'
            END
            IF @b_Debug = 1
               print 'gettrackingnumber - sp_ExecuteSql end'
            IF @b_sp_Success = 0
            BEGIN
               SET @n_Continue = 3 
               SET @n_ErrNo = 51301
               SET @c_ErrMsg = CONVERT(char(5),@n_ErrNo)+': ' 
                             + CONVERT(char(5),@n_sp_ErrNo) + ' - ' + @c_sp_ErrMsg     
               GOTO QUIT
            END
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3 
            SET @n_ErrNo = 51302
            SET @c_ErrMsg = ERROR_MESSAGE()
            GOTO QUIT
         END CATCH

         IF @b_Debug = 1
            print 'gettrackingnumber - ' + @c_CTNTrackNoSP  + ' c_TrackingNo: ' + @c_TrackingNo

         IF ISNULL(RTRIM(@c_TrackingNo), '') = '' AND @n_CartonNo > 1
         BEGIN
            IF @b_CCTVREFRESHTRACKNO = 1
            BEGIN
               SET @c_TrackingNo = '#'
            END
            ELSE
            BEGIN
               SET @c_TrackingNo = @c_ORDTrackingNo
            END
         END

         IF @b_Debug = 1
            PRINT 'gettrackingnumber - final - @c_TrackingNo=' + @c_TrackingNo
      END
   END
   --Alex01 (End)

   QUIT:
   IF @b_Debug = 1
      print 'gettrackingnumber - end'
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
