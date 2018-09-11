import { props, withComponent } from "skatejs";
import CanvasJS from './vendor/canvasjs.min.js';

const Component = withComponent();

class Hello extends Component {
  constructor() {
    super();
    this._chart = null;
    this._chartRoot = null;
    this._styles = null;
  }

  connectedCallback() {
    this.addStyles();
    this.addChartRoot();
  }

  addStyles() {
    this._styles = document.createElement('style');
    this._styles.innerHTML = `
      :host {
        width: 100%;
        height: 500px;
        display: block;
      }
    `;
    this.renderRoot.append(this._styles);
  }

  addChartRoot() {
    this._chartRoot = document.createElement('div');
    this._chartRoot.style.width = '100%';
    this._chartRoot.style.height = '100%';
    this.renderRoot.append(this._chartRoot);
  }

  static get props() {
    return {
      name: props.string,
      numbers: props.array
    };
  }

  dataPoints() {
    return this.props.numbers.map(n => ({ y: n }));
  }

  renderer(root, render) {
    if (!this._chart) {
      this._chart = new CanvasJS.Chart(this._chartRoot, {
        title: {
          text: 'Random data'
        },
        data: [
          {
            type: "spline",
            dataPoints: this.dataPoints()
          }
        ]
      })
    } else {
      this._chart.options.data[0].dataPoints = this.dataPoints()
    }
    requestAnimationFrame(render);
  }

  render() {
    this._chart.render();
  }
}

customElements.define("x-hello", Hello);
