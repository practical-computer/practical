import {startConditionalMediation, submitFormEvent} from '@practical-computer/practical-views/passkeys/handlers/authenticate';

let form = document.querySelector(`[data-new-session-form]`)

startConditionalMediation(form)
form.addEventListener('submit', submitFormEvent)