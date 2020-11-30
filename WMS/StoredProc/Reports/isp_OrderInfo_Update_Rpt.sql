IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = object_id(N'[dbo].[isp_OrderInfo_Update_Rpt]') 
              AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[isp_OrderInfo_Update_Rpt]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO  
  
/************************************************************************/  
/* Stored Procedure: isp_OrderInfo_Update_Rpt                           */  
/* Creation Date: 28-SEP-2020                                           */  
/* Copyright: LF Logistics                                              */  
/* Written by: CSCHONG                                                  */  
/*                                                                      */  
/* Purpose: WMS-15142 CN IKEA VIEWREPORT ORDERINFO UPDATING             */  
/*                                                                      */  
/* Called By: r_OrderInfo_Update_Rpt                                    */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 7.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author  Ver   Purposes                                  */  
/************************************************************************/  
  
CREATE PROC [dbo].[isp_OrderInfo_Update_Rpt]  
                @c_storerkey         NVARCHAR(20),  
                @c_facility          NVARCHAR(15),  
                @c_StartOrderDate    NVARCHAR(45) ,  
                @c_EndOrderDate      NVARCHAR(45) ,   
                @c_hostwhcode        NVARCHAR(10) = '',  
                @c_courier           NVARCHAR(45) =''
AS  
BEGIN  
    SET NOCOUNT ON       -- SQL 2005 Standard
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF
  
    DECLARE @b_debug          INT = 0;  
    DECLARE @c_TargetNum      NVARCHAR(10);  
   -- DECLARE @c_StartOrderDate NVARCHAR(20);  
   -- DECLARE @c_EndOrderDate   NVARCHAR(20);  
    DECLARE @c_GetStorerKey   NVARCHAR(15);  
    DECLARE @Orderkey         NVARCHAR(30);  
  
    DECLARE @c_SQL NVARCHAR(MAX),  
            @c_SQLParm NVARCHAR(MAX);  
  
    DECLARE @n_Continue INT,  
            @n_StartTCnt INT,  
            @b_Success INT,  
            @n_Err INT,  
            @c_ErrMsg NVARCHAR(250);  

   
