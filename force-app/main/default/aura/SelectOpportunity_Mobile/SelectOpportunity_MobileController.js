({
	scriptsLoaded : function(component, event, helper) {
        helper.getOpportunities(component, event);
    },
    chooseOpp : function(component, event, helper) {
        var res = event.target.id;
        var evt = $A.get("e.c:PassOpportunity");
        var allOpp = component.get('v.OpportunityList');
        var res2;
        var res3;
        var res4;
        var res5;
        for (var i = 0; i < allOpp.length; i++) {
            
            if(allOpp[i].Id === res)
            {
                res2 = allOpp[i].Driver__r;
                if(res2 === undefined)
                {
                    res3 = undefined;
                }
                else
                {
                    res3 = allOpp[i].Driver__r.Id;
                }
                res4 = allOpp[i].Estimateddateofnew__c;
                res5 = allOpp[i].DeliveryDate__c;
                component.set('v.selectedReservation', allOpp[i]);
            }
        }
        
        evt.setParams({"PassOpportunity" : res});
        evt.setParams({"PassSObject" : res2});
        evt.fire();
        //alert(1);
        var evt2 = $A.get("e.c:PassAccount");
        evt2.setParams({"PassAccount" : res3});
        evt2.setParams({"PassOpportunity" : res});
        evt2.setParams({"PassChageCarDate" : res4});
        evt2.setParams({"PassDeliveryDate" : res5});
        evt2.fire();
        component.set("v.isSelected", true);
        //alert(2);
    },
})