IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_UpdateAutoAllocBatch_Status]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[isp_UpdateAutoAllocBatch_Status]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: isp_UpdateAutoAllocBatch_Status                    */
/* Creation Date: 19-Apr-2018                                           */
/* Copyright: LFL                                                       */
/* Written by:  Shong                                                   */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.3 (Unicode)                                          */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Rev   Purposes                                  */
/************************************************************************/
CREATE PROC [dbo].[isp_UpdateAutoAllocBatch_Status] (  
    @n_AllocBatchNo BIGINT,   
    @c_Status       NVARCHAR(10),  
    @n_Err          INT = 0 OUTPUT,  
    @c_ErrMsg       NVARCHAR(250) = '' OUTPUT )  
AS  
BEGIN                   
   IF @c_Status = '9'  
   BEGIN  
      IF NOT EXISTS (SELECT 1 FROM AutoAllocBatch_Log WITH (NOLOCK)  
                     WHERE AllocBatchNo = @n_AllocBatchNo)  
      BEGIN  
        INSERT INTO AutoAllocBatch_Log
        (
        	AllocBatchNo,    Facility,       Storerkey,
        	BuildParmGroup,  BuildParmCode,  BuildParmString,
        	StrategyKey,     Duration,       TotalOrderCnt,
        	Priority,        UDF01,        	UDF02,
        	UDF03,        	  UDF04,        	UDF05,
        	[Status],        AddWho,        	AddDate,
        	EditWho,         EditDate,       TrafficCop,
        	ArchiveCop
        )        
        SELECT AllocBatchNo,
        	Facility,        	Storerkey,        BuildParmGroup,
        	BuildParmCode,    BuildParmString,  StrategyKey,
        	Duration,        	TotalOrderCnt,    [Priority],
        	UDF01,        	   UDF02,        	   UDF03,
        	UDF04,        	   UDF05,        	   @c_Status,
        	AddWho,        	AddDate,        	SUSER_SNAME(),
        	GETDATE(),       	TrafficCop,      	ArchiveCop
        FROM AutoAllocBatch AS aab WITH(NOLOCK)
        WHERE aab.AllocBatchNo = @n_AllocBatchNo
         
      END  
      
      IF @@ERROR = 0
      BEGIN
         DELETE AutoAllocBatch     
         WHERE AllocBatchNo = @n_AllocBatchNo      	
      END
   END  
   ELSE    
   BEGIN  
      UPDATE AutoAllocBatch    
         SET [Status] = @c_Status,   
             EditDate = GETDATE(), 
             EditWho  = SUSER_SNAME()   
      WHERE AllocBatchNo = @n_AllocBatchNo                         
   END  
   
END   
GO

GRANT EXECUTE ON [dbo].[isp_UpdateAutoAllocBatch_Status] TO NSQL
GO