DECLARE @c_getOrderkey        NVARCHAR(20),
        @c_getfacility        NVARCHAR(20),
        @c_getsku             NVARCHAR(20),
        @n_ORIQTY             INT,
        @n_AvaiQty            INT,
        @c_replen             NVARCHAR(5),
        @c_ExecMain           NVARCHAR(4000),
        @c_ExecStatements     NVARCHAR(4000),
        @c_OrderdateFilter    NVARCHAR(4000),
        @c_hostwhcodeFilter   NVARCHAR(4000),
        @c_courierFilter      NVARCHAR(4000),
        @c_ExecArguments      NVARCHAR(4000),
        @c_GrpByORD           NVARCHAR(4000),  
        @c_ORDBY              NVARCHAR(4000),  
        @c_GrpByLLISKU        NVARCHAR(4000),
        @c_ORDERBYORD         NVARCHAR(4000),
        @c_ErrorMsg           NVARCHAR(150),
        @n_INVQTY             INT,  
        @n_AVLQTY             INT,
        @n_AllocQty           INT,
        @n_getAvlqty          INT  
  
     SET @c_ErrorMsg = ''

     CREATE TABLE #TMPORD (
     RowID int identity(1,1),
     Storerkey  NVARCHAR(20), 
     Orderkey NVARCHAR (20),
     SKU      NVARCHAR(20), 
     Facility NVARCHAR(10),
     OHADDDATE DATETIME ,
     ORIQTY INT,
     REPLEN  NVARCHAR(10) 
     )
     
     CREATE TABLE #TMPINV (
     RowID int identity(1,1),
     Storerkey  NVARCHAR(20), 
     sku NVARCHAR (20), 
     Facility NVARCHAR(20) ,
     AVAILQTY INT )
     
     CREATE TABLE #TMPORDERUP
     ( RowID    int identity(1,1),
       Storerkey  NVARCHAR(20), 
       ORDERKEY NVARCHAR(20) NULL, 
       sku      NVARCHAR(20) NULL,
       Facility   NVARCHAR(10),
       ORIQTY   INT NULL,
       AVAILQTY INT NULL,
       OrdStartDate DATETIME ,
       OrderEndDate DATETIME ,
       hostwhcode   NVARCHAR(10) ,
       courier   NVARCHAR(45),
       ErrMsg    NVARCHAR(150) NULL
       ) 
     
     CREATE TABLE #TMPORDTBL (
     RowID      int identity(1,1),
     Storerkey  NVARCHAR(20), 
     Orderkey   NVARCHAR (20),
     SKU        NVARCHAR(20), 
     Facility   NVARCHAR(10),
     ORIQTY     INT,
     INVQTY     INT,
     AVLQTY     INT,
     CANREPLEN     NVARCHAR(10) 
     ) 
     
     CREATE TABLE #TMPORDTBL1 (
     RowID      int identity(1,1),
     Storerkey  NVARCHAR(20), 
     Orderkey   NVARCHAR (20),
     Facility   NVARCHAR(10),
     ) 
      
     IF ISNULL(@c_Storerkey,'') = '' OR ISNULL(@c_facility,'') = ''
     BEGIN
        SET @c_ErrorMsg = 'Input parameter for Facility or Storerkey cannot be NULL '
        GOTO QUIT_SP
     END
     
     SET @c_OrderdateFilter = ''
     IF ISNULL(@c_StartOrderDate,'') <> ''  AND ISNULL(@c_EndOrderDate,'') <> '' 
     BEGIN  
     
       
        IF DATEDIFF(DAY,CAST(@c_StartOrderDate as DATETIME),CAST(@c_ENDOrderDate AS DATETIME)) >  2
        BEGIN
         SET @c_ErrorMsg = 'Input Date more than 2 days'
         GOTO QUIT_SP
        END
       -- print '@c_ErrorMsg : ' + @c_ErrorMsg 
     
        SET @c_OrderdateFilter = N' AND OD.Adddate BETWEEN CAST(@c_StartOrderDate as DATETIME)  AND CAST(@c_ENDOrderDate as DATETIME) '
     
       -- print '@c_OrderdateFilter ' +  @c_OrderdateFilter    
     END
     ELSE
     BEGIN
        SET @c_ErrorMsg = 'Input Date cannot be blank'
        GOTO QUIT_SP 
     END
 
--IF ISNULL(@c_ErrorMsg,'') = ''
--BEGIN
   SET @c_hostwhcodeFilter  = ''
   IF ISNULL(@c_hostwhcode,'') <> ''
   BEGIN
    SET @c_hostwhcodeFilter = N' AND L.hostwhcode = @c_hostwhcode '
   END 

   SET @c_courierFilter = ''
   IF ISNULL(@c_courier,'') <> ''
   BEGIN
     IF UPPER(@c_courier) = 'ALL'
     BEGIN
       SET @c_courierFilter = ' AND OH.shipperkey in ('''',''SN'') '
     END 
     ELSE IF UPPER(@c_courier) = 'JD'
     BEGIN
       SET @c_courierFilter = ' AND OH.shipperkey in ('''') '
     END 
     ELSE IF UPPER(@c_courier) = 'SN'
     BEGIN
       SET @c_courierFilter = ' AND OH.shipperkey in (''SN'') '
     END 
