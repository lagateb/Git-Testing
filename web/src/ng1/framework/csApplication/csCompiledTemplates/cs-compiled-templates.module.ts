import * as censhare from 'censhare';
import { csLoggerModule } from '../../csApi/csLogger/logger.module';
import { CsCompiledTemplates } from './cs-compiled-templates.service';

export const csCompiledTemplatesModule: string = censhare
    .module('csCompiledTemplates', [ csLoggerModule ])
    .service(CsCompiledTemplates)
    .name;
