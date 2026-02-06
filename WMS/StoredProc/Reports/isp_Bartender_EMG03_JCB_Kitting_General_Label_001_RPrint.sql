SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*****************************************************************************/
/* Stored Procedure: isp_Bartender_EMG03_JCB_Kitting_General_Label_001_RPrint*/
/* Creation Date: 29-12-2025                                                 */
/* Copyright: MAERSK                                                         */
/* Written by: VMA237                                                        */
/*                                                                           */
/* Purpose: WCEET-3416	 													 */
/*                                                                           */
/* Called By: EMG03_JCB_Cabs_Kitting_General_Label_001.btw      		     */ 
/*                                                                           */
/* PVCS Version: 1.0                                                         */
/*                                                                           */
/* Version: 1.0                                                              */
/*                                                                           */
/* Data Modifications:                                                       */
/*                                                                           */
/* Updates:                                                                  */
/* Date         Author   Ver  Purposes                                       */
/* 03-10-2025   VMA237   1.0  Initial version is created (WCEET-3416)        */
/* 15-12-2025   AGM046   2.0  Main query changed based on taskdetail         */ 
/*****************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[isp_Bartender_EMG03_JCB_Kitting_General_Label_001_RPrint](  
   @c_Sparm01 NVARCHAR(250),	-- StorerKey                  
   @c_Sparm02 NVARCHAR(250),	-- DropID                  
   @c_Sparm03 NVARCHAR(250),	-- Not used	                  
   @c_Sparm04 NVARCHAR(250),	-- Not used                  
   @c_Sparm05 NVARCHAR(250),	-- Not used                  
   @c_Sparm06 NVARCHAR(250),	-- Not used                  
   @c_Sparm07 NVARCHAR(250),	-- Not used                  
   @c_Sparm08 NVARCHAR(250),	-- Not used                  
   @c_Sparm09 NVARCHAR(250),	-- Not used                  
   @c_Sparm10 NVARCHAR(250),	-- Not used                  
   @b_debug   INT = 0                             
)
AS  
BEGIN
   --
   SET NOCOUNT ON                     
   SET ANSI_NULLS OFF                 
   SET QUOTED_IDENTIFIER OFF          
   SET CONCAT_NULL_YIELDS_NULL OFF    
   --
   DECLARE @To_loc            NVARCHAR(200),
           @c_TaskDetailKey   NVARCHAR(10),
		   @c_DropID          NVARCHAR(20),
		   @c_StorerKey       NVARCHAR(10)
   --
   SET @c_TaskDetailKey = @c_Sparm03
   SET @c_DropID        = @c_Sparm02
   SET @c_StorerKey     = @c_Sparm01
   -- Raw pick lines summarized by SKU
   DECLARE @tempTable TABLE
   (
      ID INT IDENTITY(0,1),
      LabelHeader NVARCHAR(100),
      OrderName NVARCHAR(100),
      OrderID NVARCHAR(100),
      WaveID NVARCHAR(100),
      [Delivery_Date&Time] NVARCHAR(100),
      [Date&Time_Picked] NVARCHAR(100),
      ToLocation NVARCHAR(100),
      UID NVARCHAR(100),
      DataCheck NVARCHAR(100),
      DropID NVARCHAR(100),
	  SequenceCab NVARCHAR(100)
   );
      
   -- if taskdetailkey is not null (taskdetail + order)
   IF (@c_TaskDetailKey <> '' AND @c_TaskDetailKey IS NOT NULL)
   BEGIN
      -- Get data from taskdetail
	  INSERT INTO @tempTable
	  SELECT 
	     CASE WHEN orm.[Type] = '2' THEN 'CABS Tote Label'
		 WHEN orm.[Type] = '6' AND td.PickMethod = 'FP' THEN 'T4 Full pallet pick'
		 WHEN orm.[Type] = '6' AND td.PickMethod = 'PP' THEN 'T4 Partial Pick Pallet'
		 WHEN orm.[Type] = '8' THEN 'LANDPOWER Pallet Label'
		 ELSE 'Not a kitting order' END	AS LabelHeader,
		 orm.ExternOrderKey,
		 orm.OrderKey,
		 td.WaveKey,
		 FORMAT(orm.DeliveryDate,'dd/MM/yyyy hh:mm tt'),
		 FORMAT(GETDATE(),'dd-MM-yyyy hh:mm tt'),
		 td.ToLoc,
		 td.EditWho,
		 '' AS DataCheck,
		 @c_DropID,
         CASE 
	     WHEN orm.[Type] = '2' THEN CONCAT ('Sequence: ', orm.UserDefine01)
	     ELSE ''
	     END AS SequenceCab
      FROM dbo.TaskDetail td WITH (NOLOCK)
         INNER JOIN dbo.orders orm WITH (NOLOCK)
	        ON td.orderkey = orm.orderkey
		    AND td.storerkey = orm.storerkey 
      WHERE TD.TaskDetailKey = @c_TaskDetailKey
         AND td.storerkey = @c_StorerKey;			
			
      SELECT @To_loc = STRING_AGG(Short, ', ') WITHIN GROUP (ORDER BY Short) 
      FROM (		
         SELECT DISTINCT ck.Short 
	     FROM dbo.taskdetail td WITH (NOLOCK)
	        INNER JOIN orders orm WITH (NOLOCK)
		       ON td.OrderKey = orm.OrderKey
			   AND td.Storerkey = orm.StorerKey
		    INNER JOIN dbo.codelkup ck WITH (NOLOCK)
		       ON orm.storerkey = ck.storerkey
			   AND orm.c_company = ck.long	   
         WHERE ck.listname LIKE 'jcb%ml'
	        AND TD.TaskDetailKey = @c_TaskDetailKey
		    AND td.Storerkey = @c_StorerKey		
      ) x;
   END 
   ELSE	
   BEGIN
      -- get data from pickdetail
	  INSERT INTO @tempTable	
      SELECT TOP 1
	     CASE WHEN orm.[Type] = '2' THEN 'CABS Tote Label'
		 WHEN orm.[Type] = '6' AND cdl.[Description] = 'Full Pallet' THEN 'T4 Full pallet pick'
		 WHEN orm.[Type] = '6' AND cdl.[Description] != 'Full Pallet' THEN 'T4 Partial Pick Pallet'
		 WHEN orm.[Type] = '8' THEN 'LANDPOWER Pallet Label'
		 ELSE 'Not a kitting order' 
		 END	AS LabelHeader,
		 orm.ExternOrderKey,
		 orm.OrderKey,
		 pd.WaveKey,
		 FORMAT(orm.DeliveryDate,'dd/MM/yyyy hh:mm tt'),
		 FORMAT(MIN(pd.EditDate),'dd-MM-yyyy hh:mm tt'),
		 pd.Loc,
		 pd.EditWho,
	     CASE 
	     WHEN orm.[Type] = '2' THEN CONCAT ('Sequence: ', orm.UserDefine01)
	     ELSE ''
	     END AS SequenceCab,
		 '' AS DataCheck,
		 CASE WHEN cdl.[Description] = 'Full Pallet' THEN pd.ID
		 WHEN cdl.[Description] != 'Full Pallet' THEN pd.DropID END				
      FROM dbo.PICKDETAIL pd WITH (NOLOCK)
	     INNER JOIN dbo.ORDERS orm WITH (NOLOCK)
		    ON orm.StorerKey = pd.StorerKey AND orm.OrderKey = pd.OrderKey
		 INNER JOIN dbo.V_CODELKUP cdl (NOLOCK) 
			ON cdl.LISTNAME = 'TMUOM' AND cdl.Code = pd.[UOM] 
			AND ISNULL(cdl.Storerkey, '') = (
			                                    CASE 
					                            WHEN EXISTS (
											       SELECT TOP 1 1 
					                               FROM dbo.V_CODELKUP WITH (NOLOCK) 
					                               WHERE LISTNAME = 'TMUOM' 
												      AND Code = pd.[UOM] 
												      AND Storerkey = pd.StorerKey
										        ) 
										        THEN pd.StorerKey 
											    ELSE '' 
										        END
											 ) 
      WHERE pd.StorerKey = @c_StorerKey
	     AND (
		    (pd.DropID = @c_DropID AND cdl.[Description] != 'Full Pallet') OR 
			(pd.ID = @c_DropID AND cdl.[Description] = 'Full Pallet'))
	  GROUP BY 
	     orm.ExternOrderKey, 
		 orm.OrderKey, orm.[Type], 
		 cdl.[Description], 
		 pd.WaveKey, 
		 orm.DeliveryDate, 
		 pd.Loc, 
		 pd.EditWho, 
		 pd.ID, 
		 pd.DropID, 
		 pd.SKU,
	     CASE 
	     WHEN orm.[Type] = '2' THEN CONCAT ('Sequence: ', orm.UserDefine01)
	     ELSE ''
	     END
      ORDER BY FORMAT(MIN(pd.EditDate),'dd-MM-yyyy hh:mm tt');  
			  
      -- Get Satge Outbounds
	  SELECT @To_loc = STRING_AGG(Short, ', ') WITHIN GROUP (ORDER BY Short) 
	  FROM (		
	     SELECT DISTINCT ck.Short 
	     FROM dbo.pickdetail pd WITH (NOLOCK)
		    INNER JOIN dbo.orders orm WITH (NOLOCK)
			   ON pd.OrderKey = orm.OrderKey
			   AND pd.Storerkey = orm.StorerKey
			INNER JOIN codelkup ck WITH (NOLOCK) 
			   ON orm.storerkey = ck.storerkey
			   AND orm.c_company = ck.long	   
			WHERE ck.listname LIKE 'jcb%ml'
			   AND (pd.dropID = @c_DropID or pd.ID = @c_DropID)
			   AND pd.Storerkey = @c_StorerKey		
      ) x;
   END			
						 
   -- Output table declaration: BarTender expects many generic columns
   DECLARE @Result TABLE
   (
      ID INT IDENTITY(1,1),
      Col01 NVARCHAR(80), Col02 NVARCHAR(80), Col03 NVARCHAR(80), Col04 NVARCHAR(80),
      Col05 NVARCHAR(80), Col06 NVARCHAR(80), Col07 NVARCHAR(80), Col08 NVARCHAR(80),
      Col09 NVARCHAR(80), Col10 NVARCHAR(80), Col11 NVARCHAR(80), Col12 NVARCHAR(80),
      Col13 NVARCHAR(80), Col14 NVARCHAR(80), Col15 NVARCHAR(80), Col16 NVARCHAR(80),
      Col17 NVARCHAR(80), Col18 NVARCHAR(80), Col19 NVARCHAR(80), Col20 NVARCHAR(80),
      Col21 NVARCHAR(80), Col22 NVARCHAR(80), Col23 NVARCHAR(80), Col24 NVARCHAR(80),
      Col25 NVARCHAR(80), Col26 NVARCHAR(80), Col27 NVARCHAR(80), Col28 NVARCHAR(80),
      Col29 NVARCHAR(80), Col30 NVARCHAR(80), Col31 NVARCHAR(80), Col32 NVARCHAR(80),
      Col33 NVARCHAR(80), Col34 NVARCHAR(80), Col35 NVARCHAR(80), Col36 NVARCHAR(80),
      Col37 NVARCHAR(80), Col38 NVARCHAR(80), Col39 NVARCHAR(80), Col40 NVARCHAR(80),
      Col41 NVARCHAR(80), Col42 NVARCHAR(80), Col43 NVARCHAR(80), Col44 NVARCHAR(80),
      Col45 NVARCHAR(80), Col46 NVARCHAR(80), Col47 NVARCHAR(80), Col48 NVARCHAR(80),
      Col49 NVARCHAR(80), Col50 NVARCHAR(80), Col51 NVARCHAR(80), Col52 NVARCHAR(80),
      Col53 NVARCHAR(80), Col54 NVARCHAR(80), Col55 NVARCHAR(80), Col56 NVARCHAR(80),
      Col57 NVARCHAR(80), Col58 NVARCHAR(80), Col59 NVARCHAR(80), Col60 NVARCHAR(80)
   );
   -- Return an error message if there is no data
   IF NOT EXISTS (SELECT 1 FROM @tempTable)
   BEGIN
      INSERT INTO @Result (Col01, Col09)
	   VALUES ('Kitting Label', 'No data found for DropID');
	   SELECT * FROM @Result;
	      RETURN;
   END;
   ELSE
   BEGIN		   
      INSERT INTO @Result (
         Col01,
	     Col02,
	     Col03,
         Col04,
         Col05,
	     Col06,
	     Col07,
	     Col08,
	     Col10,
	     Col11
      )
      SELECT 
         OrderName,
         OrderID,
	     WaveID,
	     [Delivery_Date&Time],
	     [Date&Time_Picked],
	     @To_loc,
	     UID,
	     DropID,
	     LabelHeader,
	     SequenceCab
      FROM @tempTable WHERE ID = 0;
   END;
   --Final output
   SELECT * FROM @Result ORDER BY ID;
END;
