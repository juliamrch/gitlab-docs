var navtoggle = document.getElementById("docs-nav-toggle");
if (navtoggle) {
  navtoggle.addEventListener("click", toggleNavigation);
}

function toggleNavigation() {
  nav = document.getElementsByClassName('header')[0];
  nav.classList.toggle("active");
}
