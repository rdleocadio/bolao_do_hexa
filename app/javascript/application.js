// Configure your import map in config/importmap.rb
import "@hotwired/turbo-rails"
import "controllers"
import "brackets_filter"

document.addEventListener("turbo:load", () => {
  const filters = document.querySelector(".matches-filters");
  const toggle = document.querySelector("[data-filters-toggle]");

  if (!filters || !toggle) return;

  toggle.removeEventListener("click", toggle._filtersHandler);

  toggle._filtersHandler = (event) => {
    event.stopPropagation();
    filters.classList.toggle("is-open");
  };

  toggle.addEventListener("click", toggle._filtersHandler);
});

document.addEventListener("click", (event) => {
  const filters = document.querySelector(".matches-filters");
  const toggle = document.querySelector("[data-filters-toggle]");

  if (!filters || !toggle) return;

  const clickedInsideFilters = filters.contains(event.target);
  const clickedToggle = toggle.contains(event.target);

  if (!clickedInsideFilters && !clickedToggle) {
    filters.classList.remove("is-open");
  }
});
