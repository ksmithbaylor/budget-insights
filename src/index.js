import './main.css';
import {Elm} from './Main.elm';
import registerServiceWorker from './registerServiceWorker';
const env = require('../.env');

const token = atob(env.slice(13))
  .split('\n')
  .find(line => line.includes('YNAB_TOKEN'))
  .split('=')[1];

Elm.Main.init({
  flags: {
    token,
  },
});

registerServiceWorker();
