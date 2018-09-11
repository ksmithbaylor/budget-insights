import CanvasJS from './canvasjs.min.js';
import Base from './Base';

export default class CanvasChart extends Base {
  constructor() {
    super();
    this._chart = null;
  }

  renderer(root, render) {
    if (!this._chart) {
      this._chart = new CanvasJS.Chart(root, this.initialOptions());
    } else {
      this.updateOptions(this._chart.options);
    }
    requestAnimationFrame(render);
  }

  render() {
    this._chart.render();
  }
}
