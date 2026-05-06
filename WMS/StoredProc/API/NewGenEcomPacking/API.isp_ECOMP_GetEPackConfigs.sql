
/************************************************************************/              
/* Store procedure: [API].[isp_ECOMP_GetEPackConfigs]                   */              
/* Creation Date: 10-Oct-2024                                           */
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
/* Date           Author   Purposes	                                    */
/* 10-Oct-2024    Alex     #JIRA PAC-355 Initial                        */
/* 09-Jun-2025    JWF011   #UWP-34792 - Update datatype length          */
/*                         of @c_EPACKCCTVWMLOC                         */
/* 31-July-2025   JWF011   #UWP-38657 - Update datatype length          */
/*                         of EPACKCCTVOFFSETSEC                        */
/* 19-Aug-2025    JWF011   #UWP-39631 UWP-39649 - Add EPACKCCTVORDERNO  */
/* 20-Aug-2025    JWF011   #UWP-39059 - Add configs for CCTV logs       */
/* 28-Aug-2025    JWF011   #UWP-40141 - Update EPACKCCTVORDERNO         */
/* 15-Sep-2025    JWF011   #UWP-41185 - Update EPACKCCTVORDERNO         */
/* 25-Sep-2025    JWF011   #UWP-41771 - Add configs for TrackNo         */
/* 07-Jan-2026    JWF011   #FCR-10065 - Add CCTV API02 UDF Config       */
/* 24-Feb-2026    JWF011   #FCR-10065 - Fix CCTV API02 UDF Config       */
/************************************************************************/
CREATE OR ALTER PROC [API].[isp_ECOMP_GetEPackConfigs](
     @c_StorerKey                      NVARCHAR(15)   = ''
   , @c_Facility                       NVARCHAR(15)   = ''
   , @c_UserId                         NVARCHAR(128)  = ''
   , @c_ComputerName                   NVARCHAR(30)   = ''
   , @c_PackMode                       NVARCHAR(1)    = ''
   , @c_TaskBatchID                    NVARCHAR(10)   = ''
   , @c_OrderKey                       NVARCHAR(10)   = ''
   , @c_DropID                         NVARCHAR(20)   = '' 
   , @c_SKU                            NVARCHAR(500)  = ''
   , @c_EPACKConfigJSON                NVARCHAR(4000) = ''  OUTPUT
)
AS
BEGIN 
   SET NOCOUNT ON
   SET ANSI_DEFAULTS OFF 
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue                 INT            = 1
         , @n_StartCnt                 INT            = @@TRANCOUNT

   DECLARE @c_EPACKCCTV_IsEnabled      NVARCHAR(1)    = ''
         
         , @c_EPACKCCTVRECORDTYPE      NVARCHAR(10)   = ''
         
         , @c_EPACKCCTVOFFSETSEC1      NVARCHAR(3)    = ''
         , @c_EPACKCCTVWMTYPE          NVARCHAR(1)    = ''
         , @c_EPACKCCTVWMLOC           NVARCHAR(2)    = ''
         , @c_EPACKCCTVOFFSETSEC2      NVARCHAR(3)    = ''
         , @c_EPACKCCTVEXSCAN          NVARCHAR(1)    = ''
         , @c_EPACKCCTVWM_CTNNO        NVARCHAR(1)    = ''
         , @c_EPACKCCTVWM_SKU          NVARCHAR(1)    = ''
         , @c_EPACKCCTVWM_SN           NVARCHAR(1)    = ''
         , @c_EPACKCCTVWM_TRACKNO      NVARCHAR(1)    = ''
         , @c_EPACKCCTVORDERNO         NVARCHAR(100)  = ''

         , @c_CCTVREFRESHTRACKNO       NVARCHAR(1)  = ''
         , @c_CCTVJDONLINE             NVARCHAR(1)  = ''

         , @b_sp_Success               INT
         , @n_sp_err                   INT
         , @c_sp_errmsg                NVARCHAR(250)  = ''

         , @c_sc_SValue                NVARCHAR(30)   = ''
         , @c_sc_Option1               NVARCHAR(50)   = ''
         , @c_SQLQuery                 NVARCHAR(4000) = ''
         , @c_SQLParams                NVARCHAR(1000) = ''

         , @c_EPACKCCTVLOCALLOGARCHIVETIME        NVARCHAR(3)  = ''
         , @c_EPACKCCTVLOCALLOGDELETETIME         NVARCHAR(3)  = ''

         , @c_CCTV_API02_UDF01            NVARCHAR(100) = ''
         , @c_CCTV_API02_UDF02            NVARCHAR(100) = ''
         , @c_CCTV_API02_UDF03            NVARCHAR(100) = ''
         , @c_CCTV_API02_UDF04            NVARCHAR(100) = ''
         , @c_CCTV_API02_UDF_Code         NVARCHAR(5) = ''
         , @c_CCTV_API02_UDF_Table        NVARCHAR(60)  = ''
         , @c_CCTV_API02_UDF_Column       NVARCHAR(60)  = ''
         , @c_CCTV_API02_UDF_Value        NVARCHAR(100)  = ''

   DECLARE @t_EPACKConfig  AS Table (
         ConfigName        NVARCHAR(60)      NULL
      ,  [Value]           NVARCHAR(120)     NULL
   )

   DECLARE @CCTV_API02_UDFConfig TABLE (
         Code           NVARCHAR(5)
      ,  UDF_Table      NVARCHAR(60)
      ,  UDF_Column     NVARCHAR(60)
   )

   --EPACK CCTV Config - Begin
   SET @c_EPACKCCTV_IsEnabled = [API].[fnc_ECOMP_IsCCTVEnabled] ( @c_StorerKey, @c_Facility, @c_ComputerName, @c_UserId ) 

   INSERT INTO @t_EPACKConfig (ConfigName, [Value]) VALUES ('EPACKCCTV_IsEnabled', @c_EPACKCCTV_IsEnabled)

   IF @c_EPACKCCTV_IsEnabled = '1'
   BEGIN
      SET @c_EPACKCCTVWMTYPE     = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'EPACKCCTVWMTYPE')
      SET @c_EPACKCCTVWMLOC      = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'EPACKCCTVWMLOC')
      SET @c_EPACKCCTVOFFSETSEC1 = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'EPACKCCTVOFFSETSEC1')
      SET @c_EPACKCCTVOFFSETSEC2 = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'EPACKCCTVOFFSETSEC2')
      SET @c_EPACKCCTVLOCALLOGARCHIVETIME = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'EPACKCCTVLOCALLOGARCHIVETIME')
      SET @c_EPACKCCTVLOCALLOGDELETETIME = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'EPACKCCTVLOCALLOGDELETETIME')
      SET @c_CCTVREFRESHTRACKNO = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'CCTV_Refresh_TrackNo')
      SET @c_CCTVJDONLINE = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'CCTV_JD_Online')

      SET @c_EPACKCCTVWM_CTNNO = CASE 
                                    WHEN EXISTS ( SELECT 1 FROM [dbo].[Codelkup] WITH (NOLOCK) 
                                                  WHERE ListName = 'CCTVWM' 
                                                  AND Code = 'boxno' 
                                                  AND StorerKey = @c_StorerKey ) THEN '1' 
                                    ELSE '0' 
                                 END

      SET @c_EPACKCCTVWM_SKU = CASE 
                                  WHEN EXISTS ( SELECT 1 FROM [dbo].[Codelkup] WITH (NOLOCK) 
                                                WHERE ListName = 'CCTVWM' 
                                                AND Code = 'skuno' 
                                                AND StorerKey = @c_StorerKey ) THEN '1' 
                                  ELSE '0' 
                               END

      SET @c_EPACKCCTVWM_SN = CASE 
                                 WHEN EXISTS ( SELECT 1 FROM [dbo].[Codelkup] WITH (NOLOCK) 
                                               WHERE ListName = 'CCTVWM' 
                                               AND Code = 'sn' 
                                               AND StorerKey = @c_StorerKey ) THEN '1' 
                                 ELSE '0' 
                              END

      SET @c_EPACKCCTVWM_TRACKNO = CASE 
                                      WHEN EXISTS ( SELECT 1 FROM [dbo].[Codelkup] WITH (NOLOCK) 
                                                    WHERE ListName = 'CCTVWM' 
                                                    AND Code = 'waybillNo' 
                                                    AND StorerKey = @c_StorerKey ) THEN '1' 
                                      ELSE '0' 
                                   END

      -- EPACKCCTVORDERNO Start
      SET @c_EPACKCCTVORDERNO = ''
      IF @c_OrderKey <> ''
      BEGIN
         EXEC [dbo].[nspGetRight]
            @c_Facility          = ''
         ,  @c_StorerKey         = @c_StorerKey
         ,  @c_sku               = ''
         ,  @c_ConfigKey         = 'EPACKCCTVORDERNO'
         ,  @b_Success           = @b_sp_Success          OUTPUT   
         ,  @c_authority         = @c_sc_SValue           OUTPUT
         ,  @n_err               = @n_sp_err              OUTPUT    
         ,  @c_errmsg            = @c_sp_errmsg           OUTPUT  
         ,  @c_Option1           = @c_sc_Option1          OUTPUT

         IF @c_sc_SValue IS NOT NULL AND RTRIM(@c_sc_SValue) = '1'
         BEGIN
            SET @c_sc_Option1 = ISNULL(RTRIM(@c_sc_Option1), '')

            SET @c_SQLQuery = 'SELECT '
                        + '  @c_EPACKCCTVORDERNO = ' + CASE WHEN @c_sc_Option1 <> '' AND @c_sc_Option1 LIKE 'ORDERS.%' THEN @c_sc_Option1 ELSE ''''' ' END 
                        + ' FROM [dbo].[ORDERS] WITH (NOLOCK) '
                        + 'WHERE OrderKey = @c_OrderKey '
            
            SET @c_SQLParams = '@c_OrderKey NVARCHAR(10), '
                              + '@c_EPACKCCTVORDERNO NVARCHAR(100) OUTPUT '

            EXEC sp_executesql @c_SQLQuery, @c_SQLParams, @c_OrderKey, @c_EPACKCCTVORDERNO OUTPUT
         END
      END
      -- EPACKCCTVORDERNO End

      -- FCR-10065 CCTV API02 UDF
      IF @c_SKU <> ''
      BEGIN
         INSERT INTO @CCTV_API02_UDFConfig (Code, UDF_Table, UDF_Column)
         SELECT Code, ISNULL([UDF02], ''), ISNULL([UDF03], '')
         FROM [dbo].[Codelkup] WITH (NOLOCK) 
         WHERE ListName = 'CCTVAPI02' 
            AND Code IN ('UDF01', 'UDF02', 'UDF03', 'UDF04')
            AND StorerKey = @c_StorerKey
            AND UDF01 = @c_Facility
            AND Short = '1'

         DECLARE UDF_CURSOR CURSOR FOR
            SELECT Code, UDF_Table, UDF_Column FROM @CCTV_API02_UDFConfig
         
         OPEN UDF_CURSOR
         FETCH NEXT FROM UDF_CURSOR INTO @c_CCTV_API02_UDF_Code, @c_CCTV_API02_UDF_Table, @c_CCTV_API02_UDF_Column
         WHILE @@FETCH_STATUS = 0
         BEGIN
            IF @c_CCTV_API02_UDF_Table <> '' AND @c_CCTV_API02_UDF_Column <> ''
            BEGIN
               IF @c_CCTV_API02_UDF_Table = 'SKU'
               BEGIN
                  SET @c_SQLQuery = 'SELECT '
                              + '  @c_CCTV_API02_UDF_Value = ' + @c_CCTV_API02_UDF_Column
                              + ' FROM [dbo].[SKU] WITH (NOLOCK) '
                              + 'WHERE SKU = @c_SKU '
                              + 'AND StorerKey = @c_StorerKey '

                  SET @c_SQLParams = '@c_SKU NVARCHAR(500), '
                                    + '@c_StorerKey NVARCHAR(15), '
                                    + '@c_CCTV_API02_UDF_Value NVARCHAR(100) OUTPUT '

                  EXEC sp_executesql @c_SQLQuery, @c_SQLParams, @c_SKU, @c_StorerKey, @c_CCTV_API02_UDF_Value OUTPUT
               END
               ELSE IF @c_CCTV_API02_UDF_Table = 'ORDERS'
               BEGIN
                  SET @c_SQLQuery = 'SELECT '
                              + '  @c_CCTV_API02_UDF_Value = ' + @c_CCTV_API02_UDF_Column
                              + ' FROM [dbo].[ORDERS] WITH (NOLOCK) '
                              + 'WHERE OrderKey = @c_OrderKey '

                  SET @c_SQLParams = '@c_OrderKey NVARCHAR(10), '
                                    + '@c_CCTV_API02_UDF_Value NVARCHAR(100) OUTPUT '

                  EXEC sp_executesql @c_SQLQuery, @c_SQLParams, @c_OrderKey, @c_CCTV_API02_UDF_Value OUTPUT
               END

               IF @c_CCTV_API02_UDF_Code = 'UDF01'
                  SET @c_CCTV_API02_UDF01 = ISNULL(@c_CCTV_API02_UDF_Value, '')
               ELSE IF @c_CCTV_API02_UDF_Code = 'UDF02'
                  SET @c_CCTV_API02_UDF02 = ISNULL(@c_CCTV_API02_UDF_Value, '')
               ELSE IF @c_CCTV_API02_UDF_Code = 'UDF03'
                  SET @c_CCTV_API02_UDF03 = ISNULL(@c_CCTV_API02_UDF_Value, '')
               ELSE IF @c_CCTV_API02_UDF_Code = 'UDF04'
                  SET @c_CCTV_API02_UDF04 = ISNULL(@c_CCTV_API02_UDF_Value, '')

            END
            FETCH NEXT FROM UDF_CURSOR INTO @c_CCTV_API02_UDF_Code, @c_CCTV_API02_UDF_Table, @c_CCTV_API02_UDF_Column
         END

         CLOSE UDF_CURSOR
         DEALLOCATE UDF_CURSOR
      END
      -- FCR-10065 CCTV API02 UDF (End)

      INSERT INTO @t_EPACKConfig (ConfigName, [Value]) 
      SELECT 'EPACKCCTVWMTYPE'     , @c_EPACKCCTVWMTYPE    
      UNION ALL 
      SELECT 'EPACKCCTVWMLOC'      , @c_EPACKCCTVWMLOC     
      UNION ALL 
      SELECT 'EPACKCCTVOFFSETSEC1' , @c_EPACKCCTVOFFSETSEC1
      UNION ALL 
      SELECT 'EPACKCCTVOFFSETSEC2' , @c_EPACKCCTVOFFSETSEC2
      UNION ALL 
      SELECT 'EPACKCCTVWM_CTNNO'   , @c_EPACKCCTVWM_CTNNO  
      UNION ALL 
      SELECT 'EPACKCCTVWM_SKU'     , @c_EPACKCCTVWM_SKU    
      UNION ALL 
      SELECT 'EPACKCCTVWM_SN'      , @c_EPACKCCTVWM_SN     
      UNION ALL 
      SELECT 'EPACKCCTVWM_TRACKNO' , @c_EPACKCCTVWM_TRACKNO
      UNION ALL 
      SELECT 'EPACKCCTVORDERNO'    , @c_EPACKCCTVORDERNO
      UNION ALL 
      SELECT 'EPACKCCTVLOCALLOGARCHIVETIME'    , @c_EPACKCCTVLOCALLOGARCHIVETIME
      UNION ALL 
      SELECT 'EPACKCCTVLOCALLOGDELETETIME'    , @c_EPACKCCTVLOCALLOGDELETETIME
      UNION ALL
      SELECT 'CCTV_Refresh_TrackNo', @c_CCTVREFRESHTRACKNO
      UNION ALL
      SELECT 'CCTV_JD_Online'      , @c_CCTVJDONLINE
      UNION ALL 
      SELECT 'CCTV_API02_UDF01'    , @c_CCTV_API02_UDF01
      UNION ALL 
      SELECT 'CCTV_API02_UDF02'    , @c_CCTV_API02_UDF02
      UNION ALL 
      SELECT 'CCTV_API02_UDF03'    , @c_CCTV_API02_UDF03
      UNION ALL
      SELECT 'CCTV_API02_UDF04'    , @c_CCTV_API02_UDF04

      IF @c_PackMode = 'M'
      BEGIN
         SET @c_EPACKCCTVRECORDTYPE = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'EPACKCCTVRECORDTYPE')

         INSERT INTO @t_EPACKConfig (ConfigName, [Value]) VALUES ('EPACKCCTVRECORDTYPE', IIF(ISNULL(RTRIM(@c_EPACKCCTVRECORDTYPE), '') = '', '0', @c_EPACKCCTVRECORDTYPE))

         SET @c_EPACKCCTVEXSCAN = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'EPACKCCTVEXSCAN')

         INSERT INTO @t_EPACKConfig (ConfigName, [Value]) VALUES ('EPACKCCTVEXSCAN', IIF(ISNULL(RTRIM(@c_EPACKCCTVEXSCAN), '') = '', '0', @c_EPACKCCTVEXSCAN))
      END
   END
   --EPACK CCTV Config - End

   SET @c_EPACKConfigJSON = ISNULL((
                               SELECT 
                                  ConfigName, [Value]
                               FROM @t_EPACKConfig
                               FOR JSON PATH
                             ), '[]')
   QUIT:
   IF @n_Continue= 3  -- Error Occured - Process And Return      
   BEGIN
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
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN 
         COMMIT TRAN      
      END
      RETURN
   END
END -- Procedure  
