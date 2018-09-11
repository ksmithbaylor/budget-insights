import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';
import registerAllWebComponents from './js/webcomponents';

import './UI/Loader.css';

registerAllWebComponents();

Elm.Main.init({
  flags: {
    token: process.env.ELM_APP_YNAB_TOKEN
  }
});

registerServiceWorker();
