({
	getContacts : function(component) {
		var action = component.get("c.obtainContacts");
		action.setParams({
			sortingOptions: {
				sortedBy: component.get("v.sortedBy") ? component.get("v.sortedBy") : '',
				sortedDirection: component.get("v.sortedDirection") ? component.get("v.sortedDirection") : ''
			},
			recordLimit: component.get("v.initialRows"),
			currentCount: component.get("v.rowNumberOffset")
		});
		component.set("v.isLoading", true);
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS" ) {
				var resultData = response.getReturnValue();
				component.set("v.contactsList", this.composeViewData(resultData));
				component.set("v.currentCount", component.get("v.initialRows"));
			}
			component.set("v.isLoading", false);
		});
		$A.enqueueAction(action);
	},

	composeViewData: function(response) {
		return response.map((contact) => {
			return {
				Id: contact.Id,
				Name: contact.Name,
				Email: contact.Email,
				Birthdate: contact.Birthdate,
				Account: contact.Account ? contact.Account.Name : '',
			}
		});
	},
	 
	getTotalNumberOfContacts : function(component) {
		var action = component.get("c.getTotalContacts");
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS" ) {
				var resultData = response.getReturnValue();
				component.set("v.totalNumberOfRows", resultData);
			}
		});
		$A.enqueueAction(action);
	},
	 
	getMoreContacts: function(component) {
		return new Promise($A.getCallback(function(resolve, reject) {
			var action = component.get('c.obtainContacts');
			var currentCount = component.get("v.currentCount");
			var recordLimit = component.get("v.initialRows");
			action.setParams({
				sortingOptions: {
					sortedBy: component.get("v.sortedBy") ? component.get("v.sortedBy") : '',
					sortedDirection: component.get("v.sortedDirection") ? component.get("v.sortedDirection") : ''
				},
				recordLimit: recordLimit,
				currentCount: currentCount 
			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				if(state === "SUCCESS"){
					var resultData = response.getReturnValue();
					resolve(resultData);
					currentCount = currentCount + recordLimit;
					component.set("v.currentCount", currentCount);   
				}                
			});
			$A.enqueueAction(action);
		}));
	},

	deleteContact: function(component , row) {
		var self = this;
		var action = component.get('c.deleteContact');

		action.setParams({
			contact: {'sobjectType': 'Contact', 'Id': row.Id}
		})
		component.set("v.isLoading", true);
		action.setCallback(self, function(response) {
			if (response.getState() === "SUCCESS") {
				self.getContacts(component);
				self.showToast('success', 'Success', 'Contact has been successfully deleted');
			} else {
				var errormsg = response.getError()[0].pageErrors ? response.getError()[0].pageErrors[0].message : response.getError()[0].message;
				self.showToast('error', 'Error', errormsg);
			}
			component.set("v.isLoading", false);       
		});
		$A.enqueueAction(action);
	},
	
	showToast : function(type, title, message) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"type": type,
			"title": title,
			"message": message
		});
		toastEvent.fire();
	},

	hideSpinner: function(component) {
		component.set("v.isLoading", false);
	},

	showSpinner: function(component) {
		component.set("v.isLoading", true);
	},
	 
})