// Mobile Navigation Toggle
(function() {
  'use strict';

  document.addEventListener('DOMContentLoaded', function() {
    var toggle   = document.querySelector('.greedy-nav__toggle');
    var mobileNav = document.getElementById('mobile-nav');

    if (!toggle || !mobileNav) return;

    // Intercept hamburger clicks on mobile to show our custom nav panel
    toggle.addEventListener('click', function(e) {
      if (window.innerWidth > 768) return; // let greedy-nav handle desktop

      var isOpen = mobileNav.classList.toggle('is-open');
      toggle.setAttribute('aria-expanded', String(isOpen));
      mobileNav.setAttribute('aria-hidden', String(!isOpen));
    });

    // Close panel when clicking outside it
    document.addEventListener('click', function(e) {
      if (window.innerWidth > 768) return;
      if (!e.target.closest('#mobile-nav') && !e.target.closest('.greedy-nav__toggle')) {
        mobileNav.classList.remove('is-open');
        toggle.setAttribute('aria-expanded', 'false');
        mobileNav.setAttribute('aria-hidden', 'true');
      }
    });

    // Close panel when a nav link is followed
    mobileNav.querySelectorAll('a').forEach(function(link) {
      link.addEventListener('click', function() {
        mobileNav.classList.remove('is-open');
        toggle.setAttribute('aria-expanded', 'false');
        mobileNav.setAttribute('aria-hidden', 'true');
      });
    });
  });
})();