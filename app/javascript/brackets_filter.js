function setupBracketsFilter() {
  const filter = document.querySelector("#brackets-stage-filter");
  const columns = document.querySelectorAll(".brackets-column-wrapper[data-stage]");

  if (!filter || columns.length === 0) return;

  filter.onchange = () => {
    const selectedStage = filter.value;

    columns.forEach((column) => {
      const columnStage = column.dataset.stage;

      if (selectedStage === "all" || selectedStage === columnStage) {
        column.classList.remove("is-hidden-mobile");
      } else {
        column.classList.add("is-hidden-mobile");
      }
    });
  };
}

document.addEventListener("turbo:load", setupBracketsFilter);
document.addEventListener("DOMContentLoaded", setupBracketsFilter);
