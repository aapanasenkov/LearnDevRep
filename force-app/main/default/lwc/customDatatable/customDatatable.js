import LightningDatatable from 'lightning/datatable';
import iconColumnTemplate from './iconColumnTemplate.html';

export default class CustomDatatable extends LightningDatatable {
    static customTypes = {
        icon: {
            template: iconColumnTemplate,
            standardCellLayout: true,
            typeAttributes: [''],
        }
    };
}