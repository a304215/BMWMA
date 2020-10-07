({
    
    doInit: function(component, event, helper) {
        //call the helper function with pass [component, Controller field and Dependent Field] Api name 
        helper.fetchPicklistValues(component, 'HomeCity__c', 'HomeDistrict__c');
        //onControllerFieldChange(component, event, helper);
    },
    
    
    // function call on change tha controller field  
    onControllerFieldChange: function(component, event, helper) {
        // get the selected value
        var controllerValueKey = event.getSource().get("v.value");
        component.set('v.SelectedAccount.HomeCity__c' , controllerValueKey);
        // get the map values   
        var Map = component.get("v.depnedentFieldMap");
        
        // check if selected value is not equal to None then call the helper function.
        // if controller field value is none then make dependent field value is none and disable field
        if (controllerValueKey != '') {
            
            // get dependent values for controller field by using map[key].  
            // for i.e "India" is controllerValueKey so in the map give key Name for get map values like 
            // map['India'] = its return all dependent picklist values.
            var ListOfDependentFields = Map[controllerValueKey];
            helper.fetchDepValues(component, ListOfDependentFields);
            
        } else {
            var defaultVal = [{
                class: "optionClass",
                label: '---無--',
                value: ''
            }];
            component.find('conState').set("v.options", defaultVal);
            component.set("v.isDependentDisable", true);
        }
    },
    
    // function call on change tha Dependent field    
    onDependentFieldChange: function(component, event, helper) {
        var depedentValue = event.getSource().get("v.value");
        component.set('v.SelectedAccount.HomeDistrict__c' , depedentValue);
    }, 
    
    // function call on change tha controller field  
    onPassAccount: function(component, event, helper) {
        // get the selected value
        helper.getAccountInfo(component, event);
    },
    clearAll: function(component, event, helper) {
        component.set('v.SelectedAccount.HomeCity__c', '');
        component.set('v.SelectedAccount.HomeDistrict__c', '');
        component.find('conCountry').set("v.value", "");
        component.find('conState').set("v.value", "");
        component.set("v.isDependentDisable", true);
    },
})