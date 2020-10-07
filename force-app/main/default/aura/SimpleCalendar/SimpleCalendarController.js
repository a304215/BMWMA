({
	doInit: function(component, event, helper) {
        var today = new Date();
        //alert(moment(today).format('YYYY-MM-DD'));
        component.set('v.choosenDate',today.getFullYear()+"-"+(today.getMonth()+1)+"-"+today.getDate());
        //var MyDay = moment(today).format('YYYY-MM-DD');
        //component.set('v.choosenDate',MyDay);
        helper.setToday(component);
    },
    doChange: function(component, event, helper) {
        helper.setToday(component);
        
        var DD = component.get('v.choosenDate');
        var evt = $A.get("e.c:PassTestDriveChangeDate");
        evt.setParams({"PassTestDriveDate" : DD});
        evt.fire();
    },
    clickChange: function(component, event, helper) {       
        var ctarget = event.currentTarget;
        var res = ctarget.dataset.value;

        component.set('v.choosenDate',res);
        
        helper.setToday(component);
        
        var DD = component.get('v.choosenDate');
        var evt = $A.get("e.c:PassTestDriveChangeDate");
        evt.setParams({"PassTestDriveDate" : DD});
        evt.fire();
    },
    NextWeek: function(component, event, helper) {       
        var Tday = component.get('v.choosenDate');
        //笨笨的SF1，一定要這樣才可以傳送。
        var tempD = Tday.split("-");
        var theDay = new Date(tempD[0], tempD[1]-1, tempD[2]);
        var TheDays = moment(theDay).add(7, 'days').format('YYYY-MM-DD');
        component.set('v.choosenDate', TheDays);
        helper.setToday(component);
        
        var DD = component.get('v.choosenDate');
        var evt = $A.get("e.c:PassTestDriveChangeDate");
        evt.setParams({"PassTestDriveDate" : DD});
        evt.fire();
    },
    LastWeek: function(component, event, helper) {       
        var Tday = component.get('v.choosenDate');
        //笨笨的SF1，一定要這樣才可以傳送。
        var tempD = Tday.split("-");
        var theDay = new Date(tempD[0], tempD[1]-1, tempD[2]);
        var TheDays = moment(theDay).add(-7, 'days').format('YYYY-MM-DD');
        
        component.set('v.choosenDate', TheDays);
        helper.setToday(component);
        
        var DD = component.get('v.choosenDate');
        var evt = $A.get("e.c:PassTestDriveChangeDate");
        evt.setParams({"PassTestDriveDate" : DD});
        evt.fire();
    },
    NextMonth: function(component, event, helper) {       
        var Tday = component.get('v.choosenDate');
        //笨笨的SF1，一定要這樣才可以傳送。
        var tempD = Tday.split("-");
        var theDay = new Date(tempD[0], tempD[1]-1, tempD[2]);
        var TheDays = moment(theDay).add(1, 'months').format('YYYY-MM-DD');
        
        component.set('v.choosenDate', TheDays);
        helper.setToday(component);
        
        var DD = component.get('v.choosenDate');
        var evt = $A.get("e.c:PassTestDriveChangeDate");
        evt.setParams({"PassTestDriveDate" : DD});
        evt.fire();
    },
    LastMonth: function(component, event, helper) {       
        var Tday = component.get('v.choosenDate');
        var tempD = Tday.split("-");
        var theDay = new Date(tempD[0], tempD[1]-1, tempD[2]);
        var TheDays = moment(theDay).add(-1, 'months').format('YYYY-MM-DD');
        
        component.set('v.choosenDate', TheDays);
        helper.setToday(component);
        
        var DD = component.get('v.choosenDate');
        var evt = $A.get("e.c:PassTestDriveChangeDate");
        evt.setParams({"PassTestDriveDate" : DD});
        evt.fire();
    },
})