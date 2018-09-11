import { withComponent } from 'skatejs';

const Component = withComponent();

export default class Base extends Component {
  connectedCallback() {
    this.addStyles();
    this.addRenderRoot();
  }

  addStyles() {
    this._styles = document.createElement('style');
    this._styles.innerHTML = `
      :host {
        flex: 1;
        display: flex;
      }
    `;
    super.renderRoot.append(this._styles);
  }

  addRenderRoot() {
    this._renderRoot = document.createElement('div');
    this._renderRoot.style.width = '100%';
    super.renderRoot.append(this._renderRoot);
  }

  get renderRoot() {
    return this._renderRoot;
  }
}
