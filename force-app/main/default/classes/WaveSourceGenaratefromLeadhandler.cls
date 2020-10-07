public with sharing class WaveSourceGenaratefromLeadhandler 
{
	public WaveSourceGenaratefromLeadhandler(){}

	public static void DoGenarateWaveSource(list<Lead> Lead_L)
    {
    	set<string> leadid_set = new set<string>();
        map<string, map<string, date>> Oppid_historydate_map = new map<string, map<string, date>>();
        set<string> WaveKPIStage = new set<string>();
        WaveKPIStage.add('Lead');

        set<string> WaveKPISourceExtid_set = new set<string>();
        list<WaveKPISource__c> UpsertWKPIS_L = new list<WaveKPISource__c>();

       	map<string, user> id_user_map = new map<string, user>();

        map<string, WaveKPISource__c> Extid_WKPIS_map = new map<string, WaveKPISource__c>();
        map<string, decimal> WKPISExtid_count_map = new map<string, decimal>();
        map<string, WaveKPISource__c> Extid_Current_WKPIS_map = new map<string, WaveKPISource__c>();
        
        set<string> OppWaveKPIInfo_set = new set<string>();

        set<string> leadOwnerid_set = new set<string>();
        set<string> TargetYear_set = new set<string>();
        set<string> TargetMonth_set = new set<string>();

        map<string, SalesTarget__c> Extid_SalesTarget_map = new map<string, SalesTarget__c>();

        for(lead le : Lead_L)
        {
            leadOwnerid_set.add(le.Ownerid);
            leadid_set.add(le.id);
        }

        for(user u : [select id, Firstname, Lastname, Profile.Name, Retailer__c, Branch__c from user where id in: leadOwnerid_set])
        {
        	id_user_map.put(u.id, u);
        }

        for(lead le : Lead_L)
        {
            WaveKPISource__c WKPIS = new WaveKPISource__c();
            //WKPIS.Achievement__c = '';
            //WKPIS.Brand__c = Opp.SelectedCar__r.Brand__c;
            //WKPIS.Car_Generation__c = Opp.SelectedCar__r.CarGeneration__c;
            //WKPIS.CarType__c = Opp.SelectedCar__r.CarType__c;
            if(id_user_map.containskey(le.Ownerid))if(id_user_map.get(le.Ownerid).Retailer__c != null)WKPIS.Dealer__c = id_user_map.get(le.Ownerid).Retailer__c;
            if(id_user_map.containskey(le.Ownerid))if(id_user_map.get(le.Ownerid).Retailer__c != null)WKPIS.Dealer_Type__c = id_user_map.get(le.Ownerid).Retailer__c.contains('汎德') ? 'PGM' : 'Indep.';
            //WKPIS.Gap__c = '';
            if(id_user_map.containskey(le.Ownerid))WKPIS.Dep__c = id_user_map.get(le.Ownerid).profile.name.contains('銷售') ? 'Sales' : 'Marketing';
            if(id_user_map.containskey(le.Ownerid))if(id_user_map.get(le.Ownerid).Branch__c != null)WKPIS.Outlet__c = id_user_map.get(le.Ownerid).Branch__c;
            if(id_user_map.containskey(le.Ownerid))WKPIS.Sales__c = id_user_map.get(le.Ownerid).LastName + id_user_map.get(le.Ownerid).FirstName;
            if(id_user_map.containskey(le.Ownerid))WKPIS.SalesId__c = le.OwnerId;
            WKPIS.Sell_Type__c = 'Retailer';
            WKPIS.Source__c = le.LeadSource;
            WKPIS.Stage__c = 'Lead';
            WKPIS.Type__c = 'Lead';
            WKPIS.Year__c = string.valueof(le.CreatedDate.year());
            WKPIS.Month__c = (le.CreatedDate.month() < 10 ? '0' : '') + string.valueof(le.CreatedDate.month());
            WKPIS.YearMonth__c = ConvertDate(WKPIS.Year__c, WKPIS.Month__c);
            if(!string.valueof(le.ownerid).startsWith('00G'))WKPIS.ownerid = le.ownerid;
            WKPIS.OppId__c = le.ConvertedOpportunityId;
            string  WKPISExtId =  (WKPIS.Dealer__c != null?WKPIS.Dealer__c:'') + '_' + (WKPIS.Outlet__c!=null?WKPIS.Outlet__c:'') + '_' + (WKPIS.Dealer_Type__c!=null?WKPIS.Dealer_Type__c:'') + '_' + (WKPIS.Type__c!=null?WKPIS.Type__c:'') + '_' + WKPIS.Year__c + '_' + WKPIS.Month__c + '_' + (WKPIS.Stage__c!=null?WKPIS.Stage__c:'') + '_' + (WKPIS.Dep__c!=null?WKPIS.Dep__c:'') + '_' + (WKPIS.Source__c!=null?WKPIS.Source__c:'') + '_' + (WKPIS.Brand__c!=null?WKPIS.Brand__c:'') + '_' + (WKPIS.Car_Generation__c!=null?WKPIS.Car_Generation__c:'') + '_' + (WKPIS.SalesId__c!=null?string.valueof(WKPIS.SalesId__c).substring(0, 15):'') + '_' + (WKPIS.Sell_Type__c!=null?WKPIS.Sell_Type__c:'') + '_' + (WKPIS.OppId__c!=null?WKPIS.OppId__c:'');
            system.debug('+++WKPISExtId: '+WKPISExtId);
            WKPIS.Extid__c = WKPISExtId;

            if(Extid_WKPIS_map.containskey(WKPISExtId))
            {
                WKPIS.Quantity__c = Extid_WKPIS_map.get(WKPISExtId).Quantity__c + 1;
            }
            else
            {
                WKPIS.Quantity__c = 1;
            }

            system.debug('+++WKPISExtId: '+WKPISExtId);
            //組成Opp 產生 WKPIS 的MAP
            Extid_WKPIS_map.put(WKPISExtId, WKPIS);
            /*if(WKPISExtid_count_map.contaoinskey(WKPISExtId))
            {
                WKPISExtid_count_map.put(WKPISExtId, WKPISExtid_count_map.get(WKPISExtId) + 1);
            }
            else 
            {
                WKPISExtid_count_map.put(WKPISExtId, 1);
            }*/

            TargetYear_set.add(WKPIS.Year__c);
            TargetMonth_set.add(WKPIS.Month__c);
        }

        /*for(SalesTarget__c ST : [select id, ownerid, owner.Firstname, Owner.Lastname, DeliverTarget__c, OpptyTarget__c, ContractTarget__c, TestDriveTarget__c, TargetYear__c, TargetMonth__c from SalesTarget__c where ownerid in: OppOwnerid_set and (TargetYear__c in: TargetYear_set or TargetMonth__c in: TargetMonth_set)])
        {
            string key = ST.ownerid + '_' + string.valueof(decimal.valueof(ST.TargetYear__c)) + '_' + string.valueof(decimal.valueof(ST.TargetMonth__c));
            Extid_SalesTarget_map.put(key, ST);
        }*/

        //抓取目前系統上對到 Extid_WKPIS_map 的 map
        for(WaveKPISource__c WKPIS : [select Extid__c, Quantity__c from WaveKPISource__c where Extid__c in: WKPISExtid_count_map.keyset()])
        {
            Extid_Current_WKPIS_map.put(WKPIS.Extid__c, WKPIS);
        }

        //若從lead batch 建立的 WKPIS 在 系統上已存在 把系統上的 數字抓出來加總 最後 upsert
        for(string key : Extid_WKPIS_map.keyset())
        {
            WaveKPISource__c tempWKPIS = Extid_WKPIS_map.get(key);
            if(Extid_Current_WKPIS_map.containskey(tempWKPIS.Extid__c))
            {
                tempWKPIS.Quantity__c = Extid_WKPIS_map.get(tempWKPIS.Extid__c).Quantity__c + Extid_Current_WKPIS_map.get(tempWKPIS.Extid__c).Quantity__c;
                Extid_WKPIS_map.put(tempWKPIS.Extid__c, tempWKPIS);
            }
        }

        /*for(string key : Extid_WKPIS_map.keyset())
        {
            WaveKPISource__c WKPIS = Extid_WKPIS_map.get(key);

            string SalesTargetKey = WKPIS.SalesId__c + '_' + WKPIS.Year__c + '_' + WKPIS.Month__c;

            if(Extid_SalesTarget_map.containskey(SalesTargetKey))
            {
                SalesTarget__c ST = Extid_SalesTarget_map.get(SalesTargetKey);
                WKPIS.Target_Contract__c = ST.ContractTarget__c;
                WKPIS.Target_Deliver__c = ST.DeliverTarget__c;
                WKPIS.Target_Oppt__c = ST.OpptyTarget__c;
                WKPIS.Target_TestDrive__c = ST.TestDriveTarget__c;

                Extid_WKPIS_map.put(WKPIS.Extid__c, WKPIS);
            }
        }*/

        if(Extid_WKPIS_map.keyset().size() > 0)
        {
            for(WaveKPISource__c WKPIS : Extid_WKPIS_map.values())
            {
                UpsertWKPIS_L.add(WKPIS);
            }

            upsert UpsertWKPIS_L Extid__c;
        }
    }

    public static date ConvertDate(string inputyear, string inputmonth)
    {
        Date myDate;
        if(!string.isblank(inputyear) && !string.isblank(inputmonth))
        {
            string year = inputyear;
            string month = inputmonth;
            string day = '1';
            string hour = '00';
            string minute = '00';
            string second = '00';
            string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second;
            myDate = date.valueOf(stringDate);
        }
        return myDate;
    }
}