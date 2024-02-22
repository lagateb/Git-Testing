import * as censhare from 'censhare';
import {svtxDomainSwitchComponent} from './svtx-domain-switch.component';

export const svtxDomainSwitchWidgetModule: string = censhare
    .module('svtxDomainSwitchWidget', [])
    .component('svtxDomainSwitchWidget', svtxDomainSwitchComponent)
    .name;


