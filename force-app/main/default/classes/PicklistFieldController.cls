public class PicklistFieldController{    
    
    @AuraEnabled  
    public static Map<String,List<String>> getDependentOptionsImpl(string objApiName , string contrfieldApiName , string depfieldApiName){
        system.debug(objApiName + '##' + contrfieldApiName + '###' + depfieldApiName);
        
        String objectName = objApiName.toLowerCase();
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        
        if (!Schema.getGlobalDescribe().containsKey(objectName)){
            System.debug('OBJNAME NOT FOUND --.> ' + objectName);
            return null;
        }
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType==null){
            return objResults;
        }
        Bitset bitSetObj = new Bitset();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        //Check if picklist values exist
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            System.debug('FIELD NOT FOUND --.> ' + controllingField + ' OR ' + dependentField);
            return objResults;     
        }
        
        List<Schema.PicklistEntry> contrEntries = objFieldMap.get(controllingField).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> depEntries = objFieldMap.get(dependentField).getDescribe().getPicklistValues();
        objFieldMap = null;
        List<Integer> controllingIndexes = new List<Integer>();
        for(Integer contrIndex=0; contrIndex<contrEntries.size(); contrIndex++){            
            Schema.PicklistEntry ctrlentry = contrEntries[contrIndex];
            String label = ctrlentry.getLabel();
            objResults.put(label,new List<String>());
            controllingIndexes.add(contrIndex);
        }
        List<Schema.PicklistEntry> objEntries = new List<Schema.PicklistEntry>();
        List<PicklistEntryWrapper> objJsonEntries = new List<PicklistEntryWrapper>();
        for(Integer dependentIndex=0; dependentIndex<depEntries.size(); dependentIndex++){            
            Schema.PicklistEntry depentry = depEntries[dependentIndex];
            objEntries.add(depentry);
        } 
        objJsonEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objEntries), List<PicklistEntryWrapper>.class);
        List<Integer> indexes;
        for (PicklistEntryWrapper objJson : objJsonEntries){
            if (objJson.validFor==null || objJson.validFor==''){
                continue;
            }
            indexes = bitSetObj.testBits(objJson.validFor,controllingIndexes);
            for (Integer idx : indexes){                
                String contrLabel = contrEntries[idx].getLabel();
                objResults.get(contrLabel).add(objJson.label);
            }
        }
        objEntries = null;
        objJsonEntries = null;
        system.debug('objResults--->' + objResults);
        return objResults;
    }
    
    /*
    @AuraEnabled  //門市跟車。
    public static Map<String,List<String>> getDependentOptionsCar(string objApiName){
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        for(TestCar__c loopCar: [select id, UseStatus__c, Brand__c, Branch__c, 
            		CarType__c, VIN__c, Name, CarGeneration__c, Mileage__c, 
            		CarColor__c, FactoryYearMonth__c
        from TestCar__c
        order by VIN__r.CarGeneration__c])
        {
            List<String> BranchList = objResults.get(loopCar.Branch__c);
            if(BranchList == null)
            {
                BranchList = new list<string>();
                objResults.put(loopCar.Branch__c, BranchList);
            }
            BranchList.add(loopCar.id);
            
        }
        
        system.debug('objResults--->' + objResults);
        return objResults;
    }
    */
    
    @AuraEnabled  //門市跟車。
    public static Map<string,List<TestCar__c>> getDependentOptionsCard(string objApiName){
        Map<string,List<TestCar__c>> objResults = new Map<string,List<TestCar__c>>();
        list<string> StatusList = Label.Cons_TestDriveStatus.split(';');
        
        for(TestCar__c loopCar: [select id, TestDriveCarStatus__c, Brand__c, Branch__c, 
            		CarType__c, VIN__c, Name, CarGeneration__c, Mileage__c, 
            		CarColor__c, FactoryYearMonth__c
        from TestCar__c
		where (RetireDate__c = null or RetireDate__c >= today) and (TestDriveCarStatus__c IN: StatusList)
        order by Branch__c, VIN__r.CarGeneration__c])
        {
            List<TestCar__c> AllList = objResults.get('所有門市');
            if(AllList == null)
            {
				AllList = new list<TestCar__c>();
                objResults.put('所有門市', AllList);               
            }
            AllList.add(loopCar);
            
            List<TestCar__c> BranchList = objResults.get(loopCar.Branch__c);
            if(BranchList == null)
            {
                BranchList = new list<TestCar__c>();
                objResults.put(loopCar.Branch__c, BranchList);
            }
            BranchList.add(loopCar);
        }
        
        system.debug('objResults--->' + objResults);
        return objResults;
    }
    
    
    @AuraEnabled  //抓取Account 資訊。
    public static Account getAccountInfo(string accountId ){
    	Account returnAccount = new Account();
        for(Account loopAcc: [
            select 	id, Name, LastName, FirstName, PersonalID__c, Gender__pc, Phone, CompanyPhone__c, PersonMobilePhone, 
            Fax, PersonBirthdate, PersonEmail, HomeCity__c, HomeDistrict__c, HomeStreet__c, CompanyCity__c, CompanyDistrict__c, CompanyStreet__c
            from Account
            where id =: accountId])
        {
            returnAccount = loopAcc;
        }
        return returnAccount;
    }
}