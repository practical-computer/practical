import mrujs from 'mrujs'

import { handleJSONRedirectionEvent } from '@practical-computer/practical-views/handlers/json-redirection'

mrujs.start()

document.addEventListener("ajax:complete", handleJSONRedirectionEvent)