({
    doInit : function(component, event, helper) {
        var actions = [
            {label: 'Delete', name: 'delete'}
        ];
        
        component.set('v.columns', [
            {label: 'Name', fieldName:'Name', type: 'text', sortable: true},
			{label: 'Email', fieldName:'Email', type: 'email', sortable: false},
			{label: 'Birthdate', fieldName:'Birthdate', type: 'date', sortable: true},
            {label: 'Account', fieldName:'Account', type: 'text', sortable: false},
            {type: 'action', typeAttributes: { rowActions: actions } }
        ]);
        helper.getTotalNumberOfContacts(component);
        helper.getContacts(component);
    },
     
    loadMoreData: function (component, event, helper) {
        event.getSource().set("v.isLoading", true);
        helper.getMoreContacts(component, component.get('v.rowsToLoad')).then($A.getCallback(function (data) {
            if (component.get('v.contactsList').length == component.get('v.totalNumberOfRows')) {
                component.set('v.enableInfiniteLoading', false);
            } else {
                var currentData = component.get('v.contactsList');
                var newData = currentData.concat(data);
                component.set('v.contactsList', newData);
            }
            event.getSource().set("v.isLoading", false);
        }));
    },
     
    handleRowAction: function (component, event, helper) {
		var action = event.getParam('action');
		var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                helper.deleteContact(component, row);
                break;
        }
    },
     
    updateColumnSorting: function(component, event, helper) {
		var fieldName = event.getParam('fieldName');
		var sortDirection = event.getParam('sortDirection');
		component.set("v.sortedBy", fieldName);
		component.set("v.sortedDirection", sortDirection);
		helper.getContacts(component);
	},
	
	handleLoadingState: function(component, event, helper) {
        var isLoading = component.get("v.isLoading");

        if (isLoading) {
            helper.showSpinner(component);
        } else {
            helper.hideSpinner(component);
        }
    },
})