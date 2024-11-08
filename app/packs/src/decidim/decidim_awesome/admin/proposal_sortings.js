/* eslint-disable no-new */

import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("DOMContentLoaded", () => {
  const selectContainer = document.getElementById("config_additional_proposal_sortings");

  if (!selectContainer) {
    return;
  }

  new TomSelect(selectContainer, {
    plugins: ["remove_button", "dropdown_input"],
    create: false,
    render: {
      option: function (data, escape) {
        return `<div>${escape(data.text)}</div>`;
      }
    }
  });
  
  document.getElementById("additional_proposal_sortings-enable-all").addEventListener("click", (evt) => {
    evt.preventDefault();
    selectContainer.tomselect.setValue(Array.from(document.getElementById("config_additional_proposal_sortings").children).map((el) => el.value))
  });
});
