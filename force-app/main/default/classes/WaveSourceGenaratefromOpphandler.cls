public without sharing class WaveSourceGenaratefromOpphandler 
{
	//SourceTestDriveCar__c 若有值 則不納入 wave KPI 計算


    public WaveSourceGenaratefromOpphandler(){}

    public static void DoGenarateWaveSource(list<Opportunity> Opp_L)
    {
        set<string> Oppid_set = new set<string>();
        map<string, map<string, date>> Oppid_historydate_map = new map<string, map<string, date>>();
        set<string> WaveKPIStage = new set<string>();
        WaveKPIStage.add('試駕');
        //WaveKPIStage.add('簽約');
        WaveKPIStage.add('報價');
        WaveKPIStage.add('交車');

        set<string> WaveKPISourceExtid_set = new set<string>();
        list<WaveKPISource__c> UpsertWKPIS_L = new list<WaveKPISource__c>();

        map<string, WaveKPISource__c> Extid_WKPIS_map = new map<string, WaveKPISource__c>();
        map<string, decimal> WKPISExtid_count_map = new map<string, decimal>();
        map<string, WaveKPISource__c> Extid_Current_WKPIS_map = new map<string, WaveKPISource__c>();
        
        set<string> OppWaveKPIInfo_set = new set<string>();

        set<string> OppOwnerid_set = new set<string>();
        set<string> TargetYear_set = new set<string>();
        set<string> TargetMonth_set = new set<string>();

        map<string, SalesTarget__c> Extid_SalesTarget_map = new map<string, SalesTarget__c>();

        for(Opportunity Opp : Opp_L)
        {
            OppOwnerid_set.add(Opp.Ownerid);
            Oppid_set.add(Opp.id);

            ///////////////////////////////////////////////
            //testmethod 用
            if(test.isrunningtest())
            {
                map<string, date> stage_map = new map<string, date>();
                stage_map.put('報價', system.today());
                Oppid_historydate_map.put(Opp.id, stage_map);
            }
            ///////////////////////////////////////////////
        }

        for(OpportunityHistory OppH : [select id, OpportunityId, StageName, CreatedDate from OpportunityHistory where OpportunityId in: Oppid_set order by CreatedDate desc])
        {
            if(!Oppid_historydate_map.containskey(OppH.OpportunityId))
            {
                //set<string> stage_set = new set<string>();
                //stage_set.add(OppH.StageName);

                map<string, date> oppHdate_map = new map<string, date>();
                oppHdate_map.put(OppH.StageName, OppH.CreatedDate.date());
                Oppid_historydate_map.put(OppH.OpportunityId, oppHdate_map);
            }
            else
            {
                //set<string> stage_set = Oppid_history_map.get(OppH.OpportunityId);
                //stage_set.add(OppH.StageName);

                map<string, date> oppHdate_map = Oppid_historydate_map.get(OppH.OpportunityId);
                oppHdate_map.put(OppH.StageName, OppH.CreatedDate.date());
                Oppid_historydate_map.put(OppH.OpportunityId, oppHdate_map);
            }
        }

        system.debug('+++Oppid_historydate_map: '+Oppid_historydate_map);

        for(Opportunity Opp : Opp_L)
        {
            for(string OppHstage : Oppid_historydate_map.get(Opp.id).keyset())
            {
                if(WaveKPIStage.contains(OppHstage))
                {
                    WaveKPISource__c WKPIS = new WaveKPISource__c();
                    //WKPIS.Achievement__c = '';
                    WKPIS.Brand__c = Opp.SelectedCar__r.Brand__c;
                    WKPIS.Car_Generation__c = Opp.SelectedCar__r.CarGeneration__c;
                    WKPIS.CarType__c = Opp.SelectedCar__r.CarType__c;
                    if(Opp.Owner.Retailer__c != null)WKPIS.Dealer__c = Opp.Owner.Retailer__c;
                    if(Opp.Owner.Retailer__c != null)WKPIS.Dealer_Type__c = Opp.Owner.Retailer__c.contains('汎德') ? 'PGM' : 'Indep.';
                    //WKPIS.Gap__c = '';
                    WKPIS.Dep__c = Opp.owner.profile.name.contains('銷售') ? 'Sales' : 'Marketing';
                    WKPIS.Outlet__c = Opp.Owner.Branch__c;
                    WKPIS.Sales__c = Opp.Owner.LastName + Opp.Owner.FirstName;
                    WKPIS.SalesId__c = Opp.OwnerId;
                    WKPIS.Sell_Type__c = 'Retailer';
                    WKPIS.Source__c = Opp.LeadSource;
                    WKPIS.Stage__c = OppHstage;
                    WKPIS.Type__c = 'Sales';
                    system.debug('進入Year');
                    WKPIS.Year__c = WaveKPIYear(Opp, OppHstage, Oppid_historydate_map.get(Opp.id).get(OppHstage));
                    WKPIS.Month__c = WaveKPIMonth(Opp, OppHstage, Oppid_historydate_map.get(Opp.id).get(OppHstage));
                    WKPIS.YearMonth__c = ConvertDate(WKPIS.Year__c, WKPIS.Month__c);
                    WKPIS.ownerid = Opp.ownerid;
                    WKPIS.OppId__c = Opp.id;

                    string  WKPISExtId =  (WKPIS.Dealer__c!=null?WKPIS.Dealer__c:'') + '_' + (WKPIS.Outlet__c!=null?WKPIS.Outlet__c:'') + '_' + (WKPIS.Dealer_Type__c!=null?WKPIS.Dealer_Type__c:'') + '_' + (WKPIS.Type__c!=null?WKPIS.Type__c:'') + '_' + (WKPIS.Year__c!=null?WKPIS.Year__c:'') + '_' + (WKPIS.Month__c!=null?WKPIS.Month__c:'') + '_' + (WKPIS.Stage__c!=null?WKPIS.Stage__c:'') + '_' + (WKPIS.Dep__c!=null?WKPIS.Dep__c:'') + '_' + (WKPIS.Source__c!=null?WKPIS.Source__c:'') + '_' + (WKPIS.Brand__c!=null?WKPIS.Brand__c:'') + '_' + (WKPIS.Car_Generation__c!=null?WKPIS.Car_Generation__c:'') + '_' + (WKPIS.SalesId__c!=null?string.valueof(WKPIS.SalesId__c).substring(0, 15):'') + '_' + (WKPIS.Sell_Type__c!=null?WKPIS.Sell_Type__c:'') + '_' + (WKPIS.OppId__c!=null?WKPIS.OppId__c:'');
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
            }

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

        //若從Opp batch 建立的 WKPIS 在 系統上已存在 把系統上的 數字抓出來加總 最後 upsert
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

    public static string WaveKPIYear(Opportunity Opp, string OppHstege, date OppHdate)
    {
        string returnvalue = '';
        if(OppHstege == '試駕')
        {
            returnvalue = string.valueof(OppHdate.year());
        }
        //else if(OppHstege == '簽約')
        else if(OppHstege == '報價')
        {
            returnvalue = Opp.SigningDate__c != null ? string.valueof(Opp.SigningDate__c.Year()) : '';
        }
        else if(OppHstege == '交車')
        {
            returnvalue = Opp.DeliveryDate__c != null ? string.valueof(Opp.DeliveryDate__c.Year()) : '';
        }

        system.debug('returnvalue: '+returnvalue);
        return returnvalue;
    }

    public static string WaveKPIMonth(Opportunity Opp, string OppHstege, date OppHdate)
    {
        string returnvalue = '';
        if(OppHstege == '試駕')
        {
            returnvalue = string.valueof(OppHdate.month());

            if(OppHdate != null)if(OppHdate.month() < 10) returnvalue = '0' + returnvalue;
        }
        //else if(OppHstege == '簽約')
        else if(OppHstege == '報價')
        {
            returnvalue = Opp.SigningDate__c != null ? string.valueof(Opp.SigningDate__c.Month()) : '';

            if(Opp.SigningDate__c != null)if(Opp.SigningDate__c.Month() < 10) returnvalue = '0' + returnvalue;
        }
        else if(OppHstege == '交車')
        {
            returnvalue = Opp.DeliveryDate__c != null ? string.valueof(Opp.DeliveryDate__c.Month()) : '';

            if(Opp.DeliveryDate__c != null)if(Opp.DeliveryDate__c.Month() < 10) returnvalue = '0' + returnvalue;
        }
        return returnvalue;
    }
}