import { props } from 'skatejs';
import CanvasChart from './common/CanvasChart';

export default class Hello extends CanvasChart {
  static get props() {
    return {
      numbers: props.array
    };
  }

  initialOptions() {
    return {
      title: {
        text: 'Random data'
      },
      data: [
        {
          type: 'spline',
          dataPoints: this.dataPoints()
        }
      ]
    };
  }

  updateOptions(options) {
    options.data[0].dataPoints = this.dataPoints();
  }

  dataPoints() {
    return this.props.numbers.map(n => ({ y: n }));
  }
}
