({
    getOpprotunity : function(component, event) {
        var myAction = component.get("c.getOpportunity");
        
        //傳入id。
        myAction.setParams({
            "OpportunityId" : event.getParam("PassOpportunity")
        });
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var returnOPP = response.getReturnValue();
                //lookup欄位要加工1。
                component.set('v.SelectedOpp', returnOPP);
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