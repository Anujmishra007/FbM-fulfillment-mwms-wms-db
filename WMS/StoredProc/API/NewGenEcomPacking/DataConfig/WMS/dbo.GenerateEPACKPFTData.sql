CREATE OR ALTER PROC [dbo].[GenerateEPACKPFTData] (
     @c_AppType           NVARCHAR(10) = ''
)

AS BEGIN  
  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE  
      @nFunctionID   int,  
      @cStorerKey    nvarchar(15),  
      @cLoadKey      nvarchar(10),  
      @cTaskBatchNo  nvarchar(10),  
      @cOrderKey     nvarchar(10),  
      @cOrderMode    nvarchar(10),  
      @cSKU          nvarchar(20),  
      @nQty          int,  
      @cLoginId      nvarchar(30),  
      @cComputerName nvarchar(30),
      @cCartonType   nvarchar(20),  
      @dWeight       float,  
      @CTNTypeInput  char(1),  
      @WeightInput   char(1)  
  
   DECLARE cur_0 CURSOR FAST_FORWARD READ_ONLY FOR  
      SELECT 
         FunctionID, 
         Storerkey, 
         CASE WHEN @c_AppType = 'NEWGEN' THEN '' ELSE LoginId END, 
         LoadKey, 
         CASE WHEN @c_AppType = 'NEWGEN' THEN LoginId ELSE '' END
      FROM SimulationCriteria  
      WHERE FunctionID IN (998,999)  
      AND Status = '0'  
   OPEN cur_0  
   FETCH NEXT FROM cur_0 INTO @nFunctionId, @cStorerKey, @cLoginId, @cLoadKey, @cComputerName 
   WHILE @@FETCH_STATUS <> -1  
   BEGIN 
      SELECT @CTNTypeInput=isnull(svalue,'0')  
      FROM Storerconfig(nolock)  
      WHERE Storerkey=@cStorerkey and configkey='CTNTypeInput'  
  
      SELECT @WeightInput=isnull(svalue,'0')  
      FROM Storerconfig(nolock)  
      WHERE Storerkey=@cStorerkey and configkey='WeightInput'  
  
      SET @cCartonType = ''  
  
      IF @CTNTypeInput = '1'  
      BEGIN  
        SELECT @cCartonType=CartonType  
        FROM CARTONIZATION AS t1(nolock) inner join STORER AS t2(nolock) on t1.CARTONIZATIONGroup=t2.CartonGroup  
        WHERE t2.Storerkey=@cStorerkey and t1.UseSequence=1  
      END  
  
      DECLARE cur_1 CURSOR FAST_FORWARD READ_ONLY FOR  
         SELECT Distinct t1.PickslipNo  
         FROM  PickDetail as t1(nolock) inner join Orders as t2(nolock) on t1.OrderKey=t2.Orderkey  
         WHERE t2.Loadkey=@cLoadkey   
         AND isnull(t1.PickslipNo,'')<>''  
         ORDER BY t1.PickslipNo  
      OPEN cur_1  
      FETCH NEXT FROM cur_1 INTO @cTaskBatchNo  
      WHILE @@FETCH_STATUS <> -1  
      BEGIN   
         IF NOT EXISTS(SELECT 1 FROM PICKDETAIL(nolock) WHERE PickslipNo=@cTaskBatchNo and Status='5')  
         BEGIN  
            SELECT @cOrderMode=MAX(OrderMode)  
            FROM PACKTASK(nolock)  
            WHERE TaskBatchNo=@cTaskBatchNo  
         
            IF NOT EXISTS(SELECT 1 FROM PACKTASK(nolock) WHERE TaskBatchNo=@cTaskBatchNo and isnull(LogicalName,'')='' AND LEFT(@cOrderMode ,1)='M')  
            BEGIN  
               DECLARE cur_pickdetail CURSOR FAST_FORWARD READ_ONLY FOR  
                  SELECT Orderkey, SKU, Qty  
                  FROM  PickDetail(nolock)  
                  WHERE Pickslipno=@cTaskBatchNo  
                  ORDER BY  Orderkey  
                  OPEN cur_pickdetail  

               FETCH NEXT FROM cur_pickdetail INTO @cOrderKey, @cSKU, @nQty  
               WHILE @@FETCH_STATUS <> -1  
               BEGIN
                  SET @dWeight = 0  
  
                  IF @WeightInput = '1'  
                  BEGIN  
                     SELECT @dWeight=STDGrossWgt  
                     FROM SKU(nolock)  
                     WHERE Storerkey=@cStorerkey and SKU=@cSKU  
                  
                     IF @dWeight =0   
                        SET @dWeight=1.2  
                  END  

                  WHILE @nQty>0  
                  BEGIN  
                     INSERT INTO EPACKPFTDATA(TASKBATCHNO, OrderKey, OrderMode, CartonNo, SKU, RefNo, CartonType, [Weight], [Status], LoginID, AppType, ComputerName)  
                     VALUES(@cTaskBatchNo , @cOrderKey , @cOrderMode, 1, @cSKU, '', @cCartonType, @dWeight, '0', @cLoginId, @c_AppType, @cComputerName)  

                     SET @nQty = @nQty - 1  
                  END   
                  FETCH NEXT FROM cur_pickdetail INTO @cOrderkey, @cSKU, @nQty  
               END  
               CLOSE cur_pickdetail  
               DEALLOCATE cur_pickdetail  
            END  

         END  
  
         UPDATE EPACKPFTDATA  
         SET PackConfirm=t1.PackConfirm  
         FROM (SELECT TaskBatchNo, OrderKey, Max(RowRef) as RowRef, 'Y' as PackConfirm  
               FROM EPACKPFTDATA(NOLOCK)  
         WHERE TaskBatchNo = @cTaskBatchNo  
         GROUP BY TaskBatchNo, OrderKey) as t1  
         WHERE EPACKPFTDATA.TaskBatchNo=t1.TaskBatchNo and EPACKPFTDATA.OrderKey=t1.OrderKey and EPACKPFTDATA.RowRef=t1.RowRef  
  
         IF @nFunctionID=998  
         BEGIN  
            UPDATE EPACKPFTDATA  
            SET Orderkey = ''  
            WHERE TaskBatchNo = @cTaskBatchNo  
         END  
         ELSE IF @nFunctionID=999  
         BEGIN  
            UPDATE EPACKPFTDATA  
            SET TaskBatchNo = ''  
            WHERE TaskBatchNo = @cTaskBatchNo  
         END  
         FETCH NEXT FROM cur_1 INTO @cTaskBatchNo  
      END  
      CLOSE cur_1  
      DEALLOCATE cur_1  
  
      UPDATE SimulationCriteria  
      SET  Status='9'  
      WHERE FunctionID IN(998, 999) and Storerkey=@cStorerkey and Loadkey=@cLoadKey  
  
      FETCH NEXT FROM cur_0 INTO @nFunctionId, @cStorerKey, @cLoginId, @cLoadKey, @cComputerName
   END  
   CLOSE cur_0  
   DEALLOCATE cur_0  
END  
