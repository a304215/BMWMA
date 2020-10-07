({
 
    doInit: function(component, event, helper) {
        //call the helper function with pass [component, Controller field and Dependent Field] Api name 
        helper.fetchPicklistValues(component, 'SellingBrand__c', 'SellingGeneration__c');
    },
    
    
    // function call on change tha controller field  
    onControllerFieldChange: function(component, event, helper) {
        // get the selected value
        var controllerValueKey = event.getSource().get("v.value");
        
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
                label: '無可用的試駕車',
                value: '無可用的試駕車'
            }];
            component.find('conState').set("v.options", defaultVal);
            component.set("v.isDependentDisable", true);
        }
    },
    
    // function call on change tha Dependent field    
    onDependentFieldChange: function(component, event, helper) {
        var res = event.getSource().get("v.value");
        
        var evt = $A.get("e.c:PassTestCar");
        evt.setParams({"PassCar" : res});
        evt.fire();
        
    },
})