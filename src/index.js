import './main.css';
import {Elm} from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

Elm.Main.init({
  flags: {
    token: process.env.ELM_APP_YNAB_TOKEN,
  },
});

registerServiceWorker();
