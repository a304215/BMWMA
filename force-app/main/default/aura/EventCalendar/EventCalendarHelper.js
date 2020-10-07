({
    upsertEvent : function(component, evObj, callback) {
        var action = component.get("c.upsertEvents");
        
        action.setParams({ 
            "sEventObj": JSON.stringify(evObj),
            "sObjectName" : component.get("v.sObjectName"),
            "titleField" : component.get("v.titleField"),
            "startDateTimeField" : component.get("v.startDateTimeField"),
            "endDateTimeField" : component.get("v.endDateTimeField"),
            "descriptionField" : component.get("v.descriptionField"),
            "userField" : component.get("v.userField"),
            "myRecordId" : component.get("v.myRecordId"),
            "lookupTestCarField" : component.get("v.lookupTestCarField"),
            "lookupOptField" : component.get("v.lookupOptField"),
            "carUseTypeField" : component.get("v.carusetype"),
            "ownerNameField" : 'ownerName__c'
        });
        
        if (callback) {
            action.setCallback(this, callback);
        }

        $A.enqueueAction(action);
    },
    deleteEvent : function(component, event, eventId, callback){
        var action = component.get("c.deleteEvent");
        
        action.setParams({ 
            "eventId": eventId,
            "sObjectName" : component.get("v.sObjectName"),
            "titleField" : component.get("v.titleField"),
            "startDateTimeField" : component.get("v.startDateTimeField"),
            "endDateTimeField" : component.get("v.endDateTimeField"),
            "descriptionField" : component.get("v.descriptionField"),
            "userField" : component.get("v.userField")
        });
        
        if (callback) {
            action.setCallback(this, callback);
        }
        
        $A.enqueueAction(action);
    },
    openModal : function(component, event) {
        var modal = component.find('modal');
        $A.util.addClass(modal, 'slds-fade-in-open');
        var backdrop = component.find('backdrop');
        $A.util.addClass(backdrop, 'slds-backdrop--open');
    },
    doNothing : function(component, event, callback) {
		var action = component.get("c.doMyCarType");
        
        action.setParams({ 
            "inputString" : '5566'
        });
        if (callback) {
            action.setCallback(this, callback);
        }

        $A.enqueueAction(action);
    },
    doMyCarType : function(component, event, callback) {
		var action = component.get("c.doNothing");
        
        action.setParams({ 
            "inputString" : '5566'
        });
        if (callback) {
            action.setCallback(this, callback);
        }

        $A.enqueueAction(action);
    },
    closeModal : function(component, event) {
		var modal = component.find('modal');
        $A.util.removeClass(modal, 'slds-fade-in-open');
        var backdrop = component.find('backdrop');
        $A.util.removeClass(backdrop, 'slds-backdrop--open');
    }
})