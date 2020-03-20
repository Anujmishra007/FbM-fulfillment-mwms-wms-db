if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ispFinalizeStkTakeCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ispFinalizeStkTakeCount]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/***************************************************************************/  
/* Stored Proc : ispFinalizeStkTakeCount                                   */  
/* Creation Date:                                                          */  
/* Copyright: IDS                                                          */  
/* Written by:                                                             */  
/*                                                                         */  
/* Purpose:                                                                */  
/*                                                                         */  
/*                                                                         */  
/* Usage:                                                                  */  
/*                                                                         */  
/* Local Variables:                                                        */  
/*                                                                         */  
/* Called By:                                                              */  
/*                                                                         */  
/* PVCS Version: 1.1                                                       */  
/*                                                                         */  
/* Version: 5.4                                                            */  
/*                                                                         */  
/* Data Modifications:                                                     */  
/*                                                                         */  
/* Updates:                                                                */  
/* Date        Author  Ver   Purposes                                      */  
/* 06/06/2015  NJOW01  1.0   349528 - CC Finalize update last cc date      */
/***************************************************************************/  

CREATE PROCEDURE ispFinalizeStkTakeCount
	@c_StockTakeKey NVARCHAR(10), 
	@n_CountNo int
AS
	 SET NOCOUNT ON   
	 SET ANSI_NULLS OFF
	 SET QUOTED_IDENTIFIER OFF   
	 SET CONCAT_NULL_YIELDS_NULL OFF  
	
   DECLARE @n_Continue int

   SELECT @n_Continue = 1
   
   --NJOW01 Start
   DECLARE @c_SQL                      NVARCHAR(1000),
           @c_Facility                 NVARCHAR(5),
           @c_StorerParm               NVARCHAR(60),
           @c_Storer_SCSQL             NVARCHAR(800), 
           @c_Storer_SCSQL2            NVARCHAR(800),
           @b_success                  INT,
           @c_CCFinalizeUpdLastCntDate NVARCHAR(10)
  
   CREATE TABLE #STORER_CONFIG 
   (
         StorerKey  NVARChar (15) NULL ,
         Configkey  NVARChar (30) NULL ,
         SValue     NVARChar (10) NULL 
   )
   
   SELECT @c_Facility = Facility,
          @c_StorerParm = StorerKey
   FROM STOCKTAKESHEETPARAMETERS (NOLOCK)
   WHERE StockTakeKey = @c_StockTakeKey
   
   EXEC ispParseParameters
       @c_StorerParm,
       'string',
       'STORER.StorerKey',
       @c_Storer_SCSQL OUTPUT,
       @c_Storer_SCSQL2 OUTPUT,
       @b_success OUTPUT   
   
   SELECT @c_SQL = N'SELECT STORER.Storerkey, STORERCONFIG.Configkey, STORERCONFIG.Svalue '
         +  'FROM STORER (NOLOCK) '
         +  'LEFT JOIN STORERCONFIG (NOLOCK) ON STORER.Storerkey = STORERCONFIG.Storerkey AND STORERCONFIG.Svalue=''1'' '
         +  '                                AND (ISNULL(STORERCONFIG.Facility,'''')='''' OR STORERCONFIG.Facility = ''' + ISNULL(RTRIM(@c_facility), '') + ''') '
         +  'WHERE 1=1 '
         +  ISNULL(RTRIM(@c_Storer_SCSQL), '') + ' ' + ISNULL(RTRIM(@c_Storer_SCSQL2), '') + ' '
   
   INSERT INTO #STORER_CONFIG (StorerKey, Configkey, Svalue)
     EXEC (@c_SQL )         
         
   IF ((SELECT COUNT(DISTINCT Storerkey) FROM #STORER_CONFIG WHERE Configkey = 'CCFinalizeUpdLastCntDate' AND ISNULL(Svalue,'')='1') =      
      (SELECT COUNT(DISTINCT Storerkey) FROM #STORER_CONFIG)) AND 
      (SELECT COUNT(DISTINCT Storerkey) FROM #STORER_CONFIG WHERE Configkey = 'CCFinalizeUpdLastCntDate' AND ISNULL(Svalue,'')='1') > 0
   BEGIN
   	  SELECT @c_CCFinalizeUpdLastCntDate = '1'
   END
   ELSE
   BEGIN
   	  SELECT @c_CCFinalizeUpdLastCntDate = '0'
   END      
   --NJOW01 End

   IF @n_CountNo = 1 
   BEGIN
      BEGIN TRAN

   	UPDATE CCDETAIL
         SET FinalizeFlag = 'Y'
      WHERE CCKEY = @c_StockTakeKey
   	IF @@ERROR <> 0
   	BEGIN
   	   SELECT @n_continue = 3
   		RAISERROR ('Error Found Finalize Stock Take ispFinalizeStkTakeCount.', 16, 1)
   	   ROLLBACK TRAN
   	   RETURN
   	END
   	ELSE
   	  COMMIT TRAN
   END
   ELSE IF @n_CountNo = 2 
   BEGIN
      BEGIN TRAN

   	UPDATE CCDETAIL
         SET FinalizeFlag_Cnt2 = 'Y'
      WHERE CCKEY = @c_StockTakeKey
   	IF @@ERROR <> 0
   	BEGIN
   	   SELECT @n_continue = 3
   		RAISERROR ('Error Found Finalize Stock Take ispFinalizeStkTakeCount.', 16, 1)
   	   ROLLBACK TRAN
   	   RETURN
   	END
   	ELSE
   	  COMMIT TRAN
   END IF @n_CountNo = 3 
   BEGIN
      BEGIN TRAN

   	UPDATE CCDETAIL
         SET FinalizeFlag_Cnt3 = 'Y'
      WHERE CCKEY = @c_StockTakeKey
   	IF @@ERROR <> 0
   	BEGIN
   	   SELECT @n_continue = 3
   		RAISERROR ('Error Found Finalize Stock Take ispFinalizeStkTakeCount.', 16, 1)
   	   ROLLBACK TRAN
   	   RETURN
   	END
   	ELSE
   	  COMMIT TRAN
   END

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      BEGIN TRAN

   	UPDATE StockTakeSheetParameters
   		SET FinalizeStage = @n_CountNo
   	WHERE StockTakeKey = @c_StockTakeKey
   	IF @@ERROR <> 0
   	BEGIN
   	   SELECT @n_continue = 3
   		RAISERROR ('Error Found when updaing StockTakeSheetParameters.', 16, 1)
   	   ROLLBACK TRAN
   	   RETURN
   	END
   	ELSE
   	  COMMIT TRAN
   END
   
   --NJOW01
   IF (@n_continue = 1 OR @n_continue = 2) AND @c_CCFinalizeUpdLastCntDate = '1' AND @n_CountNo IN(1,2,3)
   BEGIN
      BEGIN TRAN   	
   	  UPDATE SKU WITH (ROWLOCK)
   	  SET SKU.LastCycleCount = GETDATE()
   	  FROM CCDETAIL (NOLOCK) 
   	  JOIN SKU ON CCDETAIL.Storerkey = SKU.Storerkey AND CCDETAIL.Sku = SKU.Sku
   	  WHERE CCDETAIL.CCKey = @c_StockTakeKey
   	  
   	  IF @@ERROR <> 0
   	  BEGIN
   	     SELECT @n_continue = 3
   	  	RAISERROR ('Error Found when updaing StockTakeSheetParameters.', 16, 1)
   	     ROLLBACK TRAN
   	     RETURN
   	  END
   	  ELSE
   	  BEGIN
   	    UPDATE LOC WITH (ROWLOCK)
   	    SET LOC.LastCycleCount = GETDATE()
   	    FROM CCDETAIL (NOLOCK) 
   	    JOIN LOC ON CCDETAIL.Loc = LOC.Loc
   	    WHERE CCDETAIL.CCKey = @c_StockTakeKey
   	    
   	    IF @@ERROR <> 0
   	    BEGIN
   	       SELECT @n_continue = 3
   	    	RAISERROR ('Error Found when updaing StockTakeSheetParameters.', 16, 1)
   	       ROLLBACK TRAN
   	       RETURN
   	    END
   	    ELSE
   	      COMMIT TRAN
   	  END   	    
   END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO



GRANT EXECUTE ON ispFinalizeStkTakeCount to nSQL
GO
