({
    fetchMappingValues: function(component) {
        // call the server side function  
        var today = new Date();
        component.set('v.chooseDay',today.getFullYear()+"-"+(today.getMonth()+1)+"-"+today.getDate());
        
        var action = component.get("c.getDependentOptionsCard");
        
        action.setParams({
            'objApiName': 'AAA'
        });
        
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.allMap", StoreResponse);
                
                // create a empty array for store map keys(@@--->which is controller picklist values) 
                
                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = []; // for store controller picklist value to set on ui field. 
                
                // play a for loop on Return map 
                // and fill the all map key on listOfkeys variable.
                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }
                
                component.set("v.allBranch", listOfkeys);
                
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    component.set("v.CurrentRoot1", null);
                }
                component.set('v.CurrentRoot0', "門市");
            }
        });
        $A.enqueueAction(action);
    },
    
    showAllBranch : function(component, event) {
			component.set('v.CurrentRoot0', "門市");
            component.set("v.CurrentRoot1", null);
            component.set("v.CurrentRoot2", null);
    },
    
    showTestCar : function(component, event) {
        var choosenBranch = event.target.name;        
        var Map = component.get("v.allMap");
        
        // check if selected value is not equal to None then call the helper function.
        // if controller field value is none then make dependent field value is none and disable field
        if (choosenBranch != '') {
            var ListOfDependentFields = Map[choosenBranch];
			component.set('v.allCar', ListOfDependentFields);
            component.set("v.CurrentRoot1", choosenBranch);
            component.set("v.CurrentRoot2", null);
        } else {
            //component.set("v.CurrentRoot", "無可用試駕車");
        }
    },
    showCarCalendar : function(component, event) {
        var choosenTestCar = event.target.name;
        var choosenTestCarName = event.target.innerHTML;
        var action = component.get("c.getDateNCar");
        var theDay = component.get("v.chooseDay");
        component.set('v.chooseCar', choosenTestCar);
        
        action.setParams({
            'inputDate': theDay,
            'TestCarID': choosenTestCar,
            'OpportunityId': 'dd'
        });
        
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var ReserResponse = response.getReturnValue();
        		component.set("v.thisDayReservation", ReserResponse);
                component.set("v.CurrentRoot2", choosenTestCarName);
            }
        });
        $A.enqueueAction(action);
    },
    showDateCalendar : function(component, event) {
        var choosenTestCar = component.get('v.chooseCar');
		var theDay = component.get("v.chooseDay");
        var action = component.get("c.getDateNCar");
        
        action.setParams({
            'inputDate': theDay,
            'TestCarID': choosenTestCar,
            'OpportunityId': 'dd'
        });
        
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var ReserResponse = response.getReturnValue();
        		component.set("v.thisDayReservation", ReserResponse);
            }
        });
        $A.enqueueAction(action);
    },
    getLabels : function(component, event) {
    	var myAction = component.get("c.showMeTheFieldLabel");
        
        myAction.setParams({ 
            objectAPI : "TestDriveReservation__c"
        });
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.reservationLabels",response.getReturnValue());
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
    timePicklist: function(component, event, helper) {
        //太笨了，無法共用option。
        var opts1 = [
            { class: "optionClass", label: "07:00", value: "07:00"},
            { class: "optionClass", label: "07:30", value: "07:30"},
            { class: "optionClass", label: "08:00", value: "08:00"},
            { class: "optionClass", label: "08:30", value: "08:30"},
            { class: "optionClass", label: "09:00", value: "09:00"},
            { class: "optionClass", label: "09:30", value: "09:30"},
            { class: "optionClass", label: "10:00", value: "10:00"},
            { class: "optionClass", label: "10:30", value: "10:30"},
            { class: "optionClass", label: "11:00", value: "11:00"},
            { class: "optionClass", label: "11:30", value: "11:30"},
            { class: "optionClass", label: "12:00", value: "12:00"},
            { class: "optionClass", label: "12:30", value: "12:30"},
            { class: "optionClass", label: "13:00", value: "13:00"},
            { class: "optionClass", label: "13:30", value: "13:30"},
            { class: "optionClass", label: "14:00", value: "14:00"},
            { class: "optionClass", label: "14:30", value: "14:30"},
            { class: "optionClass", label: "15:00", value: "15:00"},
            { class: "optionClass", label: "15:30", value: "15:30"},
            { class: "optionClass", label: "16:00", value: "16:00"},
            { class: "optionClass", label: "16:30", value: "16:30"},
            { class: "optionClass", label: "17:00", value: "17:00"},
            { class: "optionClass", label: "17:30", value: "17:30"},
            { class: "optionClass", label: "18:00", value: "18:00"},
            { class: "optionClass", label: "18:30", value: "18:30"},
            { class: "optionClass", label: "19:00", value: "19:00"},
            { class: "optionClass", label: "19:30", value: "19:30"},
            { class: "optionClass", label: "20:00", value: "20:00"},
            { class: "optionClass", label: "20:30", value: "20:30"},
            { class: "optionClass", label: "21:00", value: "21:00"},
            { class: "optionClass", label: "21:30", value: "21:30"},
            { class: "optionClass", label: "22:00", value: "22:00"},
            { class: "optionClass", label: "22:30", value: "22:30"},
            { class: "optionClass", label: "23:00", value: "23:00"},
            { class: "optionClass", label: "23:30", value: "23:30"}
        ];
        var opts2 = [
            { class: "optionClass", label: "00:00", value: "00:00"},
            { class: "optionClass", label: "07:00", value: "07:00"},
            { class: "optionClass", label: "07:30", value: "07:30"},
            { class: "optionClass", label: "08:00", value: "08:00"},
            { class: "optionClass", label: "08:30", value: "08:30"},
            { class: "optionClass", label: "09:00", value: "09:00"},
            { class: "optionClass", label: "09:30", value: "09:30"},
            { class: "optionClass", label: "10:00", value: "10:00"},
            { class: "optionClass", label: "10:30", value: "10:30"},
            { class: "optionClass", label: "11:00", value: "11:00"},
            { class: "optionClass", label: "11:30", value: "11:30"},
            { class: "optionClass", label: "12:00", value: "12:00"},
            { class: "optionClass", label: "12:30", value: "12:30"},
            { class: "optionClass", label: "13:00", value: "13:00"},
            { class: "optionClass", label: "13:30", value: "13:30"},
            { class: "optionClass", label: "14:00", value: "14:00"},
            { class: "optionClass", label: "14:30", value: "14:30"},
            { class: "optionClass", label: "15:00", value: "15:00"},
            { class: "optionClass", label: "15:30", value: "15:30"},
            { class: "optionClass", label: "16:00", value: "16:00"},
            { class: "optionClass", label: "16:30", value: "16:30"},
            { class: "optionClass", label: "17:00", value: "17:00"},
            { class: "optionClass", label: "17:30", value: "17:30"},
            { class: "optionClass", label: "18:00", value: "18:00"},
            { class: "optionClass", label: "18:30", value: "18:30"},
            { class: "optionClass", label: "19:00", value: "19:00"},
            { class: "optionClass", label: "19:30", value: "19:30"},
            { class: "optionClass", label: "20:00", value: "20:00"},
            { class: "optionClass", label: "20:30", value: "20:30"},
            { class: "optionClass", label: "21:00", value: "21:00"},
            { class: "optionClass", label: "21:30", value: "21:30"},
            { class: "optionClass", label: "22:00", value: "22:00"},
            { class: "optionClass", label: "22:30", value: "22:30"},
            { class: "optionClass", label: "23:00", value: "23:00"},
            { class: "optionClass", label: "23:30", value: "23:30"},
            { class: "optionClass", label: "24:00", value: "24:00"}
        ];

        component.find("InputSelectDynamic1").set("v.options", opts1);
        component.find("InputSelectDynamic2").set("v.options", opts2);
    },
    showExistEvent: function(component, event, helper) {
        var ctarget = event.currentTarget;
        var res = ctarget.dataset.value;
        //給值
        var allRes = component.get('v.thisDayReservation');
        
        for(var i=0; i<allRes.length ;i++)
        {
            if(allRes[i].Id === res)
            {
                if(allRes[i].isReadable__c)
                {
                    if(allRes[i].TestDriveStatus__c != '已預約')
                    {
                        component.set('v.isClosed', true);    
                    }
                    else
                    {
                        component.set('v.isClosed', false);    
                    }
                    
                    var t1 = moment(allRes[i].StartTime__c).format('HH:mm');
                    var t2 = moment(allRes[i].EndTime__c).format('HH:mm');  
                    component.set('v.errorMessage','');
                    
                    //component.set('v.TestDriveReservation', allRes[i]);
                    component.set('v.TestDriveReservation.CarUseType__c', allRes[i].CarUseType__c);
                    component.set('v.TestDriveReservation.TestDriveStatus__c', allRes[i].TestDriveStatus__c);
                    component.set('v.TestDriveReservation.Description__c', allRes[i].Description__c);
                    component.set('v.TestDriveReservation.StartTime__c', allRes[i].StartTime__c);
                    component.set('v.TestDriveReservation.EndTime__c', allRes[i].EndTime__c);
                    component.set('v.TestDriveReservation.TestDrivePerson__c', allRes[i].TestDrivePerson__c);
                    
                    component.set('v.idVal', allRes[i].Id);
                    component.find("myOPP").set("v.value",allRes[i].Opportunity__c);
                    component.find("myTestCar").set("v.value",allRes[i].TestCar__c);
                    component.find("InputSelectDynamic1").set("v.value",t1);
                    component.find("InputSelectDynamic2").set("v.value",t2);
                    helper.openModal(component, event);
                }
                else
                {
                    alert('No permission.');
                    helper.closeModal(component, event);
                }
            }            
        }
    },
    upsertEvent : function(component, callback) {
        //alert(component.get('v.TestDriveReservation.StartTime__c'));
        //alert(moment(component.get('v.TestDriveReservation.StartTime__c')).format('YYYY-MM-DD'));
        var action = component.get("c.upsertEvents");
        
        action.setParams({ 
            "inputId": component.get('v.idVal'),
            "testCarId": component.find("myTestCar").get("v.value"),
            "OppId": component.find("myOPP").get("v.value"),
            "carUseType": component.get('v.TestDriveReservation.CarUseType__c'),
            "description": component.get('v.TestDriveReservation.Description__c'),
            //"startDate": moment(component.get('v.TestDriveReservation.StartTime__c')).format('YYYY-MM-DD'),
            "startDate": component.get("v.chooseDay"),
            "startTime": component.find("InputSelectDynamic1").get("v.value"),
            //"endDate": moment(component.get('v.TestDriveReservation.EndTime__c')).format('YYYY-MM-DD'),
            "endDate": component.get("v.chooseDay"),
            "testDrivePerson" : component.get('v.TestDriveReservation.TestDrivePerson__c'),
            "endTime": component.find("InputSelectDynamic2").get("v.value")
        });
        
        if (callback) {
            action.setCallback(this, callback);
        }

        $A.enqueueAction(action);
    },
    cancelEvent : function(component, callback) {
        var action = component.get("c.cancelEvents");
        
        action.setParams({ 
            "inputId": component.get('v.idVal')
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
    closeModal : function(component, event) {
        //清空值。
        component.set('v.idVal','');
        var cmpTargetMyTestCar = component.find('myTestCar');
        $A.util.removeClass(cmpTargetMyTestCar, 'redLine');
        var cmpTargetMyOPP = component.find('myOPP');
        $A.util.removeClass(cmpTargetMyOPP, 'redLine');
        var cmpTargetCarType = component.find('carType');
        $A.util.removeClass(cmpTargetCarType, 'redLine');
        var cmpTargetDescription = component.find('description');
        $A.util.removeClass(cmpTargetDescription, 'redLine');
        var cmpTargetInputSelectDynamic1 = component.find('InputSelectDynamic1');
        $A.util.removeClass(cmpTargetInputSelectDynamic1, 'redLine');
        var cmpTargetInputSelectDynamic2 = component.find('InputSelectDynamic2');
        $A.util.removeClass(cmpTargetInputSelectDynamic2, 'redLine');
        
		var modal = component.find('modal');
        $A.util.removeClass(modal, 'slds-fade-in-open');
        var backdrop = component.find('backdrop');
        $A.util.removeClass(backdrop, 'slds-backdrop--open');
    },
    myOPPName : function(component, event) {
    	var myAction = component.get("c.getOPPName");
        
        myAction.setParams({ 
            OPPId : component.get('v.myOPPId')
        });
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var changeMe = component.get('v.idVal');
                if(changeMe === undefined || changeMe === '')
                {
                	component.set('v.TestDriveReservation.TestDrivePerson__c', response.getReturnValue());
                }
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
})