SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: msp_BEJ                                                 */
/* Creation Date: 2024-10-08                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:                                                             */
/*        :                                                             */
/* Called By: SQL JOB                                                   */
/*          :                                                           */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2024-10-08  Wan      1.0   Created.                                  */
/* 2025-05-09  Wan01    1.1   FCR-3958 - JCB Picking Task               */
/*                            Fix Error add default debug parameter at  */
/*                            Sub SP                                    */
/* 2025-07-25  AK01     1.2   FCR-6532 - Add support for time-based job */
/*                            scheduling using Notes2 config            */
/* 2026-06-10  VNI01    1.3   FCR-12991 - Time based scheduling update  */
/************************************************************************/
CREATE OR ALTER PROC msp_BEJ
   @c_jobname   NVARCHAR(30) = 'BEJ-STD-01'
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT            = @@TRANCOUNT
         , @n_Continue        INT            = 1
         , @c_ErrMsg          NVARCHAR(255)  = ''
 
         , @c_Code            NVARCHAR(30)   = ''
         , @c_Storerkey       NVARCHAR(15)   = ''
         , @c_Facility        NVARCHAR(30)   = ''
         , @c_StoredProc      NVARCHAR(100)  = ''
         , @c_OtherConfig     NVARCHAR(4000) = ''
         
         --AK01 START
         , @dt_LastRunDTime   NVARCHAR(30)   = ''
         , @c_JobSchedConfig  NVARCHAR(4000) = ''
         , @c_IntervalType    NVARCHAR(50)   = ''
         , @t_OccurAt         TIME           = ''
         --AK01 END
           --VNI01 START
         , @c_ExecutionHour   NVARCHAR(500)  = ''
         , @c_ExecutionMinute NVARCHAR(500)  = ''
         , @n_DailyFrequency  INT            = 0
         , @dt_NextRunSlot    DATETIME       = NULL
         , @n_ParsedSlotCnt   INT            = 0
         , @c_HourList        NVARCHAR(510)  = ''
         , @c_MinList         NVARCHAR(510)  = ''
         , @n_Pos             INT            = 0
         , @n_SlotIdx         INT            = 0
         , @c_HourItem        NVARCHAR(10)   = ''
         , @c_MinItem         NVARCHAR(10)   = ''
           --VNI01 END
         , @c_SQL             NVARCHAR(500)  = ''
         , @c_PName           NVARCHAR(30)   = '' 

         , @CUR_JOB           CURSOR
         , @CUR_PARMS         CURSOR

   IF OBJECT_ID('tempdb..#TMP_BEJCL','u') IS NOT NULL         
   BEGIN
      DROP TABLE #TMP_BEJCL;
   END
   --VNI01 START
   IF OBJECT_ID('tempdb..#TMP_BEJSCHED','u') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_BEJSCHED;
   END

   CREATE TABLE #TMP_BEJSCHED
   (  SlotIndex     INT          NOT NULL
   ,  ExecutionHour TINYINT      NULL
   ,  ExecutionMin  TINYINT      NULL
   ,  SlotDateTime  DATETIME     NULL
   )
   --VNI01 END
   --sp_help codelkup
   CREATE TABLE #TMP_BEJCL
   (  ListName    NVARCHAR(10)   NOT NULL    DEFAULT ('')
   ,  Code        NVARCHAR(30)   NOT NULL    DEFAULT ('')
   ,  Short       NVARCHAR(10)   NOT NULL    DEFAULT ('')
   ,  Long        NVARCHAR(250)  NOT NULL    DEFAULT ('')
   ,  UDF01       NVARCHAR(50)   NOT NULL    DEFAULT ('')
   ,  UDF02       NVARCHAR(50)   NOT NULL    DEFAULT ('')
   ,  UDF03       NVARCHAR(50)   NOT NULL    DEFAULT ('')
   ,  UDF04       NVARCHAR(50)   NOT NULL    DEFAULT ('')
   ,  UDF05       NVARCHAR(50)   NOT NULL    DEFAULT ('')
   ,  Storerkey   NVARCHAR(15)   NOT NULL    DEFAULT ('')
   ,  Code2       NVARCHAR(30)   NOT NULL    DEFAULT ('')
   ,  Notes       NVARCHAR(4000) NOT NULL    DEFAULT ('')
   ,  Notes2      NVARCHAR(4000) NOT NULL    DEFAULT ('')
   )
       
   INSERT INTO #TMP_BEJCL 
      (  ListName, Code, Storerkey, Code2
      ,  Short, Long, UDF01, UDF02, UDF03, UDF04, UDF05, Notes, Notes2)
   SELECT ListName, Code, Storerkey, Code2
         ,Short, Long
         ,UDF01 = IIF(ISNUMERIC(cl.UDF01)=0,'9',cl.UDF01) 
         ,UDF02
         ,UDF03 = IIF(ISNUMERIC(cl.UDF03)=0,60,cl.UDF03)
         --,UDF04 = CONVERT(NVARCHAR(25),IIF(ISDATE(cl.UDF04)=0,DATEADD(ss,-1*cl.UDF03,GETDATE()),cl.UDF04),121)
         ,UDF04 = CONVERT(NVARCHAR(25),IIF(ISDATE(cl.UDF04)=0, DATEADD(MONTH, -1 ,GETDATE()),cl.UDF04),121)       
         ,UDF05
         ,Notes = ISNULL(cl.Notes,''), Notes2 = ISNULL(cl.Notes2,'')
   FROM   CODELKUP cl WITH (NOLOCK)
   WHERE  cl.ListName = 'BEJ'
   AND    cl.Code     = @c_Jobname
   AND    cl.SHORT    = 'Y'
   AND    cl.Long NOT IN ('', NULL)
      
   SET @CUR_JOB = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT cl.code 
         ,StoredProc = ISNULL(cl.Long,'')
         ,cl.Storerkey
         ,cl.code2
         ,cl.Notes
         ,CONVERT(DATETIME, cl.UDF04)     --AK01
         ,ISNULL(RTRIM(cl.Notes2), '')    --AK01
   FROM   #TMP_BEJCL cl
   WHERE  cl.ListName = 'BEJ'
   AND    cl.Code     = @c_Jobname
   AND    cl.SHORT    = 'Y'
   AND    DATEDIFF(ss, CONVERT(DATETIME, cl.UDF04), GETDATE()) >= cl.UDF03
   ORDER BY DATEDIFF(ss, CONVERT(DATETIME, cl.UDF04), GETDATE())
         ,  cl.UDF01                --Priority
         ,  cl.UDF02                --JobStep
         ,  cl.UDF03                --Occur Every in second. Min = 10s 
      
   OPEN @CUR_JOB
   
   FETCH NEXT FROM @CUR_JOB INTO @c_Code, @c_StoredProc
                              ,  @c_Storerkey, @c_Facility
                              ,  @c_OtherConfig
                              ,  @dt_LastRunDTime                       --AK01   
                              ,  @c_JobSchedConfig                      --AK01                   
   WHILE @@FETCH_STATUS <> -1
   BEGIN 
      IF NOT EXISTS (SELECT 1 FROM sys.objects (NOLOCK) 
                     WHERE Object_ID(@c_StoredProc) = object_id 
                     AND [Type] = 'P')
      BEGIN
         GOTO NEXT_JOB
      END

      --AK01 START
      IF @c_JobSchedConfig <> ''
      BEGIN
         SET @c_IntervalType = dbo.fnc_GetParamValueFromString('@IntervalType', @c_JobSchedConfig, '')

         IF @c_IntervalType = 'SpecificTime'
         BEGIN
            SET @t_OccurAt = TRY_CAST(dbo.fnc_GetParamValueFromString('@OccurAt', @c_JobSchedConfig, '') AS TIME)
            IF @t_OccurAt IS NOT NULL
            BEGIN
               IF NOT (CONVERT(TIME, GETDATE()) >= @t_OccurAt
                  AND CAST(@dt_LastRunDTime AS DATE) < CAST(GETDATE() AS DATE))
               BEGIN
                  GOTO NEXT_JOB
               END
            END
         END
         ELSE IF @c_IntervalType = 'DailySchedule'    --VNI01 START
         BEGIN
            SET @c_ExecutionHour   = dbo.fnc_GetParamValueFromString('@ExecutionHour'  , @c_JobSchedConfig, '')
            SET @c_ExecutionMinute = dbo.fnc_GetParamValueFromString('@ExecutionMinute', @c_JobSchedConfig, '')
            SET @n_DailyFrequency  = ISNULL(TRY_CAST(dbo.fnc_GetParamValueFromString('@DailyFrequency', @c_JobSchedConfig, '1') AS INT), 1)

            TRUNCATE TABLE #TMP_BEJSCHED

            SET @c_HourList = ISNULL(@c_ExecutionHour  ,'') + ','
            SET @c_MinList  = ISNULL(@c_ExecutionMinute,'') + ','
            SET @n_SlotIdx  = 0

            WHILE CHARINDEX(',', @c_HourList) > 0 AND CHARINDEX(',', @c_MinList) > 0
            BEGIN
               SET @n_Pos      = CHARINDEX(',', @c_HourList)
               SET @c_HourItem = LTRIM(RTRIM(SUBSTRING(@c_HourList, 1, @n_Pos - 1)))
               SET @c_HourList = SUBSTRING(@c_HourList, @n_Pos + 1, LEN(@c_HourList))

               SET @n_Pos     = CHARINDEX(',', @c_MinList)
               SET @c_MinItem = LTRIM(RTRIM(SUBSTRING(@c_MinList, 1, @n_Pos - 1)))
               SET @c_MinList = SUBSTRING(@c_MinList, @n_Pos + 1, LEN(@c_MinList))

               IF ISNULL(@c_HourItem,'') = '' AND ISNULL(@c_MinItem,'') = ''
                  CONTINUE

               SET @n_SlotIdx = @n_SlotIdx + 1

               INSERT INTO #TMP_BEJSCHED (SlotIndex, ExecutionHour, ExecutionMin, SlotDateTime)
               SELECT @n_SlotIdx
                    , TRY_CAST(@c_HourItem AS TINYINT)
                    , TRY_CAST(@c_MinItem  AS TINYINT)
                    , CASE WHEN TRY_CAST(@c_HourItem AS INT) BETWEEN 0 AND 23
                            AND TRY_CAST(@c_MinItem  AS INT) BETWEEN 0 AND 59
                           THEN DATEADD(MINUTE, TRY_CAST(@c_MinItem AS INT)
                                , DATEADD(HOUR, TRY_CAST(@c_HourItem AS INT), CAST(CAST(GETDATE() AS DATE) AS DATETIME)))
                           ELSE NULL
                      END
            END

            SELECT @n_ParsedSlotCnt = COUNT(1) FROM #TMP_BEJSCHED WHERE SlotDateTime IS NOT NULL


            SELECT @dt_NextRunSlot = MAX(SlotDateTime)
            FROM #TMP_BEJSCHED
            WHERE SlotDateTime IS NOT NULL
              AND SlotDateTime <= GETDATE()

            IF @dt_NextRunSlot IS NULL OR @dt_NextRunSlot <= TRY_CAST(@dt_LastRunDTime AS DATETIME)
            BEGIN
               GOTO NEXT_JOB
            END
         END                                    --VNI01 END

         -- Future development notes:
         -- For @IntervalType=SpecificDay: Run if today matches one of the days listed in @Days (e.g., Mon,Wed,Fri).
         -- For @IntervalType=TimeRange, Run if current time is within @StartTime and @EndTime, and last run time (@UDF04) exceeds the defined interval (@UDF03).
      END
      --AK01 END

      BEGIN TRY
        --SET @c_SQL = 'EXEC '  + @c_StoredProc                                     --(Wan01) - START

        -- SET @CUR_PARMS = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
        -- SELECT PARAMETER_NAME   
        -- FROM [INFORMATION_SCHEMA].[PARAMETERS]     
        -- WHERE SPECIFIC_NAME = @c_StoredProc     
        -- ORDER BY ORDINAL_POSITION    
    
        -- OPEN @CUR_PARMS    
        -- FETCH NEXT FROM @CUR_PARMS INTO @c_PName 
        -- WHILE @@FETCH_STATUS <> -1    
        -- BEGIN 
        --    IF @c_SQL <> 'EXEC ' + @c_StoredProc 
        --    BEGIN
        --       SET @c_SQL = @c_SQL + ','
        --    END

        --    SET @c_SQL = @c_SQL + ' '      
        --               + CASE WHEN @c_PName IN ('@c_Facility', '@c_StorerKey', '@c_OtherConfig')   
        --                      THEN @c_PName + '=' + @c_PName    
        --                      END
        --    FETCH NEXT FROM @CUR_PARMS INTO @c_PName                              
        -- END
        -- CLOSE @CUR_PARMS
        -- DEALLOCATE @CUR_PARMS

         SELECT @c_SQL = STRING_AGG (p.PARAMETER_NAME  + '=' + p.PARAMETER_NAME,',')
         WITHIN GROUP (ORDER BY p.ORDINAL_POSITION ASC)
         FROM [INFORMATION_SCHEMA].[PARAMETERS] p  
         WHERE p.SPECIFIC_NAME = @c_StoredProc  
         AND p.PARAMETER_NAME IN ('@c_Facility', '@c_StorerKey', '@c_OtherConfig')

         IF @c_SQL IS NOT NULL
         BEGIN
            SET @c_SQL = 'EXEC '  + @c_StoredProc + ' ' + @c_SQL

            EXEC sp_ExecuteSQL @c_SQL
                              ,N'@c_Storerkey   NVARCHAR(15)
                              ,@c_Facility    NVARCHAR(30)
                              ,@c_OtherConfig NVARCHAR(4000)'
                              ,@c_Storerkey
                              ,@c_Facility
                              ,@c_OtherConfig  
         END                                                                        --(Wan01) - END                
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @c_ErrMsg = 'JOB Name: '  + @c_Code
                       +', Storerkey: ' + @c_Storerkey
                       +', Facility: '  + @c_Facility
                       + ' <<' + ERROR_MESSAGE() + '>>'
      END CATCH

      IF (XACT_STATE()) = -1  
      BEGIN
         SET @n_Continue = 3 
         ROLLBACK TRAN
      END  

      UPDATE Codelkup WITH (ROWLOCK)
      SET UDF04 = CONVERT(NVARCHAR(30), getdate(), 121)
         ,Trafficcop = NULL
      WHERE ListName = 'BEJ'
      AND   Code     = @c_jobname
      AND   Storerkey= @c_Storerkey
      AND   Code2    = @c_Facility
 
      NEXT_JOB:
      FETCH NEXT FROM @CUR_JOB INTO @c_Code, @c_StoredProc
                                 ,  @c_Storerkey, @c_Facility
                                 ,  @c_OtherConfig
                                 ,  @dt_LastRunDTime                       --AK01 
                                 ,  @c_JobSchedConfig                      --AK01   
   END
   CLOSE @CUR_JOB
   DEALLOCATE @CUR_JOB  

QUIT_SP:
   IF @n_Continue = 3
   BEGIN
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR
   END
END
GO

GRANT EXECUTE ON dbo.msp_BEJ TO NSQL
GO
