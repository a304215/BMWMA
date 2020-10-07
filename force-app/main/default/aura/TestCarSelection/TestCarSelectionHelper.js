({
	getTestCars : function(component, event) {
        var myAction = component.get("c.getTestCars");
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.TestCarList",response.getReturnValue());
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
	},
    chooseBar : function(component, event) {
        var isClosed = component.get('v.isClosed');
        if(isClosed)
        {
            $('#selectionBar').addClass('slds-is-open');
            $('#select-car-expando-unique-id').removeClass('showMe');
            component.set('v.isClosed', false);
        }
        else
        {
            $('#selectionBar').removeClass('slds-is-open');
            $('#select-car-expando-unique-id').addClass('showMe');
            component.set('v.isClosed', true);
        }
    }
})