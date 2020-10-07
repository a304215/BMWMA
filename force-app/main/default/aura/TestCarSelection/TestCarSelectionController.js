({
	scriptsLoaded : function(component, event, helper) {
        component.set('v.isClosed', false);
        helper.getTestCars(component, event);
    }, 
    
    chooseCar : function(component, event, helper) {
        var res = event.target.id;
        
        var evt = $A.get("e.c:PassTestCar");
        evt.setParams({"PassCar" : res});
        evt.fire();
        helper.chooseBar(component, event);
    },
    chooseBar : function(component, event, helper) {
    	helper.chooseBar(component, event);        
    }
})