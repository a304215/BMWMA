({
    getOpportunities : function(component, event) {
        var action = component.get("c.getIds");
        //action.setParams({
        //    "TestCarReservationId" : component.get("v.recordId")
        //});
        
        // Register the callback function
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.Handovers",response.getReturnValue());
                //var data = response.getReturnValue();
                // Set the component attributes using values returned by the API call
                //component.set("v.worklogId", data.Id);
                //component.set("v.opportunityId", data.LogOppty__c);
            }
            else{
                //component.set("v.worklogId", "unknown");                
                //component.set("v.opportunityId", "unknown");
            }
        });
        
        // Invoke the service
        $A.enqueueAction(action);
    },
    getLabels : function(component, event) {
    	var myAction = component.get("c.getFieldLabel");
        
        myAction.setParams({ 
            objectAPI : "Account"
        });
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.AccountLabels",response.getReturnValue());
            } else if (state === "INCOMPLETE") {
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
    getChooseOppt : function( component, event){
        var myAction = component.get("c.getChooseOppt");
        
        myAction.setParam({
            OpptId : "0060l000003cqaoAAA"
        });
        
        myAction.setCallback(this, function(response){
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.oppt",response.getReturnValue());
            } else if (state === "INCOMPLETE") {
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
    }
})