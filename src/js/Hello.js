import { props, withComponent } from "skatejs";
import CanvasJS from './vendor/canvasjs.min.js';

const Component = withComponent();

class Hello extends Component {
  constructor() {
    super();
    console.log('constructing!')
    this._chart = null;
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

  renderer(root) {
    if (!this._chart) {
      this._chart = new CanvasJS.Chart(root, {
        title: {
          text: 'Adding some data'
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
    requestAnimationFrame(() => {
      this._chart.render();
    })
  }
}

customElements.define("x-hello", Hello);

const hello = document.createElement("x-hello");

document.body.append(hello);
