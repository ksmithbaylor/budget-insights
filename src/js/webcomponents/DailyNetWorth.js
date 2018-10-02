import { props } from 'skatejs';
import CanvasJS from './common/canvasjs.min.js';
import CanvasChart from './common/CanvasChart';

export default class DailyNetWorth extends CanvasChart {
  static get props() {
    return {
      data: props.array
    };
  }

  initialOptions() {
    console.log(this.stripLines());
    return {
      title: {
        text: 'Net Worth'
      },
      zoomEnabled: true,
      zoomType: 'xy',
      axisX: {
        // viewportMinimum: new Date('2018/01/01'),
        stripLines: this.stripLines(),
        valueFormatString: 'MMM YYYY'
      },
      data: [
        {
          type: 'area',
          dataPoints: this.dataPoints()
        }
      ]
    };
  }

  updateOptions(options) {
    options.data[0].dataPoints = this.dataPoints();
  }

  dataPoints() {
    console.log(this.props.data);
    return this.props.data.map(datum => ({
      x: this.parseDate(datum.x),
      y: datum.y
    }));
  }

  stripLines() {
    return this.props.data
      .filter(datum => datum.x.endsWith('-01'))
      .map(datum => {
        const value = this.parseDate(datum.x);
        return {
          value,
          label: CanvasJS.formatDate(value, 'MMM YYYY')
        };
      });
  }

  parseDate(dateString) {
    return new Date(dateString.replace(/-/, '/'));
  }
}
