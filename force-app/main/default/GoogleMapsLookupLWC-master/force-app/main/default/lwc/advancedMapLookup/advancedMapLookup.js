import { LightningElement, track, api } from "lwc";
import placeSearch from "@salesforce/apex/AddressSearchController.placeSearch";
import detailsSearch from "@salesforce/apex/AddressDatailsController.detailsSearch";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class AdvancedMapLookup extends LightningElement {
  @track errors = [];
  @api notifyViaAlerts = false;
  zoomLvl;
  mapMarkers = [];

  handleSearch(event) {
    let searchKey = event.detail.searchTerm;
    console.log("#####" + JSON.stringify(event.detail.searchTerm));
    placeSearch({ searchPhrase: searchKey })
      .then(results => {
        this.template.querySelector("c-lookup").setSearchResults(results);
        console.log(results);
      })
      .catch(error => {
        this.notifyUser(
          "Lookup Error",
          "An error occured while searching with the lookup field.",
          "error"
        );
        this.errors = [error];
      });
  }

  handleSearchDetail(recordId) {
    if (!recordId) {
      return;
    }
    detailsSearch({ place_id: recordId })
      .then(results => {
        this.zoomLvl = 15;
        const resp = JSON.parse(results);
        const Latitude = resp.lat;
        const Longitude = resp.lng;
        this.mapMarkers = [{
          location: { Latitude, Longitude }
        }];
      })
      .catch(error => {
        this.notifyUser(
          "Lookup Error",
          "An error occured while searching with the lookup field.",
          "error"
        );
        this.errors = [error];
      });
  }

  notifyUser(title, message, variant) {
    if (this.notifyViaAlerts) {
      // eslint-disable-next-line no-alert
      alert(`${title}\n${message}`);
    } else {
      const toastEvent = new ShowToastEvent({ title, message, variant });
      this.dispatchEvent(toastEvent);
    }
  }

  handleSelectionChange(event) {
    debugger
    const recordId = event.detail;
    this.handleSearchDetail(recordId);
  }

  checkForErrors() {
    const selection = this.template.querySelector("c-lookup").getSelection();
    if (selection.length === 0) {
      this.errors = [
        { message: "You must make a selection before submitting!" },
        { message: "Please make a selection and try again." }
      ];
    } else {
      this.errors = [];
    }
  }

  handleSubmit() {
    this.checkForErrors();
    if (this.errors.length === 0) {
      this.notifyUser("Success", "The form was submitted.", "success");
    }
  }
}
