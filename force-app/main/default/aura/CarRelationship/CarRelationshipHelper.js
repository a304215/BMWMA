({
	getMyOpportunity : function(component, event){
		var myAction = component.get("c.getOpportunity");
        
        //傳入event id。
        myAction.setParams({
            OpportunityId : event.getParam("PassOpportunity")
        });
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                
                var returnOPP = response.getReturnValue();
                
                component.set('v.Opportunity', returnOPP);
                //component.set('v.ContactPersonRelation.Keyman__c', returnOPP.Driver__c);
                //component.set('v.ContactPersonRelation.SecondMan__c', returnOPP.AccoundId);
                component.set('v.LicensePersonRelation.Keyman__c', returnOPP.Driver__c);
                component.set('v.LicensePersonRelation.SecondMan__c', returnOPP.AccountId);
                component.set('v.isRead', true);
                component.set('v.isSame', returnOPP.Driver__c === returnOPP.AccountId);
                var evt = $A.get("e.c:PassOPPforRelation");
                evt.fire();
                window && window.scroll(0,0);
                
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(myAction);
	},
    saveMyRelation : function(component, event){
        var Negotiator = component.get('v.LicensePersonRelation.SecondMan__c');
        var Driver = component.get('v.LicensePersonRelation.Keyman__c');
        if(Negotiator === Driver)
        {
            var evt = $A.get("e.c:PassSurvey");
            evt.setParams({"PassReservation" : ''});
            evt.setParams({"PassOpportunity" : component.get('v.Opportunity.Id')});
            evt.fire();
            component.set('v.isRead', false);
        }
        else
        {
            var myAction = component.get("c.saveRelation");
            
            //傳入event id。
            myAction.setParams({
                EXID1 : component.get('v.ContactPersonRelation.Id'),
                relation1 : component.get('v.ContactPersonRelation.Relation__c'),
                main1 : component.get('v.ContactPersonRelation.Keyman__c'),
                sub1 : component.get('v.ContactPersonRelation.SecondMan__c'),
                EXID2 : component.get('v.LicensePersonRelation.Id'),
                relation2 : component.get('v.LicensePersonRelation.Relation__c'),
                main2 : component.get('v.LicensePersonRelation.Keyman__c'),
                sub2 : component.get('v.LicensePersonRelation.SecondMan__c')
            });
            
            myAction.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    var evt = $A.get("e.c:PassSurvey");
                    evt.setParams({"PassReservation" : ''});
                    evt.setParams({"PassOpportunity" : component.get('v.Opportunity.Id')});
                    evt.fire();
                    component.set('v.isRead', false);
                } else if (state === "INCOMPLETE") {
                    // do something
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            alert(errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            
            $A.enqueueAction(myAction);
        }
        
	},
})