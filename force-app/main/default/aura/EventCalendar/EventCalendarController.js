({
    created : function(component, event, helper) {
        helper.created(component, event);
    },
    renderCalendar : function(component, event, helper) {
        var eventsMap = component.get("v.events");
        $(document).ready(function(){
            var eventArray = [];
            $.each(eventsMap, function(index, value){
                var newEvent = {
                    id : value.Id,
                    title : value.title,
                    start : moment(value.startDateTime),
                    end : moment(value.endDateTime),
                    description : value.description,
                    owner : value.owner, 
                    testcar : value.testCardId, 
                    optid : value.OptId,
                    carusetype: value.carUseType
                }
                eventArray.push(newEvent);
            });
            var calendarButtons = component.get('v.calendarButtons');
            $('#calendar').fullCalendar({
                header: {
                    left: 'today prev,next',
                    center: 'title',
                    right: calendarButtons
                },
                defaultDate: moment().format("YYYY-MM-DD"),
                navLinks: true, // can click day/week names to navigate views
                editable: true,
                displayEventTime: false,
                eventLimit: true, // allow "more" link when too many events
                weekends: component.get('v.weekends'),
                eventBackgroundColor: component.get('v.eventBackgroundColor'),
                eventBorderColor: component.get('v.eventBorderColor'),
                eventTextColor: component.get('v.eventTextColor'),
                events: eventArray,
                eventClick: function(calEvent, jsEvent, view) {
                    component.set('v.titleVal', calEvent.title);
                    component.set('v.descriptionVal', calEvent.description);
                    component.set('v.startDateTimeVal', moment(calEvent.start._d).format());
                    component.set('v.endDateTimeVal', moment(calEvent.end._d).format());
                    component.set('v.idVal', calEvent.id);
                    
					//清空值
                    //component.set('v.TestDriveReservation.TestCar__c', '');
                    //component.find("testcLookup").get("v.body")[0].set("v.values", "");
                    
                    //清空值
                    //component.set('v.TestDriveReservation.Opportunity__c', "");
                    //component.find("oppLookup").get("v.body")[0].set("v.values", "");

                    //lookup欄位要加工1。
                    component.set('v.TestDriveReservation.TestCar__c', calEvent.testcar);
                    var tcvalues = [{
                        type: 'TestDriveReservation__c',
                        id: calEvent.testcar,
                        label: '這不重要',
                        icon : {
                            url:'/img/icon/t4v35/custom/custom31_120.png',
                            backgroundColor:'A094ED',
                            alt:'試駕車'
                        }
                    }];
                    component.find("testcLookup").get("v.body")[0].set("v.values", tcvalues);
                    //lookup欄位要加工1。

                    //lookup欄位要加工2。
                    component.set('v.TestDriveReservation.Opportunity__c', calEvent.optid);
                    var ovalues = [{
                        type: 'TestDriveReservation__c',
                        id: calEvent.optid,
                        label: '這不重要',
                        icon : {
                            url:'/img/icon/t4v35/standard/opportunity_120.png',
                            backgroundColor:'A094ED',
                            alt:'有望客戶'
                        }
                    }];
                    component.find("oppLookup").get("v.body")[0].set("v.values", ovalues);
                    //lookup欄位要加工2。
                    
                    component.set('v.carusetype99', calEvent.carusetype);
                    component.find("a_opt").set("v.value", calEvent.carusetype);
                    helper.openModal(component, event);
                },
                eventDrop: function(event, delta, revertFunc) {
                    var evObj = {
                        "Id" : event.id,
                        "title" : event.title,
                        "startDateTime" : moment(event.start._i).add(delta).format(),
                        "endDateTime" : moment(event.end._i).add(delta).format(),
                        "description" : event.description
                    };
                    helper.upsertEvent(component, evObj);
                },
                eventResize: function(event, delta, revertFunc) {
                    var evObj = {
                        "Id" : event.id,
                        "title" : event.title,
                        "startDateTime" : moment(event.start._i).format(),
                        "endDateTime" : moment(event.end._i).add(delta).format(),
                        "description" : event.description
                    };
                    helper.upsertEvent(component, evObj);
                },
                dayClick: function(date, jsEvent, view) {
                    if (date._f == "YYYY-MM-DD"){
                        component.set('v.startDateTimeVal', moment(date.format()).add(12, 'hours').format());
                        component.set('v.endDateTimeVal', moment(date.format()).add(14, 'hours').format());
                    } else {
                        component.set('v.startDateTimeVal', moment(date.format()).format());
                        component.set('v.endDateTimeVal', moment(date.format()).add(2, 'hours').format());
                    }
                    component.set('v.newOrEdit', 'New');
                    //清空值
                    /*
                    component.set('v.TestDriveReservation.TestCar__c', '');
                    component.find("testcLookup").get("v.body")[0].set("v.values", "");
                    */
                    //先給固定值。
                    component.set('v.TestDriveReservation.TestCar__c', component.get('v.myRecordId'));
                    var tcvalues = [{
                        type: 'TestDriveReservation__c',
                        id: component.get('v.myRecordId'),
                        label: '這不重要',
                        icon : {
                            url:'/img/icon/t4v35/custom/custom31_120.png',
                            backgroundColor:'A094ED',
                            alt:'試駕車'
                        }
                    }];
                    component.find("testcLookup").get("v.body")[0].set("v.values", tcvalues);
                    
                    component.set('v.TestDriveReservation.Opportunity__c', "");
                    component.find("oppLookup").get("v.body")[0].set("v.values", "");
                    
                    helper.openModal(component, event);
                }
            });
        });
    },
    createRecord : function(component, event, helper) {
        var evObj = {
            "title" : component.get('v.titleVal'),
            "startDateTime" : moment(component.get('v.startDateTimeVal')).format(),
            "endDateTime" : moment(component.get('v.endDateTimeVal')).format(),
            "description" : component.get('v.descriptionVal'),
            "testCardId" : component.get('v.TestDriveReservation.TestCar__c'),
            "OptId" : component.get('v.TestDriveReservation.Opportunity__c'),
            "carUseType" : component.find("a_opt").get('v.value')
        };
        if (component.get('v.idVal')) {
            evObj.id = component.get('v.idVal');
            $('#calendar').fullCalendar( 'removeEvents', component.get('v.idVal') );
        }
        helper.upsertEvent(component, evObj, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var newEvent = {
                    id : response.getReturnValue().Id,
                    title : response.getReturnValue().title,
                    start : moment(response.getReturnValue().startDateTime),
                    end : moment(response.getReturnValue().endDateTime),
                    description : response.getReturnValue().description,
                    owner : response.getReturnValue().owner
                }
                $('#calendar').fullCalendar( 'renderEvent', newEvent );
                helper.closeModal(component, event);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
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
    },
    deleteRecord : function(component, event, helper) {
        helper.deleteEvent(component, event, event.getSource().get("v.value"), function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                $('#calendar').fullCalendar( 'removeEvents', response.getReturnValue());
                helper.closeModal(component, event);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
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
    },
    openModal : function(component, event, helper) {
        helper.openModal(component, event);
    },
    clearMe : function(component, event, helper) {
        //helper.openModal(component, event);
        helper.doNothing(component, event, function(response){
            //改來這裡清資料。
            
            component.set('v.titleVal','');
            component.set('v.idVal','');
            component.set('v.startDateTimeVal','');
            component.set('v.endDateTimeVal','');
            component.set('v.descriptionVal','');
            
            component.set('v.TestDriveReservation.TestCar__c', '');
            component.find("testcLookup").get("v.body")[0].set("v.values", "");
            component.set('v.TestDriveReservation.Opportunity__c', "");
            component.find("oppLookup").get("v.body")[0].set("v.values", "");
            
            var state = response.getState();
            if (state === "SUCCESS") {
               // helper.closeModal(component, event);
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
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
    },
    doInit: function(component, event, helper) {
        helper.doNothing(component, event, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
               // helper.closeModal(component, event);
               component.set('v.mycarusetype', response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
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
        //component.find("a_opt").set("v.value", "試駕");
    },
    
    //先回復
    closeModal : function(component, event, helper) {
        component.set('v.titleVal','');
        component.set('v.idVal','');
        component.set('v.startDateTimeVal','');
        component.set('v.endDateTimeVal','');
        component.set('v.descriptionVal','');
        
        component.set('v.TestDriveReservation.TestCar__c', '');
        component.find("testcLookup").get("v.body")[0].set("v.values", "");
        component.set('v.TestDriveReservation.Opportunity__c', "");
        component.find("oppLookup").get("v.body")[0].set("v.values", "");
    	helper.closeModal(component, event);
    }
    /*
    closeModal : function(component, event, helper) { 
        helper.doNothing(component, event, function(response){
            //改來這裡清資料。
            
            component.set('v.titleVal','');
            component.set('v.idVal','');
            component.set('v.startDateTimeVal','');
            component.set('v.endDateTimeVal','');
            component.set('v.descriptionVal','');
            
            component.set('v.TestDriveReservation.TestCar__c', '');
            component.find("testcLookup").get("v.body")[0].set("v.values", "");
            component.set('v.TestDriveReservation.Opportunity__c', "");
            component.find("oppLookup").get("v.body")[0].set("v.values", "");
            
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.closeModal(component, event);
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
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
    }
    */
})