END


   SET @c_GrpByORD = N' Group By OH.storerkey,OD.Orderkey,OD.SKU,OH.Facility,OH.adddate'
   SET @c_GrpByLLISKU = N' Group by lli.storerkey,lli.sku,L.facility '
   SET @c_ORDERBYORD = N' ORDER BY OD.Orderkey'
   SET @c_ORDBY = N' ORDER BY OH.storerkey,OD.Orderkey,OD.SKU'
   
   SET @c_ExecMain = ''
   SET @c_ExecMain = N'       
   
   INSERT INTO #TMPORD (storerkey,orderkey,sku,Facility,OHADDDATE,ORIQTY,REPLEN)
   SELECT OH.storerkey,OD.Orderkey,OD.SKU,OH.Facility,OH.adddate,sum(OD.Originalqty),''''
   FROM ORDERS OH (NOLOCK)
   JOIN ORDERDETAIL OD WITH (NOLOCK) ON OH.Orderkey = OD.Orderkey
   WHERE    OH.StorerKey = @c_storerkey    
            AND OH.facility  = @c_Facility  
   AND OH.Status=''0''  ' 
   

    IF @b_debug = 1  
    BEGIN  
        PRINT 'check insert   #TMPORD ' + ' @c_ExecMain ' +  @c_ExecMain
    END
 
      SET @c_ExecStatements = @c_ExecMain + CHAR(13) + @c_OrderdateFilter + CHAR(13) + @c_courierFilter + CHAR(13) + @c_GrpByORD  + CHAR(13) + @c_ORDBY 

    IF @b_debug = 1  
    BEGIN  
        PRINT @c_ExecStatements  
    END
 
    SET @c_ExecArguments = N'@c_StorerKey NVARCHAR(15), @c_facility NVARCHAR(10),@c_StartOrderDate NVARCHAR(45), @c_EndOrderDate NVARCHAR(45)';  
    EXEC sp_executesql @c_ExecStatements,  
                       @c_ExecArguments,  
                       @c_StorerKey, 
                       @c_Facility,   
                       @c_StartOrderDate,  
                       @c_EndOrderDate  
  

      SET @c_ExecMain = ''
      SET @c_ExecStatements = ''
      
      SET @c_ExecMain   
              = N'   
      insert into #TMPINV(storerkey,sku,Facility,AVAILQTY)
      select lli.storerkey,lli.sku,L.facility,sum(lli.Qty - lli.QtyAllocated - lli.QtyPicked)
      from LOTxLOCxID LLI WITH (NOLOCK)-- ON LLI.Storerkey = OD.Storerkey AND LLI.Sku = OD.Sku
      JOIN LOC L WITH (NOLOCK)  ON L.loc = LLI.LOC
      where lli.Storerkey = @c_storerkey 
      and L.facility = @c_Facility
      and L.LocationType = ''PICK''  
      and (lli.Qty - lli.QtyAllocated - lli.QtyPicked) > 0  
      and lli.sku in (select sku from #TMPORD) ' 
      
       SET @c_ExecStatements = @c_ExecMain + CHAR(13) + @c_hostwhcodeFilter + CHAR(13) + @c_GrpByLLISKU
      
       IF @b_debug = 1  
          BEGIN  
              PRINT @c_ExecStatements  
          END
      
        
          SET @c_ExecArguments = N'@c_StorerKey NVARCHAR(15), @c_facility NVARCHAR(10),@c_hostwhcode NVARCHAR(20)';  
          EXEC sp_executesql @c_ExecStatements,  
                             @c_ExecArguments,  
                             @c_StorerKey, 
                             @c_Facility,   
                             @c_hostwhcode
      
      INSERT INTO #TMPORDTBL(Storerkey,Orderkey,SKU,Facility,ORIQTY,INVQTY,AVLQTY,CANREPLEN)
      select TR.Storerkey as storerkey, TR.orderkey,TR.sku, TR.Facility,TR.ORIQTY,TIV.AVAILQTY as INVQTY,(TIV.AVAILQTY-TR.ORIQTY) as AVLQTY
             ,CASE WHEN (TIV.AVAILQTY-TR.ORIQTY) >=1 THEN 'Y' ELSE 'N' END as CANREPLEN
      from #TMPORD TR
      JOIN #TMPINV TIV ON TIV.sku = TR.sku and TIV.Storerkey=TR.Storerkey AND TIV.Facility = TR.Facility
      order by TR.orderkey,TR.sku
      
      INSERT INTO #TMPORDTBL1(Storerkey,Orderkey,Facility)
      select distinct storerkey as storerkey,orderkey as orderkey ,facility as facility
      from #TMPORDTBL
      group by storerkey,orderkey,facility
      having count(distinct CANREPLEN) = 1
      
      SET @n_AvaiQty = 0
      SET @c_replen = ''
      
      DECLARE CUR_RESULT CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT TR.storerkey,TR.orderkey,TR.sku, TR.Facility,TR.ORIQTY,TIV.AVAILQTY as INVQTY,(TIV.AVAILQTY-TR.ORIQTY) as AVLQTY
         FROM   #TMPORD TR
         JOIN #TMPINV TIV ON TIV.sku = TR.sku and TIV.Storerkey=TR.Storerkey AND TIV.Facility = TR.Facility
         JOIN #TMPORDTBL1 TBL1 ON TBL1.orderkey = TR.Orderkey AND TBL1.Facility = TR.facility AND TBL1.storerkey = TR.Storerkey  
        -- WHERE REPLEN = ''
         ORDER BY TR.Rowid
      
      
         OPEN CUR_RESULT   
         
         FETCH NEXT FROM CUR_RESULT INTO @c_GetStorerkey,@c_getOrderkey,@c_getsku,@c_getfacility,@n_ORIQTY,@n_invqty,@n_Avlqty
         
         WHILE @@FETCH_STATUS <> -1  
         BEGIN    
      
             SET @c_replen = ''
             SET @n_AllocQty = 0
             SET @n_getAvlqty = 0
      
             SELECT @c_replen = REPLEN
             FROM   #TMPORD    
              WHERE Storerkey = @c_GetStorerkey
              AND Sku = @c_getsku
              AND facility = @c_getfacility
              AND Orderkey = @c_getorderkey 
      
              SELECT @n_getAvlqty = ISNULL(SUM(ORIQTY),0)
              FROM   #TMPORD    
              WHERE Storerkey = @c_GetStorerkey
              AND Sku = @c_getsku
              AND facility = @c_getfacility
              AND REPLEN = 'Y' 
      
              SET @n_Avlqty = (@n_invqty-@n_getAvlqty)
             --    select 'b4',@n_AvaiQty '@n_AvaiQty',@n_ORIQTY '@n_ORIQTY',@c_getOrderkey '@c_getOrderkey',@c_replen '@c_replen'
            IF @n_Avlqty>0 AND (@n_ORIQTY<=@n_Avlqty  ) -- AND (@n_Avlqty - @n_AllocQty) >= @n_ORIQTY --AND ( @c_replen = ''  OR @c_replen <> 'N')
            BEGIN
                IF ( @c_replen = ''  OR @c_replen <> 'N')
                BEGIN
                   UPDATE  #TMPORD
                   SET REPLEN ='Y'
                   where Orderkey = @c_getOrderkey
                   and sku = @c_getsku
      
                END
      
            END
            ELSE
            BEGIN
                UPDATE  #TMPORD
                   SET REPLEN ='N'
                     -- ,AllocatedQty = 0
                   where Orderkey = @c_getOrderkey
            END
      
         FETCH NEXT FROM CUR_RESULT INTO @c_GetStorerkey,@c_getOrderkey,@c_getsku,@c_getfacility,@n_ORIQTY,@n_invqty,@n_Avlqty
         END   
         CLOSE CUR_RESULT
         DEALLOCATE  CUR_RESULT
      
      --select 'B4_#TMPORD',* from #TMPORD
      
      DECLARE CUR_CHKTMPORD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT DISTINCT Storerkey,Orderkey
         FROM   #TMPORD   
         WHERE REPLEN = 'N' OR REPLEN = ''
         ORDER BY Orderkey
       OPEN CUR_CHKTMPORD;  
        
          FETCH NEXT FROM CUR_CHKTMPORD INTO @c_getstorerkey,@c_getorderkey
        
          WHILE @@FETCH_STATUS <> -1   --AND @n_Continue IN ( 1, 2 )  
          BEGIN 
      
         UPDATE #TMPORD
         SET REPLEN = 'N'
         WHERE Storerkey = @c_GetStorerKey 
         AND Orderkey = @c_getOrderkey
      
         FETCH NEXT FROM CUR_CHKTMPORD   INTO  @c_getstorerkey,@c_getorderkey
          END;  
        
          CLOSE CUR_CHKTMPORD;  
          DEALLOCATE CUR_CHKTMPORD;   
      
      --select '#TMPORD',* from #TMPORD
      ----------------------Update Order Info    
          
      DECLARE CUR_UPDATEOIF CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT Storerkey,Orderkey,sku,facility,Oriqty
         FROM   #TMPORD   
         WHERE REPLEN = 'Y'
         ORDER BY Rowid
        
          OPEN CUR_UPDATEOIF;  
        
          FETCH NEXT FROM CUR_UPDATEOIF INTO @c_getstorerkey,@c_getorderkey,@c_getsku,@c_getfacility,@n_ORIQTY
        
          WHILE @@FETCH_STATUS <> -1   --AND @n_Continue IN ( 1, 2 )  
          BEGIN  
              BEGIN TRAN
              UPDATE ORDERINFO WITH (ROWLOCK)  
              SET deliverymode = 'NoReplen',  
                  TrafficCop = NULL,  
                  EditDate = GETDATE(),  
                  EditWho = SUSER_SNAME()  
              WHERE OrderKey = @c_getorderkey   
        
              SELECT @c_ErrorMsg = @@ERROR;  
              IF @c_ErrorMsg <> 0  
              BEGIN  
                  --SELECT @n_Continue = 3;  
                  --SELECT @c_ErrMsg = CONVERT(CHAR(250), @n_Err),  
                  --       @n_Err = 63330;  
                  SELECT @c_ErrorMsg = ' Update Ordersinfo Failed! for Orderkey : ' + @c_getOrderkey  
                  ROLLBACK TRAN 
                  GOTO QUIT_SP
                  
              END
              ELSE
              BEGIN
                 COMMIT TRAN
      
                 INSERT INTO #TMPORDERUP (Storerkey,Facility,ORDERKEY,sku,ORIQTY,AVAILQTY ,OrdStartDate ,
                                   OrderEndDate ,hostwhcode ,courier,ErrMsg  )
                VALUES (@c_storerkey , @c_Facility ,@c_getorderkey,@c_getsku,@n_ORIQTY,0,CAST(@c_StartOrderDate as DATETIME),
                        CAST(@c_EndOrderDate as DATETIME),ISNULL(@c_hostwhcode,''),
                        ISNULL(@c_Courier,''),@c_ErrorMsg )
              END
        
              IF @b_debug = 1  
              BEGIN  
                  PRINT @c_getorderkey;  
              END;  
              
      
              FETCH NEXT FROM CUR_UPDATEOIF   INTO  @c_getstorerkey,@c_getorderkey,@c_getsku,@c_getfacility,@n_ORIQTY
          END;  
        
          CLOSE CUR_UPDATEOIF;  
          DEALLOCATE CUR_UPDATEOIF;   
      --END
           QUIT_SP:
      
         IF ISNULL(@c_ErrorMsg,'') <> '' AND NOT EXISTS (SELECT 1 FROM #TMPORDERUP WHERE Storerkey=@c_storerkey AND @c_Facility = @c_facility)
         BEGIN
         INSERT INTO #TMPORDERUP (Storerkey,Facility,ORDERKEY,sku,ORIQTY,AVAILQTY ,OrdStartDate ,
                                   OrderEndDate ,hostwhcode ,courier,ErrMsg  )
          VALUES (@c_storerkey , @c_Facility ,'','',0,0,CAST(@c_StartOrderDate as DATETIME),CAST(@c_EndOrderDate as DATETIME),ISNULL(@c_hostwhcode,''),
                  ISNULL(@c_Courier,''),@c_ErrorMsg )
      
         END
      
         SELECT * from #TMPORDERUP
      
          DROP TABLE #TMPORD  
          DROP TABLE #TMPINV 
          DROP TABLE #TMPORDERUP 
          DROP TABLE #TMPORDTBL
          DROP TABLE #TMPORDTBL1
    
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

GRANT EXECUTE ON [dbo].[isp_OrderInfo_Update_Rpt] TO [nsql]
GO
