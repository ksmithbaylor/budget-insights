import Hello from './Hello';

export default function registerAllWebComponents() {
  customElements.define('x-hello', Hello);
}
