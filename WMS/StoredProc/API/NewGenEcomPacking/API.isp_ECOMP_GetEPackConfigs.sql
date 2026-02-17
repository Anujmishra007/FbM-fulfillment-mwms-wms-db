
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

         , @b_sp_Success               INT
         , @n_sp_err                   INT
         , @c_sp_errmsg                NVARCHAR(250)  = ''

         , @c_sc_SValue                NVARCHAR(30)   = ''
         , @c_sc_Option1               NVARCHAR(50)   = ''
         , @c_SQLQuery                 NVARCHAR(4000) = ''
         , @c_SQLParams                NVARCHAR(1000) = ''

         , @c_EPACKCCTVLOCALLOGARCHIVETIME        NVARCHAR(3)  = ''
         , @c_EPACKCCTVLOCALLOGDELETETIME         NVARCHAR(3)  = ''


   DECLARE @t_EPACKConfig  AS Table (
         ConfigName        NVARCHAR(60)      NULL
      ,  [Value]           NVARCHAR(120)     NULL
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
