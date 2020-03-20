IF EXISTS ( SELECT 1 FROM sys.objects WHERE OBJECT_ID = 
      OBJECT_ID(N'[dbo].[nsp_BackEndValidateMBOL]') AND type in ('P', 'PC') )
   DROP PROCEDURE [dbo].[nsp_BackEndValidateMBOL]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO       
 
/************************************************************************/
/* Stored Procedure: nsp_BackEndValidateMBOL                            */
/* Purpose: Update PickDetail to Status 9 from backend                  */
/* Called By: SQL Schedule Job    BEJ - Backend ValidateMBOL (ALL)      */
/* Updates:                                                             */
/* Date         Author       Purposes                                   */
/* 21-Sep-2017  SHONG        Only Ship MBOL when Container.Status = 9   */
/* 2017-11-13  KHLim         Add param to exclude storer if needed(KH01)*/
/* 2018-07-18  TLTING        Performance tune                           */
/* 2018-11-12  TLTING        Performance tune                           */
/* 2018-11-13  KHLim         Performance tune                           */
/************************************************************************/

CREATE  PROCEDURE [dbo].[nsp_BackEndValidateMBOL]
     @c_StorerKey NVARCHAR(15) = '%'
     ,@b_debug    INT = 0
     ,@nMinuteToSkip INT = 30 
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue        INT = 1,
           @n_cnt             INT = 0,
           @n_err             INT = 0,
           @c_ErrMsg          NvarCHAR (255) = '',
           @n_RowCnt          INT = 0,
           @b_success         INT = 0,
           @b_ReturnCode      INT = 0,
           @b_ReturnErr       INT = 0,
           @c_ReturnErrMsg    NVARCHAR (255) = '',
           @c_MBOLKey         NVARCHAR(10) = '',
           @f_status          INT = '',
           @n_StartTran       INT = 0,
           @c_ContainerStatus NVARCHAR(10) = '0',
           @c_ValidatedFlag   NCHAR(1) = 'N',
           @d_EditDate        DATETIME 
           


   SET @n_StartTran = @@TRANCOUNT
   SET @n_continue=1
   SET @c_MBOLKey  = ''

   --CREATE TABLE #HoldMBOL
   --( rowref INT NOT NULL IDENTITY(1,1) PRIMARY KEY ,
   --   MBOLKEY NVARCHAR(10))

   IF ISNULL(RTRIM(@c_StorerKey), '') = ''
      SET @c_StorerKey = '%'


   --IF EXISTS  ( SELECT 1
   --      FROM dbo.Mbol (NOLOCK)
   --      WHERE Mbol.status = '5'
   --      AND Mbol.ValidatedFlag = 'E' AND Mbol.EditDate > dateadd (MINUTE, -20, GETDATE() ) )
   --BEGIN
   --   INSERT INTO #HoldMBOL ( MBOLKEY)
   --   SELECT Mbol.Mbolkey
   --      FROM dbo.Mbol (NOLOCK)
   --      WHERE Mbol.status = '5'
   --      AND Mbol.ValidatedFlag = 'E'
   --      AND Mbol.EditDate > dateadd (MINUTE, -20, GETDATE() )
   --END

   IF @c_StorerKey = '%'
   BEGIN
      DECLARE CUR1 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT Mbol.MbolKey, ISNULL(Mbol.ValidatedFlag, 'N'), Mbol.EditDate  
      FROM dbo.Mbol Mbol (NOLOCK)
      JOIN dbo.MBOLDETAIL MD (NOLOCK) ON MD.MbolKey = MBOL.MbolKey
      JOIN dbo.Orders O (NOLOCK) ON o.OrderKey = MD.OrderKey
      WHERE Mbol.status = '5' 
      AND EXISTS ( Select 1 from   dbo.PALLET P (NOLOCK) WHERE P.PalletKey = Mbol.ExternMbolKey AND P.Status = '9'  )
      AND NOT EXISTS ( SELECT 1 FROM Codelkup C (NOLOCK)
               WHERE C.LISTNAME  = 'VALISTORER'
                        AND C.Code = O.StorerKey ) -- KH01
      AND EXISTS ( SELECT 1 
                   FROM CONTAINER C WITH (NOLOCK)            
                   JOIN dbo.ContainerDetail CD WITH (NOLOCK) ON C.ContainerKey = CD.ContainerKey                                     
                   WHERE CD.PalletKey = Mbol.ExternMbolKey            
                   AND C.ContainerType = 'ECOM' AND C.[Status] = '9')          
                        
      ORDER BY Mbol.editdate, Mbol.MbolKey
   END
   ELSE
   BEGIN
      DECLARE CUR1 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT  DISTINCT Mbol.MbolKey, ISNULL(Mbol.ValidatedFlag, 'N'), Mbol.EditDate 
      FROM dbo.Mbol (NOLOCK)
      JOIN dbo.MBOLDETAIL MD (NOLOCK) ON MD.MbolKey = MBOL.MbolKey
      JOIN dbo.Orders O (NOLOCK) ON o.OrderKey = MD.OrderKey
      WHERE Mbol.status = '5' 
      and exists ( Select 1 from   dbo.PALLET P (NOLOCK) WHERE P.PalletKey = Mbol.ExternMbolKey AND P.Status = '9'  )
      AND O.StorerKey = @c_StorerKey
      AND EXISTS ( SELECT 1 
                   FROM CONTAINER C WITH (NOLOCK)            
                   JOIN dbo.ContainerDetail CD WITH (NOLOCK) ON C.ContainerKey = CD.ContainerKey                                     
                   WHERE CD.PalletKey = Mbol.ExternMbolKey            
                   AND C.ContainerType = 'ECOM' AND C.[Status] = '9')          
      ORDER BY Mbol.editdate, Mbol.MbolKey
   END

   OPEN CUR1
   FETCH NEXT FROM CUR1 INTO @c_MBOLKey, @c_ValidatedFlag, @d_EditDate

   SELECT @f_status = @@FETCH_STATUS
   WHILE @f_status <> -1
   BEGIN
      SELECT @n_continue =1
      IF @b_debug = 1
      BEGIN
      	PRINT '' 
         PRINT 'MBOLKey - ' + @c_MBOLKey + 
               ' ValidatedFlag - ' + @c_ValidatedFlag +
               ' EditDate - ' + CONVERT(VARCHAR(20), @d_EditDate, 120)
      END

      IF @c_ValidatedFlag = 'E' AND @d_EditDate > DATEADD (MINUTE, (@nMinuteToSkip * -1), GETDATE() ) 
      BEGIN
         IF @b_debug = 1
         BEGIN
            PRINT 'ValidatedFlag - E AND EditDate = ' + CONVERT(VARCHAR(20), @d_EditDate, 120)
         END   	
         GOTO FETXH_NEXT  
      END
      
      IF @c_ValidatedFlag = 'Y'
      BEGIN
       SET @b_ReturnCode = 0
      END
      ELSE
      BEGIN
         --INSERT INTO TraceInfo (TraceName, TimeIn, Step1, Step2, Step3,
         --                     Step4, Step5)
         --VALUES( 'nsp_BackEndValidateMBOL', GETDATE(), @c_MBOLKey, @c_StorerKey, '', '', '')

         EXEC isp_ValidateMBOL
         @c_MBOLKey    = @c_MBOLKey,
         @b_ReturnCode = @b_ReturnCode OUTPUT, -- 0 = OK, -1 = Error, 1 = Warning
         @n_err        = @b_ReturnErr    OUTPUT,
         @c_errmsg     = @c_ReturnErrMsg OUTPUT,
         @n_CBOLKey    = 0

         IF @b_debug = 1
         BEGIN
            PRINT 'Validate Mbol Return Code - ' + CAST(@b_ReturnCode AS VARCHAR )
            PRINT 'Validate MBOL Return msg - ' + @c_ReturnErrMsg
         END

         --INSERT INTO TraceInfo (TraceName, TimeIn, Step1, Step2, Step3,
         --                     Step4, Step5)
         --VALUES( 'nsp_BackEndValidateMBOL', GETDATE(), @c_MBOLKey, CAST(@b_ReturnCode AS VARCHAR ),
         --CAST(@n_err AS VARCHAR ), @c_ReturnErrMsg, '')


         IF @b_ReturnCode <> 0
         BEGIN
            SELECT @c_ReturnErrMsg = 'MBOLKey - ' + @c_MBOLKey
                  + '. MBOL Validate Pass# - (' + CAST(@b_ReturnCode AS VARCHAR) + ') '
                  + ISNULL(@c_ReturnErrMsg,'')

            execute nsplogalert
            @c_modulename   = 'nsp_BackEndValidateMBOL',
            @c_alertmessage = @c_ReturnErrMsg ,
            @n_severity     = 0,
            @b_success      = @b_success output,
            @n_err          = @n_err output,
            @c_errmsg       = @c_errmsg output
         END
      END

      IF @b_ReturnCode < 0
      BEGIN
         BEGIN TRAN
         UPDATE MBOL WITH (ROWLOCK)
         SET ValidatedFlag = 'E',  -- Error
             Editdate = GETDATE(),
             TrafficCop = NULL 
         WHERE MBOLKEY = @c_MBOLKey
         SELECT @n_err = @@ERROR
         IF @n_err <> 0
         BEGIN
            ROLLBACK TRAN
         END
         ELSE
         BEGIN
            WHILE @@TRANCOUNT > 0
            BEGIN
               COMMIT TRAN
            END
         END
      END
      ELSE
      BEGIN
         SET @c_ContainerStatus = '0'

         SELECT TOP 1
            @c_ContainerStatus = ISNULL(C.[Status],'0')
         FROM CONTAINER C WITH (NOLOCK)
         JOIN dbo.ContainerDetail CD WITH (NOLOCK) ON C.ContainerKey = CD.ContainerKey
         JOIN dbo.Mbol M WITH (NOLOCK) ON CD.PalletKey = M.ExternMbolKey
         WHERE M.MBOLKey = @c_MBOLKey
         AND C.ContainerType = 'ECOM'

         IF @b_debug = 1
         BEGIN
            PRINT 'MBOLKey - ' + @c_MBOLKey
            PRINT 'Container Status - ' + @c_ContainerStatus
         END

       IF @c_ContainerStatus = '9'
       BEGIN
          IF EXISTS(SELECT 1 FROM MBOL AS m WITH(NOLOCK) WHERE m.MbolKey = @c_MBOLKey AND m.[Status] <> '9')
          BEGIN       	
             EXECUTE dbo.isp_ShipMBOL @c_MBOLKey,
                         @b_success    output,
                         @n_err        output,
                         @c_errmsg     output

             IF @b_success <> 1
             BEGIN
                SELECT @n_continue = 3, @c_errmsg = 'isp_ShipMBOL Fail! ' + RTrim(@c_errmsg)
             END
          END
          IF @n_continue = 1 OR @n_continue =2
          BEGIN
          	IF EXISTS(SELECT 1 FROM MBOL AS m WITH(NOLOCK) WHERE m.MbolKey = @c_MBOLKey AND m.[Status] <> '9')
          	BEGIN
               BEGIN TRAN             
               UPDATE MBOL WITH (ROWLOCK)
               SET MBOL.Status = '9',  -- pending ship
                  FinalizeFlag = 'Y',
                   ValidatedFlag = 'Y',
                   Editdate = GETDATE()
               WHERE MBOLKEY = @c_MBOLKey
               SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
               IF @n_err <> 0 OR @n_cnt = 0
               BEGIN
                  SELECT @n_continue = 3, @c_errmsg = 'Fail to Update MBOL!'
                  ROLLBACK TRAN
               END
               ELSE
               BEGIN
                  WHILE @@TRANCOUNT > 0
                  BEGIN
                     COMMIT TRAN
                  END
               END          		
          	END
          END
       END
       ELSE
       BEGIN
          IF @n_continue = 1 OR @n_continue =2
          BEGIN
             BEGIN TRAN
               UPDATE MBOL WITH (ROWLOCK)
               SET ValidatedFlag = 'Y',
                   Editdate = GETDATE(),
                   TrafficCop = NULL
               WHERE MBOLKEY = @c_MBOLKey
               SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
               IF @n_err <> 0 OR @n_cnt = 0
               BEGIN
                  SELECT @n_continue = 3, @c_errmsg = 'Fail to Update MBOL!'
                  ROLLBACK TRAN
               END
               ELSE
               BEGIN
                  WHILE @@TRANCOUNT > 0
                  BEGIN
                     COMMIT TRAN
                  END
               END
            END
       END

         IF @b_debug = 1
         BEGIN
            PRINT 'Finalize Mbol - ' + @c_MBOLKey
         END
      END
      
      FETXH_NEXT:

      FETCH NEXT FROM CUR1 INTO @c_MBOLKey, @c_ValidatedFlag, @d_EditDate
      SELECT @f_status = @@FETCH_STATUS
   END -- While

   CLOSE CUR1
   DEALLOCATE CUR1



   /* #INCLUDE <SPTPA01_2.SQL> */
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_success = 0
      execute nsp_logerror @n_err, @c_errmsg, "nsp_BackEndValidateMBOL"
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
END
GO


GRANT EXECUTE ON [dbo].[nsp_BackEndValidateMBOL] TO nSQL 
GO
