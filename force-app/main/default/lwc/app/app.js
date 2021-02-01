import { LightningElement, track, wire } from 'lwc';
import NAME_FIELD from '@salesforce/schema/Contact.Name';
import EMAIL from '@salesforce/schema/Contact.Email';
import BIRTHDATE from '@salesforce/schema/Contact.Birthdate';
import getContacts from '@salesforce/apex/ContactTableController.obtainContacts';
import deleteContact from '@salesforce/apex/ContactTableController.deleteContact';
import getTotalContacts from '@salesforce/apex/ContactTableController.getTotalContacts';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const ACTIONS = [
    {label: 'Delete', name: 'delete'}
];

const COLUMNS = [
            {label: 'Name', fieldName: 'contactLink', type: 'url', sortable: true, typeAttributes: { label: { fieldName: NAME_FIELD.fieldApiName } }},
            {label: 'Email', fieldName: EMAIL.fieldApiName, type: 'email', sortable: false},
            {label: 'Birthdate', fieldName: BIRTHDATE.fieldApiName, type: 'date', sortable: true},
            {label: 'Account', fieldName: 'accountLink', type: 'url', sortable: false, typeAttributes: { label: { fieldName: 'Account' } }},
            {label: 'Custom Images', fieldName: 'icon', type: 'icon'},
            {type: 'action', typeAttributes: { rowActions: ACTIONS } }
];

export default class App extends LightningElement {
    contactsList;
    columns = COLUMNS;
    sortedBy = '';
    sortedDirection = 'asc';
    defaultSortDirection = '';
    initialRows = 30;
    currentCount = 0;
    rowNumberOffset = 0;
    enableInfiniteLoading = true;
    uploadedrecordsLength;

    @track showSpinner = false;

    @wire(getTotalContacts)
    totalNumberOfRows;

    connectedCallback() {
        this.showSpinner = true;
        this.getContactList({sortedBy : this.sortedBy, sortedDirection : this.sortedDirection}, this.initialRows, this.rowNumberOffset);
    }

    getContactList(sortingOptions, recordLimit, currentCount) {
        getContacts({
            sortingOptions: sortingOptions,
            recordLimit : recordLimit,
            currentCount : currentCount
        })
            .then(contactsList => {
                this.contactsList = this.composeViewData(contactsList)
                this.contactsList.length == this.totalNumberOfRows.data ? 
                                            this.uploadedrecordsLength = this.contactsList.length + ' items' :
                                            this.uploadedrecordsLength = this.contactsList.length + '+ items';
                this.currentCount = this.initialRows
                this.showSpinner = false;
            })
            .catch(error => {
                this.handleError(error)
            });
    }

    composeViewData(response) {
        return response.map((contact) => {
            return {
                contactLink: '/' +  contact.Id,
                Name: contact.Name,
                Email: contact.Email,
                Birthdate: contact.Birthdate,
                accountLink: contact.Account ? '/' + contact.Account.Id : '',
                Account: contact.Account ? contact.Account.Name : '',
                icon: contact.icon__c ? contact.icon__c : '',
            }
        });
    }

    showToast(title, message, type) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: type
            })
        )
        this.showSpinner = false;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.onDeleteContact(row);
                break;
        }
    }

    onDeleteContact(row) {
        this.showSpinner = true;
        deleteContact({
            contact : {'sobjectType': 'Contact', 'Id': (row.contactLink).substring(1)}
        })
        .then(data => {
            this.getContactList({sortedBy : this.sortedBy, sortedDirection : this.sortedDirection}, this.contactsList.length, 0);
            this.showToast('Success', 'Contact has been successfully deleted', 'success')
        })
        .catch(error => {
            this.handleError(error)
        });
    }

    handleError(error) {
        let message = 'Unknown error';

        if (error.body && error.body.message && error.body.message.length) {
            message = error.body.message;
        }

        if (error && error.body && error.body.pageErrors && error.body.pageErrors.length) {
            message = error.body.pageErrors[0].message;
        }

        this.showToast("Error", message, 'error');
    }

    updateColumnSorting(event) {
        const { fieldName } = event.detail;
        this.sortedBy = fieldName;
        if (this.sortedBy === 'contactLink') {
            this.sortedBy = 'Name';
        }

        if (this.sortedDirection === 'desc') {
            this.sortedDirection = 'asc';
        } else if (this.sortedDirection === 'asc') {
            this.sortedDirection = 'desc';
        }
        this.getContactList({sortedBy : this.sortedBy, sortedDirection : this.sortedDirection}, this.contactsList.length, 0);
    }

    loadMoreContacts(event) {
        const { target } = event;
        target.isLoading = true;
        getContacts({
            sortingOptions: {sortedBy : this.sortedBy, sortedDirection : this.sortedDirection},
            recordLimit : this.initialRows,
            currentCount : this.currentCount
        })
            .then(contactsList => {
                if (this.contactsList.length == this.totalNumberOfRows.data) {
                    this.enableInfiniteLoading = false;
                } else {
                    this.contactsList = this.contactsList.concat(this.composeViewData(contactsList));
                    this.contactsList.length == this.totalNumberOfRows.data ? this.uploadedrecordsLength = this.contactsList.length + ' items' : this.uploadedrecordsLength = this.contactsList.length + '+ items';
                    this.currentCount += this.initialRows;
                }
                target.isLoading = false;
            })
            .catch(error => {
                this.handleError(error)
            });
    }
}
