({
	getOpportunities : function(component, event) {
        var myAction = component.get("c.getOpportunities");
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.OpportunityList",response.getReturnValue());
                component.set("v.isSelected", false);
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(myAction);
	}
})