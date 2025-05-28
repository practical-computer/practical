import {submitFormEvent} from '@practical-computer/practical-views/passkeys/handlers/register';

let form = document.querySelector(`[data-register-passkey-form]`)

form.addEventListener('submit', submitFormEvent)