public with sharing class TriggerHandler 
{
    public static boolean isRunning = false;
    public TriggerHandler() 
    {
        
    }
    
    //Relatioship 的trigger
    public static void syncRelationship(list<Relationship__c> newList, list<Relationship__c> oldList)
    {
        //insert。//只有insert 才會加。這裡用upsert。
        system.debug(newList[0].exid__c + ':' + newList[0].Id+':'+string.valueOf(trigger.isInsert) +':'+string.valueOf(trigger.isUpdate)+':'+ string.valueOf(TriggerHandler.isRunning));
        if(oldList == null)
        {
            if(TriggerHandler.isRunning == false)
            {
                list<Relationship__c> upsertList = new list<Relationship__c>();
                for(integer i=0; i<newList.size(); i++)
                {
                    newList[i].EXID__c = string.valueOf(newList[i].Keyman__c) + string.valueOf(newList[i].SecondMan__c);
                    Relationship__c tempRecord = new Relationship__c();
                    tempRecord.Keyman__c = newList[i].SecondMan__c;
                    tempRecord.SecondMan__c = newList[i].Keyman__c;
                    tempRecord.EXID__c = string.valueOf(tempRecord.Keyman__c) + string.valueOf(tempRecord.SecondMan__c);
                    tempRecord.Relation__c = newList[i].Relation__c;
                    upsertList.add(tempRecord);
                }
                
                TriggerHandler.isRunning = true;
                upsert upsertList EXID__c;
                TriggerHandler.isRunning = false;
            }
        }
        else //update
        {
            if(TriggerHandler.isRunning == false)
            {
                map<string, Relationship__c> keyMap = new map<string, Relationship__c>();
                for(integer i=0; i<newlist.size(); i++)
                {
                    //放入old 的Key。
                    keyMap.put(string.valueOf(oldList[i].SecondMan__c)+string.valueOf(oldList[i].Keyman__c), newlist[i]);
                    newlist[i].EXID__c = string.valueOf(newlist[i].Keyman__c) + string.valueOf(newlist[i].SecondMan__c);
                }
                
                list<Relationship__c> updateList = new list<Relationship__c>();
                for(Relationship__c loopRE: [SELECT ID, EXID__c FROM Relationship__c WHERE EXID__c IN: keyMap.keyset()])
                {
                    //假設都會抓得到。
                    loopRE.Keyman__c =  keyMap.get(loopRE.EXID__c).SecondMan__c;
                    loopRE.SecondMan__c =  keyMap.get(loopRE.EXID__c).Keyman__c;
                    loopRE.Relation__c = keyMap.get(loopRE.EXID__c).Relation__c;
                    loopRE.EXID__c = string.valueOf(loopRE.Keyman__c) + string.valueOf(loopRE.SecondMan__c);
                    updateList.add(loopRE);
                }
                TriggerHandler.isRunning = true;
                update updateList;
                TriggerHandler.isRunning = false;
            }
        }
    }
    
    //Opportunity-車牌及車身變更為大寫
    public static void OpportunityUpperCase(list<Opportunity>inputNew, list<Opportunity>inputOld)
    {
        for(integer i=0; i < inputNew.size(); i++)
        {
            //inputNew[i].inputVIN__c = string.isblank(inputNew[i].inputVIN__c)?'':inputNew[i].inputVIN__c.toUpperCase();
            inputNew[i].LicensePlate__c = string.isblank(inputNew[i].LicensePlate__c)?'':inputNew[i].LicensePlate__c.toUpperCase();
        }
    }
    

    //Opportunity-搜尋VIN
    //一筆沒問題，但多筆會發生問題。
    public static void OpportunityFindVIN(list<Opportunity>inputNew, list<Opportunity>inputOld)
    {
        map<string, NewCarPool__c> newVINMap = new map<string, NewCarPool__c>();
        map<string, UsedCarPool__c> oldVINMap = new map<string, UsedCarPool__c>();
        for(integer i=0; i< inputNew.size(); i++)
        {
            //如果來源試乘車有值，則忽略。
            if( trigger.isInsert || (trigger.isUpdate && inputNew[i].inputVIN__c != inputOld[i].inputVIN__c) )
            {
                if(inputNew[i].inputVIN__c != null && inputNew[i].SourceTestDriveCar__c == null)
                {
                    if(inputNew[i].IsUsedCar__c =='是')
                    {
                        oldVINMap.put(inputNew[i].inputVIN__c, null);    
                    }
                    else 
                    {
                        newVINMap.put(inputNew[i].inputVIN__c, null);    
                    }
                }
            }
        }
        
        //有值才走下一步。for 新車
        if(newVINMap.size() > 0)
        {
            //只有新車才能出售。順便抓取底下的未完成的OPP。
            //改用自訂標籤，使用; 做分隔
            //for(NewCarPool__c loopPool:[select id, name, (select id from Opportunities__r where IsClosed = false) from NewCarPool__c where name in:newVINMap.keyset() and Status__c = '新車'])
            list<string> StatusList = Label.Cons_NewCarVINForSale.split(';');
            for(NewCarPool__c loopPool:[select id, name, (select id from Opportunities__r where IsClosed = false) from NewCarPool__c where name in:newVINMap.keyset() and Status__c in: StatusList])
            {
                newVINMap.put(loopPool.Name, loopPool);
            }
            
            for(integer i=0; i< inputNew.size(); i++)
            {
                inputNew[i].CarNotFound__c = '';
                //只有否
                if(inputNew[i].IsUsedCar__c =='否')
                {
                    //如果來源試乘車有值，則忽略。
                    if(inputNew[i].inputVIN__c == null)
                    {
                        if(inputNew[i].SourceTestDriveCar__c == null)
                        {
                            inputNew[i].SelectedCar__c = null;
                        }
                    }
                    else
                    {
                        if(inputNew[i].SourceTestDriveCar__c == null)
                        {
                            NewCarPool__c tempCar = newVINMap.get(inputNew[i].inputVIN__c);
                            if(tempCar != null)
                            {
                                if(tempCar.Opportunities__r.size() > 0)
                                {
                                    //判斷是否為自己，如果不是，則不能新增。
                                    boolean isNotMe = false;
                                    for(integer j=0; j < tempCar.Opportunities__r.size(); j++)
                                    {
                                        if(tempCar.Opportunities__r[j].id != inputNew[i].id)
                                        {
                                            isNotMe = true;
                                        }
                                    }
                                    
                                    if(isNotMe)
                                    {
                                        inputNew[i].CarNotFound__c = 'NewCarExisting';
                                    }
                                    else
                                    {
                                        inputNew[i].SelectedCar__c = tempCar.id; 
                                    }
                                }
                                else
                                {
                                    inputNew[i].SelectedCar__c = tempCar.id;
                                }
                            }
                            else
                            {
                                inputNew[i].CarNotFound__c = 'CarNotFound';
                            }
                        }
                    }
                }
            }
        }
        
        //有值才走下一步。for 中古車
        if(oldVINMap.size() > 0)
        {
            //只有中古車才能出售。
            //改用自訂標籤，使用; 做分隔
            //for(UsedCarPool__c loopPool:[select id, name, VIN__c, VIN__r.Name, (select id from opportunity__r where isClosed = false) from UsedCarPool__c where VIN__r.Name in:oldVINMap.keyset() and CarStatus__c = '已入庫'])
            list<string> StatusList = Label.Cons_UsedCarVINForSale.split(';');
            for(UsedCarPool__c loopPool:[select id, name, VIN__c, VIN__r.Name, (select id from opportunity__r where isClosed = false) from UsedCarPool__c where VIN__r.Name in:oldVINMap.keyset() and CarStatus__c in:StatusList])
            {
                oldVINMap.put(loopPool.VIN__r.Name, loopPool);
            }
            
            for(integer i=0; i< inputNew.size(); i++)
            {
                inputNew[i].CarNotFound__c = '';
                //只有是
                if(inputNew[i].IsUsedCar__c =='是')
                {
                    if(inputNew[i].inputVIN__c == null)
                    {
                        inputNew[i].SelectedCar__c = null;
                    }
                    else
                    {
                        UsedCarPool__c tempCar = oldVINMap.get(inputNew[i].inputVIN__c);
                        if(tempCar != null)
                        {
                            if(tempCar.Opportunity__r.size() > 0)
                            {
                                //判斷是否為自己，如果不是，則不能新增。
                                boolean isNotMe = false;
                                for(integer j=0; j < tempCar.Opportunity__r.size(); j++)
                                {
                                    if(tempCar.Opportunity__r[j].id != inputNew[i].id)
                                    {
                                        isNotMe = true;
                                    }
                                }
                                
                                if(isNotMe)
                                {
                                    inputNew[i].CarNotFound__c = 'UsedCarExisting';
                                }
                                else
                                {
                                    inputNew[i].SelectedCar__c = tempCar.VIN__c;
                                    inputNew[i].UsedCarPool__c = tempCar.id;
                                }
                            }
                            else
                            {
                                inputNew[i].SelectedCar__c = tempCar.VIN__c;
                                inputNew[i].UsedCarPool__c = tempCar.id;
                            }
                        }
                        else
                        {
                            inputNew[i].CarNotFound__c = 'CarNotFound';
                        }
                    }
                }
            }
        }
    }
    
    //Opportunity-更新F聯繫紀錄。
    public static void OpportunityUpdateFContactRecord(list<Opportunity>inputNew, list<Opportunity>inputOld)
    {
        for(integer i=0; i < inputNew.size(); i++)
        {
            //如果為F。
            if(inputNew[i].LastContactRate__c == 'F')
            {
                if(inputNew[i].FirstFContactRecord__c == null)
                {
                    inputNew[i].FirstFContactRecord__c = inputNew[i].LastContactRecord__c;
                }
                /* 後面的不用了，因為改判斷方式了。
                else if(inputNew[i].FirstFContactRecord__c == inputNew[i].LastContactRecord__c)
                {
                    //如果一樣就沒事。不一樣就走下一步。
                }
                else if(inputNew[i].SecondFContactRecord__c == null)
                {
                    inputNew[i].SecondFContactRecord__c = inputNew[i].LastContactRecord__c;
                }
                else if(inputNew[i].SecondFContactRecord__c == inputNew[i].LastContactRecord__c)
                {
                    //如果一樣就沒事。不一樣就走下一步。
                }
                else
                {
                    
                }
                */
            }
            /*
            else if(inputNew[i].LastContactRate__c == 'P')
            {
                
            }
            */
        }
    }
    
    
    //新增Used Car-搜尋VIN
    public static void UsedCarFindVIN(list<UsedCarPool__c>inputNew, list<UsedCarPool__c>inputOld)
    {
        map<string, NewCarPool__c> VINMap = new map<string, NewCarPool__c>();
        for(integer i=0; i< inputNew.size(); i++)
        {
            //if((trigger.isInsert || (trigger.isUpdate && inputNew[i].inputVin__c != trigger.old[i].inputVIN__c))&& inputNew[i].inputVIN__c != null)
            if(inputNew[i].inputVIN__c != null)
            {
                VINMap.put(inputNew[i].inputVIN__c, null);
            }
        }
        
        //有值才走下一步。
        if(VINMap.size() > 0)
        {
            //所有車都可以出售。
            //改用自訂標籤，使用; 做分隔
            //for(NewCarPool__c loopPool:[select id, name, (select CarStatus__c, id from UsedCar__r where CarStatus__c in('未入庫', '已入庫', '已入庫(關注中)', '已下訂') ) from NewCarPool__c where name in:VINMap.keyset()])
            list<string> UsedCarStatusList = Label.Cons_UsedCarVINforAdd.split(';');
            list<string> NewCarStatusList = Label.Cons_UsedCarVINforNewCar.split(';');
            for(NewCarPool__c loopPool:[select id, name, (select CarStatus__c, id from UsedCar__r where CarStatus__c in:UsedCarStatusList ) from NewCarPool__c where name in:VINMap.keyset() and Status__c in: NewCarStatusList])
            {
                VINMap.put(loopPool.Name, loopPool);
            }
            
            for(integer i=0; i< inputNew.size(); i++)
            {
                inputNew[i].CarNotFound__c = '';
                if(inputNew[i].inputVIN__c == null)
                {
                    inputNew[i].VIN__c = null;
                }
                else
                {
                    NewCarPool__c tempCar = VINMap.get(inputNew[i].inputVIN__c);
                    if(tempCar != null)
                    {
                        if(tempCar.UsedCar__r.size() > 0 )
                        {
                            boolean isNotMe = false;
                            for(integer j=0; j < tempCar.UsedCar__r.size(); j++)
                            {
                                if(tempCar.UsedCar__r[j].id != inputNew[i].id)
                                {
                                    isNotMe = true;
                                }
                            }
                            
                            if(isNotMe)
                            {
                                inputNew[i].CarNotFound__c = 'UsedCarExisting';
                            }
                            else
                            {
                                inputNew[i].VIN__c = tempCar.id; 
                            }
                        }
                        else
                        {
                            inputNew[i].VIN__c = tempCar.id;    
                        }
                    }
                    else
                    {
                        inputNew[i].CarNotFound__c = 'CarNotFound';
                    }
                }
            }
        }
    }
    
    //TransferCarForm -搜尋VIN
    //一筆沒問題，但多筆會發生問題。
    public static void TransferCarFindVIN(list<CarTransferForm__c>inputNew, list<CarTransferForm__c>inputOld)
    {
        map<string, NewCarPool__c> newVINMap = new map<string, NewCarPool__c>();
        for(integer i=0; i< inputNew.size(); i++)
        {
            //如果來源試乘車有值，則忽略。
            if( trigger.isInsert || (trigger.isUpdate && inputNew[i].inputVIN__c != inputOld[i].inputVIN__c) )
            {
                if(inputNew[i].inputVIN__c != null)
                {
                    newVINMap.put(inputNew[i].inputVIN__c, null);    
                }
            }
        }
        
        //有值才走下一步。for 新車
        if(newVINMap.size() > 0)
        {
            //只有新車才能調撥。順便抓取底下的未完成的OPP判斷。
            //改用自訂標籤，使用; 做分隔
            //for(NewCarPool__c loopPool:[select id, name, (select id from Opportunities__r where IsClosed = false) from NewCarPool__c where name in:newVINMap.keyset() and Status__c = '新車'])
            list<string> StatusList = Label.Cons_NewCarVINForSale.split(';');
            for(NewCarPool__c loopPool:[select id, name, (select id from Opportunities__r where IsClosed = false) from NewCarPool__c where name in:newVINMap.keyset() and Status__c in: StatusList])
            {
                newVINMap.put(loopPool.Name, loopPool);
            }
            
            for(integer i=0; i< inputNew.size(); i++)
            {
                inputNew[i].CarNotFound__c = '';
                
                if( trigger.isInsert || (trigger.isUpdate && inputNew[i].inputVIN__c != inputOld[i].inputVIN__c) )
                {
                    if(inputNew[i].inputVIN__c != null)
                    {
                        NewCarPool__c tempCar =  newVINMap.get(inputNew[i].inputVIN__c);
                        if(tempCar != null)
                        {
                            //有未結束的有望，就不能調撥。
                            if(tempCar.Opportunities__r.size() > 0 )
                            {
                               inputNew[i].CarNotFound__c = 'NoneClosedOPP';
                            }
                            else
                            {
                                inputNew[i].NewCarPool__c = tempCar.id;    
                            }
                        }
                        else
                        {
                            inputNew[i].CarNotFound__c = 'CarNotFound';
                        }
                    }
                }
            }
        }
    }
    
    
    //TransferCarForm - 對應經銷商代碼
    public static void TransferCarDealerMappign(list<NewCarPool__c>inputNew, list<NewCarPool__c>inputOld)
    {
        list<string> CarTransforStatusList = Label.Cons_CarTransforStatus.split(';');
        map<string, DealerMapping__c> codeDealerMap = DealerMapping__c.getAll();
        map<string, string> delaerCodeMap  = new map<string, string>();
        for(string loopString: codeDealerMap.keySet())
        {
            delaerCodeMap.put(codeDealerMap.get(loopString).DealerName__c, loopString);
        }
        
        set<string> allMap = new set<string>(); 
        for(CarTransferForm__c loopForm:[select NewCarPool__c, id from CarTransferForm__c where NewCarPool__c in: inputNew and NewCarPool__c !=null and TransferStatus__c in:CarTransforStatusList])
        {
            allMap.add(loopForm.NewCarPool__c);
        }
        
        
        for(integer i=0; i < inputNew.size(); i++)
        {
            //如果已存在調撥完成的調撥單，則不動作。
            if(allMap.contains(inputNew[i].Id))
            {
                inputNew[i].VenderCode__c = delaerCodeMap.get(inputNew[i].Dealer__c);
            }
            else
            {
                if(codeDealerMap.containsKey(inputNew[i].VenderCode__c))
                {
                	inputNew[i].Dealer__c = codeDealerMap.get(inputNew[i].VenderCode__c).DealerName__c;    
                }
                else
                {
                    inputNew[i].addError('無此經銷商代碼: ' + inputNew[i].VenderCode__c);
                }
                
            }
        }
    }
    
    
    //NewCarPool - 更新出廠年月
    public static void newCarPoolYearMonth (list<NewCarPool__c>inputNew, list<NewCarPool__c>inputOld)
    {
    	for(NewCarPool__c looNP: inputNew)
    	{
    		if(looNP.FactoryYearMonth__c != null)
    		{
    			if(looNP.FactoryYear__c == null)
	    		{
	    			string tempYear = looNP.FactoryYearMonth__c.left(4);
					integer tempI = integer.valueOf(tempYear);
					if(tempI< 1999)
					{
						looNP.FactoryYear__c = '1999年以前';
					}
					else
					{
						looNP.FactoryYear__c = tempYear +'年';
					}
	    		}
	    		
	    		if(looNP.FactoryMonth__c == null)
	    		{
	    			string tempMonth = looNP.FactoryYearMonth__c.right(2);
					if(tempMonth == '01')
					{
						looNP.FactoryMonth__c = '一月';
					}
					else if(tempMonth == '02')
					{
						looNP.FactoryMonth__c = '二月';
					}
					else if(tempMonth == '03')
					{
						looNP.FactoryMonth__c = '三月';
					}
					else if(tempMonth == '04')
					{
						looNP.FactoryMonth__c = '四月';
					}
					else if(tempMonth == '05')
					{
						looNP.FactoryMonth__c = '五月';
					}
					else if(tempMonth == '06')
					{
						looNP.FactoryMonth__c = '六月';
					}
					else if(tempMonth == '07')
					{
						looNP.FactoryMonth__c = '七月';
					}
					else if(tempMonth == '08')
					{
						looNP.FactoryMonth__c = '八月';
					}
					else if(tempMonth == '09')
					{
						looNP.FactoryMonth__c = '九月';
					}
					else if(tempMonth == '10')
					{
						looNP.FactoryMonth__c = '十月';
					}
					else if(tempMonth == '11')
					{
						looNP.FactoryMonth__c = '十一月';
					}
					else if(tempMonth == '12')
					{
						looNP.FactoryMonth__c = '十二月';
					}
	    		}
    		}
    	}
    }
    
    //NewCarPool - 對應車源圖片
    public static void newCarPoolImage (list<NewCarPool__c>inputNew, list<NewCarPool__c>inputOld)
    {
    	list<string> allCarGeneration = new list<string>();
    	list<string> allCarType = new list<string>();
    	for(NewCarPool__c loopNP: inputNew)
    	{
    		allCarGeneration.add(loopNP.CarGeneration__c);
    		allCarType.add(loopNP.CarType__c);
    	}
    	
    	map<string, CarPhoto__c> carPhotoMap = new map<string,  CarPhoto__c>();
    	for(CarPhoto__c loopCP: [
    		select CarType__c, CarGeneration__c 
    		from CarPhoto__c 
    		where CarType__c in: allCarType or CarGeneration__c in: allCarGeneration
    		order by lastmodifieddate
    	])
    	{
    		string tempKey = '';
    		
    		if(! string.isBlank(loopCP.CarGeneration__c) )
    		{
    			tempKey += loopCP.CarGeneration__c ;
    		}
    		
    		if(! string.isBlank(loopCP.CarType__c) )
    		{
    			tempKey += loopCP.CarType__c ;
    		}
    		
    		if(! string.isBlank(tempKey))
    		{
    			carPhotoMap.put(tempKey, loopCP);
    		}
    	}
    	
    	for(NewCarPool__c loopNP: inputNew)
    	{
    		string tempKey1 = '';
    		string tempKey2 = '';
    		
    		if(! string.isBlank(loopNP.CarGeneration__c) )
    		{
    			tempKey1 += loopNP.CarGeneration__c ;
    			tempKey2 += loopNP.CarGeneration__c ;
    		}
    		
    		if(! string.isBlank(loopNP.CarType__c) )
    		{
    			tempKey2 += loopNP.CarType__c ;
    		}
    		
    		if(carPhotoMap.containskey(tempKey1))
    		{
    			CarPhoto__c tempCP = carPhotoMap.get(tempKey1);
    			loopNP.CarPhotosource__c = tempCP.id;
    		}
    		//如果有一樣，再以這個為主。
    		if(tempKey2 != tempKey1 && carPhotoMap.containskey(tempKey2))
    		{
    			CarPhoto__c tempCP = carPhotoMap.get(tempKey2);
    			loopNP.CarPhotosource__c = tempCP.id;
    		}
    	}
    }
    
    //Lead-搜尋郵遞區號
    public static void LeadQueryZipCode(list<Lead>inputNew, list<Lead>inputOld)
    {
        for(ZipCodeMapping__c loopZCM: ZipCodeMapping__c.getAll().Values())
        {
            if(loopZCM.ObjectAPI__c =='Lead')
            {
                if(inputOld != null)
                {
                    system.debug(inputNew[0].get(loopZCM.CityAPI__c));
                    for(integer i=0; i < inputNew.size(); i++)
                    {
                        if( (inputNew[i].get(loopZCM.CityAPI__c) != inputOld[i].get(loopZCM.CityAPI__c)) || 
                            (inputNew[i].get(loopZCM.AreaAPI__c) != inputOld[i].get(loopZCM.AreaAPI__c)) 
                          )
                        {
                            string myZipCode = TriggerHandler.findZipCode(string.valueOf(inputNew[i].get(loopZCM.CityAPI__c))+string.valueOf(inputNew[i].get(loopZCM.AreaAPI__c)));
                            inputNew[i].put(loopZCM.ZipeCodeAPI__c, myZipCode);
                        }
                    }
                }
                else
                {
                    for(integer i=0; i < inputNew.size(); i++)
                    {
                        string myZipCode = TriggerHandler.findZipCode(string.valueOf(inputNew[i].get(loopZCM.CityAPI__c))+string.valueOf(inputNew[i].get(loopZCM.AreaAPI__c)));
                        inputNew[i].put(loopZCM.ZipeCodeAPI__c, myZipCode);   
                    }
                }
            }
        }
    }
    
    //Account-搜尋郵遞區號
    public static void AccountQueryZipCode(list<Account>inputNew, list<Account>inputOld)
    {
        for(ZipCodeMapping__c loopZCM: ZipCodeMapping__c.getAll().Values())
        {
            if(loopZCM.ObjectAPI__c =='Account')
            {
                if(inputOld != null)
                {
                    system.debug(inputNew[0].get(loopZCM.CityAPI__c));
                    for(integer i=0; i < inputNew.size(); i++)
                    {
                        if( (inputNew[i].get(loopZCM.CityAPI__c) != inputOld[i].get(loopZCM.CityAPI__c)) || 
                            (inputNew[i].get(loopZCM.AreaAPI__c) != inputOld[i].get(loopZCM.AreaAPI__c)) 
                          )
                        {
                            string myZipCode = TriggerHandler.findZipCode(string.valueOf(inputNew[i].get(loopZCM.CityAPI__c))+string.valueOf(inputNew[i].get(loopZCM.AreaAPI__c)));
                            inputNew[i].put(loopZCM.ZipeCodeAPI__c, myZipCode);
                        }
                    }
                }
                else
                {
                    for(integer i=0; i < inputNew.size(); i++)
                    {
                        string myZipCode = TriggerHandler.findZipCode(string.valueOf(inputNew[i].get(loopZCM.CityAPI__c))+string.valueOf(inputNew[i].get(loopZCM.AreaAPI__c)));
                        inputNew[i].put(loopZCM.ZipeCodeAPI__c, myZipCode);   
                    }
                }
            }
        }
    }
    
    //Opportunity-搜尋郵遞區號
    public static void OpportunityQueryZipCode(list<Opportunity>inputNew, list<Opportunity>inputOld)
    {
        for(ZipCodeMapping__c loopZCM: ZipCodeMapping__c.getAll().Values())
        {
            if(loopZCM.ObjectAPI__c =='Opportunity')
            {
                if(inputOld != null)
                {
                    system.debug(inputNew[0].get(loopZCM.CityAPI__c));
                    for(integer i=0; i < inputNew.size(); i++)
                    {
                        if( (inputNew[i].get(loopZCM.CityAPI__c) != inputOld[i].get(loopZCM.CityAPI__c)) || 
                            (inputNew[i].get(loopZCM.AreaAPI__c) != inputOld[i].get(loopZCM.AreaAPI__c)) 
                          )
                        {
                            string myZipCode = TriggerHandler.findZipCode(string.valueOf(inputNew[i].get(loopZCM.CityAPI__c))+string.valueOf(inputNew[i].get(loopZCM.AreaAPI__c)));
                            inputNew[i].put(loopZCM.ZipeCodeAPI__c, myZipCode);
                        }
                    }
                }
                else
                {
                    for(integer i=0; i < inputNew.size(); i++)
                    {
                        string myZipCode = TriggerHandler.findZipCode(string.valueOf(inputNew[i].get(loopZCM.CityAPI__c))+string.valueOf(inputNew[i].get(loopZCM.AreaAPI__c)));
                        inputNew[i].put(loopZCM.ZipeCodeAPI__c, myZipCode);   
                    }
                }
            }
        }
    }
    
    //Asset-更新車主flag。
    //20181016 新增現有車款數及購車總數
    /* 移至Without Sharing
    public static void changeCarUserStatus(list<Asset> inputNew, list<Asset> inputOld)
    {
        map<string, account> AccMap =  new map<string, account>();
        //insert
        if(inputOld == null)
        {
            for(integer i=0; i<inputNew.size(); i++)
            {
                AccMap.put(inputNew[i].AccountId, new Account(id=inputNew[i].AccountId, BuyCarNumber__c=0, ExistingCarNumber__c=0));
            }
        }
        else
        {
            for(integer i=0; i<inputNew.size(); i++)
            {
                //排除狀態更新的情況。
                //if(inputNew[i].Status != inputOld[i].Status)
                {
                    AccMap.put(inputNew[i].AccountId, new Account(id=inputNew[i].AccountId, BuyCarNumber__c=0, ExistingCarNumber__c=0));
                }
            }
        }
        //改用自訂標籤，使用; 做分隔
        list<string> statusList = Label.Cons_AssetStatusWithCarOwner.split(';');
        
        //總車輛數
        for(aggregateResult loopAR: [select AccountId ACCID, count(id) QTY from Asset where accountid in: AccMap.keyset() group by accountid])
        {
            Account TempAccount = AccMap.get(string.valueOf(loopAR.get('ACCID')));
            TempAccount.CarOwner__c = false;
            TempAccount.BuyCarNumber__c = integer.valueOf(loopAR.get('QTY'));
        }
        
        //現車總數
        for(aggregateResult loopAR: [select accountid ACCID, count(id) QTY from Asset where accountid in: AccMap.keyset() and Status in: statusList group by accountid])
        {
            Account TempAccount = AccMap.get(string.valueOf(loopAR.get('ACCID')));
            TempAccount.CarOwner__c = true;
            TempAccount.ExistingCarNumber__c = integer.valueOf(loopAR.get('QTY'));
        }
        
        update AccMap.values();
    }
	*/
    
    
    //Asset -搜尋VIN
    public static void AssetFindVIN(list<Asset>inputNew, list<Asset>inputOld)
    {
        map<string, NewCarPool__c> newVINMap = new map<string, NewCarPool__c>();
        for(integer i=0; i< inputNew.size(); i++)
        {
            if((trigger.isInsert && !string.isBlank(inputNew[i].AddedVin__c)) || (trigger.isUpdate && inputNew[i].AddedVin__c != inputOld[i].AddedVin__c) )
            {
                if(!string.isBlank(inputNew[i].AddedVin__c))
                {
                    newVINMap.put(inputNew[i].AddedVin__c, null);    
                }
            }
        }

        //因為是補登，所以所有的狀態都可以用。
        for(NewCarPool__c loopPool:[select id, name from NewCarPool__c where name in:newVINMap.keyset()])
        {
            newVINMap.put(loopPool.Name, loopPool);
        }
        
        for(integer i=0; i< inputNew.size(); i++)
        {
            inputNew[i].CarNotFound__c = '';
            
            if( (trigger.isInsert && !string.isBlank(inputNew[i].AddedVin__c) ) || (trigger.isUpdate && inputNew[i].AddedVin__c != inputOld[i].AddedVin__c) )
            {
            	system.debug('==luke: ' + string.isBlank(inputNew[i].AddedVin__c) );
                if(! string.isBlank(inputNew[i].AddedVin__c))
                {
                    NewCarPool__c tempCar =  newVINMap.get(inputNew[i].AddedVin__c);
                    if(tempCar != null)
                    {
                        inputNew[i].VIN__c = tempCar.id;    
                    }
                    else
                    {
                        inputNew[i].CarNotFound__c = 'CarNotFound';
                    }
                }
                else //從有值改成沒值。
                {
                	inputNew[i].VIN__c = null;
                }
            }
        }
    }
    
    //搜尋郵遞區號
    public static string findZipCode(string CityArea)
    {
        ZipCode__c myCS = ZipCode__c.getValues(CityArea);
        if(myCS != null)
        {
            return myCS.ZipCode__c;
        }
        return Label.Msg_ZipCodeNotFound;
    }

    //Lead 組成 重複規則 欄位
    public static void combinecontrolduplicateLead(list<Lead>inputNew, list<lead>inputOld)
    {
        for(lead le : inputNew)
        {
            le.ControlDuplicate__c = le.f_ControlDuplicate__c;
            le.NotifyDuplicate__c = le.f_NotifyDuplicate__c;
        }
    }
    
    //Account 組成 重複規則 欄位
    public static void combinecontrolduplicateAccount(list<Account>inputNew, list<Account>inputOld)
    {
        for(Account acc : inputNew)
        {
            acc.ControlDuplicate__c = acc.f_ControlDuplicate__c;
            acc.NotifyDuplicate__c = acc.f_NotifyDuplicate__c;

        }
    }
    
    //Lead 組成 Marketing Target 計算 欄位
    public static void marketingTargetLead(list<Lead>inputNew, list<lead>inputOld)
    {
        for(lead le : inputNew)
        {
            le.sys_MarketingValue__c = le.sys_f_MarketingValue__c;
        }
    }
    
    //Opportunity 組成 Marketing Target 計算 欄位
    public static void marketingTargetOpportunity(list<Opportunity>inputNew, list<Opportunity>inputOld)
    {
        for(Opportunity le : inputNew)
        {
            le.sys_MarketingValue__c = le.sys_f_MarketingValue__c;
        }
    }
    
    //Marketing Target Yeare 組成 Marketing Target 計算 欄位
    public static void marketingTargetYear(list<MarketingTargetY__c>inputNew, list<MarketingTargetY__c>inputOld)
    {
        for(MarketingTargetY__c le : inputNew)
        {
            le.RetailerYear__c = le.sys_f_MarketingYearValue__c;
        }
    }

    //Marketing Target 計算
    public static void calcularMarketingExactly(list<MarketingTargetY__c>inputNew, list<MarketingTargetY__c>inputOld)
    {
        for(MarketingTargetY__c loopMT : inputNew)
        {
            calcularMarketingExactlyFuture(loopMT.id);
        }
    }

    //Marketing Target 計算 future
    //多架一層殼。
    @future 
    public static void calcularMarketingExactlyFuture(string inputID)
    {
        MarketingTarget_Method.calculateYearTarget(inputID);
    }
    
    //Marketing Campaign 計算
    public static void calcularCampaign(list<Campaign>inputNew, list<Campaign>inputOld)
    {
        MarketingTarget_Method.calculateCampaignResult(inputNew);
    }
    
    //從acc帶資訊到Opp
    public static void FillOppInfoByAcc(list<Opportunity>inputNew, list<Opportunity>inputOld)
    {
        set<string> Accid_set = new set<string>();
        map<string, Account> Acc_map = new map<string, Account>();
        for(Opportunity opp : inputNew)
        {
            Accid_set.add(opp.AccountId);
        }
        
        for(Account acc : [select id, Phone, MainAddress__c, CompanyPhone__c, PersonMobilePhone, HomeCity__c, HomeStreet__c, HomePostCode__c, HomeDistrict__c,
                           CompanyCity__c, CompanyStreet__c, CompanyPostCode__c, CompanyDistrict__c
                           from account 
                           where id in: Accid_set])
        {
            Acc_map.put(acc.id, acc);
        }
        
        for(Opportunity opp : inputNew)
        {
            Account tmpacc = Acc_map.get(opp.AccountId);
           
            if(tmpacc != null)
            {
                if(string.isblank(opp.HomePhone__c)) opp.HomePhone__c = tmpacc.phone;
                if(string.isblank(opp.CompanyPhone__c)) opp.CompanyPhone__c = tmpacc.CompanyPhone__c;
                if(string.isblank(opp.Mobile__c)) opp.Mobile__c = tmpacc.PersonMobilePhone;
                
                if(tmpacc.MainAddress__c == '住家')
                {	
                    if(string.isblank(opp.ContactCity__c)) opp.ContactCity__c = tmpacc.HomeCity__c;
                    if(string.isblank(opp.ContactStree__c)) opp.ContactStree__c = tmpacc.HomeStreet__c;
                    if(string.isblank(opp.ContactDistrict__c)) opp.ContactDistrict__c = tmpacc.HomeDistrict__c;
                    if(string.isblank(opp.ContactPostCode__c)) opp.ContactPostCode__c = tmpacc.HomePostCode__c;
                }
                else if(tmpacc.MainAddress__c == '公司')
                {   
                    if(string.isblank(opp.ContactCity__c)) opp.ContactCity__c = tmpacc.CompanyCity__c;
                    if(string.isblank(opp.ContactStree__c)) opp.ContactStree__c = tmpacc.CompanyStreet__c;
                    if(string.isblank(opp.ContactDistrict__c)) opp.ContactDistrict__c = tmpacc.CompanyDistrict__c;
                    if(string.isblank(opp.ContactPostCode__c)) opp.ContactPostCode__c = tmpacc.CompanyPostCode__c;
                }
            }
        }
    }
    
    //試駕車不可以重覆預約
    //改為without sharing
    public static void TestDriveOnlyOne(list<TestDriveReservation__c>inputNew, list<TestDriveReservation__c>inputOld)
    {
        TriggerHandlerWithoutSharing.TestDriveOnlyOne(inputNew, inputOld);
    }
    
    //update ONLY
    //變更時，Account共用Sharing 資料。
    public static void AccountSharing(list<Account>inputNew, list<Account>inputOld)
    {   
        list<string> accList = new list<string>();
        for(integer i=0; i <inputNew.size(); i++)
        {
            //Owner ID 有換過。
            if(inputNew[i].ownerId != inputOld[i].ownerId)
            {
                accList.add(inputNew[i].id);
                //五筆五筆一個commit，假設一次最多250 筆的Account 做移轉，可以有50個future call。
                //假設一個Account 有1000資料做移轉，五筆就是1000*2*5 = 10000 個。
                if(accList.size() == 5)
                {
                    TriggerHandlerWithoutSharing.AccountSharing(accList);
                    accList = new list<string>();
                }
            }
        }
        
        if(accList.size() > 0)
        {
            TriggerHandlerWithoutSharing.AccountSharing(accList);
        }
    }
    
    //變更時，聯繫紀錄共用Sharing 資料。以抓取Account 及有望Owner 為主。
	public static void WorkLogSharing(list<WorkLog__c>inputNew, list<WorkLog__c>inputOld)
    {
        list<string> WorkLogList   = new list<string>();
        //新增直接跑
        if(inputOld == null)
        {
            for(integer i=0; i <inputNew.size(); i++)
            {
                WorkLogList.add(inputNew[i].id);
            }
        }
        //變更的話，要change Owner 才跑。
        else
        {
            for(integer i=0; i <inputNew.size(); i++)
            {
                //Owner ID 有換過。
                if(inputNew[i].ownerId != inputOld[i].ownerId)
                {
                    WorkLogList.add(inputNew[i].id);
                }
            }
        }
        
        if(WorkLogList.size() > 0)
        {
            TriggerHandlerWithoutSharing.WorkLogSharing(WorkLogList);
        }
    }
    
    /* 不用這一段。因為Account 會自動共用OPP。
    OPP 不用
	*/
    
    //變更時，Asset共用Sharing 資料。以抓取Account 及有望Owner 為主。
	public static void AssetSharing(list<Asset>inputNew, list<Asset>inputOld)
    {
        list<string> AssetList   = new list<string>();
        //新增直接跑
        if(inputOld == null)
        {
            for(integer i=0; i <inputNew.size(); i++)
            {
                AssetList.add(inputNew[i].id);
            }
        }
        //變更的話，要change Owner 才跑。
        else
        {
            for(integer i=0; i <inputNew.size(); i++)
            {
                //Owner ID 有換過。
                if(inputNew[i].ownerId != inputOld[i].ownerId)
                {
                    AssetList.add(inputNew[i].id);
                }
            }
        }
        
        if(AssetList.size() > 0)
        {
            TriggerHandlerWithoutSharing.AssetSharing(AssetList);
        }
    }
    
    //變更時，Relationship共用Sharing 資料。以抓取Account為主。
	public static void RelationSharing(list<Relationship__c>inputNew, list<Relationship__c>inputOld)
    {
        list<string> RelationList   = new list<string>();
        //新增直接跑
        if(inputOld == null)
        {
            for(integer i=0; i <inputNew.size(); i++)
            {
                RelationList.add(inputNew[i].id);
            }
        }
        //變更的話，要change Owner 才跑。
        else
        {
            for(integer i=0; i <inputNew.size(); i++)
            {
                //Owner ID 有換過。
                if(inputNew[i].ownerId != inputOld[i].ownerId)
                {
                    RelationList.add(inputNew[i].id);
                }
            }
        }
        
        if(RelationList.size() > 0)
        {
            TriggerHandlerWithoutSharing.RelactionSharing(RelationList);
        }
    }
    
    //變更時，LoyalProgram共用Sharing 資料。以抓取Account為主。
	public static void LoyalSharing(list<LoyalProgramMember__c>inputNew, list<LoyalProgramMember__c>inputOld)
    {
        list<string> LoyalList   = new list<string>();
        //新增直接跑
        if(inputOld == null)
        {
            for(integer i=0; i <inputNew.size(); i++)
            {
                LoyalList.add(inputNew[i].id);
            }
        }
        //變更的話，要change Owner 才跑。
        else
        {
            for(integer i=0; i <inputNew.size(); i++)
            {
                //Owner ID 有換過。
                if(inputNew[i].ownerId != inputOld[i].ownerId)
                {
                    LoyalList.add(inputNew[i].id);
                }
            }
        }
        
        if(LoyalList.size() > 0)
        {
            TriggerHandlerWithoutSharing.LoyalSharing(LoyalList);
        }
    }
    
    //變更時，試駕預約共用Sharing 資料。
	public static void TestDriveSharing(list<TestDriveReservation__c>inputNew, list<TestDriveReservation__c>inputOld)
    {
        list<string> TestDriveList   = new list<string>();
        //新增直接跑
        if(inputOld == null)
        {
            for(integer i=0; i <inputNew.size(); i++)
            {
                TestDriveList.add(inputNew[i].id);
            }
        }
        //變更的話，要change Owner 才跑。
        else
        {
            for(integer i=0; i <inputNew.size(); i++)
            {
                //Owner ID 有換過。
                if(inputNew[i].ownerId != inputOld[i].ownerId)
                {
                    TestDriveList.add(inputNew[i].id);
                }
            }
        }
        
        if(TestDriveList.size() > 0)
        {
            TriggerHandlerWithoutSharing.TestDriveSharing(TestDriveList);
        }
    }
    
    //變更時，問卷共用Sharing 資料。
	public static void SurveySharing(list<SurveyTaker__c>inputNew, list<SurveyTaker__c>inputOld)
    {
        list<string> SurveyList   = new list<string>();
        //新增直接跑
        if(inputOld == null)
        {
            for(integer i=0; i <inputNew.size(); i++)
            {
                SurveyList.add(inputNew[i].id);
            }
        }
        //變更的話，要change Owner 才跑。
        else
        {
            for(integer i=0; i <inputNew.size(); i++)
            {
                //Owner ID 有換過。
                if(inputNew[i].ownerId != inputOld[i].ownerId)
                {
                    SurveyList.add(inputNew[i].id);
                }
            }
        }
        
        if(SurveyList.size() > 0)
        {
            TriggerHandlerWithoutSharing.SurveyTakenSharing(SurveyList);
        }
    }
}