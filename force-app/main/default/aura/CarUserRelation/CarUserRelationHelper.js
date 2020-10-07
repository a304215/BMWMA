({
	getRelation : function(component, event) {
		var myAction = component.get("c.getRelationship");
        
        //傳入event id。
        myAction.setParams({
            MainId : component.get('v.MyPersonRelation.Keyman__c'), 
            SubId : component.get('v.MyPersonRelation.SecondMan__c')
        });
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set('v.MyPersonRelation', response.getReturnValue());
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
})