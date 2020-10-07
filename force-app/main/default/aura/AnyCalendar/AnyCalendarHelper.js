({
	getEvents : function(component, event) {
        var myAction = component.get("c.showMeTheFieldLabel");
        
        myAction.setParams({ 
            objectAPI : component.get("v.sObjectName")
        });
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.reservationLabels99",response.getReturnValue());
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

		var action = component.get("c.getEvents");

        action.setParams({ 
            sObjectName : component.get("v.sObjectName"),
            titleField : component.get("v.titleField"),
            startDateTimeField : component.get("v.startDateTimeField"),
            endDateTimeField : component.get("v.endDateTimeField"),
            descriptionField : component.get("v.descriptionField"),
            userField : component.get("v.userField"),
            filterByUserField : component.get("v.filterByUserField"),
            lookupTestCarField : 'TestCar__c', 
            lookupOptField : 'Opportunity__c',
            carUseTypeField : 'carUseType__c',
            ownerNameField : 'OwnerName__c',
            myRecordId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.eventsMap",response.getReturnValue());
                component.set("v.myRecordId99", component.get("v.recordId"));
                component.set("v.lookupTestCarField99", 'TestCar__c');
                component.set("v.lookupOptField99", 'Opportunity__c');
                component.set("v.carusetype99", 'carUseType__c');
                //component.set("v.lookupOptField99", 'OwnerName__c');
                
                //給預設值。
                var detailtemp = { 'sobjectType': 'TestDriveReservation__c','TestCar__c': component.get("v.recordId")};
                component.set("v.TestDriveReservation99",detailtemp);
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
        
        $A.enqueueAction(action);
	}
})