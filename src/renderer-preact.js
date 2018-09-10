const { h, render } = require('preact/dist/preact.min.js');

export default () =>
  class PreactRenderer extends HTMLElement {
    get props() {
      // We override props so that we can satisfy most use
      // cases for children by using a slot.
      return {
        ...super.props,
        ...{ children: h('slot') },
      };
    }
    renderer(renderRoot, renderCallback) {
      this._renderRoot = renderRoot;
      this._preactDom = render(
        renderCallback(),
        this._renderRoot,
        this._preactDom || this._renderRoot.children[0]
      );
    }
    disconnectedCallback() {
      super.disconnectedCallback && super.disconnectedCallback();
      // Preact hack https://github.com/developit/preact/issues/53
      const Nothing = () => null;
      this._preactDom = render(h(Nothing), this._renderRoot, this._preactDom);
    }
};
