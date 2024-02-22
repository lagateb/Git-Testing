import * as censhare from 'censhare';

import { AllianzDeleteProductAction } from './allianz-delete-product-action.constant';

export const allianzDeleteProductActionModule: string = censhare
    .module('allianzDeleteProductAction', [])
    .constant('allianzDeleteProductBehavior', AllianzDeleteProductAction)
    .name;
