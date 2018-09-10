import { props, withComponent } from 'skatejs';
import withRenderer from './renderer-preact';
const { h } = require('preact/dist/preact.min.js');

const Component = withComponent(withRenderer());

class Hello extends Component {
  static get props() {
    return {
      name: props.string,
      numbers: props.array
    };
  }

  render({ name, numbers }) {
    return h('span', null,
      `Hello ${name}!`,
      h('ul', null,
        numbers.map(n => h('li', null, n))
      )
    )
  }
}

customElements.define('x-hello', Hello);
